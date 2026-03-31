# Lab 00C: OPNsense Firewall - Troubleshooting Guide

Issues encountered during deployment with diagnosis and resolution steps.

---

## Proxmox Cluster Quorum Blocked

**Symptom:** All VM operations frozen. `pvecm status` shows `Quorate: No` and `Activity blocked`.

**Cause:** Server relocated without second cluster node (Dell T3300) or Qdevice (Raspberry Pi). Cluster requires majority vote to operate - single node out of two cannot achieve quorum.

**Resolution:**
```bash
# Check current state
pvecm status

# Edit corosync config
nano /etc/corosync/corosync.conf
# Remove the qdevice { } section entirely

# Force expected votes to 1
corosync-quorumtool -e 1

# Add two_node directive under quorum { }
# two_node: 1
# expected_votes: 1

# Verify
pvecm status
# Should show: Quorate: Yes
```

**Prevention:** Before relocating a clustered node, either:
- Bring all nodes and the Qdevice to the new location
- Pre-configure single-node quorum before disconnecting

---

## pfSense CE Installation Blocked

**Symptom:** pfSense installer requires Netgate account registration during setup. Cannot proceed without internet connectivity and account verification.

**Cause:** pfSense CE now mandates online registration as part of the installation process. This blocks offline installs, virtualised installs without WAN during setup, and air-gapped environments.

**Resolution:** Use OPNsense instead. OPNsense 26.1.2 DVD ISO installs without any external connectivity or registration requirements.

**OPNsense install notes:**
- First boot credentials: `installer` / `opnsense`
- Use ZFS installer if UFS partition destroy fails
- Must use OVMF (UEFI) BIOS in Proxmox - SeaBIOS hangs

---

## OPNsense Boot Hangs on SeaBIOS

**Symptom:** OPNsense VM hangs during boot with no output or a blinking cursor.

**Cause:** OPNsense requires UEFI boot. SeaBIOS is not supported.

**Resolution:**
1. Shut down the VM
2. Proxmox > VM > Hardware > BIOS
3. Change from `SeaBIOS` to `OVMF (UEFI)`
4. Add an EFI disk if prompted
5. Start VM

**Note:** Home Assistant OS has the same requirement - always use OVMF.

---

## PPPoE Authentication Silently Fails (KCOM)

**Symptom:** WAN physical link is up, OPNsense shows PPPoE attempting to connect, but no session is established. No error messages in logs. WAN interface shows "no carrier" or "down" at the PPPoE level.

**Cause:** KCOM FTTP requires PPPoE to run over VLAN 101. Without the VLAN tag, the KCOM network ignores PPPoE initiation packets.

**Diagnosis:**
```bash
# On OPNsense shell - monitor PPPoE negotiation
tcpdump -i vtnet0 -n pppoe
# You'll see PADI packets being sent repeatedly with no PADO response

# On the correct VLAN interface:
tcpdump -i vtnet0.101 -n pppoe
# After fix: PADI → PADO → PADR → PADS (successful negotiation)
```

**Resolution:**
1. Interfaces > Other Types > VLAN
2. Create VLAN: parent `vtnet0`, tag `101`
3. Interfaces > Other Types > PPP > Devices
4. Set link interface to the VLAN interface (`vtnet0.101`), **not** the raw physical (`vtnet0`)
5. Enter KCOM credentials (format: `kcoma[account]w[suffix]`)
6. Assign WAN to the PPPoE device

**Key Insight:** The failure mode is completely silent. The physical link is up, PPPoE sends initiation packets, but the ISP's DSLAM/OLT won't respond without the VLAN 101 tag. Only identifiable through packet capture.

---

## Kea DHCP Not Responding on VLAN Subinterfaces

**Symptom:** Devices on VLAN 40 (IoT) send DHCP Discover but never receive an Offer. Devices stuck on APIPA (169.254.x.x) addresses.

**Cause:** Kea DHCP does not respond to DHCP requests arriving on VLAN subinterfaces in OPNsense. This appears to be a Kea limitation with VLAN-tagged interfaces.

**Diagnosis:**
```bash
# On OPNsense shell
tcpdump -i vlan0.40 port 67 or port 68
# Output shows DHCP Discover packets arriving
# But no DHCP Offer in response from Kea
```

**Resolution:** Switch from Kea to Dnsmasq:
1. Services > Kea DHCP > Disable
2. Services > Dnsmasq DNS > Settings > Enable
3. Services > Dnsmasq DNS > Settings > DHCP > Enable
4. Configure DHCP ranges for each interface (LAN and IoT)
5. Restart Dnsmasq service

Dnsmasq responds to DHCP requests on VLAN subinterfaces immediately with no additional configuration.

**Verification:**
```bash
tcpdump -i vlan0.40 port 67 or port 68
# Should now show full DORA handshake:
# Discover → Offer → Request → Ack
```

---

## VLAN Traffic Not Reaching OPNsense

**Symptom:** Devices on VLAN 40 have no connectivity. Switch shows VLAN configured correctly, but OPNsense doesn't see any traffic on the VLAN interface.

**Cause:** The Proxmox bridge carrying LAN traffic (vmbr2) is not set to VLAN aware. Without this, Proxmox drops 802.1Q tagged frames at the bridge level - silently, with no log entry.

**Resolution:**
1. Proxmox > server01 > Network
2. Edit `vmbr2`
3. Check **VLAN aware** checkbox
4. Apply Configuration

**Note:** Only the LAN bridge (vmbr2) needs VLAN awareness. The WAN bridge (vmbr1) does not - VLAN 101 tagging is handled inside OPNsense on the virtual interface, not at the bridge level.

**Verification:**
```bash
# On Proxmox host
bridge vlan show dev vmbr2
# Should show VLAN entries if VLAN aware is enabled
```

---

## IoT Devices Can Reach LAN Despite Firewall Rules

**Symptom:** IoT devices (192.168.40.x) can ping or access LAN devices (192.168.4.x) despite block rules being configured.

**Cause:** Firewall rules are in the wrong order. OPNsense evaluates rules top-to-bottom, first match wins. If the `Pass IoT → any` rule is above the `Block IoT → LAN` rule, all traffic matches the pass rule first.

**Resolution:** Reorder rules on the IoT interface:

| Order | Action | Source | Destination |
|-------|--------|--------|-------------|
| 1 | **Block** | IoT net | LAN net |
| 2 | **Block** | IoT net | 192.168.4.0/24 |
| 3 | **Pass** | IoT net | any |

Use the drag handles in OPNsense Firewall > Rules > IoT to reorder, then Apply Changes.

---

## Home Assistant OS Won't Boot in Proxmox

**Symptom:** HAOS VM shows black screen or hangs at boot after importing the qcow2 disk.

**Cause (likely):**
1. SeaBIOS selected instead of OVMF (UEFI)
2. No EFI disk added
3. Boot order not set to the imported disk

**Resolution:**
1. Ensure BIOS is set to **OVMF (UEFI)**
2. Add an EFI disk (Hardware > Add > EFI Disk)
3. After importing disk via `qm importdisk`, go to Hardware and:
   - Double-click the unused disk → Add
   - Set as VirtIO Block
4. Options > Boot Order → set imported disk as first boot device
5. Remove any CD/DVD drives from boot order

---

## UFS Partition Destroy Failure During OPNsense Install

**Symptom:** OPNsense installer fails when trying to use UFS filesystem - cannot destroy existing partitions.

**Cause:** Pre-existing partition table on the virtual disk conflicts with UFS installer.

**Resolution:** Select ZFS as the filesystem during OPNsense installation instead of UFS. ZFS handles disk initialisation more reliably and offers additional features (snapshots, compression).

---

## Switch Port Not Passing VLAN Traffic

**Symptom:** Device connected to a specific switch port doesn't get DHCP or connectivity on the expected VLAN.

**Diagnosis Checklist:**
1. **Check port VLAN membership** - Netgear GUI > VLAN > 802.1Q > VLAN Membership
   - Trunk ports (e.g., g2): VLANs should be **Tagged**
   - Access ports (e.g., g6): VLAN should be **Untagged**

2. **Check PVID** - Netgear GUI > VLAN > 802.1Q > Port PVID Configuration
   - Access ports must have PVID matching their VLAN (e.g., g6 PVID = 40)
   - Trunk ports typically PVID = 1 (native)

3. **Check the device** - IoT devices (Eero in bridge mode) must be connected to the correct port

**Common Mistake:** Setting a VLAN as Tagged on an access port. End devices don't understand VLAN tags - access ports must be Untagged with the correct PVID.

---

## DNS Resolution Failing

**Symptom:** Devices can ping IP addresses (8.8.8.8) but cannot resolve domain names.

**Resolution:**
1. Check Unbound is running: Services > Unbound DNS > General > Enable
2. Verify Dnsmasq is not conflicting on port 53
3. Ensure DHCP is handing out `192.168.4.1` (or `192.168.40.1` for IoT) as the DNS server
4. Test from OPNsense shell:
   ```bash
   drill google.com @127.0.0.1
   # Should return A record
   ```

If using both Unbound and Dnsmasq:
- Unbound handles DNS resolution (port 53)
- Dnsmasq handles DHCP only (not DNS, or on a different port)
- Check for port conflicts in Services > Diagnostics > Ports

---

## Useful Diagnostic Commands

### OPNsense Shell

```bash
# Check all interface status
ifconfig -a

# Monitor PPPoE session
ifconfig pppoe0

# Watch firewall logs in real time
clog /var/log/filter.log | tail -f

# Monitor DHCP on specific VLAN
tcpdump -i vlan0.40 port 67 or port 68

# Check routing table
netstat -rn

# Test DNS resolution
drill google.com @127.0.0.1

# Monitor all traffic on an interface
tcpdump -i vtnet1 -n
```

### Proxmox Shell

```bash
# Check cluster status
pvecm status

# View bridge configuration
brctl show
bridge vlan show

# Check NIC link state
ip link show

# View network config
cat /etc/network/interfaces

# Monitor traffic on bridge
tcpdump -i vmbr2 -e -c 20 vlan
```

### Netgear Switch

- Management GUI: `http://192.168.4.250` (or configured IP)
- VLAN config: Switching > VLAN > 802.1Q
- Port status: Monitoring > Port Statistics

---

*Troubleshooting reference for Lab 00C - OPNsense Firewall Deployment*
*Last Updated: 2026-03-31*
