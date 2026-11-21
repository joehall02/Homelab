# Machines

Every machine in the homelab. Each one managed by this repo has its own page
for the config that only applies to its hardware.

| Hostname                | Role                                             | Hardware                  | CPU                                              | GPU                    | RAM                  | Storage                                                       | OS          |
| ----------------------- | ------------------------------------------------ | ------------------------- | ------------------------------------------------ | ---------------------- | -------------------- | ------------------------------------------------------------- | ----------- |
| [`homelab`](homelab.md) | Headless server: media, file sharing, monitoring | Dell Inspiron 5570 laptop | Intel Core i5-8250U (4 cores / 8 threads)        | Intel UHD Graphics 620 | 8 GB DDR4-2400       | 256 GB NVMe SSD (boot) + 1 TB HDD (`/mnt/hdd1`)               | NixOS 26.05 |
| `macmini`               | Runs the local AI models in LM Studio, and Kokoro text to speech | Mac mini (M4, 2024)       | Apple M4 (10 cores: 4 performance, 6 efficiency) | Apple M4, 10 cores     | 24 GB unified memory | 512 GB internal SSD (boot) + 2 TB external NVMe SSD | macOS 26.3  |

The deploy script runs from a separate workstation, see [Deployment](../deployment.md).
