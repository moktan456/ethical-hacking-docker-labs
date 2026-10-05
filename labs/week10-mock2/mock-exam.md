# Week 10 Mock Exam 2: Penetration Testing Assessment

**Course:** CYB204 Ethical Hacking
**Duration:** 3 hours
**Total Marks:** 100
**Pass Mark:** 50%

---

## Candidate Instructions

### Before You Begin

1. **Read all instructions carefully** before starting
2. **Document everything** as you work, not at the end
3. **Take screenshots** of all significant findings
4. **Work systematically** through the phases

### Exam Environment

- **Target Network:** 10.10.60.0/24
- **Your Attack Platform:** 10.10.60.2 (week10mock2-attacker)
- **Access:** `docker exec -it week10mock2-attacker bash`

### How This Exam Is Different From Mock 1

There are only **3 flags** this time, deliberately uneven in difficulty:
one easy, two genuinely hard. **Flag 1 plus solid documentation is worth
50% on its own** — you can pass without cracking a single password or
hash, just by doing careful recon and writing it up properly. The other
50% is earned by two flags that actually require you to attack something
(a targeted password guess you have to construct yourself, and an offline
hash crack + decryption).

---

## Assessment Tasks

### Phase 1: Reconnaissance (30 minutes recommended)

Scan the network, identify every host and service, and document what you
find (versions, purpose, your initial read on each service's attack
surface). No flag here — this phase is graded entirely under
Documentation below, but skipping it will cost you later.

### Phase 2: Flag 1 — FTP Enumeration (EASY, 20 marks)

Investigate the web server and the FTP server. One of them allows
anonymous access and hands you Flag 1 directly once you connect and look
around. The other gives you a lead (not a flag) toward Phase 3.

**Capture Flag 1.**

### Phase 3: Flag 2 — Targeted Password Attack + Privilege Escalation (HARD, 25 marks)

The lead from Phase 2 narrows down an SSH account to a **small, specific
set of candidate passwords** — it does not hand you the password. Build
your own wordlist from the hint before reaching for Hydra; throwing
`rockyou.txt` at it blindly is not the intended path and you should be
able to explain in your report why a targeted list is both faster and
more realistic here.

Once you have a foothold, enumerate for privilege escalation
(`sudo -l` is a good start) and get root.

**Capture Flag 2.**

### Phase 4: Flag 3 — Credential Reuse, Hash Cracking, and Decryption (HARD, 25 marks)

Somewhere on the host you gained access to in Phase 3 is a script holding
credentials for another service. Use them to reach it and look for
anything stored there that isn't already in plaintext.

What you find won't be the flag yet — one more step (offline cracking)
reveals a password, and that password is also the key to something that
needs decrypting. Chain the two together.

**Capture Flag 3.**

### Phase 5: Documentation (30 marks)

- **Methodology (15 marks):** tools used, commands run, reasoning for
  each step, in order — including Phase 1's recon even though it had no
  flag attached.
- **Evidence (10 marks):** screenshots/output for every flag you
  captured and every major pivot, even failed attempts worth noting.
- **Security Recommendations (5 marks):** for each vulnerability found,
  a specific (not generic) remediation step.

---

## Marking Rubric

### Flags (70% total)

| Flag | Marks | Difficulty | Minimum Requirement |
|------|-------|-----------|--------------------|
| Flag 1: FTP enumeration | 20 | Easy | Screenshot of the FTP session + flag |
| Flag 2: Targeted password attack → GTFOBins privesc | 25 | Hard | Proof of the wordlist you built, the Hydra run, the shell, and the privesc command |
| Flag 3: Credential reuse → hash crack → decrypt | 25 | Hard | Proof of the DB query, the cracking run, and the decryption command |

### Documentation (30% total)

- **Methodology (15):** Excellent 13–15 · Good 10–12 · Satisfactory 7–9 · Poor 4–6 · Fail 0–3
- **Evidence (10):** Excellent 9–10 · Good 7–8 · Satisfactory 5–6 · Poor 3–4 · Fail 0–2
- **Recommendations (5):** Excellent 5 · Good 4 · Satisfactory 3 · Poor 1–2 · Fail 0

---

## Achievement Levels

### Pass (50%)
- Flag 1 captured (20%)
- Solid Phase 1 recon + basic methodology/evidence/recommendations for everything attempted, including Phase 1 (30%)
- **No hard flag required to pass.**

### Credit (60–69%)
- Flag 1 + one hard flag (20% + 25% = 45%), decent documentation (15–24%)

### Distinction (70–84%)
- Flag 1 + both hard flags (70%), good documentation (15%+)

### High Distinction (85–100%)
- All 3 flags, professional-grade documentation across all three criteria

---

## Submission Requirements

1. **Main Report (PDF):** student name/ID, executive summary, methodology, findings (including Phase 1 recon even without a flag), recommendations, screenshot appendix.
2. **File naming:** `StudentID_Week10Mock2.pdf` — max 50 MB.

---

## Academic Integrity

Individual assessment. Course materials and general online resources are
fine; collaboration with other students during the exam is not. Cite any
external resources used.

---

## Technical Support

```bash
docker compose ps
docker compose restart [service-name]
docker compose logs [service-name]
docker compose down && docker compose up -d
```

---

## Time Management Guide

**Hour 1:** Recon (0:00–0:25) → Flag 1 / FTP + web (0:25–0:45) → document so far (0:45–1:00)
**Hour 2:** Build the targeted wordlist and crack SSH (1:00–1:30) → privesc → Flag 2 (1:30–2:00)
**Hour 3:** DB credential reuse, hash crack, decrypt → Flag 3 (2:00–2:30) → final report polish (2:30–3:00)

**Remember:** complete documentation + Flag 1 alone already passes you.
Don't burn your whole exam on Flag 3 at the expense of writing anything up.

---

## Good Luck!

Methodology matters, evidence is key, and don't get stuck chasing the
last 25% at the cost of the guaranteed 50%.
