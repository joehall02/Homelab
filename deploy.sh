#!/usr/bin/env bash
# deploy.sh: copy this folder to the homelab and rebuild NixOS.
# Deploys exactly what is on disk.
#
#   ./deploy.sh           normal deploy
#   ./deploy.sh --pull    copy edits made on the homelab back to the Mac
#   ./deploy.sh --force   skip the safety check (rarely needed)
#   ./deploy.sh --update  update nixpkgs and other inputs, then deploy

# Stop at the first error, on unset variables, and on failures inside pipes
set -euo pipefail

# --- Settings ---
HOST="homelab"
# Folder in the home directory on the homelab that receives the config
REMOTE_DIR="nixos-config"
# Machine name from flake.nix: nixosConfigurations.homelab
FLAKE_NAME="homelab"

# --- Options ---
FORCE=false
UPDATE=false
PULL=false
for arg in "$@"; do
  case "$arg" in
    --force)  FORCE=true ;;
    --update) UPDATE=true ;;
    --pull)   PULL=true ;;
    *) echo "Unknown option: $arg"; exit 1 ;;
  esac
done

# Always run from the folder this script lives in
cd "$(dirname "$0")"

# --- Pull mode ---
# With --pull, copy the homelab's files back to the Mac, then save a new
# fingerprint so the next deploy knows the edits have been brought over.
if [ "$PULL" = true ]; then
  echo "Copying the homelab's files to the Mac..."
  rsync -av --exclude .deployed.sha256 "$HOST:$REMOTE_DIR/" ./
  ssh "$HOST" "cd $REMOTE_DIR && find . -type f ! -name .deployed.sha256 -print0 | xargs -0 sha256sum > .deployed.sha256"
  echo "Done. Review the changes with: git diff"
  exit 0
fi

# --- 1. Safety check ---
# .deployed.sha256 on the homelab is a fingerprint of every file from the
# previous deploy. If any file no longer matches it, someone edited the
# homelab's copy directly, so stop rather than overwrite that work.
# On the very first deploy the file doesn't exist yet and the check is skipped.
echo "Checking the homelab for local edits..."
if [ "$FORCE" = false ] && ! ssh "$HOST" "[ ! -f $REMOTE_DIR/.deployed.sha256 ] || (cd $REMOTE_DIR && sha256sum --check --quiet .deployed.sha256)"; then
  echo "Files on the homelab changed since the last deploy. Not overwriting them."
  echo "Bring them to the Mac with ./deploy.sh --pull, review them, then deploy again."
  exit 1
fi

# --- 2. Copy the folder ---
# -a keeps timestamps and permissions, -v lists each file, -z compresses.
# --delete removes files from the homelab that were deleted on the Mac.
# The excludes skip git history, Finder junk and the fingerprint file.
echo "Copying config to the homelab..."
rsync -avz --delete \
  --exclude .git \
  --exclude .DS_Store \
  --exclude .deployed.sha256 \
  --exclude deploy.sh \
  --exclude .gitignore \
  --exclude .sops.yaml \
  ./ "$HOST:$REMOTE_DIR/"

# --- 3. Rebuild ---
# Write flake.lock as the normal user before the sudo rebuild, so root never
# owns it (a root-owned flake.lock makes the next rsync fail).
# nix flake lock only adds missing inputs; with --update, refresh them all.
UPDATE_CMD="nix flake lock && "
if [ "$UPDATE" = true ]; then
  UPDATE_CMD="nix flake update && "
fi

# -t gives ssh a real terminal so sudo can ask for a password.
# set +e lets the script continue if the rebuild fails, because steps 4
# and 5 must run either way to keep both machines in sync.
echo "Rebuilding NixOS..."
set +e
ssh -t "$HOST" "cd $REMOTE_DIR && ${UPDATE_CMD}sudo nixos-rebuild switch --flake .#$FLAKE_NAME"
REBUILD_STATUS=$?
set -e

# --- 4. Sync flake.lock back to the Mac ---
# The rebuild may have created or changed flake.lock (first deploy, a new
# input in flake.nix, or --update). Copy it back so the Mac always has the
# exact versions the homelab used. rsync only transfers it if it changed.
echo "Syncing flake.lock back to the Mac..."
rsync -a "$HOST:$REMOTE_DIR/flake.lock" ./flake.lock 2>/dev/null \
  || echo "No flake.lock on the homelab yet (the build stopped early)."

# --- 5. Save a new fingerprint ---
# Recorded after the rebuild so its changes to flake.lock aren't mistaken
# for manual edits on the next deploy.
ssh "$HOST" "cd $REMOTE_DIR && find . -type f ! -name .deployed.sha256 -print0 | xargs -0 sha256sum > .deployed.sha256"

# Finish with the rebuild's result, so a failed build still shows as an error
exit $REBUILD_STATUS
