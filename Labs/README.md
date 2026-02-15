# Security Lab Roadmap

Building toward a complete Mini SOC environment. Each lab builds progressively, adding new tools, attack techniques, and MITRE ATT&CK coverage.

**Total Coverage:** 40+ MITRE ATT&CK techniques | 6 BTL1 exam domains | 7 integrated labs

---

## Lab Overview

```
Lab 00A  Network Foundation ─────────────────────────────────────┐
Lab 00B  VLAN Segmentation (GS510TLP) ──────────────────────────┤
Lab 01   Splunk SIEM ── 4 attacks ── Dashboard ── Detections ───┤
Lab 02   Active Directory ── 5 attacks ── WEF ── Kerberoasting ─┤ ──▶ Mini SOC
Lab 03   Phishing Analysis ── Triage ── GoPhish ────────────────┤    (Lab 06)
Lab 04   SOAR ── BloodHound ── AS-REP Roast ── Playbooks ──────┤
Lab 05   EDR ── DCSync ── Pass-the-Hash ── Lateral Movement ───┘
```

---

## Infrastructure

### Lab 00A: Network Foundation
![Progress](https://img.shields.io/badge/Progress-100%25-brightgreen?style=flat-square)

Proxmox bridge configuration with isolated lab network using iptables NAT. Foundation for all security labs.

| Component | Status |
|-----------|--------|
| vmbr0 Production Bridge (192.168.4.0/24) | Complete |
| vmbr1 Isolated Lab Bridge (10.0.0.0/24) | Complete |
| iptables NAT for Lab Internet Access | Complete |
| Kali Static Route Configuration | Complete |

---

### Lab 00B: Network Enhancement with VLAN Segmentation
![Progress](https://img.shields.io/badge/Progress-0%25-red?style=flat-square)

Upgrade from basic Proxmox bridges to enterprise-style 802.1Q VLAN segmentation using a Netgear GS510TLP managed switch. Replaces the TP-Link TL-SG105E and establishes the VLAN infrastructure used by all subsequent labs.

| Component | Status |
|-----------|--------|
| GS510TLP VLAN Configuration (4 VLANs) | Not Started |
| Proxmox VLAN-Aware Bridging | Not Started |
| Inter-VLAN Routing via iptables | Not Started |
| Splunk VM Migration to VLAN 30 | Not Started |
| TL-SG105E Retirement | Not Started |
| Kali Multi-VLAN Access | Not Started |

**VLANs:** MGMT (1) · AD Servers (10) · AD Workstations (20) · Security Tools (30)

---

## Priority Labs

### 1. SIEM Deployment with Splunk
![Progress](https://img.shields.io/badge/Progress-100%25-brightgreen?style=flat-square)

Deployed Splunk Enterprise as a centralized SIEM with Windows endpoint telemetry (Sysmon + Security Events), attack simulation from Kali Linux, and custom detection rules mapped to MITRE ATT&CK.

| Component | Status |
|-----------|--------|
| Splunk Enterprise on Ubuntu 22.04 | Complete |
| Windows Victim VM + Sysmon | Complete |
| Splunk Universal Forwarder | Complete |
| Attack Simulation (4 scenarios) | Complete |
| SOC Dashboard (6 panels) | Complete |
| Detection Rules (4 saved reports) | Complete |
| MITRE ATT&CK Mapping | Complete |

**Attacks:** Network Recon · RDP Brute Force · PowerShell Download Cradle · Mimikatz LSASS Dump
**Results:** 100% detection rate · <2 min MTTD · 4 MITRE techniques mapped

---

### 2. Active Directory Security Fundamentals
![Progress](https://img.shields.io/badge/Progress-0%25-red?style=flat-square)

Build an enterprise Active Directory environment with VLAN-segmented infrastructure, Windows Event Forwarding to Splunk, and detection of core AD attack techniques. Advanced attacks (DCSync, Pass-the-Hash, Golden Ticket) are reserved for later labs where EDR and SOAR provide proper detection capabilities.

| Component | Status |
|-----------|--------|
| Windows Server 2022 Domain Controller | Not Started |
| OU Structure, Users & Groups (6 accounts) | Not Started |
| Group Policy (Audit, PowerShell Logging) | Not Started |
| Domain Join 2 Workstations | Not Started |
| Windows Event Forwarding (WEF) to Splunk | Not Started |
| Splunk Integration (3 new indexes) | Not Started |
| Attack Simulation (5 scenarios) | Not Started |
| SPL Detection Rules (10 queries) | Not Started |
| AD Security Dashboard | Not Started |

**Attacks:** AD Enumeration · Password Spray · PowerShell Execution · Kerberoasting · Mimikatz LSASS Dump
**Target:** 10 MITRE ATT&CK techniques · 100% detection rate

---

### 3. Phishing Analysis
![Progress](https://img.shields.io/badge/Progress-0%25-red?style=flat-square)

Static phishing email analysis and triage workflow exercise. Directly addresses the BTL1 Phishing Analysis domain (15% of exam). Optional GoPhish campaign simulation integrated with Splunk.

| Component | Status |
|-----------|--------|
| Phishing Sample Collection | Not Started |
| Header Analysis & IOC Extraction | Not Started |
| SPF/DKIM/DMARC Validation | Not Started |
| Triage Decision Workflow | Not Started |
| GoPhish Campaign Simulation (Optional) | Not Started |
| Phishing Triage Playbook | Not Started |

---

### 4. SOAR Automation
![Progress](https://img.shields.io/badge/Progress-0%25-red?style=flat-square)

Deploy Shuffle SOAR integrated with Splunk for automated incident response. Includes intermediate AD attacks that generate alerts suitable for orchestrated response playbooks.

| Component | Status |
|-----------|--------|
| Shuffle SOAR Deployment | Not Started |
| Splunk Alert Integration | Not Started |
| Attack: AS-REP Roasting | Not Started |
| Attack: BloodHound AD Enumeration | Not Started |
| Attack: PowerShell Persistence | Not Started |
| Playbook: Auto-Block Source IP | Not Started |
| Playbook: Alert Triage & Notification | Not Started |
| Playbook: Account Lockdown | Not Started |
| Atomic Red Team Integration | Not Started |

---

### 5. EDR + SOAR Integration
![Progress](https://img.shields.io/badge/Progress-0%25-red?style=flat-square)

Deploy LimaCharlie EDR with Tines SOAR for advanced endpoint detection. Covers credential theft and lateral movement attacks that require endpoint-level visibility beyond what SIEM alone can provide.

| Component | Status |
|-----------|--------|
| LimaCharlie EDR Deployment | Not Started |
| Agent Installation on AD Endpoints | Not Started |
| Tines SOAR Integration | Not Started |
| Attack: DCSync Domain Replication | Not Started |
| Attack: Pass-the-Hash Lateral Movement | Not Started |
| Attack: Advanced Mimikatz (Tickets, SAM) | Not Started |
| EDR Detection Rules | Not Started |
| Automated Response: Host Isolation | Not Started |
| Automated Response: Forensic Collection | Not Started |

---

### 6. Mini SOC (Capstone)
![Progress](https://img.shields.io/badge/Progress-0%25-red?style=flat-square)

Integration project combining all previous labs into a functional SOC environment. Full APT attack simulation from initial access through persistence and exfiltration, with multi-tool detection and professional incident response documentation.

| Component | Status |
|-----------|--------|
| Architecture Design & Data Flow Diagram | Not Started |
| Full APT Attack Chain Simulation | Not Started |
| Golden Ticket Persistence Attack | Not Started |
| DNS Tunneling Exfiltration | Not Started |
| IDS Integration (Suricata) | Not Started |
| Multi-Tool Detection Correlation | Not Started |
| MITRE ATT&CK Navigator Layer | Not Started |
| Incident Report #1 (Full Format) | Not Started |
| Incident Report #2 (Full Format) | Not Started |
| Synthesis Document | Not Started |

---

## BTL1 Certification Alignment

Each lab progressively builds toward full [Blue Team Level 1](https://www.securityblue.team/certifications/blue-team-level-1) exam domain coverage:

| BTL1 Domain (Weight) | Lab 01 | Lab 02 | Lab 03 | Lab 04 | Lab 05 | Lab 06 |
|----------------------|:------:|:------:|:------:|:------:|:------:|:------:|
| Security Fundamentals (15%) | Partial | Partial | - | - | - | Full |
| Phishing Analysis (15%) | - | - | **Full** | - | - | Full |
| Threat Intelligence (15%) | Partial | **Full** | Partial | Full | Full | Full |
| Digital Forensics (20%) | Partial | **Full** | - | Partial | Full | Full |
| SIEM (20%) | **Full** | **Full** | - | Full | Full | Full |
| Incident Response (15%) | Partial | Partial | Partial | **Full** | Full | Full |

---

## Additional Labs (Backlog)

| Lab | Description | Progress |
|-----|-------------|----------|
| IDS/IPS (Suricata) | Network intrusion detection with custom rules | ![0%](https://img.shields.io/badge/-0%25-red?style=flat-square) |
| Network Monitoring (Zeek) | Protocol analysis and traffic logging | ![0%](https://img.shields.io/badge/-0%25-red?style=flat-square) |
| Vulnerability Scanner | OpenVAS or Nessus for vulnerability assessment | ![0%](https://img.shields.io/badge/-0%25-red?style=flat-square) |
| Honeypot (T-Pot) | Capture attacker TTPs in controlled environment | ![0%](https://img.shields.io/badge/-0%25-red?style=flat-square) |

---

## Completed Labs

| Lab | Write-up | Completed |
|-----|----------|-----------|
| Lab 00A: Network Foundation | [Network Setup Guide](./00_Network_Setup/README.md) | Jan 2026 |
| Lab 01: SIEM Deployment | [Splunk SIEM Write-up](./01_Splunk_SIEM_Lab/GITHUB_WRITEUP.md) | Jan 2026 |
