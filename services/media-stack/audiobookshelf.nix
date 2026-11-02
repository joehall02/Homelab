{ private, ... }:

{
  services.audiobookshelf = {
    enable = true;
    # No openFirewall: the web UI is reached through the namespace port mapping
    # The module's default of 127.0.0.1 would hide it from the port mapping
    host = "0.0.0.0";
    port = private.audiobookshelfPort;
  };

  # Join the shared media group, and make new files group-writable. It needs
  # write access for podcast downloads and web UI uploads
  users.users.audiobookshelf.extraGroups = [ "media" ];
  systemd.services.audiobookshelf.serviceConfig.UMask = "0002";

  # Run Audiobookshelf inside the VPN namespace, so podcast downloads and
  # metadata lookups use the tunnel
  systemd.services.audiobookshelf.vpnConfinement = {
    enable = true;
    vpnNamespace = "vpn";
  };

  # Make the web UI reachable from outside the namespace
  vpnNamespaces.vpn.portMappings = [
    {
      from = private.audiobookshelfPort;
      to = private.audiobookshelfPort;
    }
  ];
}
