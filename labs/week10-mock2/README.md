# Week 10 Mock Exam 2: Comprehensive Penetration Test

A challenging 3-hour practical exam covering Weeks 1-9. Only 3 flags,
deliberately uneven: 1 easy, 2 genuinely hard. Flag 1 plus solid
documentation already equals 50% of the grade — the other 50% has to be
earned by actually attacking something.

---

## Scenario

You have been contracted by **CyberGuard Corp** to test their internal
network, capture flags as proof of compromise, and document your
methodology.

**Network Range:** 10.10.60.0/24
**Time Limit:** 3 hours
**Starting Point:** Attacker machine at 10.10.60.2

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

## Lab Network

| Container | IP | Services |
|-----------|-----|----------|
| week10mock2-attacker | 10.10.60.2 | Kali (ethical-base) — your attack platform |
| week10mock2-web | 10.10.60.10 | HTTP :80 — corporate site (recon lead, no flag) |
| week10mock2-ftp | 10.10.60.11 | FTP :21 — anonymous access, Flag 1 |
| week10mock2-ssh | 10.10.60.12 | SSH :22 — Flag 2 (targeted password attack + GTFOBins) |
| week10mock2-db | 10.10.60.13 | MariaDB :3306 — Flag 3 (credential reuse + hash crack + decrypt) |

---

## Exam Structure & Marking Guide

**Total Marks: 100%**

### Part A: Flags (70%)

| Flag | Difficulty | Marks | Concepts Tested |
|------|-----------|-------|----------------|
| Flag 1: FTP Enumeration | ⭐ EASY | 20% | Week 4/5: Nmap, anonymous FTP |
| Flag 2: Targeted Password Attack → Privesc | ⭐⭐⭐ HARD | 25% | Week 6: Hydra against a *built* wordlist; Week 8: GTFOBins (sudo `find`) |
| Flag 3: Credential Reuse → Hash Crack → Decrypt | ⭐⭐⭐ HARD | 25% | Week 9: credential reuse; Week 6: offline hash cracking (john/hashcat); openssl decryption |

### Part B: Documentation (30%)

| Component | Marks | Requirements |
|-----------|-------|-------------|
| Methodology | 15% | Every phase, including recon — even the phase with no flag attached |
| Evidence | 10% | Output/screenshots for every flag and major pivot |
| Recommendations | 5% | One specific remediation per vulnerability found |

---

## Minimum Pass Criteria (50%)

**To achieve 50%, students must:**

1. **Capture Flag 1 (20%)** — anonymous FTP access, no exploitation needed.
2. **Document recon + the attempt narrative fully (30%)** — including
   Phase 1 (network/service enumeration) even though it carries no flag,
   and whatever was tried on Flags 2/3 even if incomplete.

**No hard flag is required to pass.** This is intentional — it rewards
disciplined methodology on its own, separately from exploitation skill.

---

## Higher Achievement

- **60–69%:** Flag 1 + one hard flag, decent documentation.
- **70–84%:** Flag 1 + both hard flags, good documentation.
- **85–100%:** All 3 flags, professional-grade documentation across
  methodology, evidence, and recommendations.

---

## Concepts Covered (Weeks 1-9)

| Week | Concept | How It's Tested |
|------|---------|----------------|
| Week 4 | Reconnaissance (Nmap) | Required throughout |
| Week 5 | Service enumeration | FTP, SSH, MariaDB |
| Week 6 | Password/hash attacks | Hydra (Flag 2), john/hashcat (Flag 3) |
| Week 8 | Privilege escalation | GTFOBins `sudo find` (Flag 2) |
| Week 9 | Lateral movement / credential reuse | DB creds leaked on ssh-target (Flag 3) |

---

## Essential Tools (pre-installed on the attacker)

`nmap` · `curl` · `hydra` · `ssh`/`sshpass` · `mysql` (use `--skip-ssl`
against this MariaDB image) · `john` / `hashcat` · `openssl`

---

## Flag Format

`flag{mock2_description_with_numbers}` — e.g. `flag{mock2_ftp_an0nym0us_acc3ss}`

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

**week10-mock** (original): 3 services, 2 flags, linear, ~90 minutes.

**week10-mock2** (this lab): 5 services, 3 flags deliberately uneven in
difficulty (1 easy, 2 hard), a full 3-hour exam, and a grading structure
where documentation + the one easy flag already guarantees a pass —
exploitation skill is what separates a pass from a high grade, not what
gates the pass itself.

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
