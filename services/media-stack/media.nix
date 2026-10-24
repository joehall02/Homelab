{ private, ... }:

{
  # Shared group for every media service (Jellyfin, Sonarr, Radarr, etc.).
  # A service joins it with: users.users.<name>.extraGroups = [ "media" ];
  users.groups.media = { };
  users.users.joehall.extraGroups = [ "media" ];

  # Create the folders if missing. The setgid bit (the 2 in 2775) makes new
  # files belong to the media group.
  systemd.tmpfiles.rules = [
    "d ${private.mediaDir}        2775 joehall media -"
    "d ${private.mediaDir}/tv     2775 joehall media -"
    "d ${private.mediaDir}/movies 2775 joehall media -"
  ];
}
