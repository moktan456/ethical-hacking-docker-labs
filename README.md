# Ethical Hacking Course Docker Labs

<!-- BADGES:START -->
[![cybersecurity](https://img.shields.io/badge/-cybersecurity-f44336?style=flat-square)](https://github.com/topics/cybersecurity) [![docker](https://img.shields.io/badge/-docker-2496ed?style=flat-square)](https://github.com/topics/docker) [![docker-compose](https://img.shields.io/badge/-docker--compose-blue?style=flat-square)](https://github.com/topics/docker-compose) [![edtech](https://img.shields.io/badge/-edtech-4caf50?style=flat-square)](https://github.com/topics/edtech) [![educational](https://img.shields.io/badge/-educational-blue?style=flat-square)](https://github.com/topics/educational) [![ethical-hacking](https://img.shields.io/badge/-ethical--hacking-blue?style=flat-square)](https://github.com/topics/ethical-hacking) [![kali-linux](https://img.shields.io/badge/-kali--linux-blue?style=flat-square)](https://github.com/topics/kali-linux) [![penetration-testing](https://img.shields.io/badge/-penetration--testing-blue?style=flat-square)](https://github.com/topics/penetration-testing) [![security-training](https://img.shields.io/badge/-security--training-blue?style=flat-square)](https://github.com/topics/security-training) [![vulnerability-assessment](https://img.shields.io/badge/-vulnerability--assessment-blue?style=flat-square)](https://github.com/topics/vulnerability-assessment)
<!-- BADGES:END -->

Docker-based lab environment for a 12-week ethical hacking course (CYB204) at ADCI. Each week runs as an isolated Docker Compose stack — a Kali Linux attacker container plus purpose-built vulnerable targets — on a private bridge network.

> **Want to use your own Kali VM?** See [KALI-VM-GUIDE.md](./KALI-VM-GUIDE.md) for Kali installation, VulnHub setup, and how to attack practice machines from your own VM.

---

## Prerequisites

| Tool | Min Version | Install |
|------|-------------|---------|
| Docker Desktop (macOS / Windows) or Docker Engine (Linux) | 24.x | https://docs.docker.com/get-docker/ |
| Docker Compose | v2.x | Bundled with Docker Desktop |
| Git | Any | https://git-scm.com/ |
| Make | Any | macOS: `xcode-select --install` · Linux: `sudo apt install make` · Windows: Git Bash or WSL2 |

**Recommended:** 8 GB RAM, 20 GB free disk space.

> **Windows users** — run all commands in **WSL2** (Ubuntu) or **Git Bash**.

---

## Installation

### 1. Clone the repository

```bash
git clone https://github.com/moktan456/ethical-hacking-docker-labs.git
cd ethical-hacking-docker-labs
```

### 2. Build the shared Kali attacker image

All labs share a single base image (`ethical-base`) built from `base.Dockerfile` — Kali Linux Rolling with the following tools pre-installed:

`nmap` · `hydra` · `medusa` · `john` · `hashcat` · `wireshark` · `gobuster` · `nikto` · `sqlmap` · `dirb` · `netcat` · `telnet` · `curl` · `wget` · `python3` · `rockyou wordlist`

**Build once before running any weekly lab:**

```bash
# Using make (Linux / macOS / Git Bash / WSL2)
make build-base

# Direct docker command (Windows PowerShell / Command Prompt)
docker build -t ethical-base -f base.Dockerfile .
```

Verify the image exists:

```bash
docker images | grep ethical-base
```

---

## Running a Lab

### Start a week

```bash
make run-week4      # replace 4 with the week number
```

This runs `docker compose up -d` in `labs/weekN/`, starting the attacker container and all targets in the background.

### Enter the attacker container

```bash
docker exec -it week4-attacker bash
```

> Container names are week-prefixed (e.g. `week4-attacker`, `week9-attacker`). Check the week's `README.md` for the exact name.

### Stop a specific week

```bash
cd labs/week4 && docker compose down
```

### Stop all running labs

```bash
make stop-all
```

### Full cleanup (removes stopped containers and dangling images)

```bash
make clean-all
```

---

## Network Architecture

All weeks use the `10.10.WEEK.0/24` subnet — the week number is always visible in the address. The attacker is always at `.2`; targets start at `.10`.

| Week | Subnet | Attacker | Targets |
|------|--------|----------|---------|
| 1 | 10.10.1.0/24 | 10.10.1.2 | 10.10.1.2 proxy · 10.10.1.5 secutils |
| 3 | 10.10.3.0/24 | 10.10.3.2 | 10.10.3.10 sample-target |
| 4 | 10.10.4.0/24 | 10.10.4.2 | 10.10.4.10 web · .11 ftp · .12 ssh |
| 5 | 10.10.5.0/24 | 10.10.5.2 | 10.10.5.10 ldap · .11 mysql · .12 smb |
| 6 | 10.10.6.0/24 | 10.10.6.2 | 10.10.6.10 ssh-target · .11 web-target |
| 7 | 10.10.7.0/24 | 10.10.7.13 | 10.10.7.7 ldap · .9 mysql · .10 telnet · .11 juice-shop · .12 dvwa |
| 8 | 10.10.8.0/24 | 10.10.8.2 | 10.10.8.10 web · .11 ssh · .12 ftp |
| 9 (external) | 10.10.9.0/24 | 10.10.9.2 | 10.10.9.10 pivot-host |
| 9 (internal) | 10.10.90.0/24 | — | 10.10.90.20 internal-web · .21 internal-db |
| 10 | 10.10.10.0/24 | 10.10.10.2 | 10.10.10.10 web-recon · .11 vuln-target |

> **Week 9 internal network** uses `internal: true` — it is completely isolated and unreachable without pivoting through `10.10.9.10`. This is by design.

---

## Week-by-Week Reference

| Week | Topic | Lab Type | Attacker Entry Point |
|------|--------|----------|----------------------|
| 1 | Docker Environment Setup | Wireshark + SecUtils | `docker exec -it week1-attacker bash` |
| 2 | Ethics & Legal Issues | Discussion only | See `labs/week2/README.md` |
| 3 | Scope & Proposal Development | Traffic analysis | Wireshark GUI → `http://localhost:3000` |
| 4 | Reconnaissance & Information Gathering | Nmap scanning | `docker exec -it week4-attacker bash` |
| 5 | System & Network Enumeration | LDAP, MySQL, SMB | `docker exec -it week5-attacker bash` |
| 6 | Password Cracking | Hydra, John, Hashcat | `docker exec -it password-cracking-lab bash` |
| 7 | Web Application Vulnerabilities | DVWA, Juice Shop | `docker exec -it week7-attacker bash` |
| 8 | Privilege Escalation (De-ICE) | Full pentest chain | `docker exec -it de-ice-attacker bash` |
| 9 | Lateral Movement & Pivoting | Multi-subnet pivot | `docker exec -it week9-attacker bash` |
| 10 | Exploit Development (BOF) | Stack buffer overflow | `docker exec -it week10-attacker bash` |
| 11 | Physical Access Controls | Discussion only | See `labs/week11/README.md` |
| 12 | Social Engineering | Discussion only | See `labs/week12/README.md` |

Each week folder (`labs/weekN/`) contains:

- `README.md` — overview, network topology, target credentials
- `worksheet.md` — guided step-by-step exercises
- `docker-compose.yaml` — full stack definition
- `ctf-challenge.md` — optional CTF objectives (no hints)
- `ctf-walkthrough.md` — instructor-only CTF solution

---

## Optional CTF Challenges

Each lab week includes an optional Capture The Flag challenge. Two flags are hidden inside the existing containers:

- `user.txt` — earned via initial access / enumeration
- `root.txt` — earned via deeper exploitation or privilege escalation

Flag format: `flag{...}`

Students work from `ctf-challenge.md`. The instructor releases `ctf-walkthrough.md` at the end of the session.

---

## VulnHub Practice Machines

Each week's `README.md` lists two relevant VulnHub machines for additional independent practice (all Easy or Medium difficulty). VulnHub machines run as standalone VMs — see [KALI-VM-GUIDE.md](./KALI-VM-GUIDE.md) for setup instructions.

---

## Common Commands

```bash
# Build the shared Kali image (once)
make build-base
# or on Windows without make:
docker build -t ethical-base -f base.Dockerfile .

# Start a weekly lab
make run-week4
# or on Windows:
# cd labs\week4 && docker compose up -d

# List running containers
docker ps

# Enter the attacker container
docker exec -it week4-attacker bash

# Check a container's logs
docker logs week4-ftp

# Stop one week's stack
cd labs/week4 && docker compose down

# Stop all weeks
make stop-all

# Full cleanup
make clean-all
```

---

## Repository Structure

```
ethical-hacking-docker-labs/
├── base.Dockerfile          # Shared Kali attacker image
├── Makefile                 # build-base, run-weekN, stop-all, clean-all
├── KALI-VM-GUIDE.md         # Kali VM setup + VulnHub attack guide
└── labs/
    ├── week1/ ... week12/
    │   ├── docker-compose.yaml
    │   ├── README.md
    │   ├── worksheet.md
    │   ├── ctf-challenge.md
    │   └── ctf-walkthrough.md
```

---

## Troubleshooting

**`make build-base` (or `docker build -t ethical-base -f base.Dockerfile .` on Windows) fails with a network error**
Docker is not running, or no internet access. Start Docker Desktop and retry.

**`docker compose up` fails with "port already in use"**
Another lab week is still running on a conflicting port. Run `make stop-all` first.

**Container exits immediately**
Check logs: `docker logs <container-name>`. Most common cause is a missing `apt-get update` before an install — all compose files in this repo already include it.

**Week 9 internal targets are unreachable**
This is intentional — set up SSH port forwarding through `week9-pivot` first. See `labs/week9/worksheet.md`.

---

> **Authorised use only.** These labs are for educational purposes within the CYB204 course. Do not use these tools or techniques against any systems outside this controlled environment without explicit written authorisation.
