# Alternative Midterm Examination: Penetration Test — Student Worksheet

**Name:** ************\_************ **Date:** ******\_******

## Lab Scenario

You have been hired to perform a penetration test on Solari Analytics Inc.'s
web server. The CISO believes the system is secure since they run regular
vulnerability scans. Your job is to prove that automated scanning isn't
enough. This is the course's examination — no walkthrough, no hints.
Approach it the way you'd approach a real engagement.

**Time Limit:** 3 hours
**Submission:** Complete this worksheet and submit your findings

## Pre-Lab Setup

□ Pull the latest changes, or clone a fresh copy of the repository, so you're
running the current version of this lab:
```bash
git pull
# or, for a completely new clone:
git clone <repository-url>
```
□ Build the base attacker image:
```bash
# Using make (Linux / macOS / Git Bash / WSL2)
make build-base

# Direct docker command (Windows PowerShell / Command Prompt)
docker build -t ethical-base -f base.Dockerfile . #(Don't miss this dot)
```
□ Start the lab environment: `docker compose up -d`
□ Access attacker machine: `docker exec -it altmidterm2026-attacker bash`
□ Verify you're in the Kali container: `whoami` (should show "hacker")

---

## Phase 1: Reconnaissance (30 points)

### 1.1 Network Discovery (13 points)

Run a network scan to identify all hosts in the lab network.

**Command used:**

```bash
_________________________________________________
```

**Hosts discovered:**
| IP Address | Hostname | Status |
|------------|----------|---------|
| | | |
| | | |
| | | |

### 1.2 Port Scanning (17 points)

Scan the target services for open ports.

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

---

## Phase 2: Web Application Enumeration (20 points)

### 2.1 Web Content Analysis (13 points)

Examine the web application for useful information.

**Command used:**

```bash
_________________________________________________
```

**Employee information discovered:**
| Full Name | Email | Potential Username |
|-----------|-------|-------------------|
| | | |
| | | |
| | | |
| | | |
| | | |

**Flag captured:** ****************\_****************

### 2.2 Username Generation (7 points)

Based on the naming convention, create a username list.

**Username list created:** □ Yes □ No

**File location:** ****************\_****************

---

## Phase 3: FTP Enumeration (9 points)

### 3.1 FTP Access (5 points)

Attempt to access the FTP service.

**Connection command:**

```bash
_________________________________________________
```

**Authentication method:** **********\_\_\_**********

**Success:** □ Yes □ No

**Flag captured:** ****************\_****************

### 3.2 FTP File Discovery (4 points)

Explore the FTP directory structure and identify interesting files.

**Directories found:**

****************\_\_\_\_****************

**Files discovered:**
| Filename | Size | Location | Downloaded |
|----------|------|----------|------------|
| | | | □ |
| | | | □ |
| | | | □ |

---

## Phase 4: SSH Attack (16 points)

### 4.1 Password List Creation (4 points)

Create a password list for brute force attacks. Use only the **top 10 passwords
from `/usr/share/wordlists/rockyou.txt`** — not the full list (`head -n 10
/usr/share/wordlists/rockyou.txt`).

**Hint:** rockyou alone may not be enough. Weak passwords are sometimes just
a username with a short numeric suffix tacked on — try adding each
discovered username, with a couple of common two-digit suffixes appended, to
your list.

**Password list file:** ****************\_****************

### 4.2 SSH Brute Force (8 points)

Perform a brute force attack against the SSH service.

**Command used:**

```bash
_________________________________________________
```

**Successful credentials found:**
Username: ********\_******** Password: ********\_********

### 4.3 SSH Access (4 points)

Log into the system with discovered credentials.

**Login successful:** □ Yes □ No

**User privileges discovered:**

```bash
whoami: _________________
id: _____________________
```

**Flag captured:** ****************\_****************

---

## Phase 5: File Analysis (13 points)

### 5.1 System Exploration (4 points)

Explore the system for interesting files.

**Commands used:**

```bash
_________________________________________________
_________________________________________________
```

**Interesting files found:**

****************\_\_\_\_****************

### 5.2 File Decryption (9 points)

Attempt to decrypt any encrypted files found.

**Hint:** this file was encrypted with OpenSSL's symmetric cipher, AES-256-CBC
with a salt. Only the password is unknown — the tool and algorithm aren't.
Don't stop at the encrypted file itself — check what else was left
alongside it on the FTP server, and re-check the web directory for
anything about the people involved.

```bash
openssl enc -aes-256-cbc -d -salt -in <file> -out <output> -k <password>
```

**Encrypted file:** ****************\_****************

**Decryption attempts:**
| Password Tried | Success |
|----------------|---------|
| | □ |
| | □ |
| | □ |

**Successful decryption password:** ********\_\_\_\_********

**Decrypted content (first 3 lines):**

```
_________________________________________________
_________________________________________________
_________________________________________________
```

**Flag captured:** ****************\_****************

---

## Phase 6: Privilege Escalation (12 points)

### 6.1 SUID Binary Enumeration (4 points)

Find binaries with the SUID bit set — one of them isn't part of a stock
Ubuntu install.

**Command used:**

```bash
_________________________________________________
```

**SUID binary found (not stock):** ****************\_****************

### 6.2 Root Exploitation (4 points)

Use the misconfiguration to get a root shell.

**Command used:**

```bash
_________________________________________________
```

**Flag captured:** ****************\_****************

### 6.3 Reflection (4 points)

Why does a SUID bit on a binary like `find` grant full root access when a
low-privilege user runs it? (Hint: check GTFOBins for that binary, and note
what the `-p` flag does when spawning a shell from it.)

****************\_\_\_\_****************

****************\_\_\_\_****************

---

## Lab Cleanup

Before leaving:
□ Document all findings
□ Stop the lab: `docker compose down`
□ Submit completed worksheet

---

## Instructor Use Only

**Grade Breakdown:**

- Reconnaissance: \_\_\_/30
- Web Enumeration: \_\_\_/20
- FTP Access: \_\_\_/9
- SSH Attack: \_\_\_/16
- File Analysis: \_\_\_/13
- Privilege Escalation: \_\_\_/12

**Total Score: \_\_\_/100**

**Note:** Phases 1–2 (Reconnaissance + Web Application Enumeration) are
weighted at 50 of the 100 points by design — a student who completes
them fully, including capturing the web-recon flag, has already earned
half the exam regardless of how far they get afterward. This is
intentional: it rewards solid fundamentals even for students who don't
reach privilege escalation.

**Comments:**

****************\_\_\_\_****************

****************\_\_\_\_****************

****************\_\_\_\_****************
