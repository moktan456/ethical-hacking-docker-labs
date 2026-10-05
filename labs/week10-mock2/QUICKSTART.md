# Week 10 Mock Exam 2: Quick Start Guide

**⚡ Get the lab running in 2 minutes**

This page is deliberately spoiler-free — it only covers *launching* the
lab, not attacking it. For the actual exam instructions and grading, see
[mock-exam.md](./mock-exam.md).

---

## Prerequisites

✅ Docker Desktop installed and running
✅ `ethical-base` image built (from repo root)
✅ At least 4GB free RAM
✅ 3 hours available for the exam

---

## Quick Setup

### Step 1: Navigate to Lab Directory

```bash
cd labs/week10-mock2
```

### Step 2: Start the Lab

```bash
docker compose up -d
```

Give `ssh-target` and `database` 30-60 seconds to finish installing
packages before scanning them.

### Step 3: Access the Attacker Machine

```bash
docker exec -it week10mock2-attacker bash
```

### Step 4: Find Your Own Position

```bash
ip addr show
```

This is intentionally the first real task, not a formality — it's graded
under Network/Host Discovery in [mock-exam.md](./mock-exam.md). Nothing
about the target network, hosts, or services is given anywhere in the
candidate-facing docs.

---

## What You'll See

```
========================================
Week 10 Mock Exam 2 - CyberGuard Corp
========================================

SCENARIO:
You have been hired to test CyberGuard Corp's internal network.
Your goal: Find 3 flags (1 easy, 2 hard) and document your methodology.

No network, host, or service info is given - find it yourself.
Time limit: 3 hours

Access the attacker machine:
  docker exec -it week10mock2-attacker bash
```

---

## How Marks Break Down (see mock-exam.md for full detail)

- **Recon & Enumeration — 30%:** network/host discovery, port scanning,
  service enumeration, web enumeration, FTP enumeration, file discovery
  (5% each). Graded on what you documented, not on whether it led to a
  flag.
- **Two hard flags — 25% each:** both require actually attacking
  something (a targeted password attack + privesc, and a credential
  reuse → hash crack → decrypt chain).
- **Documentation — 20%:** methodology, evidence, recommendations.

**Minimum to pass (50%):** full recon marks + baseline documentation.
No hard flag is required to pass.

---

## Essential Tools (Pre-installed on the attacker)

- `nmap` - Network scanning
- `ftp` / `curl` - Service clients
- `hydra` - Password attacks
- `ssh` / `sshpass` - SSH client
- `mysql` - Database client (use `--skip-ssl` against this MariaDB image)
- `john` / `hashcat` - Hash cracking
- `openssl` - Decryption

---

## Important Files

- **mock-exam.md** — official exam instructions and full rubric (student-facing, spoiler-free)
- **README.md** — overview and marking guide (student-facing, spoiler-free)
- **ctf-challenge.md** — CTF-style version of the same exam (student-facing, spoiler-free)
- **mock-exam-walkthrough.md** — complete verified solution (**instructor only**)
- **ctf-walkthrough.md** — points to the same solution (**instructor only**)

---

## If Something Goes Wrong

```bash
docker compose ps                      # all should show "Up"
docker compose logs [container-name]
docker compose restart
# If a container loops with "dpkg was interrupted" in its logs:
docker compose up -d --force-recreate [service-name]
```

### Complete Reset

```bash
docker compose down
docker compose up -d
```

---

## Stop the Lab

```bash
docker compose down
```

---

## Need Help?

1. **Stuck?** Re-read the hints embedded in what you've already found —
   nothing extra is given in mock-exam.md beyond the rubric.
2. **Technical issues?** See the README.md troubleshooting section.
3. **Want the solution?** mock-exam-walkthrough.md — instructor only,
   after attempting.

---

**Good luck! Methodology and documentation are 50% of your grade before
you crack anything.**
