{ lib, private, ... }:

{
  services.lidarr = {
    enable = true;
    # Opens settings.server.port
    openFirewall = true;
    settings = {
      server.port = private.lidarrPort;
      log.analyticsEnabled = false;
    };
  };

  # Join the shared media group, and make new files group-writable.
  # mkForce: matches Sonarr/Radarr, whose modules set their own UMask
  users.users.lidarr.extraGroups = [ "media" ];
  systemd.services.lidarr.serviceConfig.UMask = lib.mkForce "0002";
}
