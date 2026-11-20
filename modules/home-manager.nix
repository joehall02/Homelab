{ username, ... }:

{
  home-manager = {
    # Use the system's nixpkgs instead of evaluating a second copy
    useGlobalPkgs = true;
    # Install user packages through NixOS (/etc/profiles), not ~/.nix-profile
    useUserPackages = true;
    # Rename existing dotfiles (e.g. an old ~/.zshrc) instead of failing
    backupFileExtension = "backup";
    users.${username} = import ../home/homelab.nix;
  };
}
