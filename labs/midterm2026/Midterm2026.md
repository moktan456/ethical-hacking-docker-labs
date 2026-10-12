# Midterm Examination: Penetration Test — Student Worksheet

**Name:** _________________________ **Date:** _____________

## Lab Scenario
You have been hired to perform a penetration test on De-ICE Corporation's web server. The CEO believes the system is secure since they run regular Nessus scans. Your job is to prove that automated scanning isn't enough. This is the course's capstone exercise — no walkthrough, no hints. Approach it the way you'd approach a real engagement.

**Time Limit:** 2 hours  
**Submission:** Complete this worksheet and submit your findings

## Pre-Lab Setup
□ Start the lab environment: `docker compose up -d`  
□ Access attacker machine: `docker exec -it midterm2026-attacker bash`  
□ Verify you're in the Kali container: `whoami` (should show "root")

---

## Phase 1: Reconnaissance (15 points)

### 1.1 Network Discovery (7 points)
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

### 1.2 Port Scanning (8 points)
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

## Phase 2: Web Application Enumeration (10 points)

### 2.1 Web Content Analysis (7 points)
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

**Flag captured:** _________________________________

### 2.2 Username Generation (3 points)
Based on the naming convention, create a username list.

**Username list created:** □ Yes □ No

**File location:** _________________________________

---

## Phase 3: FTP Enumeration (10 points)

### 3.1 FTP Access (5 points)
Attempt to access the FTP service.

**Connection command:**
```bash
_________________________________________________
```

**Authentication method:** _______________________

**Success:** □ Yes □ No

**Flag captured:** _________________________________

### 3.2 FTP File Discovery (5 points)
Explore the FTP directory structure and identify interesting files.

**Directories found:**
_________________________________________________

**Files discovered:**
| Filename | Size | Location | Downloaded |
|----------|------|----------|------------|
| | | | □ |
| | | | □ |
| | | | □ |

---

## Phase 4: SSH Attack (20 points)

### 4.1 Password List Creation (5 points)
Create a password list for brute force attacks. Use only the **top 10 passwords
from `/usr/share/wordlists/rockyou.txt`** — not the full list (`head -n 10
/usr/share/wordlists/rockyou.txt`).

**Hint:** rockyou alone may not be enough. Weak passwords are sometimes a
username spelled backwards — try adding each discovered username, reversed,
to your list.

**Password list file:** _________________________________

### 4.2 SSH Brute Force (10 points)
Perform a brute force attack against the SSH service.

**Command used:**
```bash
_________________________________________________
```

**Successful credentials found:**
Username: _________________ Password: _________________

### 4.3 SSH Access (5 points)
Log into the system with discovered credentials.

**Login successful:** □ Yes □ No

**User privileges discovered:**
```bash
whoami: _________________
id: _____________________
```

**Flag captured:** _________________________________

---

## Phase 5: File Analysis (15 points)

### 5.1 System Exploration (5 points)
Explore the system for interesting files.

**Commands used:**
```bash
_________________________________________________
_________________________________________________
```

**Interesting files found:**
_________________________________________________

### 5.2 File Decryption (10 points)
Attempt to decrypt any encrypted files found.

**Hint:** this file was encrypted with OpenSSL's symmetric cipher, AES-256-CBC
with a salt. Only the password is unknown — the tool and algorithm aren't.
```bash
openssl enc -aes-256-cbc -d -salt -in <file> -out <output> -k <password>
```

**Encrypted file:** _________________________________

**Decryption attempts:**
| Password Tried | Success |
|----------------|---------|
| | □ |
| | □ |
| | □ |

**Successful decryption password:** ____________________

**Decrypted content (first 3 lines):**
```
_________________________________________________
_________________________________________________
_________________________________________________
```

**Flag captured:** _________________________________

---

## Phase 6: Privilege Escalation (15 points)

### 6.1 Sudo Enumeration (5 points)
Check what the compromised account is allowed to run as another user.

**Command used:**
```bash
_________________________________________________
```

**Sudo rights found:** _________________________________

### 6.2 Root Exploitation (5 points)
Use the misconfiguration to read a root-owned file.

**Command used:**
```bash
_________________________________________________
```

**Flag captured:** _________________________________

### 6.3 Reflection (5 points)
Why does a `NOPASSWD` sudo rule on a seemingly harmless binary (like `cat`)
grant full root access? (Hint: check GTFOBins for that binary.)

_________________________________________________
_________________________________________________

---

## Phase 7: Analysis & Reporting (15 points)

### 7.1 Vulnerability Summary
List the major vulnerabilities discovered:

1. **Information Disclosure:**
   _________________________________________________

2. **Weak Authentication:**
   _________________________________________________

3. **File Security:**
   _________________________________________________

4. **Service Configuration:**
   _________________________________________________

5. **Privilege Management:**
   _________________________________________________

### 7.2 Risk Assessment
Rate each vulnerability (Low/Medium/High/Critical):

| Vulnerability | Risk Level | Impact |
|---------------|------------|--------|
| Information Disclosure | | |
| Weak SSH Password | | |
| Anonymous FTP Access | | |
| Weak Encryption | | |
| Sudo Misconfiguration | | |

### 7.3 Recommendations
Provide 3 key security recommendations:

1. _________________________________________________
   _________________________________________________

2. _________________________________________________
   _________________________________________________

3. _________________________________________________
   _________________________________________________

---

## Bonus Questions (Extra Credit - 5 points each)

1. **Pattern Analysis:** What pattern did you notice in the successful SSH password?
   _________________________________________________

2. **Attack Vector:** What other services could be targeted for additional access?
   _________________________________________________

3. **Persistence:** How might an attacker maintain access to this system?
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
- Reconnaissance: ___/15
- Web Enumeration: ___/10
- FTP Access: ___/10
- SSH Attack: ___/20
- File Analysis: ___/15
- Privilege Escalation: ___/15
- Analysis & Reporting: ___/15
- Bonus: ___/15

**Total Score: ___/100 (+ ___/15 bonus)**

**Comments:**
_________________________________________________
_________________________________________________
_________________________________________________
