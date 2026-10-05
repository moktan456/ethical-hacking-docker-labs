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

- **Access:** `docker exec -it week10mock2-attacker bash`

No target network, host list, or service list is provided. Finding all
of that yourself **is** the first graded skill this exam tests — see the
rubric below. Your first command should establish where you are before
you decide what to scan.

### How This Exam Is Different From Mock 1

Recon and enumeration are graded step by step this time, not lumped into
a single "methodology" mark — see the rubric. **A thorough, well-
documented recon phase plus baseline write-up is worth 50% on its own**,
before you crack a single password or hash. The other 50% comes from two
genuinely hard flags.

---

## Assessment Tasks

### Phase 1: Network & Host Discovery

Work out what network you're actually on (don't assume — confirm it from
your own attack platform), then identify every live host in it.

### Phase 2: Port Scanning

For every host you found, identify open ports. A default/top-ports scan
is a start, not the deliverable — justify in your report whether a fuller
scan was warranted.

### Phase 3: Host / Service Enumeration

For every open port on every host, identify the service and version
running on it — **including services you never end up exploiting.**
Document what each one is, and your initial read on whether it's worth
pursuing.

### Phase 4: Web Enumeration

Thoroughly investigate whatever's running on port 80. Don't just load the
page — look at the source, check for anything that isn't shown to a
casual visitor.

### Phase 5: FTP Enumeration

Thoroughly investigate whatever's running on port 21. Test what access
level is actually available to you before assuming you need credentials
you don't have.

### Phase 6: File Discovery

Retrieve and read whatever files you can actually reach, on whichever
services allow it. Something you find here carries you into Phase 7.

### Phase 7: Targeted Password Attack + Privilege Escalation (HARD, 25 marks)

Something found earlier narrows an account down to a **small, specific
set of candidate passwords** — it does not hand you the password. Build
your own wordlist before reaching for Hydra; throwing `rockyou.txt` at it
blindly is not the intended path, and you should be able to explain in
your report why a targeted list is both faster and more realistic here.

Once you have a foothold, enumerate for privilege escalation
(`sudo -l` is a good start) and get root.

**Capture the flag this unlocks.**

### Phase 8: Credential Reuse, Hash Cracking, and Decryption (HARD, 25 marks)

Somewhere on the host from Phase 7 is a script holding credentials for
another service you identified back in Phase 3. Use them to reach it and
look for anything stored there that isn't already in plaintext.

What you find won't be the flag yet — one more step (offline cracking)
reveals a password, and that password is also the key to something that
needs decrypting. Chain the two together.

**Capture the flag this unlocks.**

### Phase 9: Documentation (20 marks)

- **Methodology (10 marks):** tools used, commands run, reasoning for
  each step, in order — Phases 1-6 included, even the ones with no flag
  directly attached.
- **Evidence (5 marks):** screenshots/output for everything you found and
  every major pivot, including dead ends worth noting.
- **Security Recommendations (5 marks):** for each vulnerability found, a
  specific (not generic) remediation step.

---

## Marking Rubric

### Recon & Enumeration (30% total)

Graded on what you actually found and documented, not on whether a flag
happened to come out of it.

| Item | Marks | What's Being Checked |
|------|-------|----------------------|
| Network / Host Discovery | 5 | Correctly determined the network range from your own platform; found every live host |
| Port Scanning | 5 | Full, justified port coverage per host (not just defaults, or a reasoned call that defaults were enough) |
| Host / Service Enumeration | 5 | Correct service + version identified on every open port you found — **including ones you didn't go on to exploit** |
| Web Enumeration | 5 | Evidence you actually inspected the web service beyond the rendered page |
| FTP Enumeration | 5 | Evidence you tested what access was actually available, and explored what it gave you |
| File Discovery | 5 | Files actually retrieved and read, including anything that turned into a flag |

### Hard Flags (50% total)

| Flag | Marks | Difficulty | Minimum Requirement |
|------|-------|-----------|--------------------|
| Targeted password attack → GTFOBins privesc | 25 | Hard | Proof of the wordlist you built, the Hydra run, the shell, and the privesc command |
| Credential reuse → hash crack → decrypt | 25 | Hard | Proof of the DB query, the cracking run, and the decryption command |

### Documentation (20% total)

- **Methodology (10):** Excellent 9–10 · Good 7–8 · Satisfactory 5–6 · Poor 3–4 · Fail 0–2
- **Evidence (5):** Excellent 5 · Good 4 · Satisfactory 3 · Poor 1–2 · Fail 0
- **Recommendations (5):** Excellent 5 · Good 4 · Satisfactory 3 · Poor 1–2 · Fail 0

---

## Achievement Levels

### Pass (50%)
- Full marks (or close to it) on Recon & Enumeration (30%) + baseline Documentation (20%)
- **No hard flag required to pass.**

### Credit (60–69%)
- Recon + documentation (50%) + one hard flag (25%)

### Distinction (70–84%)
- Recon + documentation (50%) + both hard flags (50%) partially, or one flag fully plus excellent documentation

### High Distinction (85–100%)
- Both hard flags, near-full recon marks, professional-grade documentation across all three criteria

---

## Submission Requirements

1. **Main Report (PDF):** student name/ID, executive summary, methodology, findings for every phase (1-6 included, even without a flag attached), recommendations, screenshot appendix.
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

**Hour 1:** Determine your network, discover hosts, full port scans, service enumeration (0:00–0:40) → web + FTP enumeration + file discovery (0:40–1:00)
**Hour 2:** Build the targeted wordlist and crack the foothold (1:00–1:30) → privesc → first hard flag (1:30–2:00)
**Hour 3:** Credential reuse, hash crack, decrypt → second hard flag (2:00–2:30) → final report polish (2:30–3:00)

**Remember:** thorough recon + documentation alone already passes you.
Don't burn your whole exam chasing the last 50% at the cost of the
guaranteed half.

---

## Good Luck!

Methodology matters, evidence is key, and don't get stuck chasing the
hard flags at the cost of the recon marks that are entirely within your
control.
