# Guide Part 5: Secure Remote Access with a Reverse Proxy

This guide provides a detailed, step-by-step walkthrough for setting up Nginx Proxy Manager (NPM) to enable secure, remote access to your Jellyfin server over the internet.

---

## Introduction: Why Use a Reverse Proxy?

Right now, the Jellyfin server is only accessible on the home network. While you could expose it directly to the internet using port forwarding, this is a major security risk.

A **reverse proxy** acts as a secure gateway or "front door" for your home network. All traffic from the internet first hits the reverse proxy, which then safely forwards it to the correct internal service (like Jellyfin).

**Benefits:**
*   **Security:** You only expose the reverse proxy to the internet, not your actual applications. NPM includes features to block common exploits.
*   **Convenience:** You can access Jellyfin via a simple, memorable domain name (e.g., `https://jellyfin.your-domain.com`) instead of an IP address.
*   **Encryption (SSL/HTTPS):** NPM will automatically obtain and renew free SSL certificates from Let's Encrypt, so your connection is encrypted (you get the padlock in your browser).

---

## Prerequisites & Part 1: Domain Setup and Port Forwarding

To get started, you need a domain name that points to your home network.

### Option A: Get a Free Domain with DuckDNS (Recommended)

This is the cheapest and most efficient method for a homelab. DuckDNS is a free service that gives you a subdomain (like `your-name.duckdns.org`) and helps manage your home's dynamic IP address.

1.  **Sign Up for DuckDNS:**
    *   Go to the DuckDNS website: [https://www.duckdns.org/](https://www.duckdns.org/)
    *   Log in using a provider like Google, GitHub, etc.

2.  **Create Your Subdomain:**
    *   In the "domains" section, type a unique name for your server (e.g., `my-jellyfin-server`) and click "add domain". You now have a domain: `my-jellyfin-server.duckdns.org`.
    *   This is the domain you will use in Nginx Proxy Manager later.
    > **<img width="833" height="410" alt="image" src="https://github.com/user-attachments/assets/7ccab243-238a-49d7-a5c5-575c8a3c38df" />
**
    > *Caption: The DuckDNS dashboard where your domain is created and your token is shown at the top.*

3.  **Set Up Automatic IP Updates:**
    *   Most home internet connections have a "dynamic IP" that changes. We will run a small Docker container that automatically tells DuckDNS your new IP whenever it changes.
    *   On your Ubuntu VM, create a new directory for this container:
        ```bash
        mkdir ~/duckdns
        cd ~/duckdns
        nano docker-compose.yml
        ```
    *   Paste the following into the file. **You must replace the `SUBDOMAINS` and `TOKEN` values.** Your token is displayed at the top of the DuckDNS website.
        ```yaml
        services:
          duckdns:
            image: lscr.io/linuxserver/duckdns:latest
            container_name: duckdns
            environment:
              - PUID=1000
              - PGID=1000
              - TZ=auto
              - SUBDOMAINS=your-subdomain-name # The name you chose, e.g., my-jellyfin-server
              - TOKEN=your-duckdns-token # Your token from the DuckDNS website
              - LOG_FILE=false
            restart: unless-stopped
        ```
    *   Save the file and start the container:
        ```bash
        docker compose up -d
        ```
    *   Your DuckDNS domain will now always point to your home network.



### Configure Port Forwarding on Your Router


1.  Log in to your home router's administration page.
2.  Find the "Port Forwarding" or "Application Forwarding" section.
3.  Create two new rules:
    1.  **HTTP Rule:**
        *   **External Port:** `80`
        *   **Internal Port:** `80`
        *   **Protocol:** `TCP`
        *   **Device IP / Forward to:** The **private IP address** of your Ubuntu VM (e.g., `<your IP>`).
    2.  **HTTPS Rule:**
        *   **External Port:** `443`
        *   **Internal Port:** `443`
        *   **Protocol:** `TCP`
        *   **Device IP / Forward to:** The **private IP address** of your Ubuntu VM.
4.  Save and apply the rules.
> **<img width="323" height="444" alt="image" src="https://github.com/user-attachments/assets/8d4c8ad4-10a8-4b76-9342-3ad75db00c2e" />
**
> *Caption: An example of port forwarding rules on a home router. All incoming web traffic is now directed to our Docker VM.*

---

## Part 2: Deploy Nginx Proxy Manager (NPM)

We will deploy NPM as a Docker container on the same Ubuntu VM as Jellyfin.

1.  **Create a Directory for NPM:**
    *   Connect to your Ubuntu VM via SSH.
    *   Create a new directory to hold the NPM configuration and start a new `docker-compose.yml` file.
        ```bash
        mkdir ~/npm
        cd ~/npm
        nano docker-compose.yml
        ```

2.  **Create the Docker Compose File for NPM:**
    *   Paste the following content into the `docker-compose.yml` file.

        ```yaml
        services:
          app:
            image: 'jc21/nginx-proxy-manager:latest'
            restart: unless-stopped
            ports:
              # Public-facing web ports
              - '80:80'
              - '443:443'
              # Admin UI port
              - '81:81'
            volumes:
              - ./data:/data
              - ./letsencrypt:/etc/letsencrypt
        ```
    *   Save the file (Ctrl+O, Enter) and exit `nano` (Ctrl+X).

3.  **Start Nginx Proxy Manager:**
    *   Run the following command from the `~/npm` directory:
        ```bash
        docker compose up -d
        ```

---

## Part 3: Configure Nginx Proxy Manager

Now we will configure NPM to route traffic to Jellyfin.

1.  **Log in to NPM:**
    *   Open a web browser and navigate to the NPM admin panel using your VM's IP address and port 81: `http://<ubuntu-vm-ip>:81` (e.g., `<Your-IP>`).
    *   Log in with the default credentials:
        *   **Email:** `admin@example.com`
        *   **Password:** `changeme`
    *   You will be immediately prompted to change your username, email, and password. **Do this now.**

2.  **Create a New Proxy Host:**
    *   Navigate to **Hosts > Proxy Hosts** and click **"Add Proxy Host"**.
    > **<img width="1340" height="257" alt="image" src="https://github.com/user-attachments/assets/62abb6ba-ebe0-465d-aa71-4636d563cc77" />
**
    > *Caption: The Nginx Proxy Manager dashboard.*
    *   Fill out the **Details** tab:
        *   **Domain Names:** Enter the full domain or subdomain you set up in your DNS records (e.g., `jellyfin.your-domain.com`).
        *   **Scheme:** `http`
        *   **Forward Hostname / IP:** Enter the private IP address of your Ubuntu VM (e.g., `<Your-IP>`).
        *   **Forward Port:** `8096` (the port Jellyfin is running on).
        *   **Enable `Block Common Exploits`**.
    > **<img width="518" height="546" alt="image" src="https://github.com/user-attachments/assets/14271616-b4ac-4ec3-8f72-347273eea241" />
**
    > *Caption: Filling out the proxy host details to point to Jellyfin.*
    *   Click on the **SSL** tab:
        *   In the **SSL Certificate** dropdown, select **"Request a new SSL Certificate"**.
        *   Enable **`Force SSL`**. This forces all connections to use secure HTTPS.
        *   Enable **`HTTP/2 Support`**.
        *   Agree to the Let's Encrypt Terms of Service.
    > **<img width="512" height="308" alt="image" src="https://github.com/user-attachments/assets/82a09164-3c72-4aad-8cce-38e464b3fcb4" />
**
    > *Caption: Requesting a free SSL certificate from Let's Encrypt.*
    *   Click **"Save"**.

---

## Part 4: Access Jellyfin Remotely

After you click save, NPM will obtain the SSL certificate. This may take a minute or two.

Once it's done, you should be able to securely access your Jellyfin server from anywhere in the world by navigating to **`https://your-jellyfin-domain.com`**.
