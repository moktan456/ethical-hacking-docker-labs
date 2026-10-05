# Week 10 Mock Exam 2: Comprehensive Penetration Test

A challenging 3-hour practical exam covering Weeks 1-9. Recon and
enumeration are graded step by step (30% of the total), two flags are
genuinely hard (25% each), and documentation rounds it out (20%).
Thorough recon + documentation alone already equals a 50% pass — no
exploit required to pass, but two real ones are needed to score high.

---

## Scenario

You have been contracted by **CyberGuard Corp** to test their internal
network, capture flags as proof of compromise, and document your
methodology.

**Time Limit:** 3 hours
**Starting Point:** `docker exec -it week10mock2-attacker bash`

No network range, host list, or service list is given anywhere in this
file — working that out yourself is the first graded skill (see the
rubric below). Instructors: the real topology is in `docker-compose.yaml`
and `mock-exam-walkthrough.md`; don't hand either to students before the
session ends.

---

## Quick Start

```bash
cd labs/week10-mock2
docker compose up -d
docker exec -it week10mock2-attacker bash
```

Give the `ssh-target` and `database` containers 30-60 seconds to finish
installing packages before scanning them.

---

## Exam Structure & Marking Guide

**Total Marks: 100%**

### Part A: Recon & Enumeration (30%)

Graded on what was actually found and documented, not on whether a flag
happened to come out of it.

| Item | Marks | Concepts Tested |
|------|-------|----------------|
| Network / Host Discovery | 5% | Week 4: determining scope from your own platform, finding live hosts |
| Port Scanning | 5% | Week 4: full, justified port coverage |
| Host / Service Enumeration | 5% | Week 5: service + version on every open port, including ones never exploited |
| Web Enumeration | 5% | Week 5: inspecting beyond the rendered page |
| FTP Enumeration | 5% | Week 5: testing actual access level, exploring what it gives |
| File Discovery | 5% | Retrieving and reading whatever's reachable |

### Part B: Hard Flags (50%)

| Flag | Difficulty | Marks | Concepts Tested |
|------|-----------|-------|----------------|
| Targeted Password Attack → Privesc | ⭐⭐⭐ HARD | 25% | Week 6: Hydra against a *built* wordlist; Week 8: GTFOBins (sudo `find`) |
| Credential Reuse → Hash Crack → Decrypt | ⭐⭐⭐ HARD | 25% | Week 9: credential reuse; Week 6: offline hash cracking (john/hashcat); openssl decryption |

### Part C: Documentation (20%)

| Component | Marks | Requirements |
|-----------|-------|-------------|
| Methodology | 10% | Every phase, including recon — even where no flag was attached |
| Evidence | 5% | Output/screenshots for every finding and major pivot |
| Recommendations | 5% | One specific remediation per vulnerability found |

---

## Minimum Pass Criteria (50%)

**To achieve 50%, students must:**

1. **Fully complete and document Recon & Enumeration (30%)** — network/host discovery, port scanning, service enumeration (including unexploited services), web enumeration, FTP enumeration, file discovery.
2. **Baseline Documentation (20%)** — write up everything above properly, even where it didn't lead to a flag.

**No hard flag is required to pass.** This is intentional — it rewards
disciplined methodology on its own, separately from exploitation skill.

---

## Higher Achievement

- **60–69%:** Full recon + documentation (50%) + one hard flag (25%).
- **70–84%:** Full recon + documentation (50%) + most of both hard flags.
- **85–100%:** Both hard flags fully, near-complete recon marks,
  professional-grade documentation across all three criteria.

---

## Concepts Covered (Weeks 1-9)

| Week | Concept | How It's Tested |
|------|---------|----------------|
| Week 4 | Reconnaissance (Nmap) | Network/host discovery, port scanning |
| Week 5 | Service enumeration | Host/service, web, FTP enumeration, file discovery |
| Week 6 | Password/hash attacks | Hydra (hard flag 1), john/hashcat (hard flag 2) |
| Week 8 | Privilege escalation | GTFOBins `sudo find` (hard flag 1) |
| Week 9 | Lateral movement / credential reuse | DB creds leaked on ssh-target (hard flag 2) |

---

## Essential Tools (pre-installed on the attacker)

`nmap` · `curl` · `hydra` · `ssh`/`sshpass` · `mysql` (use `--skip-ssl`
against this MariaDB image) · `john` / `hashcat` · `openssl`

---

## Flag Format

Flags follow the format `flag{mock2_description_with_numbers}`. No
example flag is given here — the exact strings are in the compose file
and the instructor-only walkthrough.

---

## Cleanup

```bash
cd labs/week10-mock2
docker compose down
```

---

## Ethical Hacking Reminder

⚠️ All techniques here are for use inside this isolated Docker
environment only. Never attempt them against systems you don't own or
don't have explicit written authorisation to test.

---

## Differences from week10-mock

**week10-mock** (original): 3 services, 2 flags, linear, ~90 minutes,
target network given up front.

**week10-mock2** (this lab): 5 services, recon graded as its own 30%
block instead of a single pass/fail flag, 2 deliberately hard flags
(25% each), a full 3-hour exam, and nothing about the network or
services handed to the student — scope discovery is itself assessed.

---

## Support

```bash
docker compose ps
docker compose logs [service_name]
# If a target container is stuck restarting with "dpkg was interrupted"
# in its logs (can happen if Docker itself crashed mid-provisioning):
docker compose up -d --force-recreate [service_name]
```

---

**Good luck! Methodology and documentation are just as important as finding flags.**
