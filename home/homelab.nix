{ pkgs, ... }:

{
  # Release this setup started on, not the version in use. Leave it as is when
  # upgrading nixpkgs; it keeps old defaults for files that already exist.
  home.stateVersion = "26.05";

  # Used by fzf below to list files fast, respecting .gitignore
  home.packages = [ pkgs.fd ];

  programs.zsh = {
    enable = true;
    # Grey suggestion from history as you type; → accepts it
    autosuggestion.enable = true;
    # Colours commands green or red as you type, depending on whether they exist
    syntaxHighlighting.enable = true;

    history = {
      size = 50000;
      save = 50000;
      # Keep only the latest copy of a repeated command
      ignoreAllDups = true;
      # Record when each command ran
      extended = true;
    };

    oh-my-zsh = {
      enable = true;
      # Starship draws the prompt, so no oh-my-zsh theme
      theme = "";
      plugins = [
        "sudo"              # Esc twice puts sudo in front of the command
        "systemd"           # sc-status, sc-restart… for systemctl
        "colored-man-pages"
        "extract"           # `extract <file>` unpacks any archive type
      ];
    };
  };

  # Prompt: directory, git status, command duration and exit code
  programs.starship.enable = true;

  # Ctrl-R fuzzy history search, Ctrl-T file picker, Alt-C jump to directory
  programs.fzf = {
    enable = true;
    defaultCommand = "fd --type f --hidden --exclude .git";
    fileWidgetCommand = "fd --type f --hidden --exclude .git";
    changeDirWidgetCommand = "fd --type d --hidden --exclude .git";
  };

  # `z <part of a path>` jumps to a directory you've visited before
  programs.zoxide.enable = true;

  # Replaces ls (ls, ll, la, lt aliases), with git status per file
  programs.eza = {
    enable = true;
    git = true;
    # File icons need a Nerd Font in the terminal
    icons = "auto";
  };

  # cat with syntax highlighting
  programs.bat.enable = true;

  # Resource monitor: CPU, memory, disks, network and processes
  programs.btop = {
    enable = true;
    settings = {
      # Use the terminal's background instead of the theme's
      theme_background = false;
      # Show processes as a tree, so a service's child processes sit under it
      proc_tree = true;
    };
  };
}
