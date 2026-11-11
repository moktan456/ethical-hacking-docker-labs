# Alternative Final Examination: Penetration Test — Vanta Health Pty Ltd

The **make-up sitting** of the course's capstone practical exam, for students
who missed `final2026`. Same five-phase chain and mark scheme, a different
scenario, network, credentials, password policy and privilege-escalation
route.

- **Five flags, 10 marks each — 50 total.**
- **3 hours**, plus **15 minutes** at the start to build and launch Docker.
- Worksheet-style: students answer **on paper** ([AltFinal2026.md](./AltFinal2026.md)).
- Built with **pull-only images** plus the shared Kali attacker container.
- **Single isolated network, no published host ports** — never clashes with
  any other week's stack; targets are reached only from the attacker container.

> This exam is **released**. The answer key is
> [INSTRUCTOR-WALKTHROUGH.md](./INSTRUCTOR-WALKTHROUGH.md).

---

## Two-Shell Lab Setup (Recommended)

**Terminal 1 — start the target network (victim machines)**
```bash
# Linux / macOS / Git Bash
cd labs/altfinal2026
docker compose up -d

# Windows PowerShell
cd labs\altfinal2026
docker compose up -d
```

**Terminal 2 — enter Kali (attacker machine)**
```bash
docker exec -it altfinal2026-attacker bash
```

> Give the targets ~60 seconds after `up -d` — the SMB, SSH and database
> containers install and seed their services on first boot.

---

## Architecture

**Pull-only images** on one bridge network (`10.10.13.0/24`):

| Role | Container | IP | Image |
|------|-----------|----|-------|
| Attacker (Kali) | altfinal2026-attacker | 10.10.13.2 | ethical-base |
| Web | altfinal2026-web | 10.10.13.10 | httpd:2.4-bookworm |
| File server (SMB) | altfinal2026-smb | 10.10.13.11 | ubuntu:22.04 + samba |
| App server (SSH) | altfinal2026-ssh | 10.10.13.12 | ubuntu:22.04 |
| Database | altfinal2026-db | 10.10.13.13 | mariadb:10.11 |

No ports are published to the host. All reconnaissance and exploitation
happen from inside `altfinal2026-attacker`.

---

## Skills Assessed (Weeks 4–8)

| Flag | Phase | Skill | Week |
|------|-------|-------|------|
| 1 | Recon + web enumeration | nmap host/port/service discovery, reading page source for staff + username convention | 4, 7 |
| 2 | SMB enumeration | anonymous share listing and file retrieval (`smbclient`) | 5 |
| 3 | SSH foothold | building a targeted wordlist from a policy, Hydra brute force | 6 |
| 4 | Privilege escalation | finding and abusing a non-stock **SUID binary** (GTFOBins) | 8 |
| 5 | Crack + decrypt | credential reuse into MariaDB, offline MD5 cracking (john), OpenSSL decryption | 5, 6 |

> **How this differs from `final2026`:** different staff/usernames, a
> **Month+Year** temporary-password policy (vs Season+Year), and a **SUID
> `cp`** privilege escalation (vs `final2026`'s world-writable `/etc/passwd`).

---

## Instructor Notes

- **Verify the lab.** `solve.sh` (the automated solver, at the lab root) is
  not mounted into the attacker container. Run it against a freshly started
  stack by piping it in:
  ```bash
  docker exec -i altfinal2026-attacker bash -s < solve.sh
  ```
  It should report `ALL FIVE FLAGS REACHABLE`.
- **Reset between students:** `docker compose down && docker compose up -d`.
- Answer key and per-flag values: see `INSTRUCTOR-WALKTHROUGH.md`.
