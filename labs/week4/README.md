# Week 4: Reconnaissance and Information Gathering

## CYB204 Ethical Hacking — Lab 4

**Topic:** Active reconnaissance using Nmap

---

## Overview

In this lab you will use Nmap to perform reconnaissance against three simulated target systems on an isolated lab network. You will practice port scanning, service version detection, and OS fingerprinting — core skills for the Assessment 1 engagement proposal.

| Container | IP | Services |
|---|---|---|
| week4-attacker | 10.10.4.2 | Kali attacker (your machine) |
| week4-web | 10.10.4.10 | HTTP (port 80, Nginx) |
| week4-ftp | 10.10.4.11 | FTP (port 21, vsftpd) |
| week4-ssh | 10.10.4.12 | SSH (port 22, OpenSSH) |

---

## Prerequisites

- Docker and Docker Compose installed
- Shared `ethical-base` image built (`make build-base` from repo root)

---

## Quick Start

```bash
# From repo root — build the base image once if you haven't already
make build-base

# Start Week 4 lab
make run-week4

# Enter the attacker container
docker exec -it week4-attacker bash
```

---

## Lab Exercises

See **worksheet.md** for step-by-step exercises.

---

## Cleanup

```bash
cd labs/week4 && docker compose down
```

---

## Practice on VulnHub

Once you are comfortable with the Nmap exercises in this lab, use these machines as "live" Nmap targets. They each expose a different mix of services so your scan results will look different every time.

| Machine | URL | Why it fits |
|---------|-----|------------|
| **Kioptrix: Level 1** | https://www.vulnhub.com/entry/kioptrix-level-1-1,22/ | Classic beginner machine with SMB, HTTP, and SSH exposed. Run every scan type from the worksheet against it — `-sV`, `-A`, `--script smb-*` — and compare your output to what a real engagement might look like. |
| **Mr-Robot: 1** | https://www.vulnhub.com/entry/mr-robot-1,151/ | Web-heavy machine with a WordPress site. Nmap will detect HTTP but not reveal everything — you need `gobuster` and `nikto` to go deeper. Good bridge between Week 4 (recon) and Week 5 (enumeration). |
