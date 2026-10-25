{ lib, private, ... }:

{
  services.sonarr = {
    enable = true;
    # Opens settings.server.port
    openFirewall = true;
    settings = {
      server.port = private.sonarrPort;
      log.analyticsEnabled = false;
    };
  };

  # Join the shared media group, and make new files group-writable.
  # mkForce: the module sets its own UMask of 0022
  users.users.sonarr.extraGroups = [ "media" ];
  systemd.services.sonarr.serviceConfig.UMask = lib.mkForce "0002";
}
