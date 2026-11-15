# Other services

## Beszel (monitoring)

`services/monitoring.nix`. [Beszel](https://beszel.dev) is a lightweight
server-monitoring dashboard: CPU, memory, disk, network, temperatures, and disk
health through SMART.

It has two parts, both on the homelab:

- **Hub**: the web UI, on port 8090 (`beszel.<domain>` through Caddy). It
  listens on `0.0.0.0` so the LAN can reach it directly. Its module has no
  `openFirewall` option, so 8090 is opened by hand.
- **Agent**: collects the metrics. The hub connects to it over localhost, so
  its port isn't opened. `smartmon.enable` adds drive health. The agent only
  accepts a hub holding the private key that matches `beszelHubKey` in
  `private.nix` (a public key, so not secret).