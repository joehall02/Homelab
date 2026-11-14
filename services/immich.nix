{ private, ... }:

{
  services.immich = {
    enable = true;
    # Opens the port for http://<lanIp>:<port>
    openFirewall = true;
    # The module's default of localhost would hide it from the LAN
    host = "0.0.0.0";
    port = private.immichPort;
    mediaLocation = private.cameraRollDir;
    # Let Immich use the Intel iGPU (Quick Sync) for video transcoding.
    # NOTE: Also pick QSV in Administration > Settings > Video Transcoding.
    accelerationDevices = [ "/dev/dri/renderD128" ];
  };

  # GPU access (video, render)
  users.users.immich.extraGroups = [
    "video"
    "render"
  ];

  # Use the modern iHD driver rather than the old i965 one
  systemd.services.immich-server.environment.LIBVA_DRIVER_NAME = "iHD";
}
