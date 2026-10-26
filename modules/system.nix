{ pkgs, ... }:

{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Headless server: never suspend (e.g. on lid close)
  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
  };

  boot.kernelParams = [
    # Turn the screen off after 60s without keyboard input; any key wakes it
    "consoleblank=60"
    # Reboot 10s after a kernel crash instead of hanging
    "panic=10"
  ];

  # Shut down cleanly when the battery is nearly flat (e.g. long power cut)
  services.upower = {
    enable = true;
    criticalPowerAction = "PowerOff";
    percentageAction = 5;
    percentageCritical = 6;
  };

  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";
  console.keyMap = "uk";

  # Large console font so the laptop screen is readable
  console.font = "ter-v32n";
  console.packages = [ pkgs.terminus_font ];
  console.earlySetup = true;

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  environment.systemPackages = with pkgs; [
    rsync
    git
    asciiquarium
  ];
}
