# Homelab docs

A single NixOS machine, configured entirely from this repo with a flake. It runs
a media stack, file sharing and monitoring, reachable on the LAN and over
Tailscale. Torrent and indexer traffic is confined to a WireGuard VPN namespace.

## Pages

| Page                                | What it covers                                                                      |
| ----------------------------------- | ----------------------------------------------------------------------------------- |
| [Machines](machines/index.md)       | Hardware specs, and machine-specific config (power, graphics, disks)                |
| [Deployment](deployment.md)         | `check.sh` and `deploy.sh`: how config gets from the repo onto the homelab          |
| [Secrets](secrets.md)               | sops-nix for real secrets, `private.nix` for private but non-secret values          |
| [Network](network.md)               | Tailscale, certificates, Caddy, the VPN namespace, Samba, SSH                       |
| [Media stack](media-stack.md)       | Jellyfin, the arr apps, qBittorrent, Shelfmark, Audiobookshelf and how they connect |
| [Other services](other-services.md) | Beszel monitoring, Immich                                                           |
