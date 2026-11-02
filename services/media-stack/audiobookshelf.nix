{ private, ... }:

{
  services.audiobookshelf = {
    enable = true;
    # Opens port
    openFirewall = true;
    # The module's default of 127.0.0.1 would hide it from the LAN
    host = "0.0.0.0";
    port = private.audiobookshelfPort;
  };

  # Join the shared media group, and make new files group-writable. It needs
  # write access for podcast downloads and web UI uploads
  users.users.audiobookshelf.extraGroups = [ "media" ];
  systemd.services.audiobookshelf.serviceConfig.UMask = "0002";
}
