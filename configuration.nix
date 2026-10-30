{
  imports = [
    ./hardware-configuration.nix

    # Base system
    ./modules/system.nix
    ./modules/networking.nix
    ./modules/users.nix
    ./modules/sops.nix
    ./modules/vpn.nix
    ./modules/graphics.nix
    ./modules/tailscale.nix

    # What the homelab runs
    ./services/ssh.nix
    ./services/certs.nix
    ./services/reverse-proxy.nix
    ./services/media-stack
    ./services/file-sharing.nix
    ./services/monitoring.nix
  ];

  # Version of the first install; never change it (see the NixOS manual)
  system.stateVersion = "26.05";
}
