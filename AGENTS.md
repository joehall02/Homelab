# AGENTS.md

Guidance for AI agents (and people) changing this repo.

Read [`docs/index.md`](docs/index.md) first for the layout and how modules fit together.

## Ground rules

- **Declare everything you can in Nix.** If a setting can be set through a
  NixOS option, `settings`, `serverConfig`, environment variables or a config
  file the module writes, set it there rather than leaving it to the web UI.
- **Turn off telemetry.** When adding a service, disable analytics, telemetry,
  usage reporting, crash reporting and "phone home" update checks wherever
  they can be declared. For example `log.analyticsEnabled = false` for the
  arr apps. Check the module's options and the app's docs for the right key.
- **No secrets in plain text.** Passwords, API keys and tokens go in
  `secrets/secrets.yaml` through sops and are passed to services by path
  (`config.sops.secrets.<name>.path`). Never read, print or commit decrypted
  secrets. See `docs/secrets.md`.
- **Private, non-secret values go in `private.nix`**: ports, paths, the
  domain, the LAN subnet. Never hard-code them. When adding a key, also add it
  with a placeholder value to `private.example.nix`. Never commit
  `private.nix`.
- **Don't edit `hardware-configuration.nix`.** It's generated.
- **Never change `system.stateVersion`.**
- **Don't deploy or commit unless asked.** `./deploy.sh` rebuilds a live
  server.

## Conventions

- **Everything about a service lives in its own module**: its sops secrets,
  extra groups, UMask, VPN confinement, port mappings. Only the Caddy entry goes
  elsewhere (`services/reverse-proxy.nix`).
- Services in the VPN namespace don't use `openFirewall`; they use
  `vpnNamespaces.vpn.portMappings`.
- **Listen address**: set it to `0.0.0.0` when a module defaults to
  `127.0.0.1` and the service has to be reachable from the LAN or through a
  port mapping.
- **Torrent, indexer or scraping traffic** must run in the `vpn` namespace.
  Use `vpnConfinement` plus a port mapping for its web UI, and proxy it
  through Caddy at `config.vpnNamespaces.vpn.namespaceAddress`.
- **Prefer stable nixpkgs.** Only use `unstable.<pkg>` for a specific reason.
- **Comments** are short, plain English, and explain *why*, matching the
  existing files.

## Where do I change…

| I want to… | Edit |
| --- | --- |
| Add or remove a service | A file in `services/`, plus its import in `configuration.nix` or `services/media-stack/default.nix` |
| Change a port, path or the domain | `private.nix` (and `private.example.nix` for new keys) |
| Give a service an HTTPS name | The `services` list in `services/reverse-proxy.nix` |
| Route a service through the VPN | Its own module ([Network › VPN namespace](docs/network.md#vpn-namespace)) |
| Change power, boot or console settings | `modules/system.nix` |

## Adding a service: checklist

1. Create `services/<name>.nix` and import it.
2. Ports and paths in `private.nix` and `private.example.nix`. Secrets in sops.
3. Telemetry off. Everything declarable is declared.
4. Firewall / listen address / VPN confinement, as above.
5. A line in `services/reverse-proxy.nix` for `https://<name>.<domain>`.
6. Update the relevant page in `docs/`.
7. Run `./check.sh`.

## Checking your work

`./check.sh` evaluates the whole config without building it. It's the fastest
way to catch wrong option names and types. Option names change between NixOS
releases, so check them against the docs for the release `flake.nix` pins
or the module source, rather than from memory.

If you can't run `nix` in your environment, say so, and don't claim that the
config was checked.
