# homelab

A Dell Inspiron 5570 laptop running headless as an always-on server.

## Specs

|               |                                                                                                                                 |
| ------------- | ------------------------------------------------------------------------------------------------------------------------------- |
| Model         | Dell Inspiron 5570 (regulatory type P75F001)                                                                                    |
| CPU           | Intel Core i5-8250U, 8th gen (Kaby Lake R), 4 cores / 8 threads, 1.6 GHz base, 3.4 GHz boost                                    |
| GPU           | Intel UHD Graphics 620 (Kaby Lake GT2), integrated                                                                              |
| Memory        | 8 GB DDR4-2400 SODIMM (Samsung M471A1K43CB1-CRC, single rank, 1.2 V) in DIMM B. DIMM A is empty, so a second stick can be added |
| Boot drive    | Samsung PM961 (MZ-VLW2560) 256 GB M.2 2280 NVMe SSD                                                                             |
| Storage drive | 1 TB HDD, mounted at `/mnt/hdd1`                                                                                                |
| Battery       | Internal, `BAT0`. Always plugged in; keeps the homelab running through a power cut, with a clean shutdown at 5% (see [Battery](#battery))                                                                       |
| Network       | Wi-Fi through NetworkManager                                                                                                    |
| NixOS         | 26.05 (`system.stateVersion = "26.05"`)                                                                                         |

## Disks

From `hardware-configuration.nix`:

| Mount       | Filesystem | Notes                                                        |
| ----------- | ---------- | ------------------------------------------------------------ |
| `/`         | ext4       | Root filesystem, on the 256 GB NVMe SSD                      |
| `/boot`     | vfat       | EFI system partition on the NVMe SSD, booted by systemd-boot |
| `/mnt/hdd1` | ext4       | The 1 TB HDD, for extra storage                              |

## Running a laptop as a server

`modules/system.nix` holds the settings that make a laptop behave like a server:

- **Lid closed doesn't mean suspend.** `HandleLidSwitch*` are all set to
  `ignore`, so the machine keeps running with the lid shut, on battery or AC.
- **The screen turns off.** `consoleblank=60` blanks the console after 60
  seconds without keyboard input. Any key wakes it.
- **It recovers from crashes.** `panic=10` reboots 10 seconds after a kernel
  panic instead of hanging.
- **The console is readable.** A large Terminus font (`ter-v32n`) is loaded
  early in boot. Keymap is UK, locale `en_GB.UTF-8`, timezone `Europe/London`.
- **It has swap.** An 8 GB swap file at `/var/lib/swapfile` on the SSD, so a
  memory spike slows the machine down instead of the kernel killing a 
  process. The partition table has no swap, so `hardware-configuration.nix`
  lists none; the file is declared in `system.nix`.

### Battery

The laptop is always plugged in, so the battery is managed for a long life
rather than full charge:

- **Charge limits.** `systemd.tmpfiles` writes to `/sys/class/power_supply/BAT0`
  at boot: charging starts below 75% and stops at 80%. Dell firmware ignores
  these thresholds unless `charge_types` is `Custom`, so that's written too.
- **Safe shutdown in a power cut.** UPower powers the machine off when the
  battery reaches 5% (6% counts as critical), so a long outage ends in a clean
  shutdown rather than a dead battery and a dirty filesystem.

## Graphics

`modules/graphics.nix` enables the Intel iGPU for hardware video transcoding:

| Package                         | Purpose                                             |
| ------------------------------- | --------------------------------------------------- |
| `intel-media-driver`            | VA-API driver (`iHD`) for 8th gen and newer         |
| `intel-compute-runtime-legacy1` | OpenCL for Gen 8–11 GPUs, used for HDR tone mapping |

Apps reach the GPU through `/dev/dri/renderD128`. A service that uses it needs:

1. Its user in the `video` and `render` groups.
2. `LIBVA_DRIVER_NAME=iHD` in its environment, so it uses the modern driver
   instead of the old `i965` one.

Jellyfin is set up this way (`services/media-stack/jellyfin.nix`),
and so is Immich when it's enabled.

The UHD 620 can hardware-decode H.264, HEVC (including 10-bit), MPEG-2, VC-1,
VP8 and VP9. It **can't decode AV1**: that needs an 11th gen or newer Intel GPU,
so AV1 files are transcoded on the CPU.

## Networking

`modules/networking.nix` sets the hostname to `homelab` and uses
NetworkManager. Wi-Fi power saving is turned off, because it adds latency and
dropouts on a machine that should always be reachable. The rest of the network
setup is in [Network](../network.md).
