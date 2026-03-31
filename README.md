# Homelab RYZEN: A 10-Inch Rack Server Project

This repository documents the journey of designing, building, and configuring a compact, powerful, and custom-built 10-inch rack server. Powered by an AMD Ryzen 7 5700G, this homelab is part of a two-node Proxmox cluster and serves as a versatile platform for cybersecurity labs, virtualisation, and network experimentation.
The primary goal is to create a robust, expandable home lab environment while simultaneously serving as a portfolio piece demonstrating skills in hardware selection, system integration, virtualisation, networking, and security operations.

<img width="459" height="484" alt="image" src="https://github.com/user-attachments/assets/34e65b75-5f01-4a92-8b3f-32c5a4b78199" />


## Table of Contents

- [Project Goals](#project-goals)
- [Cluster Overview](#cluster-overview)
- [Hardware Overview](#hardware-overview)
- [Software Stack](#software-stack)
- [Networking Setup](#networking-setup)
- [Project Documentation](#project-documentation)
- [Future Plans](#future-plans)

## Project Goals

- **Virtualisation Host:** Run multiple virtual machines using Proxmox VE for segregated services and labs.
- **Network Attached Storage (NAS):** Provide centralised, redundant file storage for the home network using TrueNAS SCALE with ECC memory and RAIDZ1.
- **Media Server:** Host a Jellyfin instance for streaming movies, TV shows, and music.
- **Cybersecurity Lab:** Create a dedicated environment for hands-on security labs, including Active Directory, SIEM, IDS, and vulnerability scanning.
- **Self-Managed Network:** Run a virtualised OPNsense firewall handling all routing, firewalling, DHCP, DNS, and VLAN segmentation - replacing the ISP router entirely.
- **Portfolio Piece:** Document the entire process as a practical demonstration of technical skills for an infrastructure and security portfolio.

## Cluster Overview

The homelab has evolved into a two-node Proxmox VE cluster with a Raspberry Pi acting as a Corosync Qdevice for quorum. The primary node runs Active Directory, SIEM detection testing, and a virtualised OPNsense firewall that handles all home network routing.
- **Storage Node (in progress):** Running TrueNAS SCALE with ECC RAM and RAIDZ1 for redundant, integrity-checked storage of family photos and media.
- **Raspberry Pi:** Acts as the Corosync Qdevice, providing the third quorum vote.

This architecture separates storage and lab workloads cleanly, resolving resource contention that existed when both ran on a single node.

## Hardware Overview

The hardware was carefully selected to balance performance, cost, and a compact footprint suitable for a 10-inch rack.

| Component    | Specification                               | Purpose                                                              |
| :----------- | :------------------------------------------ | :------------------------------------------------------------------- |
| **CPU**      | AMD Ryzen 7 5700G (8-Core, 16-Thread)       | Powerful processing for VMs and hardware transcoding (iGPU).         |
| **Motherboard**| Gigabyte B550I AORUS PRO AX (Mini-ITX)      | Compact form factor with 2.5GbE LAN and Wi-Fi.                       |
| **RAM**      | 16GB DDR4 (@ 3000)          | Sufficient memory for multiple concurrent services.                  |
| **OS Drive** | Lexar NM610PRO 500GB NVMe SSD               | Fast storage for Proxmox OS and critical VM disks.                   |
| **Case**     | Custom 3D Printed 10-Inch Rackmount       | Tailor-made chassis for a perfect fit and optimized airflow.         |
> The storage node hardware is still being finalised and will be documented in a separate repository once complete.

For a detailed bill of materials and rationale for each component, see the [Hardware Documentation](./Hardware.md).

## Software Stack

The server runs a lightweight and powerful software stack to achieve its goals.

- **Hypervisor:** [Proxmox VE](https://www.proxmox.com/en/proxmox-ve)
  - **Why:** A powerful, open-source virtualisation platform combining KVM for virtual machines and LXC for containers. This node runs as part of a two-node cluster, with a Raspberry Pi Qdevice providing quorum.
- **Network Attached Storage (NAS):** [TrueNAS SCALE](https://www.truenas.com/truenas-scale/)
  - **Why:** Replaces the previous OpenMediaVault setup. TrueNAS SCALE runs on a dedicated storage node with ECC RAM and a RAIDZ1 pool, providing data integrity checking and drive redundancy for family photos and media.
- **Firewall/Router:** [OPNsense](https://opnsense.org/)
  - **Why:** Runs as a VM with dedicated WAN and LAN NICs, handling all home network routing, stateful firewalling, DHCP (Dnsmasq), DNS (Unbound with DNSSEC), and PPPoE authentication to the ISP. Replaced the ISP router entirely. See [Lab 00C](./Labs/00C_OPNsense_Firewall/) for full documentation.
- **Smart Home:** [Home Assistant OS](https://www.home-assistant.io/)
  - **Why:** Runs as a VM on the LAN with firewall-controlled access to IoT devices on a dedicated VLAN. Manages smart plugs, lighting, and home automation.
- **Media Server:** [Jellyfin](https://jellyfin.org/)
  - **Why:** An open-source media server deployed inside a Docker container, configured with NFS shares for efficient playback.
- **Remote Access:** [Nginx Proxy Manager](https://nginxproxymanager.com/)
  - **Why:** Provides SSL termination and reverse proxying for secure remote access to web services.

## Networking Setup

The network is fully self-managed through a virtualised OPNsense firewall, with VLAN segmentation isolating different traffic types and security zones.

- **OPNsense Gateway:** Virtualised firewall handling all routing, DHCP, DNS, and firewalling. Connected to the ISP via PPPoE over VLAN 101 on a dedicated WAN NIC, with the LAN on a separate NIC to a managed switch.
- **VLAN Segmentation:** 802.1Q VLANs separate management, lab, IoT, and storage traffic. Managed via a Netgear GS510TLP switch with VLAN-aware bridging configured in Proxmox.
- **IoT Isolation (VLAN 40):** Smart home devices sit on a dedicated VLAN (192.168.40.0/24) with firewall rules blocking access to the LAN and Proxmox management. Home Assistant reaches IoT devices via a targeted firewall rule.
- **Lab Isolation:** Cybersecurity lab VMs - including Active Directory and SIEM - run on isolated VLANs, allowing safe attack simulation without impacting home services.
- **Dedicated Network Interfaces:** A dual-NIC card provides separate WAN and LAN interfaces to the OPNsense VM, with the onboard NIC reserved for Proxmox management.

## Project Documentation

This repository contains all the documentation for the project.

- **[Guides](./Guides/)**: Step-by-step installation and configuration guides for all major software components.
  - [Initial Build](./Guides/Initial%20Build/) - Hardware assembly and component selection
  - [Networking](./Guides/Networking/) - Network configuration and VLANs
  - [Software and VM Deployment](./Guides/Software%20and%20VM%20deployement/) - Proxmox, TrueNAS, Jellyfin setup
- **[Hardware.md](./Guides/Initial%20Build/Hardware.md)**: A detailed list of all hardware, including the rationale behind each choice.
- **[Troubleshooting.md](./Troubleshooting.md)**: A log of challenges faced and the solutions implemented.
- **[Labs](./Labs/)**: Security lab documentation and write-ups.
- **[Scripts](./Scripts/)**: Utility scripts used in the project.

## Future Plans

The homelab is an evolving project. Current priorities:

- Complete Active Directory lab and document attack/detection use cases against the SIEM
- Bring the Dell T3300 second node online and re-register the Raspberry Pi Qdevice
- Integrate Tapo smart devices with Home Assistant via HACS
- Set up WireGuard VPN for remote access through OPNsense
- Document the storage node once hardware is finalised
- Deploy Suricata IDS on OPNsense

For a full list of planned labs and enhancements, see the [Future Plans](Labs/README.md) document.
