# Week 4 CTF Challenge — Reconnaissance & Scanning

> **Optional challenge** — attempt after completing the main worksheet exercises.  
> Instructor releases the walkthrough at the end of the session.

---

## Target Environment

| Host | IP | Services |
|------|----|---------|
| week4-web | 172.40.0.10 | HTTP (Nginx) |
| week4-ftp | 172.40.0.11 | FTP (vsftpd) |
| week4-ssh | 172.40.0.12 | SSH (OpenSSH) |

Your attacker IP: `172.40.0.2`

---

## Your Mission

Two flags are hidden across the target network.  
Submit each flag in the format `flag{...}`.

### Flag 1 — user.txt

The FTP server allows anonymous login. Enumerate its contents and retrieve the flag.

`user.txt` → `flag{________________________}`

### Flag 2 — root.txt

The web server hosts a hidden directory not linked from the main page.  
Use a directory brute-force tool to discover it and retrieve the flag.

`root.txt` → `flag{________________________}`

---

*No further hints. Your walkthrough will be provided at the end of the session.*
