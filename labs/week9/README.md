# Week 9: Lateral Movement Between Systems and Services

## CYB204 Ethical Hacking — Lab 9

**Topic:** Lateral movement — reusing credentials and trust relationships to move between already-reachable systems

---

## Overview

You start with one low-privilege foothold and have to turn it into `root`
on a different machine, using nothing but what you find along the way:
a hash dumped to a careless file, an SSH private key backed up with weak
permissions, and a password reused between a config file and a root
account. This matches the Week 9 slide deck's core techniques directly —
credential dumping, Pass-the-Hash, and exploiting trust relationships —
rather than network pivoting (that's a different exercise).

```
week9-attacker (Kali)        10.10.9.2
week9-workstation             10.10.9.10   foothold (creds given)
week9-fileserver (Samba)      10.10.9.12   anonymous + pass-the-hash shares
week9-ubuntu-desktop          10.10.9.11   reached via a leaked SSH key
```

All four containers sit on one flat network — every host is directly
reachable from the attacker. There's no segmentation to route around this
week; the obstacle is entirely credentials and trust.

---

## Prerequisites

- Docker and Docker Compose installed
- `make build-base` (or `docker build -t ethical-base -f base.Dockerfile .`
  on Windows) run at least once — `week9-attacker` uses the shared Kali
  (`ethical-base`) image, same as every other week

---

## Quick Start

```bash
# Linux / macOS / Git Bash
make run-week9
docker exec -it week9-attacker bash

# Windows PowerShell / Command Prompt
cd labs\week9 && docker compose up -d
docker exec -it week9-attacker bash
```

Provisioning takes roughly 30–45 seconds — the targets are installing
SSH/Samba, creating accounts, and `week9-workstation` is generating the SSH
keypair that becomes the "leaked" credential in Part 4 of the worksheet.

## 💻 Two-Shell Lab Setup (Recommended)

**Terminal 1 — Start the lab (victim machines)**
```bash
cd labs/week9
docker compose up -d
```

**Terminal 2 — Enter Kali (attacker machine)**
```bash
docker exec -it week9-attacker bash
```

> Terminal 1 is the victim network running in the background; Terminal 2 is
> your Kali attack box. All worksheet commands run from Terminal 2.

---

## Lab Environment

| Container | IP | Role |
|-----------|-----|------|
| week9-attacker | 10.10.9.2 | Kali-based attack box (`ethical-base` image) |
| week9-workstation | 10.10.9.10 | Initial foothold — SSH creds supplied |
| week9-fileserver | 10.10.9.12 | Samba: anonymous share + pass-the-hash-only share |
| week9-ubuntu-desktop | 10.10.9.11 | Reached via a leaked SSH key; root via a reused password |

---

## Lab Exercises

See **[worksheet.md](./worksheet.md)** for step-by-step exercises, and
**[ctf-challenge.md](./ctf-challenge.md)** for the optional end-of-session
challenge.

---

## Cleanup

```bash
cd labs/week9 && docker compose down
```

---

## A Note on This Lab's Techniques vs. the Original Slide Deck

The slide deck frames several steps around Windows-only tooling
(`mimikatz.exe`, `net user`, `impacket-psexec`/`wmiexec` against a generic
Windows box). Since every container here is Linux, the worksheet uses the
real Linux equivalent for each one instead of a command that would simply
fail — the same approach Week 8 takes for its own Windows-framed material.
See the **"A Note on Windows-Only Tooling"** section at the end of
`worksheet.md` for exactly what maps to what, and why.

---

## Practice Further on VulnHub

Both machines below require reusing credentials or trust relationships
discovered on one host to reach another — they will not fall to attacking
a single box in isolation, which is exactly what this lab practices.

| Machine | URL | Why it fits |
|---------|-----|------------|
| **Breach: 1** | https://www.vulnhub.com/entry/breach-1,152/ | Initial web foothold leads to credentials reused for SSH, then to further lateral movement toward root. Mirrors the "dumped credential → reused elsewhere" chain in this lab. Difficulty: intermediate. |
| **SickOs: 1.2** | https://www.vulnhub.com/entry/sickos-12,144/ | A low-privilege foothold exposes a config file with a reusable password, leading to a second service and eventually root — the same credential-hunting pattern as Part 5 of the worksheet. Difficulty: beginner–intermediate. |
