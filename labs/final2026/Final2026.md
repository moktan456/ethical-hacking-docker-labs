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

**Marks:** 50 total — **five flags, 10 marks each.** Marks are awarded for
the correct flag **and** for the commands and evidence that led to it.
Record your commands as you go; a flag with no working shown earns partial
marks only.

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

## Phase 1: Reconnaissance & Web Enumeration — Flag 1 (10 marks)

### 1.1 Establish your network and discover hosts

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

### 1.2 Port & service scan

Scan the hosts you found and identify the service and version on each open
port — including services you do not end up exploiting.

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

### 1.3 Web content analysis

Examine the web service. Do not stop at the rendered page — look at the
source and anything not shown to a casual visitor.

**Command(s) used:**
```bash
_________________________________________________
```

**Staff discovered (for later username building):**
| Full Name | Email | Likely Username |
|-----------|-------|-----------------|
| | | |
| | | |
| | | |
| | | |
| | | |

**Username naming convention:** ****************\_****************

**Flag 1:** ****************\_****************

---

## Phase 2: SMB Enumeration — Flag 2 (10 marks)

### 2.1 Enumerate the file-sharing service

List the shares offered by the file server and access what you are allowed
to without credentials.

**Command(s) used:**
```bash
_________________________________________________
_________________________________________________
```

**Share(s) found:** ****************\_****************

**Access level available (authenticated / anonymous / guest):**
****************\_****************

### 2.2 Retrieve and read the files

**Files retrieved:**
| Filename | Share | Downloaded |
|----------|-------|------------|
| | | □ |
| | | □ |

**The temporary-password policy (write it out — you need it in Phase 3):**

****************\_\_\_\_****************

**Flag 2:** ****************\_****************

---

## Phase 3: SSH Brute Force & Foothold — Flag 3 (10 marks)

### 3.1 Build your attack lists

Build a **username list** from Phase 1 and a **small, targeted password
list** from the policy you found in Phase 2. Do **not** throw the whole of
`rockyou.txt` at this — the policy narrows the password to a handful of
candidates, and a targeted list is both faster and more realistic.

**Username list file:** ****************\_****************

**Password list file:** ****************\_****************

**Passwords you included, and why:**

****************\_\_\_\_****************

### 3.2 Brute force SSH

**Command used:**
```bash
_________________________________________________
```

**Successful credentials found:**
Username: ********\_******** Password: ********\_********

### 3.3 Log in and read the flag

**Login successful:** □ Yes □ No

```bash
whoami: _________________
id:     _________________
```

**Flag 3:** ****************\_****************

---

## Phase 4: Privilege Escalation — Flag 4 (10 marks)

### 4.1 Enumerate for a privilege-escalation path

Look for misconfigurations that let your low-privilege account become root.
Check what you can run as another user, look at file permissions on
sensitive system files, and note anything that should not be writable.

**Command(s) used:**
```bash
_________________________________________________
_________________________________________________
```

**Misconfiguration found:** ****************\_****************

### 4.2 Exploit it to get root

**Command(s) used:**
```bash
_________________________________________________
_________________________________________________
```

**Proof you are root (`id` output):** ****************\_****************

**Flag 4:** ****************\_****************

### 4.3 Reflection

Why is the misconfiguration you exploited so dangerous? What is the correct
secure setting, and how would you remediate it?

****************\_\_\_\_****************

****************\_\_\_\_****************

---

## Phase 5: Credential Reuse, Hash Cracking & Decryption — Flag 5 (10 marks)

### 5.1 Find reusable credentials

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

### 5.2 Extract and crack

The database stores a hash, not a plaintext. Extract it and crack it
offline.

**Hash extracted:** ****************\_****************

**Cracking command used:**
```bash
_________________________________________________
```

**Cracked plaintext:** ****************\_****************

### 5.3 Decrypt the protected file

The cracked plaintext is also the key to an encrypted file left on the app
server. Decrypt it.

**Encrypted file:** ****************\_****************

**Decryption command used:**
```bash
_________________________________________________
```

**Flag 5:** ****************\_****************

---

## Lab Cleanup

Before you leave:
□ Document all findings
□ Stop the lab: `docker compose down`
□ Submit this completed worksheet

---

## Instructor Use Only

**Grade Breakdown (10 marks each):**

- Flag 1 — Web recon & username convention: \_\_\_/10
- Flag 2 — Anonymous SMB share & policy: \_\_\_/10
- Flag 3 — Targeted SSH brute force foothold: \_\_\_/10
- Flag 4 — Privilege escalation to root: \_\_\_/10
- Flag 5 — Credential reuse → hash crack → decrypt: \_\_\_/10

**Total Score: \_\_\_/50**

**Comments:**

****************\_\_\_\_****************

****************\_\_\_\_****************
