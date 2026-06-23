# Ethical Hacking Course Docker Labs

<!-- BADGES:START -->
[![cybersecurity](https://img.shields.io/badge/-cybersecurity-f44336?style=flat-square)](https://github.com/topics/cybersecurity) [![docker](https://img.shields.io/badge/-docker-2496ed?style=flat-square)](https://github.com/topics/docker) [![docker-compose](https://img.shields.io/badge/-docker--compose-blue?style=flat-square)](https://github.com/topics/docker-compose) [![edtech](https://img.shields.io/badge/-edtech-4caf50?style=flat-square)](https://github.com/topics/edtech) [![educational](https://img.shields.io/badge/-educational-blue?style=flat-square)](https://github.com/topics/educational) [![ethical-hacking](https://img.shields.io/badge/-ethical--hacking-blue?style=flat-square)](https://github.com/topics/ethical-hacking) [![kali-linux](https://img.shields.io/badge/-kali--linux-blue?style=flat-square)](https://github.com/topics/kali-linux) [![penetration-testing](https://img.shields.io/badge/-penetration--testing-blue?style=flat-square)](https://github.com/topics/penetration-testing) [![security-training](https://img.shields.io/badge/-security--training-blue?style=flat-square)](https://github.com/topics/security-training) [![vulnerability-assessment](https://img.shields.io/badge/-vulnerability--assessment-blue?style=flat-square)](https://github.com/topics/vulnerability-assessment)
<!-- BADGES:END -->

Docker-based lab environment for a 12-week ethical hacking course (CYB204) at ADCI. Each week runs as an isolated Docker Compose stack — either with a built-in Kali Linux attacker container, or exposing ports so you can attack from your own Kali VM.

---

## Prerequisites

| Tool | Min Version | Install |
|------|-------------|---------|
| Docker Desktop (macOS/Windows) or Docker Engine (Linux) | 24.x | https://docs.docker.com/get-docker/ |
| Docker Compose | v2.x | Bundled with Docker Desktop |
| Git | Any | https://git-scm.com/ |
| Make | Any | macOS: `xcode-select --install` · Linux: `sudo apt install make` · Windows: Git Bash or WSL2 |

**Recommended:** 8 GB RAM, 20 GB free disk.

> **Windows users** — run all commands in **WSL2** (Ubuntu) or **Git Bash**.

---

## Installation

### 1. Clone the repository

```bash
git clone https://github.com/moktan456/ethical-hacking-docker-labs.git
cd ethical-hacking-docker-labs
```

### 2. Build the shared Kali attacker image

All labs share one base image (`ethical-base`) built from `base.Dockerfile` — Kali Linux Rolling with tools pre-installed:

`nmap` · `hydra` · `medusa` · `john` · `hashcat` · `wireshark` · `gobuster` · `nikto` · `sqlmap` · `dirb` · `netcat` · `telnet` · `curl` · `wget` · `python3` · `rockyou wordlist`

**Build once before running any weekly lab:**

```bash
make build-base
```

Verify:
```bash
docker images | grep ethical-base
```

---

## Two Ways to Attack

### Mode A — All-Docker (default)

The built-in Kali attacker container and all targets spin up together.  
**Recommended for students who do not have a separate Kali VM.**

```bash
make run-week4          # start week 4 (attacker + targets)
docker exec -it week4-attacker bash   # enter the attacker
```

### Mode B — Kali VM (bring your own Kali)

Target containers only are started, with their service ports exposed to your host machine.  
Your Kali VM connects to the targets via the host's IP address.  
**Use this if you already have a running Kali VM, or when practising on VulnHub machines.**

```bash
make run-week4-kali     # start week 4 targets only, ports exposed to host
```

Then from your Kali VM, find the host machine's IP and attack:

```bash
# From inside your Kali VM — find the Docker host IP:
ip route show default      # look for the gateway address (e.g. 10.0.2.2 for VirtualBox NAT)
# or
arp -n                     # lists hosts your VM has talked to recently
```

Common host IPs by hypervisor:

| Hypervisor | Network Mode | Typical Host IP |
|------------|-------------|-----------------|
| VirtualBox | NAT (default) | `10.0.2.2` |
| VirtualBox | Host-only | `192.168.56.1` |
| VMware Workstation/Fusion | NAT | `192.168.x.2` (check `ip route`) |
| Parallels | Shared | `10.211.55.1` |

Once you have the host IP, use it in place of the container IPs in all exercises:
```bash
nmap -sV HOST_IP -p 4020-4023   # scan week 4 targets via exposed ports
ftp HOST_IP 4021                  # connect to week 4 FTP
ssh -p 4022 sysadmin@HOST_IP      # connect to week 4 SSH
```

---

## Network Architecture

All lab weeks use the `10.10.WEEK.0/24` subnet scheme — the week number is always visible in the IP address. The attacker is always `.2`, targets start at `.10`.

| Week | Subnet | Attacker | Targets |
|------|--------|----------|---------|
| 1 | 10.10.1.0/24 | 10.10.1.2 (week1-attacker) | 10.10.1.2 proxy · 10.10.1.5 secutils |
| 3 | 10.10.3.0/24 | 10.10.3.2 (wireshark) | 10.10.3.10 sample-target |
| 4 | 10.10.4.0/24 | 10.10.4.2 (week4-attacker) | 10.10.4.10 web · .11 ftp · .12 ssh |
| 5 | 10.10.5.0/24 | 10.10.5.2 (week5-attacker) | 10.10.5.10 ldap · .11 mysql · .12 smb |
| 6 | 10.10.6.0/24 | 10.10.6.2 (password-cracking-lab) | 10.10.6.10 ssh-target · .11 web-target |
| 7 | 10.10.7.0/24 | 10.10.7.13 (week7-attacker) | 10.10.7.7 ldap · .9 mysql · .10 telnet · .11 juice-shop · .12 dvwa |
| 8 | 10.10.8.0/24 | 10.10.8.2 (de-ice-attacker) | 10.10.8.10 web · .11 ssh · .12 ftp |
| 9 (ext) | 10.10.9.0/24 | 10.10.9.2 (week9-attacker) | 10.10.9.10 pivot-host |
| 9 (int) | 10.10.90.0/24 | — (internal only) | 10.10.90.20 internal-web · .21 internal-db |
| 10 | 10.10.10.0/24 | 10.10.10.2 (week10-attacker) | 10.10.10.10 web-recon · .11 vuln-target |

> **Week 9 internal network** has `internal: true` — it has no internet access and is unreachable without pivoting through `10.10.9.10`. Even in Kali VM mode, the internal targets are not exposed to the host; you must pivot through the SSH port forward.

---

## Port Reference (Kali VM Mode)

When using `make run-weekN-kali`, targets are accessible from your Kali VM at `HOST_IP:<port>`:

| Week | Service | Host Port | Maps To |
|------|---------|-----------|---------|
| 4 | HTTP (Nginx) | 4080 | 10.10.4.10:80 |
| 4 | FTP (vsftpd) | 4021 | 10.10.4.11:21 |
| 4 | SSH (OpenSSH) | 4022 | 10.10.4.12:22 |
| 5 | LDAP | 5389 | 10.10.5.10:389 |
| 5 | MySQL | 5306 | 10.10.5.11:3306 |
| 5 | SMB | 5445 | 10.10.5.12:445 |
| 6 | SSH | 6022 | 10.10.6.10:22 |
| 6 | Web login | 8080 | 10.10.6.11:80 |
| 7 | DVWA | 7085 | 10.10.7.12:80 |
| 7 | Juice Shop | 7012 | 10.10.7.11:3000 |
| 7 | MySQL | 7306 | 10.10.7.9:3306 |
| 7 | Telnet | 7023 | 10.10.7.10:23 |
| 7 | LDAP | 7389 | 10.10.7.7:389 |
| 8 | HTTP | 80 | 10.10.8.10:80 |
| 8 | SSH | 2222 | 10.10.8.11:22 |
| 8 | FTP | 21 | 10.10.8.12:21 |
| 9 | SSH (pivot) | 9022 | 10.10.9.10:22 |
| 10 | Recon web | 10080 | 10.10.10.10:80 |
| 10 | SSH (lowpriv) | 10022 | 10.10.10.11:22 |
| 10 | Vuln service | 10999 | 10.10.10.11:9999 |

---

## Week-by-Week Reference

| Week | Topic | Docker mode entry | Kali VM mode |
|------|--------|-------------------|--------------|
| 1 | Docker Environment Setup | `docker exec -it week1-attacker bash` | N/A |
| 2 | Ethics & Legal Issues | Discussion only — see `labs/week2/README.md` | — |
| 3 | Scope & Proposal Development | Wireshark GUI → `http://localhost:3000` | N/A |
| 4 | Reconnaissance & Nmap | `docker exec -it week4-attacker bash` | `make run-week4-kali` |
| 5 | System & Network Enumeration | `docker exec -it week5-attacker bash` | `make run-week5-kali` |
| 6 | Password Cracking | `docker exec -it password-cracking-lab bash` | `make run-week6-kali` |
| 7 | Web Application Vulnerabilities | `docker exec -it week7-attacker bash` | `make run-week7-kali` |
| 8 | Privilege Escalation (De-ICE) | `docker exec -it de-ice-attacker bash` | `make run-week8-kali` |
| 9 | Lateral Movement & Pivoting | `docker exec -it week9-attacker bash` | `make run-week9-kali` |
| 10 | Exploit Development (BOF) | `docker exec -it week10-attacker bash` | `make run-week10-kali` |
| 11 | Physical Access Controls | Discussion only — see `labs/week11/README.md` | — |
| 12 | Social Engineering | Discussion only — see `labs/week12/README.md` | — |

Each week's folder contains: `README.md` · `worksheet.md` · `docker-compose.yaml` · `docker-compose.kali.yaml` · `ctf-challenge.md` · `ctf-walkthrough.md`

---

## VulnHub Practice Machines

Each lab week's `README.md` lists two relevant VulnHub machines for additional practice.  
All recommended machines are **Easy or Medium** difficulty and align to that week's skills.

For VulnHub machines, use your **Kali VM** directly — download the `.ova`, import into VirtualBox or VMware, set the network adapter to **Host-only** or **NAT Network** (same as your Kali VM), then attack from Kali.

---

## Optional CTF Challenges

Each lab week includes an optional Capture The Flag challenge. Two flags are hidden in the existing containers:

- `user.txt` — earned via initial access / enumeration  
- `root.txt` — earned via deeper exploitation or privilege escalation

Flag format: `flag{...}`

Students work from `ctf-challenge.md` (objectives only, no hints). The instructor releases `ctf-walkthrough.md` at the end of the session.

---

## Common Commands

```bash
# Build the base Kali image (once)
make build-base

# Start a lab — all-Docker mode
make run-week4

# Start a lab — Kali VM mode (targets only, ports exposed)
make run-week4-kali

# List running containers
docker ps

# Enter the attacker container (all-Docker mode)
docker exec -it week4-attacker bash

# Check container logs
docker logs week4-ftp

# Stop a specific week
cd labs/week4 && docker compose down

# Stop all weeks (both modes)
make stop-all

# Full cleanup
make clean-all
```

---

## Repository Structure

```
ethical-hacking-docker-labs/
├── base.Dockerfile              # Shared Kali attacker image
├── Makefile                     # run-weekN, run-weekN-kali, stop-all, clean-all
└── labs/
    └── weekN/
        ├── docker-compose.yaml       # All-Docker mode (attacker + targets)
        ├── docker-compose.kali.yaml  # Kali VM mode (targets only, ports exposed)
        ├── README.md
        ├── worksheet.md
        ├── ctf-challenge.md          # Student-facing CTF objectives
        └── ctf-walkthrough.md        # Instructor-only CTF solution
```

---

## Troubleshooting

**`make build-base` fails with a network error**  
Ensure Docker is running and you have internet access.

**`docker compose up` fails with "port already in use"**  
Another week may be running on the same port. Run `make stop-all` first.

**Kali VM cannot reach the targets**  
Confirm the host IP from inside Kali: `ip route show default`. The host (Docker machine) is typically the default gateway. Try `ping HOST_IP` from Kali first. If using VirtualBox NAT, the host is always `10.0.2.2`.

**Week 9 internal targets not reachable even with Kali VM mode**  
This is by design — you must pivot through the SSH port forward. See `labs/week9/worksheet.md` and `labs/week9/docker-compose.kali.yaml` for the exact commands.

**Container exits immediately**  
Check logs: `docker logs <container-name>`. Common cause: package install failed. Re-run `docker compose up -d` after a moment.

---

> **Authorised use only.** These labs are for educational purposes within the CYB204 course. Do not use these tools or techniques against any systems outside this controlled environment without explicit written authorisation.
