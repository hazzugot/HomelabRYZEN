# Lab 00: Network Foundation Setup

This guide sets up the network infrastructure for your security homelab using a **simplified Proxmox-centric approach**. Complete this before starting other labs.

---

## Design Philosophy

**Isolation through topology, not firewall rules.** Lab VMs live on an internal-only Proxmox bridge with no physical uplink. They physically cannot reach production.

### Why This Approach?

| Old Design | New Design |
|------------|------------|
| 4 VLANs (1, 10, 20, 30) | No VLANs - flat network + internal bridge |
| pfSense VM required for routing | iptables on Proxmox host |
| Complex switch 802.1Q config | Switch as simple patch panel |
| 6+ Proxmox bridges | 2 bridges (vmbr0, vmbr1) |
| Firewall rules for isolation | Topology-based isolation |

---

## Equipment

| Device | Model | Role |
|--------|-------|------|
| Router | eero 6 Plus | Main gateway, DHCP (can't bridge mode) |
| Switch | TP-Link TL-SG105E | Simple switch (VLANs disabled) |
| Server | Proxmox Host | Virtualization + NAT router for labs |
| Attack Box | VirtualBox on PC | Kali Linux (bridged to WiFi) |

---

## Network Architecture

### Bridges

| Bridge | Physical NIC | Purpose | Subnet |
|--------|-------------|---------|--------|
| vmbr0 | nic0 | Production (Jellyfin, OMV, Proxmox mgmt) | 192.168.4.0/24 (eero DHCP) |
| vmbr1 | **None** | Isolated Lab Network | 10.0.0.0/24 (static) |

### Physical Topology

```
Internet
   |
+-------+
| eero  | 192.168.4.1 (gateway, DHCP)
+---+---+
   | Port 1
+---v---------+
| TL-SG105E   | (Simple switch - no VLANs)
| Port 2 ---------> Proxmox nic0 (192.168.4.10)
+-------------+

Main PC --- WiFi ---> eero (192.168.4.x)
   |
   +-- VirtualBox Kali (bridged to WiFi, 192.168.4.x)
           |
           +-- Static route to 10.0.0.0/24 via 192.168.4.10
```

### Proxmox Internal Network

```
+-----------------------------------------------------+
|                   Proxmox Host                       |
|                   192.168.4.10                       |
|                                                      |
|  vmbr0 (nic0) <---- Production Network ----> eero   |
|      |                                               |
|      +-- OMV VM (192.168.4.x)                       |
|      +-- Jellyfin VM (192.168.4.x)                  |
|      +-- Nginx Proxy Manager                         |
|                                                      |
|  vmbr1 (no NIC) <-- Lab Network (internal only)     |
|      |              10.0.0.1 (Proxmox gateway)      |
|      |                                               |
|      +-- Splunk VM (10.0.0.10)                      |
|      +-- Windows Victim (10.0.0.20)                 |
|      +-- [Future: AD Lab, VulnHub targets]          |
|                                                      |
|  Routing:                                            |
|  - IP forwarding enabled                             |
|  - iptables NAT: vmbr1 -> internet                  |
|  - PC static route: 10.0.0.0/24 via 192.168.4.10   |
+-----------------------------------------------------+
```

---

## Phase 1: Switch Simplification

The TL-SG105E should be used as a simple unmanaged switch.

### Option A: Factory Reset (Recommended)

1. Hold reset button for 5+ seconds until LEDs flash
2. Switch returns to default (no VLANs, simple switching)

### Option B: Disable 802.1Q VLANs

1. Access switch at `http://192.168.0.1` (or current IP)
2. Navigate to: **VLAN > 802.1Q VLAN**
3. **Disable 802.1Q VLAN** toggle
4. Click Apply

### Cable Connections

| Port | Device |
|------|--------|
| 1 | eero Ethernet |
| 2 | Proxmox nic0 |
| 3-5 | Available |

---

## Phase 2: Proxmox Network Configuration

### Step 2.1: Backup Current Config

> **Run on: Proxmox Shell** (via web UI "Shell" button or SSH to 192.168.4.10)

```bash
cp /etc/network/interfaces /etc/network/interfaces.backup
```

### Step 2.2: Configure Network Interfaces

#### Option A: Edit Config File (CLI)

> **Run on: Proxmox Shell**

```bash
nano /etc/network/interfaces
```

Replace with:

```bash
# Loopback
auto lo
iface lo inet loopback

# Production bridge (physical - connects to eero via switch)
auto vmbr0
iface vmbr0 inet static
   address 192.168.4.10/24
   gateway 192.168.4.1
   bridge-ports nic0
   bridge-stp off
   bridge-fd 0

# Lab bridge (internal only - NO physical NIC)
auto vmbr1
iface vmbr1 inet static
   address 10.0.0.1/24
   bridge-ports none
   bridge-stp off
   bridge-fd 0
```

**Note:** Replace `nic0` with your actual interface name. Check with `ip link show`.

#### Option B: Proxmox Web UI (Easier for vmbr1)

If vmbr0 already exists and you just need to create vmbr1:

1. Open Proxmox web UI: `https://192.168.4.10:8006`
2. Navigate to: **Datacenter > pve > Network**
3. Click **Create > Linux Bridge**
4. Configure:
  - **Name:** `vmbr1`
  - **IPv4/CIDR:** `10.0.0.1/24`
  - **Gateway (IPv4):** (leave empty)
  - **IPv6/CIDR:** (leave empty)
  - **Gateway (IPv6):** (leave empty)
  - **Autostart:** unchecked
  - **Bridge ports:** (leave empty - this is what makes it internal-only)
  - **Comment:** `Isolated Lab Network` (optional)
  - **MTU:** `1500` (default)
5. Click **Create**
6. Click **Apply Configuration** at the top of the Network panel

### Step 2.3: Apply Configuration (CLI method)

> **Run on: Proxmox Shell**

```bash
# Validate syntax
ifreload -a --dry-run

# Apply changes
ifreload -a

# Verify bridges
brctl show
```

Expected output:
```
bridge name     bridge id               STP enabled     interfaces
vmbr0           8000.xxxxxxxxxxxx       no              nic0
vmbr1           8000.xxxxxxxxxxxx       no
```

### Step 2.4: Verify Access

From your PC, confirm Proxmox web UI is accessible at `https://192.168.4.10:8006`

---

## Phase 3: NAT & Routing Configuration

This allows lab VMs on vmbr1 to reach the internet through Proxmox.

### Step 3.1: Enable IP Forwarding

> **Run on: Proxmox Shell**

```bash
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -p
```

### Step 3.2: Configure iptables NAT

> **Run on: Proxmox Shell**

```bash
# NAT for lab network
iptables -t nat -A POSTROUTING -s 10.0.0.0/24 -o vmbr0 -j MASQUERADE

# Allow forwarding
iptables -A FORWARD -i vmbr1 -o vmbr0 -j ACCEPT
iptables -A FORWARD -i vmbr0 -o vmbr1 -m state --state RELATED,ESTABLISHED -j ACCEPT
```

### Step 3.3: Make Persistent

> **Run on: Proxmox Shell**

```bash
apt install iptables-persistent -y
netfilter-persistent save
```

### Step 3.4: Verify NAT

> **Run on: Proxmox Shell**

```bash
iptables -t nat -L -n
```

Should show MASQUERADE rule for 10.0.0.0/24.

---

## Phase 4: Lab VM Setup

### Create SIEM VM on vmbr1 (e.g., Splunk)

1. In Proxmox, create new VM
2. **Network**: Select `vmbr1`
3. After OS install, configure static IP:

> **Run on: Lab VM (Ubuntu)**

```yaml
# /etc/netplan/00-installer-config.yaml
network:
 version: 2
 ethernets:
   ens18:
     addresses:
       - 10.0.0.10/24
     gateway4: 10.0.0.1
     nameservers:
       addresses:
         - 8.8.8.8
         - 8.8.4.4
```

> **Run on: Lab VM (Ubuntu)**

```bash
sudo netplan apply
```

### Verify Lab VM Connectivity

> **Run on: Lab VM (e.g., SIEM/Splunk VM)**

```bash
ping 10.0.0.1      # Proxmox gateway - should work
ping 8.8.8.8       # Internet via NAT - should work
ping 192.168.4.1   # Production network - should FAIL (isolated)
```

---

## Phase 5: Kali VirtualBox Configuration

Kali runs in VirtualBox on your PC, bridged to WiFi.

### Step 5.1: VirtualBox Network Settings

1. Open VirtualBox, select Kali VM
2. **Settings > Network > Adapter 1**
3. Attached to: **Bridged Adapter**
4. Name: Select your **WiFi adapter**

### Step 5.2: Verify Kali IP

Start Kali and confirm it gets an IP from eero:

> **Run on: Kali VM**

```bash
ip addr show eth0
# Should show 192.168.4.x
```

### Step 5.3: Add Static Route to Lab Network

> **Run on: Kali VM**

**Temporary (until reboot):**
```bash
sudo ip route add 10.0.0.0/24 via 192.168.4.10
```

**Permanent (Debian/Kali):**

Edit `/etc/network/interfaces`:
```bash
auto eth0
iface eth0 inet dhcp
   post-up ip route add 10.0.0.0/24 via 192.168.4.10
```

Or create `/etc/network/if-up.d/lab-route`:
```bash
#!/bin/sh
ip route add 10.0.0.0/24 via 192.168.4.10
```

> **Run on: Kali VM**

```bash
chmod +x /etc/network/if-up.d/lab-route
```

### Step 5.4: Test Kali to Lab Connectivity

> **Run on: Kali VM**

```bash
ping 10.0.0.10    # SIEM server - should work
ping 10.0.0.20    # VulnHub target - should work
```

---

## Verification Checklist

### Network Connectivity
- [ ] Proxmox web UI accessible from PC at 192.168.4.10:8006
- [ ] OMV accessible at 192.168.4.x
- [ ] Jellyfin accessible via reverse proxy

### Lab Isolation
- [ ] Lab VM (10.0.0.x) can ping 10.0.0.1 (Proxmox)
- [ ] Lab VM can ping 8.8.8.8 (internet via NAT)
- [ ] Lab VM CANNOT ping 192.168.4.x (production isolated)

### Attack Lab Ready
- [ ] Kali can ping 10.0.0.10 (SIEM server)
- [ ] Kali can ping VulnHub targets
- [ ] Kali has internet for tool updates

---

## Quick Reference

### IP Addressing

| Device | IP Address | Network |
|--------|------------|---------|
| eero Gateway | 192.168.4.1 | Production |
| Proxmox Host | 192.168.4.10 | Production |
| Proxmox Lab Gateway | 10.0.0.1 | Lab |
| SIEM VM | 10.0.0.10 | Lab |
| VulnHub Target | 10.0.0.20+ | Lab |

### Proxmox Bridges

| Bridge | Purpose | Has Physical NIC? |
|--------|---------|-------------------|
| vmbr0 | Production | Yes (nic0) |
| vmbr1 | Lab (isolated) | No |

### When Creating Lab VMs

- **Network bridge**: Always use `vmbr1`
- **IP range**: 10.0.0.x/24
- **Gateway**: 10.0.0.1
- **DNS**: 8.8.8.8

---

## Troubleshooting

### Lab VM can't reach internet

1. Check IP forwarding:

  > **Run on: Proxmox Shell**

  ```bash
  cat /proc/sys/net/ipv4/ip_forward
  # Should output: 1
  ```

2. Check iptables NAT:

  > **Run on: Proxmox Shell**

  ```bash
  iptables -t nat -L POSTROUTING -n
  # Should show MASQUERADE for 10.0.0.0/24
  ```

3. Check VM gateway is 10.0.0.1 (on the Lab VM)

### Kali can't reach lab VMs

1. Check route exists:

  > **Run on: Kali VM**

  ```bash
  ip route | grep 10.0.0.0
  # Should show: 10.0.0.0/24 via 192.168.4.10
  ```

2. Check Proxmox is reachable:

  > **Run on: Kali VM**

  ```bash
  ping 192.168.4.10
  ```

3. Verify iptables allows forwarding on Proxmox (see Phase 3.2)

### nic0 Link Flapping

If Proxmox nic0 shows intermittent "Link is Down/Up" in dmesg:
- Try different Ethernet cable
- Try different switch port
- See main `TROUBLESHOOTING.md` for detailed workarounds

---

## Future Expansion

| Lab | Network Changes Needed |
|-----|------------------------|
| SIEM (Splunk/Wazuh) | None - use vmbr1 as-is |
| Active Directory | Add DC + client VMs to vmbr1 |
| Vulnerability Scanning | Add scanner VM to vmbr1 |
| IDS/IPS (Lab 4) | Add pfSense between vmbr1 and NAT |

---

*Network Foundation Lab - Homelab Security Project*
*Last Updated: 2026-02-02*
