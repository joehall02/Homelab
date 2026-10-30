{ private, ... }:

{
  # Web UI on port 8090
  services.beszel.hub = {
    enable = true;
    # Listen on all addresses so the LAN can reach the UI, not just Caddy
    host = "0.0.0.0";
  };

  # The hub module has no openFirewall option
  networking.firewall.allowedTCPPorts = [ 8090 ];

  services.beszel.agent = {
    enable = true; 
    # No openFirewall default: the hub is on this machine and connects over localhost
    openFirewall = false;
    # Disk health (SMART) for the drives
    smartmon.enable = true;
    # Only the hub holding the matching private key can connect
    environment.KEY = private.beszelHubKey;
  };
}
