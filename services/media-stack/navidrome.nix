{ config, private, ... }:

{
  # ND_* settings as KEY=value lines; only ND_PASSWORDENCRYPTIONKEY for now
  sops.secrets.navidrome-env = { };

  services.navidrome = {
    enable = true;
    # Opens settings.Port
    openFirewall = true;
    environmentFile = config.sops.secrets.navidrome-env.path;
    settings = {
      # The module's default of 127.0.0.1 would hide it from the LAN
      Address = "0.0.0.0";
      Port = private.navidromePort;
      # Read-only is enough: the folders are world-readable, so no media group
      MusicFolder = "${private.mediaDir}/music";
    };
  };
}
