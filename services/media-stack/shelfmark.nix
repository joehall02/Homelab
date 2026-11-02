{ config, lib, private, username, ... }:

{
  # Secret settings as KEY=value lines
  sops.secrets.shelfmark-env = { };

  services.shelfmark = {
    enable = true;
    # Opens environment.FLASK_PORT
    openFirewall = true;
    environment = {
      # The module's default of 127.0.0.1 would hide it from the LAN
      FLASK_HOST = "0.0.0.0";
      FLASK_PORT = private.shelfmarkPort;
      INGEST_DIR = "${private.mediaDir}/books";
      # Search Prowlarr's indexers. It runs in the VPN namespace, so it's
      # reached at the namespace address; PROWLARR_API_KEY is in shelfmark-env
      PROWLARR_ENABLED = "true";
      PROWLARR_URL = "http://${config.vpnNamespaces.vpn.namespaceAddress}:${toString private.prowlarrPort}";
      # Send torrents to qBittorrent, also in the VPN namespace. It saves to
      # the shared downloads folder, which Shelfmark can read through the
      # media group. The password is entered in Shelfmark's web UI, which
      # keeps it in its own state folder
      PROWLARR_TORRENT_CLIENT = "qbittorrent";
      QBITTORRENT_URL = "http://${config.vpnNamespaces.vpn.namespaceAddress}:${toString private.qbittorrentWebuiPort}";
      QBITTORRENT_USERNAME = username;
      # After copying a download into books, have qBittorrent drop the torrent
      # and its files. qBittorrent stops seeding on completion anyway
      PROWLARR_TORRENT_ACTION = "remove_and_delete";
    };
  };

  systemd.services.shelfmark.serviceConfig = {
    # The module has no environmentFile option. systemd reads this as root
    # before switching to the service user, so the root-only secret works
    EnvironmentFile = config.sops.secrets.shelfmark-env.path;
    # DynamicUser has no users.users entry, so join the media group here
    SupplementaryGroups = [ "media" ];
    # The module's ProtectSystem=strict makes everything else read-only
    ReadWritePaths = [ "${private.mediaDir}/books" ];
    # mkForce: the module sets 0077; match the arr apps' group-writable files
    UMask = lib.mkForce "0002";
  };
}
