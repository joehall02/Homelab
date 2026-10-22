{
  sops = {
    # The encrypted secrets file
    defaultSopsFile = ../secrets/secrets.yaml;

    # Decrypt using the homelab's SSH host key
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    secrets.hello = { };
  };
}
