{ config, lib, private, unstable, ... }:

let
  # Send searches through the VPN.
  useVpn = true;
in
{
  # SEARXNG_SECRET=<random string>, signs SearXNG's cookies
  sops.secrets.searxng-env = { };

  services.searx = {
    enable = true;
    # TODO: Remove when updating to latest nixpkgs
    # 26.05's build (May 2026) predates fixes for Brave, DuckDuckGo, Yahoo
    # and others, which fail without them
    package = unstable.searxng;
    # Through the VPN, the port mapping makes it reachable instead
    openFirewall = !useVpn;
    environmentFile = config.sops.secrets.searxng-env.path;
    settings = {
      server = {
        # The module's default of 127.0.0.1 would hide it from the LAN and the
        # port mapping
        bind_address = "0.0.0.0";
        port = private.searxngPort;
        # Filled in from environmentFile when the service starts
        secret_key = "$SEARXNG_SECRET";
        # Load result images through SearXNG, so image hosts never see the
        # browser's address
        image_proxy = true;
      };
      search = {
        # Open WebUI asks for JSON results; without it SearXNG answers 403
        formats = [
          "html"
          "json"
        ];
        safe_search = 0;
        # Suggest searches as you type. What you type goes to DuckDuckGo
        # (through SearXNG, so it never sees the browser)
        autocomplete = "duckduckgo";
      };
      # Dark theme by default
      ui.theme_args.simple_style = "dark";
      # Settings that come from here only, not the browser's preferences page
      preferences.lock = [
        "safesearch"
        "autocomplete"
        "method"
        "image_proxy"
      ];
      # Wait longer than the default 3 seconds before giving up on an engine,
      # so slower ones still count
      outgoing = {
        request_timeout = 5.0;
        max_request_timeout = 10.0;
      };
      # Turn on the main engines that are off by default, so a search still
      # gets results when some engines fail. Merged with SearXNG's own engine
      # list by name
      engines = [
        {
          name = "bing";
          disabled = false;
        }
        {
          name = "qwant";
          disabled = false;
        }
        {
          name = "yahoo";
          disabled = false;
        }
      ];
    };
  };

  # Run SearXNG inside the VPN namespace, so its searches use the tunnel
  systemd.services.searx.vpnConfinement = lib.mkIf useVpn {
    enable = true;
    vpnNamespace = "vpn";
  };

  # Make it reachable from outside the namespace: Open WebUI on the host, the
  # LAN and Caddy
  vpnNamespaces.vpn.portMappings = lib.mkIf useVpn [
    {
      from = private.searxngPort;
      to = private.searxngPort;
    }
  ];
}
