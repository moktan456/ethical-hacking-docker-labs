# Week 10: Exploit Development

## CYB204 Ethical Hacking — Lab 10

**Topic:** Buffer overflow analysis and exploitation

---

## Overview

This lab provides a full-chain pentest simulation: recon → enumeration → exploit development → privilege escalation. It is designed as preparation for **Assessment 2** (3000-word practical pentest report).

| Container | IP | Services |
|---|---|---|
| week10-attacker | 172.100.0.2 | Kali attacker — includes GDB, pwntools |
| week10-web-recon | 172.100.0.10 | HTTP (port 80, Nginx) |
| week10-vuln-target | 172.100.0.11 | Vulnerable debug service (port 9999), SSH (port 22) |

**Target service:** `week10-vuln-target:9999` — a C network service compiled without stack canaries, ASLR, or PIE. Classic ret2win buffer overflow.

---

## Prerequisites

- Docker and Docker Compose installed
- Shared `ethical-base` image built (`make build-base` from repo root)

---

## Quick Start

```bash
# Build base image (once)
make build-base

# Start Week 10 lab (target compiles vuln.c on startup — allow ~60s)
make run-week10

# Enter attacker container
docker exec -it week10-attacker bash
```

**Note:** The attacker startup installs `gdb` and `pwntools` (~60s on first run). The target compiles the vulnerable service from source using `gcc` with protections disabled.

---

## Lab Exercises

See **worksheet.md** for step-by-step exercises.

---

## Source Code

The vulnerable service source is at `labs/week10/target-files/vuln.c`.

An exploit template is at `labs/week10/target-files/exploit_template.py`.

---

## Cleanup

```bash
cd labs/week10 && docker compose down
```

---

## Practice on VulnHub

These two machines are the most highly recommended buffer-overflow practice targets in the VulnHub catalogue. Both are commonly used in OSCP prep — the same style of exploit development this lab teaches.

| Machine | URL | Why it fits |
|---------|-----|------------|
| **Brainpan: 1** | https://www.vulnhub.com/entry/brainpan-1,51/ | Purpose-built for buffer overflow practice. A Windows PE binary runs as a network service on a Linux host — you fuzz it, find the offset with a cyclic pattern, control EIP, and land a shell. The exploit flow is identical to `vuln.c` in this lab but with a real binary. Widely regarded as the best BOF starter VM. Difficulty: intermediate. |
| **/dev/random: scream** | https://www.vulnhub.com/entry/devrandom-scream,47/ | Purpose-built buffer-overflow challenge. A vulnerable service listens on a custom port; you fuzz it, find the offset, control EIP, and deliver shellcode — mirroring every step in the Week 10 worksheet. Two community walkthroughs exist (easy and alternate method), making it ideal for checking your work. Difficulty: medium. |
