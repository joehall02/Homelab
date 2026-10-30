{ config, lib, private, ... }:

let
  # Where each app listens. qBittorrent and Prowlarr run inside the VPN
  # namespace, so they're reached at its address instead of 127.0.0.1
  vpn = config.vpnNamespaces.vpn.namespaceAddress;
  services = {
    jellyfin = "127.0.0.1:${toString private.jellyfinPort}";
    sonarr = "127.0.0.1:${toString private.sonarrPort}";
    radarr = "127.0.0.1:${toString private.radarrPort}";
    lidarr = "127.0.0.1:${toString private.lidarrPort}";
    prowlarr = "${vpn}:${toString private.prowlarrPort}";
    qbittorrent = "${vpn}:${toString private.qbittorrentWebuiPort}";
    beszel = "127.0.0.1:${toString config.services.beszel.hub.port}";
  };
in
{
  services.caddy.enable = true;

  # https://<name>.<domain> for every entry above, using the wildcard cert
  # from certs.nix
  services.caddy.virtualHosts = lib.mapAttrs' (
    name: target:
    lib.nameValuePair "${name}.${private.domain}" {
      useACMEHost = private.domain;
      extraConfig = "reverse_proxy ${target}";
    }
  ) services;

  # HTTPS on Tailscale only; the LAN keeps using http://<lanIp>:<port>
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 443 ];
}
