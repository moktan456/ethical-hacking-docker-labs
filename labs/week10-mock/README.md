# Week 10 Mock Exam: Practice Penetration Test

A rehearsal for the real Week 10 capstone — same skill chain (recon, web
enumeration, FTP enumeration, password cracking, SSH foothold, privilege
escalation), a different scenario, and a bit friendlier: fewer services,
more direct hints, a shorter time limit.

**Not published to the public repo.** This lab is gitignored
(`labs/week10-mock/`) — like Week 10 itself, it should only reach students
when the instructor deliberately hands it out (a zip, an LMS upload, or a
one-off `git add -f`), not sit visible in git history beforehand.

## Quick Start

```bash
cd labs/week10-mock
docker compose up -d
docker exec -it week10mock-attacker bash
```

## Lab Network

All containers run on an isolated network (`10.10.50.0/24`):

| Container | IP | Service |
|-----------|-----|---------|
| week10mock-attacker | 10.10.50.2 | Kali (ethical-base) |
| week10mock-web | 10.10.50.10 | HTTP :80 |
| week10mock-ftp | 10.10.50.11 | FTP :21 (anonymous) |
| week10mock-ssh | 10.10.50.12 | SSH :22 |

## Documentation

- [worksheet.md](worksheet.md) — student exam worksheet
- [ctf-challenge.md](ctf-challenge.md) — optional CTF framing (two flags)
- `INSTRUCTOR-WALKTHROUGH.md` / `ctf-walkthrough.md` — instructor-only
  answer keys (gitignored, not present unless generated locally)

## Cleanup

```bash
docker compose down
```
