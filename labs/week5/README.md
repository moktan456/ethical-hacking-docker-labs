# Week 5: System and Network Enumeration

## CYB204 Ethical Hacking — Lab 5

**Topic:** Active enumeration — LDAP, MySQL, SMB

---

## Overview

This lab provides three enumeration targets simulating a typical corporate network. You will extract usernames, database schemas, and file-share information using standard enumeration tools.

| Container | IP | Services |
|---|---|---|
| week5-attacker | 10.10.5.2 | Kali attacker (your machine) |
| week5-ldap | 10.10.5.10 | LDAP (port 389, OpenLDAP) |
| week5-mysql | 10.10.5.11 | MySQL (port 3306) |
| week5-smb | 10.10.5.12 | SMB/Samba (port 445) |
| week5-netshoot | 10.10.5.20 | Network diagnostic utility |

**LDAP credentials** (for authenticated queries): `cn=readonly,dc=cybercorp,dc=local` / `readonly123`

**MySQL credentials** (for authenticated queries): `dbuser` / `dbpass123`

---

## Prerequisites

- Docker and Docker Compose installed
- Shared `ethical-base` image built (`make build-base` (or `docker build -t ethical-base -f base.Dockerfile .` on Windows) from repo root)

---

## Quick Start

```bash
# Linux / macOS / Git Bash
# Build base image (once)
make build-base

# Start Week 5 lab
make run-week5

# Enter the attacker container
docker exec -it week5-attacker bash

# Windows PowerShell / Command Prompt
docker build -t ethical-base -f base.Dockerfile .
cd labs\week5 && docker compose up -d
```

The attacker startup installs `enum4linux`, `ldap-utils`, `smbclient`, and `mysql-client` — this takes ~30 seconds on first run.

---

## Lab Exercises

See **worksheet.md** for step-by-step exercises.

---

## Cleanup

```bash
cd labs/week5 && docker compose down
```

---

## Practice on VulnHub

These machines require the same enumeration skills practised in this lab — LDAP, SMB, MySQL — but in a less guided "figure it out yourself" context.

| Machine | URL | Why it fits |
|---------|-----|------------|
| **HackLAB: Vulnix** | https://www.vulnhub.com/entry/hacklab-vulnix,48/ | Heavy on LDAP and NFS enumeration. You enumerate user accounts via `finger` and LDAP, then leverage NFS exports to gain access — a realistic chain that mirrors exactly what Week 5 teaches. Difficulty: beginner–intermediate. |
| **Stapler: 1** | https://www.vulnhub.com/entry/stapler-1,150/ | Exposes FTP, SSH, HTTP, SMB, MySQL, and more. `enum4linux` against this machine produces a rich haul of usernames, shares, and password-policy info — the same workflow as the Week 5 SMB exercises. Difficulty: intermediate. |
