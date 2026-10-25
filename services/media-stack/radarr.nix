{ lib, private, ... }:

{
  services.radarr = {
    enable = true;
    # Opens settings.server.port
    openFirewall = true;
    settings = {
      server.port = private.radarrPort;
      log.analyticsEnabled = false;
    };
  };

  # Join the shared media group, and make new files group-writable.
  # mkForce: the module sets its own UMask of 0022
  users.users.radarr.extraGroups = [ "media" ];
  systemd.services.radarr.serviceConfig.UMask = lib.mkForce "0002";
}
