# Secrets

The repo keeps two kinds of sensitive value apart:

|                           | `secrets/secrets.yaml` (sops)                    | `private.nix`                                                                       |
| ------------------------- | ------------------------------------------------ | ----------------------------------------------------------------------------------- |
| For                       | Passwords, API keys, auth keys, VPN configs      | Values that aren't secret but shouldn't be public: domain, LAN subnet, ports, paths |
| In git?                   | Yes, encrypted                                   | No, gitignored                                                                      |
| Reaches the homelab by    | rsync, still encrypted. Decrypted on the homelab | rsync, in plain text                                                                |
| Ends up in the Nix store? | No. Decrypted to `/run/secrets` at activation    | **Yes**: values are baked into world-readable config files                          |

The last row is why passwords never go in `private.nix`. Anything a module reads
from it can end up readable by every user on the homelab.

## sops and sops-nix

[**sops**](https://github.com/getsops/sops) (Secrets OPerationS) encrypts the
*values* in a YAML or JSON file but leaves the *keys* readable. The file can
then be committed: anyone can see which secrets exist, but only holders of a
listed private key can read them. Here it uses [**age**](https://age-encryption.org)
keys.

[**sops-nix**](https://github.com/Mic92/sops-nix) is a NixOS module that
decrypts a sops file during system activation and writes each secret to its own
file under `/run/secrets/`, owned by root by default. A module refers to a
secret by its path, never its value, so the plain text never enters the Nix
store.

## Who can decrypt

`.sops.yaml` lists the recipients for every file in `secrets/`:

| Key        | Where the private half lives                                             | Used for                 |
| ---------- | ------------------------------------------------------------------------ | ------------------------ |
| `&mac`     | An age key on the workstation                                            | Editing secrets          |
| `&homelab` | Derived from the homelab's SSH host key, `/etc/ssh/ssh_host_ed25519_key` | Decrypting at activation |

`modules/sops.nix` points sops-nix at that host key (`age.sshKeyPaths`), so the
homelab needs no extra key file. This means **reinstalling the homelab with a
new SSH host key** stops it decrypting until the file is re-keyed (see below).

## Current secrets

| Secret              | Format                                                         | Used by                                       |
| ------------------- | -------------------------------------------------------------- | --------------------------------------------- |
| `surfshark.conf`    | A full WireGuard `.conf` from Surfshark.                       | `modules/vpn.nix` (VPN namespace)             |
| `porkbun-acme`      | `PORKBUN_API_KEY=…` and `PORKBUN_SECRET_API_KEY=…` lines       | `services/certs.nix` (Let's Encrypt via lego) |
| `tailscale-authkey` | A single-use, tagged auth key from the Tailscale admin console | `modules/tailscale.nix`                       |
| `navidrome-env`     | `ND_PASSWORDENCRYPTIONKEY=…`                                   | `services/media-stack/navidrome.nix`          |
| `shelfmark-env`     | `KEY=value` lines, including `PROWLARR_API_KEY`                | `services/media-stack/shelfmark.nix`          |
| `open-webui-env`    | `WEBUI_SECRET_KEY=…` and `OPENAI_API_KEY=…` (LM Studio token)  | `services/open-webui.nix`                     |

## Using a secret in a module

Declare it, then pass its path to whatever needs it:

```nix
{ config, ... }:
{
  sops.secrets.my-app-env = { };

  services.my-app.environmentFile = config.sops.secrets.my-app-env.path;
}
```

`environmentFile`-style options are read by systemd as root before the service
drops privileges, so a root-only secret works. If a module has no such option,
set `systemd.services.<name>.serviceConfig.EnvironmentFile` directly, as
`shelfmark.nix` does. If the service reads the file itself as its own user, set
`owner` on the secret.

## Editing secrets

On the workstation, with the age key available to sops:

```sh
sops secrets/secrets.yaml
```

This opens the decrypted file in `$EDITOR` and re-encrypts it on save. Add the
new key, declare it in a module, then deploy.

## Re-keying

Change `.sops.yaml` when a recipient changes, for example on a new workstation
or after reinstalling the homelab, then re-encrypt for the new list:

```sh
# Homelab: get its age recipient from the SSH host key
ssh-keyscan homelab | ssh-to-age
# or, on the homelab:  ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub

# New workstation: make an age key and read its public half
age-keygen -o ~/.config/sops/age/keys.txt

# After editing .sops.yaml, re-encrypt with the new recipients
sops updatekeys secrets/secrets.yaml
```

## `private.nix`

A plain Nix attribute set, loaded once in `flake.nix` and passed to every module
as `private`:

```nix
services.sonarr.settings.server.port = private.sonarrPort;
```

It's listed in `.gitignore`, but `deploy.sh` copies it like any other file.
`private.example.nix` is the committed template. It has every key with
placeholder values.