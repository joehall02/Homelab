{ config, private, ... }:

{
  services.prowlarr = {
    enable = true;
    # No openFirewall: the web UI is reached through the namespace port mapping
    settings = {
      server.port = private.prowlarrPort;
      log.analyticsEnabled = false;
    };
  };

  # Run Prowlarr inside the VPN namespace, so indexer searches use the tunnel
  systemd.services.prowlarr.vpnConfinement = {
    enable = true;
    vpnNamespace = "vpn";
  };

  vpnNamespaces.vpn = {
    # Make the web UI reachable from outside the namespace
    portMappings = [
      {
        from = private.prowlarrPort;
        to = private.prowlarrPort;
      }
    ];
    # Let Prowlarr connect out to Sonarr/Radarr/Lidarr on the host.
    # Everything else still only leaves through the tunnel.
    allowedEgress = [ config.vpnNamespaces.vpn.bridgeAddress ];
  };
}
