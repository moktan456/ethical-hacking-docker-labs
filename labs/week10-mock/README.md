# Week 10 Mock Exam: Practice Penetration Test

A rehearsal for the real Week 10 capstone — same skill chain (recon, web
enumeration, FTP enumeration, password cracking, SSH foothold, privilege
escalation), a different scenario, and a bit friendlier: fewer services,
more direct hints, a shorter time limit.

This is practice material — a rehearsal for the real Week 10 exam, which
stays private and unpublished. This mock version, including its answer
key, is published for students to use.

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

- [mock-exam.md](mock-exam.md) — student exam worksheet
- [ctf-challenge.md](ctf-challenge.md) — optional CTF framing (two flags)
- [mock-exam-walkthrough.md](mock-exam-walkthrough.md) /
  [ctf-walkthrough.md](ctf-walkthrough.md) — answer keys

## Cleanup

```bash
docker compose down
```
