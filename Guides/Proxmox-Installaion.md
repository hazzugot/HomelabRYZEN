# Guide Part 2: Proxmox VE Installation

This guide is for the installation of the Proxmox VE hypervisor on the new homelab server.

---

## Installing Proxmox VE

### What is a Hypervisor?
A hypervisor is a piece of software that creates and runs virtual machines (VMs). It allows you to run multiple independent "guest" computers on a single physical machine. Proxmox VE is a powerful, open-source hypervisor that we will install directly onto the server's hardware. This is called a "bare-metal" hypervisor.

1.  **Download the Proxmox VE ISO:**
 *   This Iso is sort of used like a fake disc for installtion bootmedia.
 *   Go to the [Proxmox Downloads page](https://www.proxmox.com/en/downloads) and download the latest Proxmox VE ISO file.

2.  **Create a Bootable USB Drive:**
 *   To install Proxmox, you need to write the ISO file to a USB drive.
 *   Use a free tool like [Rufus](https://rufus.ie/) or [balenaEtcher](https://www.balena.io/etcher/) for this. Open the tool, select the Proxmox ISO file, choose your USB drive, and let it create the installer.
<img width="471" height="541" alt="Screenshot 2026-01-16 155317" src="https://github.com/user-attachments/assets/05bcc908-3e5a-4f85-a31b-c1852d1f344a" />


3.  **Install Proxmox:**
    *   Insert the bootable USB drive into the server and turn it on. You may need to press a key (like F2, F12, or DEL) to enter the BIOS/UEFI and select the USB drive as the boot device.
    *   Follow the on-screen installation steps.
    *   **Target Harddisk:** Select your fastest drive (ideally the NVMe SSD) as the installation target. This is where Proxmox itself will live.
    *   **Network Configuration:** You must assign a permanent, static IP address to the server. A server needs a predictable address so you can always connect to it.
        *   **What is a Static IP?** Your home router usually assigns IP addresses automatically (DHCP). A static IP is an address you set manually that won't change.
        *   Choose an unused IP address outside of your router's DHCP range (e.g., `192.168.1.10`).
        *   **Gateway:** This is your router's IP address (e.g., `192.168.1.1`).
        *   **DNS Server:** This can be your router's IP or a public one like Cloudflare's `1.1.1.1`.

    > **<img width="953" height="1108" alt="image" src="https://github.com/user-attachments/assets/0f27b816-3dfe-4334-b86c-43f957a635ae" />
**
    > *Caption: The network configuration screen during Proxmox installation. Set a static IP.*

4.  **Accessing the Proxmox Web UI:**
    *   After installation, remove the USB drive and reboot.
    *   From another computer on your network, open a web browser and go to `https://<your-server-ip>:8006`.
    *   **Security Warning:** Your browser will show a security warning. This is normal and safe. It happens because Proxmox creates its own security certificate that your browser doesn't recognize. Click "Advanced" and "Proceed".
    *   Log in with the username `root` and the password you created during installation.

    > **<img width="2070" height="985" alt="image" src="https://github.com/user-attachments/assets/90bb9a99-2fe1-4a13-97c9-44ce8618dd67" />
**
    > *Caption: The Proxmox web login screen. Welcome to your hypervisor!*
