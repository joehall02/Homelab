# Future plans

## Mac support

Make the repo usable on the Mac as well as the homelab. Each machine gets its
own Home Manager configuration, so the Mac's desktop tools don't end up on the
server and server settings don't end up on the Mac. Settings both machines use
can be shared between them.

What the Mac's configuration will manage:

- **AeroSpace** (tiling window manager), through Home Manager's
  `programs.aerospace`. Its config is written to
  `~/.config/aerospace/aerospace.toml`. With `launchd.enable = true`,
  AeroSpace starts at login and reloads its config when the file changes.
  `start-at-login` and `after-login-command` can't be set, because launchd
  starts AeroSpace. Put startup commands in `after-startup-command`.
- **SketchyBar** (menu bar replacement), through Home Manager's
  `programs.sketchybar`. Its `config` can point at a whole folder of config
  files, which suits a setup with many plugin scripts. Check its full option
  list against the Home Manager manual before writing the config.
- **AeroSpace and SketchyBar together**: an `exec-on-workspace-change` entry in
  AeroSpace runs `sketchybar --trigger aerospace_workspace_change`, so the bar
  shows the current workspace.
- **JankyBorders** for window borders that match the bar.

Both tools are managed by Home Manager instead of nix-darwin, so all of the
Mac's settings live in one place.
