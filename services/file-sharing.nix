{ private, username, ... }:

{
  # Samba (SMB): the protocol Finder uses to browse and copy files.
  #
  # Samba keeps its own passwords, separate from the Linux login. On a fresh
  # install, set the users password once (it survives rebuilds and reboots):
  # `ssh -t homelab sudo smbpasswd -a joehall`
  services.samba = {
    enable = true;
    # Ports 139 and 445; "hosts allow" below limits who gets in
    openFirewall = true;

    settings = {
      global = {
        # Only the LAN and Tailscale devices (100.64.0.0/10) may connect
        "hosts allow" = "${private.lanSubnet} 100.64.0.0/10 127.0.0.1";
        "hosts deny" = "0.0.0.0/0";

        # SMB3 only, and every connection encrypted
        "server min protocol" = "SMB3";
        "server smb encrypt" = "required";

        # No guest access: a Samba password is always needed
        "map to guest" = "never";

        # Apple extensions: store Finder's metadata properly instead of
        # leaving ._ files next to everything you copy
        "vfs objects" = "fruit streams_xattr";
        "fruit:metadata" = "stream";
      };

      # The share as Finder shows it: the whole filesystem, as joehall.
      # Normal Linux permissions still apply, so system files are read-only.
      root = {
        path = "/";
        "read only" = "no";
        "valid users" = username;
      };
    };
  };

  # Bonjour: puts the homelab in Finder's sidebar under Network
  services.avahi = {
    enable = true;
    openFirewall = true;
    publish.enable = true;
    publish.userServices = true;

    # The default samba package can't announce itself, so advertise the
    # SMB share here
    extraServiceFiles.smb = ''
      <?xml version="1.0" standalone='no'?>
      <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
      <service-group>
        <name replace-wildcards="yes">%h</name>
        <service>
          <type>_smb._tcp</type>
          <port>445</port>
        </service>
      </service-group>
    '';
  };
}
