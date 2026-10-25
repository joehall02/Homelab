{ private, username, ... }:

{
  services.qbittorrent = {
    enable = true;
    webuiPort = private.qbittorrentWebuiPort;

    # Written to qBittorrent.conf on every start, so settings changed in the
    # web UI are lost on restart. Keep the ones that matter here.
    serverConfig = {
      LegalNotice.Accepted = true;

      # No UPnP/NAT-PMP: traffic goes through the VPN, not the router
      Network.PortForwardingEnabled = false;

      BitTorrent.Session = {
        DefaultSavePath = "${private.mediaDir}/downloads";
        AnonymousModeEnabled = true;

        # Only use the WireGuard interface (VPN-Confinement names it
        # <namespace>0), as a backup to the namespace kill switch
        Interface = "vpn0";
        InterfaceName = "vpn0";

        # Max active uploads only applies when queueing is on
        QueueingSystemEnabled = true;
        MaxActiveUploads = 0;

        # Stop seeding as soon as a download finishes (-1 means no limit)
        GlobalMaxRatio = 0;
        GlobalMaxSeedingMinutes = 0;
        GlobalMaxInactiveSeedingMinutes = 0;

        # Skip common malware file types (.exe allowed)
        ExcludedFileNames = "*.scr, *.bat, *.cmd, *.lnk, *.msi, *.vbs, *.js";
      };
      BitTorrent.ExcludedFileNamesEnabled = true;

      Preferences.WebUI = {
        Username = username;
        Password_PBKDF2 = private.qbittorrentPasswordHash;
      };
    };
  };

  # Join the shared media group so it can write to the downloads folder,
  # and make new files group-writable so Sonarr/Radarr can move them
  users.users.qbittorrent.extraGroups = [ "media" ];
  systemd.services.qbittorrent.serviceConfig.UMask = "0002";

  # Run qBittorrent inside the VPN namespace (no traffic leaves outside the tunnel)
  systemd.services.qbittorrent.vpnConfinement = {
    enable = true;
    vpnNamespace = "vpn";
  };

  # Make the web UI reachable from outside the namespace
  vpnNamespaces.vpn.portMappings = [{
    from = private.qbittorrentWebuiPort;
    to = private.qbittorrentWebuiPort;
  }];

  # Web UI is reached through the namespace port mapping
  networking.firewall.allowedTCPPorts = [ private.qbittorrentWebuiPort ];
}

