{ ... }:

{
  # Solves Cloudflare/DDoS-Guard challenges for other apps. Reach it at
  # http://<namespace address>:8191 from Shelfmark, or from Prowlarr as an
  # indexer proxy
  services.flaresolverr.enable = true;

  # Run it inside the VPN namespace next to the apps that use it, so its
  # browser traffic goes through the tunnel. No port mapping: only apps in
  # the namespace need it
  systemd.services.flaresolverr.vpnConfinement = {
    enable = true;
    vpnNamespace = "vpn";
  };
}
