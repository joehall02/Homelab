{ config, lib, private, username, unstable, ... }:

{
  # Secret settings as KEY=value lines
  sops.secrets.shelfmark-env = { };

  services.shelfmark = {
    enable = true;
    # TODO: Remove when updating to latest nixpkgs
    # 26.05's 1.3.0 never uses FlareSolverr for searches (fixed in 1.3.7).
    package = unstable.shelfmark;
    # No openFirewall: the web UI is reached through the namespace port mapping
    environment = {
      # The module's default of 127.0.0.1 would hide it from the port mapping
      FLASK_HOST = "0.0.0.0";
      FLASK_PORT = private.shelfmarkPort;
      INGEST_DIR = "${private.mediaDir}/books";
      # Sort ebooks into <Author>/ folders, as <Title> (<Year>).<ext>
      FILE_ORGANIZATION = "organize";
      # Save audiobooks to their own folder, one <Author>/<Title>/ folder per book
      DESTINATION_AUDIOBOOK = "${private.mediaDir}/audiobooks";
      FILE_ORGANIZATION_AUDIOBOOK = "organize";
      # Copy instead of hardlinking (the default). A hardlink shares the data so
      # the torrent can keep seeding, but skips extracting zip/rar downloads.
      # qBittorrent doesn't seed and remove_and_delete drops its copy anyway
      HARDLINK_TORRENTS_AUDIOBOOK = "false";
      # Search Prowlarr's indexers. It shares the VPN namespace with Shelfmark,
      # so it's reached at the namespace address; PROWLARR_API_KEY is in shelfmark-env
      PROWLARR_ENABLED = "true";
      PROWLARR_URL = "http://${config.vpnNamespaces.vpn.namespaceAddress}:${toString private.prowlarrPort}";
      # Send torrents to qBittorrent, also in the namespace. It saves to
      # the shared downloads folder, which Shelfmark can read through the
      # media group. The password is entered in Shelfmark's web UI, which
      # keeps it in its own state folder
      PROWLARR_TORRENT_CLIENT = "qbittorrent";
      QBITTORRENT_URL = "http://${config.vpnNamespaces.vpn.namespaceAddress}:${toString private.qbittorrentWebuiPort}";
      QBITTORRENT_USERNAME = username;
      # After copying a download into books, have qBittorrent drop the torrent
      # and its files. qBittorrent stops seeding on completion anyway
      PROWLARR_TORRENT_ACTION = "remove_and_delete";
      # Solve DDoS-Guard/Cloudflare challenges on the mirrors with FlareSolverr (flaresolverr.nix)
      EXT_BYPASSER_URL = "http://${config.vpnNamespaces.vpn.namespaceAddress}:${toString config.services.flaresolverr.port}";
    };
  };

  systemd.services.shelfmark.serviceConfig = {
    # The module has no environmentFile option. systemd reads this as root
    # before switching to the service user, so the root-only secret works
    EnvironmentFile = config.sops.secrets.shelfmark-env.path;
    # DynamicUser has no users.users entry, so join the media group here
    SupplementaryGroups = [ "media" ];
    # The module's ProtectSystem=strict makes everything else read-only
    ReadWritePaths = [
      "${private.mediaDir}/books"
      "${private.mediaDir}/audiobooks"
    ];
    # mkForce: the module sets 0077; match the arr apps' group-writable files
    UMask = lib.mkForce "0002";
  };

  # Run Shelfmark inside the VPN namespace, so mirror downloads use the tunnel
  systemd.services.shelfmark.vpnConfinement = {
    enable = true;
    vpnNamespace = "vpn";
  };

  # Make the web UI reachable from outside the namespace
  vpnNamespaces.vpn.portMappings = [
    {
      from = private.shelfmarkPort;
      to = private.shelfmarkPort;
    }
  ];
}
