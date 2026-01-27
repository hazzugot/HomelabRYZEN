# Guide Part 4: Jellyfin and Docker Setup

This guide provides steps taken for the creation of a dedicated "services" VM, installing Ubuntu Server, setting up Docker, and deploying Jellyfin.

---

## 1. Create and Install the Ubuntu Server VM

First, we'll create the VM in Proxmox that will run all our services.

1.  **Create the VM in Proxmox:**
   *   In the Proxmox web UI, click **"Create VM"**.
   *   **OS:** Select the Ubuntu Server 22.04 LTS ISO you have downloaded.
   *   **System:** Leave defaults.
   *   **Hard Disk:** A 64GB virtual disk on `local-lvm` is a good start.
   *   **CPU:** **2-4 cores** (start with 2, you can increase later if needed).
   *   **Memory:** 4096 MB (4GB) or more.
   *   Confirm and create the VM.

2.  **Install Ubuntu Server:**
   *   Select the newly created VM in Proxmox and click **"Start"**, then open the **"Console"**.
   *   You will see the Ubuntu Server installer load. Follow the on-screen prompts:
       *   **Language & Keyboard:** Choose your preferred options.
       *   **Network:** The default DHCP settings should be fine. The VM will get an IP address from your router.
       *   **Storage:** Use the default guided storage setup to use the entire virtual disk.
       *   **Profile Setup:** Create a username and password for your main user on this VM.
       *   **SSH Setup:** **Important:** Check the box to `Install OpenSSH server`. This will allow you to connect to the VM from another computer's terminal, which is much easier than using the Proxmox console.
       > **<img width="757" height="283" alt="image" src="https://github.com/user-attachments/assets/b2596006-0caa-451b-b73c-6e17e19304a3" />
**
       > *Caption: Make sure to select the option to install the OpenSSH server.*
       *   **Server Snaps:** You can skip installing any of the featured server snaps for now.
   *   The installation will proceed. Once it's finished, select `Reboot Now`. The VM will restart.

---

## 2. Connect via SSH and Install Docker

Now, we'll connect to the new VM and install Docker.

1.  **Find the VM's IP Address:**
    *   In the Proxmox UI, select the Ubuntu VM. In the "Summary" view, expand the "Network" section to find the IP address assigned to the VM.

2.  **Connect with SSH:**
    *   From your main computer, open a terminal (like PowerShell, Command Prompt, or Terminal on Mac/Linux) and connect to the VM. Replace `<username>` with the user you created during installation and `<vm-ip-address>` with the IP you just found.
        ```bash
        ssh <username>@<vm-ip-address>
        ```
        *Explanation:* This command establishes a secure shell connection from your local machine to your Ubuntu VM. You replace `<username>` with the user you created during Ubuntu installation and `<vm-ip-address>` with the VM's actual IP address.

3.  **Install Docker Engine:**
    *   Once logged in via SSH, run the following commands one by one. These steps follow the official Docker documentation to set up Docker's repository and install the engine.
    *   **Update package list:**
        ```bash
        sudo apt update
        ```
        *Explanation:* This command refreshes the list of available packages from the Ubuntu repositories. It doesn't install or upgrade anything, just updates the local cache of what's available.
    *   **Install prerequisite packages:**
        ```bash
        sudo apt install -y ca-certificates curl gnupg lsb-release
        ```
        *Explanation:* These packages are required for `apt` to securely handle repositories over HTTPS (`ca-certificates`), download files (`curl`), manage cryptographic keys (`gnupg`), and identify the Linux distribution (`lsb-release`).
    *   **Add Docker’s official GPG key:**
        ```bash
        sudo install -m 0755 -d /etc/apt/keyrings
        ```
        *Explanation:* This creates the `/etc/apt/keyrings` directory with appropriate permissions, where cryptographic keys are stored.
        ```bash
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        ```
        *Explanation:* This downloads Docker's public GPG key and converts it into a format (`dearmor`) that `apt` can use, then saves it to the keyrings directory. This key is used to verify the authenticity of Docker packages.
        ```bash
        sudo chmod a+r /etc/apt/keyrings/docker.gpg
        ```
        *Explanation:* This sets the correct permissions on the GPG key file, making it readable by all users so `apt` can access it.
    *   **Set up the Docker repository:**
        ```bash
        echo \
          "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
          $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        ```
        *Explanation:* This command adds the official Docker repository to your system's `apt` sources. This tells `apt` where to find the Docker packages. It dynamically detects your system's architecture and Ubuntu codename to ensure the correct repository is added.
    *   **Install Docker Engine and Compose:**
        ```bash
        sudo apt update
        ```
        *Explanation:* This `apt update` command is run again to refresh the package list, now including the newly added Docker repository.
        ```bash
        sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        ```
        *Explanation:* This command installs the main Docker components: the Docker Engine itself (`docker-ce`), the command-line client (`docker-ce-cli`), the container runtime (`containerd.io`), and the Docker Buildx and Compose plugins for building and orchestrating multi-container applications.
    *   **Add your user to the `docker` group (optional but recommended):** This allows you to run `docker` commands without `sudo`.
        ```bash
        sudo usermod -aG docker $USER
        ```
        *Explanation:* This command adds your current user (`$USER` is an environment variable that holds your username) to the `docker` Unix group. Members of this group can execute Docker commands without needing `sudo`. You must log out and log back in (or start a new shell session) for this change to take effect.
    *   **Log out and log back in** to your SSH session for the group change to take effect.

---

## 3. Mount Network Share and Deploy Jellyfin

Before we can run Jellyfin, we must mount the media share from our OMV NAS. We will use NFS as it is more performant than SMB/CIFS for this use case.

1.  **Install NFS Utilities:**
    *   This package allows Ubuntu to mount NFS network shares.
        ```bash
        sudo apt update
        sudo apt install -y nfs-common
        ```
        *Explanation:* `nfs-common` provides the necessary tools for your Linux system to connect to and interact with NFS network shares from your OpenMediaVault NAS.

2.  **Create a Mount Point:**
    *   We need a local directory on the Ubuntu VM where the network share will be attached.
        ```bash
        sudo mkdir /mnt/media
        ```
        *Explanation:* This command creates an empty directory named `media` inside the `/mnt` directory. This will serve as the "mount point" for your OMV network share.

3.  **Mount the Share Permanently:**
    *   We will edit the `/etc/fstab` file to make the system automatically mount the share on boot.
    *   Open `/etc/fstab` to add the mount entry.
        ```bash
        sudo nano /etc/fstab
        ```
        *Explanation:* This command opens the `/etc/fstab` file in the `nano` text editor. This file defines how filesystems should be automatically mounted at boot.
    *   Add the following line to the end of the file. Replace `<omv-ip-address>` with the IP of your OMV server and `/export/Media` with the exact **Exported path** you noted from the OMV NFS share settings.
        ```
        <omv-ip-address>:/export/Media /mnt/media nfs defaults 0 0
        ```
        *Explanation:* This critical line tells your system to mount the OMV share.
            *   `<omv-ip-address>:/export/Media`: The IP and exported path of your NFS share on the OMV server.
            *   `/mnt/media`: The local mount point created earlier.
            *   `nfs`: Specifies the filesystem type.
            *   `defaults`: A standard set of mount options that works well for most setups.
            *   `0 0`: These numbers control filesystem dumping and checking, and should be `0 0` for network mounts.
    *   Save the file (Ctrl+O, Enter) and exit (Ctrl+X).
    *   Mount the share now without rebooting:
        ```bash
        sudo mount -a
        ```
        *Explanation:* This command tells your system to read `/etc/fstab` and mount all unmounted filesystems. It's a way to test your `fstab` entry without rebooting.
    *   You should now be able to see the contents of your NAS share by running `ls -l /mnt/media`.

4.  **Deploy Jellyfin with Docker Compose:**
    *   Create a directory for your Jellyfin configuration.
        ```bash
        mkdir ~/jellyfin
        cd ~/jellyfin
        ```
    *   Create a file named `docker-compose.yml`:
        ```bash
        nano docker-compose.yml
        ```
    *   Paste the following content into the file. Note how `/mnt/media` is now used as the source for the media volume.

        ```yaml
        services:
          jellyfin:
            image: jellyfin/jellyfin
            container_name: jellyfin
            network_mode: host
            environment:
              - PUID=1000 # Your user's ID
              - PGID=1000 # Your user's group ID
            volumes:
              - ./config:/config
              - ./cache:/cache
              - /mnt/media:/media
            devices:
              # For optional hardware transcoding. Remove if not used or configured.
              - /dev/dri:/dev/dri
            restart: 'unless-stopped'
        ```
    *   Save the file (Ctrl+O, Enter) and exit (Ctrl+X).
    *   Start Jellyfin:
        ```bash
        docker compose up -d
        ```
        *Explanation:* This command tells Docker Compose to read your `docker-compose.yml` file, pull the Jellyfin image, and start the container in the background (`-d` for "detached" mode).

Your Jellyfin server is now running! You can access it by opening a web browser and navigating to `http://<vm-ip-address>:8096`..
> **<img width="719" height="400" alt="image" src="https://github.com/user-attachments/assets/cef3c6fc-7554-4403-ba61-c3b5198bf836" />
**
       > *Caption: Showing jellyfin up and running.*
*less screenshots are present in this guide as there is a lot of sensitive information*

