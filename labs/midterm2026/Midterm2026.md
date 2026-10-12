# Midterm Examination: Penetration Test — Student Worksheet

**Name:** ************\_************ **Date:** ******\_******

## Lab Scenario

You have been hired to perform a penetration test on De-ICE Corporation's web server. The CEO believes the system is secure since they run regular Nessus scans. Your job is to prove that automated scanning isn't enough. This is the course's examination — no walkthrough, no hints. Approach it the way you'd approach a real engagement.

**Time Limit:** 2 hours  
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
□ Access attacker machine: `docker exec -it midterm2026-attacker bash`  
□ Verify you're in the Kali container: `whoami` (should show "root")

---

## Phase 1: Reconnaissance (18 points)

### 1.1 Network Discovery (8 points)

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

### 1.2 Port Scanning (10 points)

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

## Phase 2: Web Application Enumeration (12 points)

### 2.1 Web Content Analysis (8 points)

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

### 2.2 Username Generation (4 points)

Based on the naming convention, create a username list.

**Username list created:** □ Yes □ No

**File location:** ****************\_****************

---

## Phase 3: FTP Enumeration (12 points)

### 3.1 FTP Access (6 points)

Attempt to access the FTP service.

**Connection command:**

```bash
_________________________________________________
```

**Authentication method:** **********\_\_\_**********

**Success:** □ Yes □ No

**Flag captured:** ****************\_****************

### 3.2 FTP File Discovery (6 points)

Explore the FTP directory structure and identify interesting files.

**Directories found:**

---

**Files discovered:**
| Filename | Size | Location | Downloaded |
|----------|------|----------|------------|
| | | | □ |
| | | | □ |
| | | | □ |

---

## Phase 4: SSH Attack (23 points)

### 4.1 Password List Creation (6 points)

Create a password list for brute force attacks. Use only the **top 10 passwords
from `/usr/share/wordlists/rockyou.txt`** — not the full list (`head -n 10
/usr/share/wordlists/rockyou.txt`).

**Hint:** rockyou alone may not be enough. Weak passwords are sometimes a
username spelled backwards — try adding each discovered username, reversed,
to your list.

**Password list file:** ****************\_****************

### 4.2 SSH Brute Force (12 points)

Perform a brute force attack against the SSH service.

**Command used:**

```bash
_________________________________________________
```

**Successful credentials found:**
Username: ********\_******** Password: ********\_********

### 4.3 SSH Access (5 points)

Log into the system with discovered credentials.

**Login successful:** □ Yes □ No

**User privileges discovered:**

```bash
whoami: _________________
id: _____________________
```

**Flag captured:** ****************\_****************

---

## Phase 5: File Analysis (18 points)

### 5.1 System Exploration (6 points)

Explore the system for interesting files.

**Commands used:**

```bash
_________________________________________________
_________________________________________________
```

**Interesting files found:**

---

### 5.2 File Decryption (12 points)

Attempt to decrypt any encrypted files found.

**Hint:** this file was encrypted with OpenSSL's symmetric cipher, AES-256-CBC
with a salt. Only the password is unknown — the tool and algorithm aren't.

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

## Phase 6: Privilege Escalation (17 points)

### 6.1 Sudo Enumeration (6 points)

Check what the compromised account is allowed to run as another user.

**Command used:**

```bash
_________________________________________________
```

**Sudo rights found:** ****************\_****************

### 6.2 Root Exploitation (6 points)

Use the misconfiguration to read a root-owned file.

**Command used:**

```bash
_________________________________________________
```

**Flag captured:** ****************\_****************

### 6.3 Reflection (5 points)

Why does a `NOPASSWD` sudo rule on a seemingly harmless binary (like `cat`)
grant full root access? (Hint: check GTFOBins for that binary.)

---

## Lab Cleanup

Before leaving:
□ Document all findings  
□ Stop the lab: `docker compose down`  
□ Submit completed worksheet

---

## Instructor Use Only

**Grade Breakdown:**

- Reconnaissance: \_\_\_/18
- Web Enumeration: \_\_\_/12
- FTP Access: \_\_\_/12
- SSH Attack: \_\_\_/23
- File Analysis: \_\_\_/18
- Privilege Escalation: \_\_\_/17

**Total Score: \_\_\_/100**

**Comments:**

---

---

---
