{ config, ... }:

{
  # Single-use, tagged auth key from the Tailscale admin console
  sops.secrets.tailscale-authkey = { };

  services.tailscale = {
    enable = true;
    # Tailscale's own UDP port, for direct connections between devices
    openFirewall = true;
    # Log in automatically on first boot (tailscaled-autoconnect.service).
    # Once logged in the key isn't needed again, even after it expires.
    authKeyFile = config.sops.secrets.tailscale-authkey.path;
    extraUpFlags = [ "--advertise-tags=tag:homelab" ];
  };
}
