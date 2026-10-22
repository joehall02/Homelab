{
  description = "Homelab NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    # sops-nix decrypts secrets on the homelab
    sops-nix = {
      url = "github:Mic92/sops-nix";
      # Reuse the nixpkgs above instead of downloading a second copy
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # VPN-Confinement runs chosen systemd services inside a WireGuard namespace
    vpn-confinement.url = "github:Maroka-chan/VPN-Confinement";
  };

  outputs = { nixpkgs, sops-nix, vpn-confinement, ... }: {
    # "homelab" is the name used in --flake `deploy.sh`.
    nixosConfigurations.homelab = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      # Load private.nix once and make it available to every module
      specialArgs = {
        private = import ./private.nix;
      };

      modules = [
        ./configuration.nix
        sops-nix.nixosModules.sops
        vpn-confinement.nixosModules.default
      ];
    };
  };
}
