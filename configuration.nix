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

    # What the homelab runs
    ./services/ssh.nix
    ./services/media-stack
  ];

  # Version of the first install; never change it (see the NixOS manual)
  system.stateVersion = "26.05";
}
