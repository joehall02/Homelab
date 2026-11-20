{ pkgs, username, ... }:

{
  users.users.${username} = {
    isNormalUser = true;
    description = "Joe Hall";
    extraGroups = [ "networkmanager" "wheel" ];
    # Login shell for SSH and the console. /bin/sh and root stay on bash.
    shell = pkgs.zsh;
  };

  # Required for a zsh login shell. The shell itself is configured with Home
  # Manager in home/homelab.nix.
  programs.zsh = {
    enable = true;
    # The ~/.zshrc from Home Manager already runs compinit; running it in
    # /etc/zshrc too only slows down startup
    enableGlobalCompInit = false;
  };
}
