# Homelab

A single NixOS machine, configured entirely from this repo with a flake. It runs
a media stack, file sharing and monitoring, reachable on the LAN and over
Tailscale. Torrent and indexer traffic is confined to a WireGuard VPN namespace.

The system itself can be rebuilt from this repo, the encrypted secrets file and
a `private.nix`. App data and the few settings that can only be made in a web UI
live on the machine.

## What it runs

| Area | Services |
| --- | --- |
| Video | Jellyfin, with hardware transcoding on the Intel iGPU |
| TV, films and music | Sonarr, Radarr, Lidarr, Prowlarr, qBittorrent |
| Books and audio | Shelfmark, Audiobookshelf, Navidrome, FlareSolverr |
| Access | Tailscale (also an exit node), Caddy with a Let's Encrypt wildcard certificate, SSH |
| File sharing | Samba, advertised over Bonjour |
| Monitoring | Beszel |
| Local AI | Open WebUI, using models served by LM Studio on the Mac mini |
| Camera roll | Immich (written, currently disabled) |

qBittorrent, Prowlarr, Shelfmark, Audiobookshelf and FlareSolverr run inside a
network namespace whose only way out is a Surfshark WireGuard tunnel. See
[Network](docs/network.md#vpn-namespace).

## Docs

| Page | What it covers |
| --- | --- |
| [Machines](docs/machines/index.md) | Hardware specs, and machine-specific config (power, graphics, disks) |
| [Deployment](docs/deployment.md) | `check.sh` and `deploy.sh`: how config gets from the repo onto the homelab |
| [Secrets](docs/secrets.md) | sops-nix for real secrets, `private.nix` for private but non-secret values |
| [Network](docs/network.md) | Tailscale, certificates, Caddy, the VPN namespace, Samba, SSH |
| [Media stack](docs/media-stack.md) | Jellyfin, the arr apps, qBittorrent, Shelfmark, Audiobookshelf and how they connect |
| [AI](docs/ai.md) | Open WebUI on the homelab, and the link to LM Studio on the Mac mini where the models run |
| [Other services](docs/other-services.md) | Beszel monitoring, Immich |

## Getting started

On the workstation that deploys:

1. Install Nix with flakes enabled. `check.sh` needs it.
2. Clone the repo and create `private.nix` from the template, then fill it in:
   ```sh
   cp private.example.nix private.nix
   ```
3. Set up an SSH host alias called `homelab` that logs in with a key.
4. To edit secrets, add this machine's age key to `.sops.yaml` and re-encrypt.
   See [Secrets](docs/secrets.md#re-keying).
5. Check the config, then deploy:
   ```sh
   ./check.sh
   ./deploy.sh
   ```

## Everyday commands

| Command | What it does |
| --- | --- |
| `./check.sh` | Evaluate the config without building it. Catches typos and wrong options |
| `./deploy.sh` | Check, copy the repo to the homelab and switch to the new config |
| `./deploy.sh --update` | The same, after updating nixpkgs and the other flake inputs |
| `./deploy.sh --pull` | Bring edits made directly on the homelab back into the repo |
| `./deploy.sh --force` | Deploy without the config check or the check for edits on the homelab. Rarely needed |
| `sops secrets/secrets.yaml` | Edit the encrypted secrets |

More on each in [Deployment](docs/deployment.md).
