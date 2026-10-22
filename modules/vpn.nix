{ config, private, ... }:

{
  # Full Surfshark WireGuard .conf
  sops.secrets."surfshark.conf" = { };

  # Network namespace whose only route out is the Surfshark tunnel.
  #
  # To confine a service, set systemd.services.<name>.vpnConfinement in its
  # own module and add its web UI port to portMappings there.
  vpnNamespaces.vpn = {
    enable = true;
    wireguardConfigFile = config.sops.secrets."surfshark.conf".path;
    # Let the LAN reach web UIs inside the namespace
    accessibleFrom = [ private.lanSubnet ];
  };
}
