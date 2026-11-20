{
  description = "Homelab NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    # Only for single packages that need a newer version
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    # sops-nix decrypts secrets on the homelab
    sops-nix = {
      url = "github:Mic92/sops-nix";
      # Reuse the nixpkgs above instead of downloading a second copy
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # VPN-Confinement runs chosen systemd services inside a WireGuard namespace
    vpn-confinement.url = "github:Maroka-chan/VPN-Confinement";

    # Home Manager manages the user's own environment: shell, dotfiles, user
    # programs. Its release branch must match nixpkgs.
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, nixpkgs-unstable, sops-nix, vpn-confinement, home-manager, ... }: {
    # "homelab" is the name used in --flake `deploy.sh`.
    nixosConfigurations.homelab = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      # Load private.nix once and make it available to every module
      specialArgs = {
        private = import ./private.nix;
        username = "joehall";
        # Packages from nixos-unstable
        unstable = nixpkgs-unstable.legacyPackages.x86_64-linux;
      };

      modules = [
        ./configuration.nix
        sops-nix.nixosModules.sops
        vpn-confinement.nixosModules.default
        home-manager.nixosModules.home-manager
      ];
    };
  };
}
