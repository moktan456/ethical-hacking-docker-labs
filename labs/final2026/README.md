# Final Examination: Penetration Test — Meridian Freight Pty Ltd

The course's **capstone practical exam**. A full, unguided penetration test
against a simulated corporate network: recon → web/SMB enumeration → targeted
SSH brute force → privilege escalation → credential reuse, hash cracking and
decryption.

- **Five flags across five phases — 80 marks total** (practical; marks are
  weighted per phase, see [Final2026.md](./Final2026.md)).
- **3 hours**, plus **15 minutes** at the start to build and launch Docker.
- Worksheet-style: students answer **on paper** ([Final2026.md](./Final2026.md)).
- Built with **pull-only images** plus the shared Kali attacker container.
- **Single isolated network, no published host ports** — this lab never
  clashes with any other week's stack, and targets are reached only from
  the attacker container.

> This is a **live exam**. `labs/final2026/` is gitignored — do not track or
> push it until the sitting is over. The instructor walkthrough
> (`INSTRUCTOR-WALKTHROUGH.md`) is the answer key and stays untracked even
> after release.

---

## Two-Shell Lab Setup (Recommended)

**Terminal 1 — start the target network (victim machines)**
```bash
# Linux / macOS / Git Bash
cd labs/final2026
docker compose up -d

# Windows PowerShell
cd labs\final2026
docker compose up -d
```

**Terminal 2 — enter Kali (attacker machine)**
```bash
docker exec -it final2026-attacker bash
```

> Give the targets ~60 seconds after `up -d` — the SMB, SSH and database
> containers install and seed their services on first boot.

---

## Architecture

**Pull-only images** on one bridge network (`10.10.12.0/24`):

| Role | Container | IP | Image |
|------|-----------|----|-------|
| Attacker (Kali) | final2026-attacker | 10.10.12.2 | ethical-base |
| Web | final2026-web | 10.10.12.10 | httpd:2.4-bookworm |
| File server (SMB) | final2026-smb | 10.10.12.11 | ubuntu:22.04 + samba |
| App server (SSH) | final2026-ssh | 10.10.12.12 | ubuntu:22.04 |
| Database | final2026-db | 10.10.12.13 | mariadb:10.11 |

No ports are published to the host. All reconnaissance and exploitation
happen from inside `final2026-attacker`.

---

## Skills Assessed (Weeks 4–8)

| Flag | Phase | Skill | Week |
|------|-------|-------|------|
| 1 | Recon + web enumeration | nmap host/port/service discovery, reading page source for staff + username convention | 4, 7 |
| 2 | SMB enumeration | anonymous share listing and file retrieval (`smbclient`) | 5 |
| 3 | SSH foothold | building a targeted wordlist from a policy, Hydra brute force | 6 |
| 4 | Privilege escalation | spotting and abusing a misconfigured system file | 8 |
| 5 | Crack + decrypt | credential reuse into MySQL/MariaDB, offline MD5 cracking (john), OpenSSL decryption | 5, 6 |

---

## Instructor Notes

- **Verify before the sitting.** `solve.sh` is **not** shipped inside the
  lab (it would hand students every answer) — it lives at the lab root and is
  gitignored. Run it against a freshly started stack by piping it into the
  attacker container:
  ```bash
  docker exec -i final2026-attacker bash -s < solve.sh
  ```
  It should report `ALL FIVE FLAGS REACHABLE`.
- **Reset between students:** `docker compose down && docker compose up -d`.
- Answer key and per-flag values: see `INSTRUCTOR-WALKTHROUGH.md`.
