# Week 9: Lateral Movement Between Systems and Services

## CYB204 Ethical Hacking — Lab 9

**Topic:** Network pivoting — using a compromised host to reach internal systems

---

## Overview

This lab simulates a segmented corporate network. You start on the external network and must pivot through a compromised host to reach the internal network.

```
EXTERNAL (10.10.9.0/24)          INTERNAL (10.10.90.0/24)
┌─────────────────────┐            ┌──────────────────────────┐
│  week9-attacker     │            │  week9-internal-web :80  │
│  10.10.9.2        │            │  10.10.90.20            │
│                     │            │                          │
│  week9-pivot ───────┼────────────┤  week9-internal-db :3306 │
│  10.10.9.10       │            │  10.10.90.21            │
└─────────────────────┘            └──────────────────────────┘
```

The attacker **cannot directly reach** 10.10.90.x — all traffic must go through the pivot host.

---

## Prerequisites

- Docker and Docker Compose installed
- No `make build-base` (or `docker build -t ethical-base -f base.Dockerfile .` on Windows) needed — week9-attacker uses the Metasploit Framework image

---

## Quick Start

```bash
# Linux / macOS / Git Bash
# Start Week 9 lab
make run-week9

# Enter the attacker container
docker exec -it week9-attacker bash

# Windows PowerShell / Command Prompt
cd labs\week9 && docker compose up -d
```


## 💻 Two-Shell Lab Setup (Recommended)

Running two terminal windows side-by-side gives you the real attacker/victim experience:

**Terminal 1 — Start the lab (victim machines)**
```bash
# Linux / macOS / Git Bash
cd labs/week9
docker compose up -d

# Windows PowerShell
cd labs\week9
docker compose up -d
```

**Terminal 2 — Enter Kali (attacker machine)**
```bash
docker exec -it week9-attacker bash
```

> Think of Terminal 1 as the victim network running in the background, and Terminal 2 as your Kali attacking machine. All commands in the worksheets are run from Terminal 2 (inside Kali).

---
---

## Lab Exercises

See **worksheet.md** for step-by-step exercises.

---

## Cleanup

```bash
cd labs/week9 && docker compose down
```

---

## Practice on VulnHub

Both machines require pivoting between network segments to complete the challenge — you cannot root them by staying on a single host. Use the SSH tunnelling and proxychains techniques from this lab's worksheet.

| Machine | URL | Why it fits |
|---------|-----|------------|
| **WinterMute: 1** | https://www.vulnhub.com/entry/wintermute-1,239/ | Two-machine series: you compromise the first host (Straylight) then must pivot to reach the second (Neuromancer) on a separate network. Classic lateral movement requiring SOCKS proxy or port forwarding — exactly the skills in the Week 9 worksheet. Difficulty: intermediate. |
| **Nully Cybersecurity: 1** | https://www.vulnhub.com/entry/nully-cybersecurity-1,549/ | Multi-host lab with three internal machines on different network segments. You pivot through each one using SSH tunnels and Metasploit routes. The topology directly mirrors the Week 9 external/internal network design. Difficulty: intermediate. |
