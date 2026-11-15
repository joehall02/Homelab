
# private.nix: private but non-secret values.
# Listed in .gitignore, so it never reaches GitHub; rsync still deploys it.
# Never put passwords or keys here.
{
  # Static LAN address of the homelab
  lanIp = "192.168.1.10";

  # LAN subnet allowed to reach services inside the VPN namespace
  lanSubnet = "192.168.1.0/24";

  # Root folder for TV, movies and downloads
  mediaDir = "/srv/media";

  # qBittorrent web UI port
  qbittorrentWebuiPort = 8080;
  # Web UI password hash: the WebUI\Password_PBKDF2 value from
  # /var/lib/qBittorrent/qBittorrent/config/qBittorrent.conf, without quotes
  qbittorrentPasswordHash = "@ByteArray(salt==:hash==)";

  # Arr stack web UI ports
  sonarrPort = 8989;
  radarrPort = 7878;
  lidarrPort = 8686;
  prowlarrPort = 9696;
  navidromePort = 4533;
  shelfmarkPort = 8084;
  audiobookshelfPort = 8000;
  immichPort = 2283;

  # Where Immich stores uploaded photos and videos
  cameraRollDir = "/srv/photos";

  # Jellyfin web UI port. NixOS can't set it: change it in Jellyfin's
  # dashboard (Networking) first, then here to match
  jellyfinPort = 8096;

  # Open WebUI port
  openWebuiPort = 8082;

  # Mac mini running LM Studio, which serves the models for Open WebUI
  macMiniIp = "192.168.1.20";
  lmStudioPort = 1234;

  # Beszel hub's public key
  beszelHubKey = "ssh-ed25519 AAAA...";

  # Your domain, for service names like jellyfin.home.example.com
  domain = "home.example.com";
}
