{
  services.jellyfin = {
    enable = true;
    # Web UI on 8096 plus LAN discovery ports
    openFirewall = true;

    hardwareAcceleration = {
      enable = true;
      type = "vaapi";
      device = "/dev/dri/renderD128";
    };

    # Apply the settings below on every start; dashboard changes to
    # transcoding are lost on restart
    forceEncodingConfig = true;

    transcoding = {
      enableHardwareEncoding = true;
      enableToneMapping = true;

      # What the UHD 630 can decode (no AV1: that needs 11th gen or newer)
      hardwareDecodingCodecs = {
        h264 = true;
        hevc = true;
        hevc10bit = true;
        mpeg2 = true;
        vc1 = true;
        vp8 = true;
        vp9 = true;
      };

      # H.264 encoding is always on; HEVC is optional
      hardwareEncodingCodecs.hevc = true;
    };
  };

  # GPU access (video, render) and the shared media folders (media)
  users.users.jellyfin.extraGroups = [
    "video"
    "render"
    "media"
  ];

  # Use the modern iHD driver rather than the old i965 one
  systemd.services.jellyfin.environment.LIBVA_DRIVER_NAME = "iHD";
}
