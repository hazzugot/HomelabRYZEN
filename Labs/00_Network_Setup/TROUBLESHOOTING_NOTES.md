# Network Troubleshooting Notes - 2026-01-30

## Problem Summary
Proxmox server (192.168.4.10) has intermittent connectivity from wired PC. Link keeps flapping (going up/down).

## Environment
- **Proxmox IP:** 192.168.4.10
- **Proxmox NIC:** nic0 (MAC: 30:56:0f:40:10:25) - Motherboard 2.5GbE
- **Switch:** TP-Link TL-SG105E (Gigabit)
- **Gateway:** eero at 192.168.4.1
- **PC:** Connected to switch Port 3, gets IP via DHCP (192.168.5.x range, /22 subnet)

## Symptoms
- `dmesg` on Proxmox shows repeated link flapping:
  ```
  nic0: Link is Down
  nic0: Link is Up - 1Gbps/Full - flow control off
  ```
- Happens every few minutes
- PC loses connectivity to Proxmox when link drops
- Other devices (eero, Hue bulbs) reachable fine

## Attempted Fixes (Did Not Work)
1. Disabled EEE on Proxmox: `ethtool --set-eee nic0 eee off`
2. Forced 1Gbps speed: `ethtool -s nic0 speed 1000 duplex full autoneg off`
3. Disabled Windows firewall
4. Static ARP entry on Windows (workaround only)

## Working Workaround
Static ARP entry on Windows PC:
```powershell
netsh interface ip add neighbors "Ethernet 3" 192.168.4.10 30-56-0f-40-10-25
```
Script saved at: `F:\Homelab\Scripts\add-proxmox-arp.ps1`

## Key Discovery
**Proxmox works fine over WiFi when PC is unplugged from switch Port 3!**

This suggests the switch is the problem - possibly:
- Switch can't handle multiple active ports (power/hardware issue)
- STP is causing port blocking
- Port 3 is faulty and affecting other ports
- Switch needs factory reset

## Next Steps to Try
1. **Disable STP** on the switch (Switching > STP > Disable)
2. **Factory reset the switch** and reconfigure
3. **Try PC on Port 4** instead of Port 3
4. **Replace Ethernet cable** between Proxmox (nic0) and switch Port 1
5. **Test direct to eero** - bypass switch entirely to isolate the problem
6. **If still flapping** - consider replacing the TL-SG105E switch
7. **Workaround:** Keep PC on WiFi, only use switch for Proxmox

## Useful Commands

### On Proxmox
```bash
# Watch link status in real-time
dmesg -w | grep -i "link"

# Check link status
ethtool nic0 | grep -i "link detected"

# Check EEE status
ethtool --show-eee nic0

# Force 1Gbps
ethtool -s nic0 speed 1000 duplex full autoneg off
```

### On Windows PC
```powershell
# Check ARP table
arp -a | findstr 192.168.4

# Add static ARP
netsh interface ip add neighbors "Ethernet 3" 192.168.4.10 30-56-0f-40-10-25

# Continuous ping
ping -t 192.168.4.10
```

## Physical Setup
| Port | Device | Status |
|------|--------|--------|
| 1 | Proxmox nic0 (Trunk) | FLAPPING |
| 2 | Proxmox nic1 (VLAN 20) | Not tested |
| 3 | Main PC | Working |
| 4 | Reserved | Available for testing |
| 5 | eero Uplink | Working |
