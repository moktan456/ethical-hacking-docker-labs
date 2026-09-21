# Week 10 Mock Exam — Practice Penetration Test

**Name:** _________________________ **Date:** _____________

## Lab Scenario

TechNova Solutions has asked for a practice security review before their
real audit next month. This is a rehearsal for the real capstone exam —
same skills, same format, a friendlier target. Work through it the way
you'd approach a real engagement: recon first, then enumerate every
service you find, then look for a way in.

**Time Limit:** 90 minutes
**Submission:** Complete this worksheet and submit your findings

## Pre-Lab Setup

□ Start the lab environment: `docker compose up -d`
□ Access attacker machine: `docker exec -it week10mock-attacker bash`
□ Verify you're in the attacker container: `whoami`

---

## Phase 1: Reconnaissance (20 points)

### 1.1 Network Discovery

**Command used:**
```bash
_________________________________________________
```

**Hosts discovered:**
| IP Address | Status |
|------------|--------|
| | |
| | |
| | |

### 1.2 Port Scanning

**Command used:**
```bash
_________________________________________________
```

**Open ports discovered:**
| Host | Port | Service |
|------|------|---------|
| | | |
| | | |
| | | |

---

## Phase 2: Web Enumeration (15 points)

**Command used:**
```bash
_________________________________________________
```

**Staff names found:** _________________________________

**Username naming convention:** _________________________________

**Question:** One username is named directly, but not in the visible page
text. Where did you find it, and what is it?

_________________________________

---

## Phase 3: FTP Enumeration & File Recovery (20 points)

### 3.1 FTP Access

**Connection command:**
```bash
_________________________________________________
```

**Authentication method used:** _______________________

### 3.2 File Discovery

**Files found on the FTP server:**
| Filename | Downloaded |
|----------|------------|
| | □ |
| | □ |

**Question:** What password policy did the plaintext file describe?

_________________________________

### 3.3 Decrypting the Locked File

**Command used to decrypt it:**
```bash
_________________________________________________
```

**Password used:** _________________________________

**What did the decrypted file confirm?**

_________________________________

---

## Phase 4: SSH Foothold (25 points)

### 4.1 Login

**Command used:**
```bash
_________________________________________________
```

**Username / password that worked:**
Username: _________________ Password: _________________

**User flag found:** _________________________________

**Question:** Where did this password come from — was it guessed, or
recovered from something you already found? Explain the connection.

_________________________________

---

## Phase 5: Privilege Escalation (10 points)

**Command used to check your current privileges:**
```bash
_________________________________________________
```

**Command used to escalate:**
```bash
_________________________________________________
```

**Root flag found:** _________________________________

**Question:** What specific misconfiguration made this escalation
possible?

_________________________________

---

## Phase 6: Analysis & Reporting (10 points)

### 6.1 Vulnerability Summary

List the vulnerabilities you found, in the order you exploited them:

1. _________________________________________________
2. _________________________________________________
3. _________________________________________________
4. _________________________________________________

### 6.2 Risk Assessment

| Vulnerability | Risk Level (Low/Medium/High/Critical) |
|----------------|----------------------------------------|
| | |
| | |
| | |
| | |

### 6.3 Recommendations

Give one specific fix for each vulnerability above (not "use better
security" — name the actual change):

1. _________________________________________________
2. _________________________________________________
3. _________________________________________________
4. _________________________________________________

---

## Bonus Questions (Extra Credit — 5 points each)

1. **Password reuse:** This lab's password appeared in more than one
   place. Why is password reuse across services a bigger risk than a
   single weak password on its own?

   _________________________________________________

2. **Detection:** If TechNova had proper logging, what specific event in
   this exercise would have been the earliest sign of an attack?

   _________________________________________________

---

## Lab Cleanup

Before leaving:
□ Document all findings
□ Stop the lab: `docker compose down`
□ Submit completed worksheet

---

## Instructor Use Only

**Grade Breakdown:**
- Reconnaissance: ___/20
- Web Enumeration: ___/15
- FTP Enumeration & Recovery: ___/20
- SSH Foothold: ___/25
- Privilege Escalation: ___/10
- Analysis & Reporting: ___/10
- Bonus: ___/10

**Total Score: ___/100 (+ ___/10 bonus)**

**Comments:**
_________________________________________________
_________________________________________________

---

## Optional: CTF Challenge

Once you have completed all exercises above, test your skills with an
optional Capture The Flag challenge.

See **[ctf-challenge.md](./ctf-challenge.md)** for objectives.

Two flags to capture: `user.txt` and `root.txt`
Flag format: `flag{...}`
