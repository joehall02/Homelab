#!/usr/bin/env bash
# Catch config errors on the Mac before deploying.
# Evaluates the full NixOS config without building anything, so syntax
# errors, typos in option names, wrong types and missing files all show up
# here instead of halfway through a rebuild on the homelab.

set -euo pipefail

# Machine name from flake.nix: nixosConfigurations.homelab
FLAKE_NAME="homelab"

cd "$(dirname "$0")"

if ! command -v nix >/dev/null 2>&1; then
  echo "nix isn't installed on this Mac, so the config can't be checked."
  exit 1
fi

# path:. reads the folder as it is on disk, like rsync does. Plain . would
# only see files tracked by git, which leaves out private.nix and new files.
# --no-write-lock-file leaves flake.lock alone; the homelab owns it.
echo "Checking the NixOS config..."
nix --extra-experimental-features "nix-command flakes" \
  eval --no-write-lock-file --raw \
  "path:.#nixosConfigurations.$FLAKE_NAME.config.system.build.toplevel.drvPath" \
  >/dev/null

echo "Config is valid."
