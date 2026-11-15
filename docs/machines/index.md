# Machines

Every machine managed by this repo. Each one has its own page for the config
that only applies to its hardware.

| Hostname                | Role                                             | Hardware                  | CPU                                       | GPU                    | RAM            | Storage                                         | OS          |
| ----------------------- | ------------------------------------------------ | ------------------------- | ----------------------------------------- | ---------------------- | -------------- | ----------------------------------------------- | ----------- |
| [`homelab`](homelab.md) | Headless server: media, file sharing, monitoring | Dell Inspiron 5570 laptop | Intel Core i5-8250U (4 cores / 8 threads) | Intel UHD Graphics 620 | 8 GB DDR4-2400 | 256 GB NVMe SSD (boot) + 1 TB HDD (`/mnt/hdd1`) | NixOS 26.05 |

The deploy script runs from a separate workstation, see [Deployment](../deployment.md).
