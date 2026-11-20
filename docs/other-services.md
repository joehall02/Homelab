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

## SearXNG (search)

`services/searxng.nix`, using NixOS's `services.searx` module.
[SearXNG](https://docs.searxng.org) is a private metasearch engine. It has no
index of its own: it sends each query to other search engines (DuckDuckGo,
Brave, Wikipedia and so on), merges the results, and doesn't track or profile
whoever searched. It's also what Open WebUI uses for web search; see
[AI › Web search](ai.md#web-search).

- **Runs in the VPN namespace, with a switch.** `useVpn` at the top of the
  module decides. `true` (the default) confines it to the namespace like the
  other scraping services, with a port mapping, so engines see the VPN's
  address. `false` runs it on the host with an open firewall port, so engines
  see the home IP. Open WebUI and Caddy work out the right address
  themselves, so the switch is the only thing to change before deploying.
  - **After switching**, engines suspended under the old setting stay
    suspended for a few minutes; `systemctl restart searx` clears that.
- **Reached at** `http://<lanIp>:<searxngPort>` on the LAN and
  `searxng.<domain>` through Caddy, either way. It listens on `0.0.0.0`,
  because the module's default of `127.0.0.1` would hide it from the LAN and
  the port mapping. It works as a private search engine in a browser too.
- **Package from nixos-unstable.** Search engines change their pages often,
  so SearXNG's engines break and get fixed all the time. 26.05's May 2026
  build had Brave, DuckDuckGo, Yahoo and others failing; switch back to the
  stable package once it catches up.
- **Engines**: Bing, Qwant and Yahoo are turned on as well as SearXNG's
  defaults, so a search draws on more sources and still gets
  results when an engine fails. Each engine gets 5 seconds (10 at most)
  instead of 3, so slower engines still count. `/stats` shows how each engine
  is doing.
- **Set in Nix, not the browser**: safe search (off), search suggestions as
  you type (from DuckDuckGo) and the dark theme are defaults. Safe search,
  autocomplete, the request method
  and the image proxy are locked, so the preferences page can't change them.
  Other preferences are saved per browser, in a cookie.
- **Image proxy on**: result images load through SearXNG, so image hosts
  never see the browser's address. Thumbnails load a little
  slower.
- **JSON results are on** (`search.formats`). Open WebUI asks for JSON, and
  SearXNG refuses it with a 403 otherwise.
- **Searches aren't logged.** The built-in server logs every request, search
  query included, and the journal keeps it across reboots. `LogLevelMax =
  "warning"` drops all of SearXNG's output, because it all arrives at info
  level; systemd's own warnings about the service still show. That hides
  SearXNG's errors too.
- **No limiter.** SearXNG's bot limiter is for public instances and is off by
  default, so it needs no Valkey (Redis) either.
- **Secret**: `searxng-env` holds `SEARXNG_SECRET`, which signs SearXNG's
  cookies. Any long random string, for example from `openssl rand -hex 32`.
