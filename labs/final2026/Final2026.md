# Final Examination: Penetration Test — Student Worksheet

**Name:** ************\_************ **Student ID:** ********\_********

**Date:** ******\_******

## Lab Scenario

You have been engaged to perform a penetration test on **Meridian Freight
Pty Ltd**'s application server and supporting systems. Management believes
the environment is secure because an external auditor scans it regularly.
Your job is to prove that automated scanning is not enough.

This is the course's capstone examination — no walkthrough, no hints.
Approach it the way you would approach a real engagement: recon first, then
enumerate every service you find, then look for a way in, then escalate.

**Time Limit:** 3 hours (plus 15 minutes at the start to build and launch
the Docker environment — the clock on the 3 hours starts once your lab is
up).

**Marks:** 100 total, across six graded phases. Marks are awarded for the
five flags **and** for the commands, evidence, and written analysis that
support them. Record your commands as you go; a flag with no working shown
earns partial marks only.

**Submission:** Complete this worksheet by hand and submit it with your
findings.

---

## Pre-Lab Setup (15 minutes — not counted against the 3 hours)

□ Delete any previous copy of the repository, then clone a completely fresh
copy — do **not** `git pull` an old clone, as the exam must run on the current
version:
```bash
# Remove your previous clone first (adjust the path if yours differs)
rm -rf ethical-hacking-docker-labs

# Clone a fresh copy
git clone https://github.com/moktan456/ethical-hacking-docker-labs
cd ethical-hacking-docker-labs
```
□ Build the base attacker image (skip if already built this term):
```bash
# Using make (Linux / macOS / Git Bash / WSL2)
make build-base

# Direct docker command (Windows PowerShell / Command Prompt)
docker build -t ethical-base -f base.Dockerfile . #(Don't miss this dot)
```
□ Start the lab environment:
```bash
cd labs/final2026
docker compose up -d
```
□ Wait ~60 seconds for the targets to finish installing their services.
□ Access the attacker machine:
```bash
docker exec -it final2026-attacker bash
```
□ Verify you are in the Kali container: `whoami` (should show `root`).

> No target network, host list, or service list is given. Working out where
> you are and what is reachable is the first thing you must do yourself.

---

## Phase 1: Reconnaissance & Web Enumeration (20 marks)

### 1.1 Network & host discovery (5 marks)

Confirm which network your attacker container is on, then find every live
host on it.

**Command(s) used:**
```bash
_________________________________________________
_________________________________________________
```

**Hosts discovered:**
| IP Address | Hostname | Status |
|------------|----------|--------|
| | | |
| | | |
| | | |
| | | |

### 1.2 Port & service scan (7 marks)

Scan the hosts you found and identify the **service and version** on each
open port — including services you do not end up exploiting.

**Command used:**
```bash
_________________________________________________
```

**Open ports discovered:**
| Host | Port | Service | Version |
|------|------|---------|---------|
| | | | |
| | | | |
| | | | |
| | | | |
| | | | |

### 1.3 Web content analysis — Flag 1 (4 marks)

Examine the web service. Do not stop at the rendered page — look at the
source and anything not shown to a casual visitor.

**Command(s) used:**
```bash
_________________________________________________
```

**Flag 1:** ****************\_****************

### 1.4 Username naming convention (4 marks)

From the information on the web service, work out the organisation's account
naming convention and build a candidate username list.

**Staff discovered:**
| Full Name | Email | Likely Username |
|-----------|-------|-----------------|
| | | |
| | | |
| | | |
| | | |
| | | |

**Username naming convention:** ****************\_****************

---

## Phase 2: SMB Enumeration (15 marks)

### 2.1 Enumerate the file-sharing service (6 marks)

List the shares offered by the file server and determine what access you
have without credentials.

**Command(s) used:**
```bash
_________________________________________________
_________________________________________________
```

**Share(s) found:** ****************\_****************

**Access level available (authenticated / anonymous / guest):**
****************\_****************

### 2.2 Retrieve the files — Flag 2 (5 marks)

**Files retrieved:**
| Filename | Share | Downloaded |
|----------|-------|------------|
| | | □ |
| | | □ |

**Flag 2:** ****************\_****************

### 2.3 Interpret the password policy (4 marks)

Read the policy you recovered and write out, in your own words, the rule it
sets for temporary passwords — you will need this in Phase 3.

****************\_\_\_\_****************

****************\_\_\_\_****************

---

## Phase 3: SSH Brute Force & Foothold (20 marks)

### 3.1 Build your attack lists (8 marks)

Build a **username list** from Phase 1 and a **small, targeted password
list** from the policy you found in Phase 2. Do **not** throw the whole of
`rockyou.txt` at this — the policy narrows the password to a handful of
candidates.

**Username list file:** ****************\_****************

**Password list file:** ****************\_****************

**Passwords you included, and how the policy produced them:**

****************\_\_\_\_****************

### 3.2 Brute force SSH (6 marks)

**Command used:**
```bash
_________________________________________________
```

**Successful credentials found:**
Username: ********\_******** Password: ********\_********

### 3.3 Log in and read the flag — Flag 3 (3 marks)

**Login successful:** □ Yes □ No

```bash
whoami: _________________
id:     _________________
```

**Flag 3:** ****************\_****************

### 3.4 Justify your approach (3 marks)

Explain why a small targeted wordlist was the right call here — both faster
and more realistic than a full `rockyou.txt` run.

****************\_\_\_\_****************

****************\_\_\_\_****************

---

## Phase 4: Privilege Escalation (20 marks)

### 4.1 Identify the misconfiguration (6 marks)

Enumerate the foothold for a privilege-escalation path. Check what you can
run as another user, look at permissions on sensitive system files, and
note anything that should not be writable.

**Command(s) used:**
```bash
_________________________________________________
_________________________________________________
```

**Misconfiguration found:** ****************\_****************

### 4.2 Exploit it to get root — Flag 4 (8 marks)

**Command(s) used:**
```bash
_________________________________________________
_________________________________________________
```

**Proof you are root (`id` output):** ****************\_****************

**Flag 4:** ****************\_****************

### 4.3 Assess and remediate (6 marks)

Why is the misconfiguration you exploited so dangerous? What is the correct
secure setting, and how would you remediate it?

****************\_\_\_\_****************

****************\_\_\_\_****************

****************\_\_\_\_****************

---

## Phase 5: Credential Reuse, Hash Cracking & Decryption (20 marks)

### 5.1 Find reusable credentials and connect (6 marks)

Somewhere on the application server is a script or config holding
credentials for a **database service** you identified back in Phase 1. Find
it and use it to connect to that database.

> **Tip:** if your MySQL/MariaDB client reports *"SSL is required, but the
> server does not support it"*, add `--ssl=0` (or `--skip-ssl`) to the
> `mysql` command — the server here does not offer TLS.

**Where the credentials were found:** ****************\_****************

**Command used to connect:**
```bash
_________________________________________________
```

### 5.2 Extract and crack the hash (6 marks)

The database stores a hash, not a plaintext. Enumerate the database, extract
the hash, and crack it offline.

**Hash extracted:** ****************\_****************

**Cracking command used:**
```bash
_________________________________________________
```

**Cracked plaintext:** ****************\_****************

### 5.3 Decrypt the protected file — Flag 5 (4 marks)

The cracked plaintext is also the key to an encrypted file left on the app
server. Decrypt it.

**Encrypted file:** ****************\_****************

**Decryption command used:**
```bash
_________________________________________________
```

**Flag 5:** ****************\_****************

### 5.4 Explain the chain (4 marks)

In your own words, explain how credential reuse, offline cracking, and
decryption chained together to reach the final flag.

****************\_\_\_\_****************

****************\_\_\_\_****************

---

## Phase 6: Findings & Remediation (5 marks)

For each vulnerability you exploited, give it a risk rating (e.g.
Critical / High / Medium / Low) and one **specific** remediation step — not
a generic "patch everything."

| Vulnerability | Risk rating | Specific remediation |
|---------------|-------------|----------------------|
| | | |
| | | |
| | | |
| | | |
| | | |

---

## Lab Cleanup

Before you leave:
□ Document all findings
□ Stop the lab: `docker compose down`
□ Submit this completed worksheet

---

## Instructor Use Only

**Grade Breakdown (100 marks):**

Phase 1 — Reconnaissance & Web Enumeration ..... ___/20
- 1.1 Network & host discovery: ___/5
- 1.2 Port & service scan (service + version): ___/7
- 1.3 Web content analysis — Flag 1: ___/4
- 1.4 Username naming convention: ___/4

Phase 2 — SMB Enumeration ..................... ___/15
- 2.1 Enumerate shares + access level: ___/6
- 2.2 Retrieve files — Flag 2: ___/5
- 2.3 Interpret the password policy: ___/4

Phase 3 — SSH Brute Force & Foothold .......... ___/20
- 3.1 Build targeted attack lists: ___/8
- 3.2 Brute force SSH: ___/6
- 3.3 Log in — Flag 3: ___/3
- 3.4 Justify your approach: ___/3

Phase 4 — Privilege Escalation ................ ___/20
- 4.1 Identify the misconfiguration: ___/6
- 4.2 Exploit to root — Flag 4: ___/8
- 4.3 Assess and remediate: ___/6

Phase 5 — Credential Reuse / Crack / Decrypt .. ___/20
- 5.1 Find reusable credentials and connect: ___/6
- 5.2 Extract and crack the hash: ___/6
- 5.3 Decrypt the file — Flag 5: ___/4
- 5.4 Explain the chain: ___/4

Phase 6 — Findings & Remediation .............. ___/5

**Total Score: ___/100**

**Comments:**

****************\_\_\_\_****************

****************\_\_\_\_****************
