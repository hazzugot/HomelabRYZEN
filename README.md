# Homelab RYZEN: A 10-Inch Rack Server Project

This repository documents the journey of designing, building, and configuring a compact, powerful, and custom-built 10-inch rack server. Powered by an AMD Ryzen 7 5700G, this homelab is a versatile platform for virtualization, network-attached storage (NAS), media streaming, and hands-on cybersecurity labs.

The primary goal is to create a robust, energy-efficient, and expandable home server while simultaneously serving as a comprehensive portfolio piece demonstrating skills in hardware selection, system integration, virtualization, networking, and service deployment.
<img width="459" height="484" alt="image" src="https://github.com/user-attachments/assets/34e65b75-5f01-4a92-8b3f-32c5a4b78199" />


## Table of Contents

- [Project Goals](#project-goals)
- [Hardware Overview](#hardware-overview)
- [Software Stack](#software-stack)
- [Networking Setup](#networking-setup)
- [Project Documentation](#project-documentation)
- [Future Plans](#future-plans)

## Project Goals

- **Virtualization Host:** Run multiple virtual machines using Proxmox VE for segregated services and labs.
- **Network Attached Storage (NAS):** Provide centralized file storage and backups for the home network using OpenMediaVault.
- **Media Server:** Host a Jellyfin instance for streaming movies, TV shows, and music, with hardware transcoding enabled.
- **Cybersecurity Lab:** Create a dedicated environment for hands-on security labs, including SIEM, IDS, and vulnerability scanning.
- **Portfolio Piece:** Document the entire process as a practical demonstration of technical skills for a SOC Analyst portfolio.

## Hardware Overview

The hardware was carefully selected to balance performance, cost, and a compact footprint suitable for a 10-inch rack.

| Component    | Specification                               | Purpose                                                              |
| :----------- | :------------------------------------------ | :------------------------------------------------------------------- |
| **CPU**      | AMD Ryzen 7 5700G (8-Core, 16-Thread)       | Powerful processing for VMs and hardware transcoding (iGPU).         |
| **Motherboard**| Gigabyte B550I AORUS PRO AX (Mini-ITX)      | Compact form factor with 2.5GbE LAN and Wi-Fi.                       |
| **RAM**      | 16GB DDR4 (@ 3000)          | Sufficient memory for multiple concurrent services.                  |
| **OS Drive** | Lexar NM610PRO 500GB NVMe SSD               | Fast storage for Proxmox OS and critical VM disks.                   |
| **Case**     | Custom 3D Printed 10-Inch Rackmount       | Tailor-made chassis for a perfect fit and optimized airflow.         |

For a detailed bill of materials and rationale for each component, see the [Hardware Documentation](./Hardware.md).

## Software Stack

The server runs a lightweight and powerful software stack to achieve its goals.

- **Hypervisor:** [Proxmox VE](https://www.proxmox.com/en/proxmox-ve)
  - **Why:** A powerful, open-source virtualization platform that combines KVM for virtual machines and LXC for containers. It provides a web-based management interface, making it easy to manage the entire server.

- **Network Attached Storage (NAS):** [OpenMediaVault (OMV)](https://www.openmediavault.org/)
  - **Why:** A feature-rich NAS solution that runs as a virtual machine. It's configured with MergerFS to pool multiple drives into a single large volume and SnapRAID for parity-based data protection.

- **Media Server:** [Jellyfin](https://jellyfin.org/)
  - **Why:** An open-source media server for streaming content. It is deployed inside a Docker container and configured with NFS shares for efficient playback. It's also able to enable transcoding using the integrated CPU which may be configured in the future if the CPU can't handle the variable load.

- **Remote Access:** [Nginx Proxy Manager](https://nginxproxymanager.com/)
  - **Why:** Provides easy-to-manage SSL termination and reverse proxying, allowing for secure remote access to web services like Jellyfin and OMV.

## Networking Setup

The network is designed for flexibility and security, with different virtual machines in Proxmox dedicated to distinct functions and network isolation. This approach allows for effective segmentation of services and lab environments.

- **Isolation via VMs:** Services like OpenMediaVault, Jellyfin, and dedicated lab environments are run in separate virtual machines within Proxmox. This provides a layer of isolation, preventing services from interfering with each other and allowing for secure experimentation in lab VMs without impacting the core network.
- **Dedicated Network Interfaces:** A dedicated dual-NIC card is installed in the server to provide multiple network interfaces to Proxmox, which can then be assigned to different virtual machines for further network segregation if desired.

## Project Documentation

This repository contains all the documentation for the project.

- **[Guides](./Guides/)**: Step-by-step installation and configuration guides for all major software components.
- **[Hardware.md](./Hardware.md)**: A detailed list of all hardware, including the rationale behind each choice.
- **[Troubleshooting.md](./Troubleshooting.md)**: A log of challenges faced and the solutions implemented.

## Future Plans

The homelab is an evolving project. For a complete list of upcoming cybersecurity labs and other planned enhancements, please see the [Future Plans](./Future_Plans.md) document.
