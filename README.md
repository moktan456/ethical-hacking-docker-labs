# Ethical Hacking Course Docker Labs

<!-- BADGES:START -->
[![cybersecurity](https://img.shields.io/badge/-cybersecurity-f44336?style=flat-square)](https://github.com/topics/cybersecurity) [![docker](https://img.shields.io/badge/-docker-2496ed?style=flat-square)](https://github.com/topics/docker) [![docker-compose](https://img.shields.io/badge/-docker--compose-blue?style=flat-square)](https://github.com/topics/docker-compose) [![edtech](https://img.shields.io/badge/-edtech-4caf50?style=flat-square)](https://github.com/topics/edtech) [![educational](https://img.shields.io/badge/-educational-blue?style=flat-square)](https://github.com/topics/educational) [![ethical-hacking](https://img.shields.io/badge/-ethical--hacking-blue?style=flat-square)](https://github.com/topics/ethical-hacking) [![kali-linux](https://img.shields.io/badge/-kali--linux-blue?style=flat-square)](https://github.com/topics/kali-linux) [![penetration-testing](https://img.shields.io/badge/-penetration--testing-blue?style=flat-square)](https://github.com/topics/penetration-testing) [![security-training](https://img.shields.io/badge/-security--training-blue?style=flat-square)](https://github.com/topics/security-training) [![vulnerability-assessment](https://img.shields.io/badge/-vulnerability--assessment-blue?style=flat-square)](https://github.com/topics/vulnerability-assessment)
<!-- BADGES:END -->

Docker-based lab environment for a 12-week ethical hacking course (CYB204) at ADCI. Each week runs as an isolated Docker Compose stack — a Kali Linux attacker container plus one or more purpose-built vulnerable targets — all on a private bridge network with no internet exposure.

---

## Prerequisites

Install the following on your host machine before anything else:

| Tool | Minimum Version | Install |
|------|----------------|---------|
| Docker Desktop (macOS/Windows) or Docker Engine (Linux) | 24.x | https://docs.docker.com/get-docker/ |
| Docker Compose (included with Docker Desktop) | v2.x | Bundled with Docker Desktop |
| Git | Any recent | https://git-scm.com/ |
| Make | Any | macOS: `xcode-select --install` · Linux: `sudo apt install make` · Windows: via WSL2 or Git Bash |

**Recommended system specs:** 8 GB RAM, 20 GB free disk space.

> **Windows users** — run all commands inside **WSL2** (Ubuntu) or **Git Bash**. Native CMD/PowerShell are not supported.

---

## Installation

### 1. Clone the repository

```bash
git clone https://github.com/moktan456/ethical-hacking-docker-labs.git
cd ethical-hacking-docker-labs
```

### 2. Build the shared Kali attacker image

All lab weeks share a single base image (`ethical-base`) built from `base.Dockerfile`. This is a Kali Linux Rolling image with the following tools pre-installed:

`nmap` · `hydra` · `medusa` · `john` · `hashcat` · `wireshark` · `gobuster` · `nikto` · `sqlmap` · `dirb` · `netcat` · `telnet` · `curl` · `wget` · `python3` · `rockyou wordlist`

**Build it once** before running any weekly lab:

```bash
make build-base
```

This pulls the Kali Rolling base layer (~600 MB) and installs all tools. It takes a few minutes on first run and is cached for subsequent builds.

Verify the image was created:

```bash
docker images | grep ethical-base
```

---

## Running a Weekly Lab

### Start a week

```bash
make run-week4     # replace 4 with the week number you want
```

This runs `docker compose up -d` inside `labs/weekN/`, starting the attacker container and all target containers in the background.

### Enter the attacker container

```bash
docker exec -it week4-attacker bash
```

> Container names are week-prefixed (e.g. `week4-attacker`, `week9-attacker`). Check the week's `README.md` for the exact container name.

### Stop a specific week

```bash
cd labs/week4 && docker compose down
```

### Stop all weeks at once

```bash
make stop-all
```

### Remove unused images and volumes (full cleanup)

```bash
make clean-all
```

---

## Week-by-Week Reference

| Week | Topic | Lab Type | Attacker Entry Point |
|------|--------|----------|----------------------|
| 1 | Docker Environment Setup | Wireshark + SecUtils | `docker exec -it week1-attacker bash` |
| 2 | Ethics & Legal Issues | Discussion only — no Docker | Review `labs/week2/README.md` |
| 3 | Scope & Proposal Development | Traffic analysis | Wireshark GUI on port 3000 |
| 4 | Reconnaissance & Information Gathering | Nmap scanning | `docker exec -it week4-attacker bash` |
| 5 | System & Network Enumeration | LDAP, MySQL, SMB | `docker exec -it week5-attacker bash` |
| 6 | Password Cracking | Hydra, John, Hashcat | `docker exec -it password-cracking-lab bash` |
| 7 | Web Application Vulnerabilities | DVWA, Juice Shop | `docker exec -it week7-attacker bash` |
| 8 | Privilege Escalation | De-ICE full pentest | `docker exec -it de-ice-attacker bash` |
| 9 | Lateral Movement & Pivoting | Multi-subnet pivot | `docker exec -it week9-attacker bash` |
| 10 | Exploit Development | Stack buffer overflow | `docker exec -it week10-attacker bash` |
| 11 | Physical Access Controls | Discussion only — no Docker | Review `labs/week11/README.md` |
| 12 | Social Engineering | Discussion only — no Docker | Review `labs/week12/README.md` |

Each lab week folder (`labs/weekN/`) contains:

- `README.md` — lab overview, network topology, target credentials
- `worksheet.md` — step-by-step guided exercises
- `docker-compose.yaml` — the full stack definition
- `ctf-challenge.md` — optional CTF objectives (no hints)
- `ctf-walkthrough.md` — instructor-only solution guide

---

## Network Architecture

Every week runs on its own isolated Docker bridge network. The attacker and targets share that network but have **no internet access**. Subnets are week-specific to prevent collisions if multiple weeks run simultaneously:

| Week | Subnet |
|------|--------|
| 1 | 192.168.1.0/24 |
| 3 | 172.30.0.0/24 |
| 4 | 172.40.0.0/24 |
| 5 | 172.50.0.0/24 |
| 6 | Dynamic (bridge) |
| 7 | 172.20.0.0/24 |
| 8 | 172.20.0.0/24 |
| 9 | External 172.90.10.0/24 + Internal 172.90.20.0/24 |
| 10 | 172.100.0.0/24 |

> Week 9 uses two networks: an external segment (attacker ↔ pivot) and an internal segment (`internal: true`) that is unreachable without pivoting through the hop host.

---

## Optional CTF Challenges

Each lab week includes an optional Capture The Flag challenge. Two flags are hidden inside the existing containers:

- **`user.txt`** — earned via initial access / enumeration
- **`root.txt`** — earned via deeper exploitation or privilege escalation

Flag format: `flag{...}`

Students work from `ctf-challenge.md` (objectives only, no hints). The instructor releases `ctf-walkthrough.md` at the end of the session.

---

## Common Commands Reference

```bash
# Build the base Kali attacker image (run once)
make build-base

# Start a weekly lab
make run-week4

# List running containers
docker ps

# Enter the attacker container for week 4
docker exec -it week4-attacker bash

# Check container logs
docker logs week4-ftp

# Stop a specific week's stack
cd labs/week4 && docker compose down

# Stop all weeks
make stop-all

# Full cleanup (removes stopped containers, dangling images)
make clean-all
```

---

## Repository Structure

```
ethical-hacking-docker-labs/
├── base.Dockerfile          # Shared Kali attacker image
├── Makefile                 # Orchestration (build-base, run-weekN, stop-all)
└── labs/
    ├── week1/
    │   ├── docker-compose.yaml
    │   ├── README.md
    │   ├── worksheet.md
    │   ├── ctf-challenge.md
    │   ├── ctf-walkthrough.md
    │   └── data/            # Shared volume (pcap files)
    ├── week2/               # Discussion only
    │   └── README.md
    ├── week3/ ...
    ├── week4/ ...
    │   └── web-content/     # Nginx served content
    ├── week5/ ...
    │   └── mysql-init/      # Database seed SQL
    ...
    └── week12/              # Discussion only
        └── README.md
```

---

## Troubleshooting

**`make build-base` fails with a network error**  
Ensure Docker is running and you have internet access to pull `kalilinux/kali-rolling`.

**`docker compose up` fails with "port already in use"**  
Another week's stack may still be running on the same port. Run `make stop-all` first.

**Container exits immediately**  
Check the logs: `docker logs <container-name>`. Common cause: an `apt-get install` failed due to a stale package index. The fix is already in place (`apt-get update` precedes every install in all compose files).

**Week 9 internal targets unreachable from attacker**  
This is by design — the internal network is isolated. You must pivot through `week9-pivot` (172.90.10.10) using SSH port forwarding or a SOCKS proxy. See `labs/week9/worksheet.md`.

---

> **Authorised use only.** These labs are for educational purposes within the CYB204 course. Do not run attack tools against any systems outside this controlled Docker environment without explicit written authorisation.
