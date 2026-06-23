# Week 10 CTF Challenge — Exploit Development

> **Optional challenge** — attempt after completing the main worksheet exercises.  
> Instructor releases the walkthrough at the end of the session.

---

## Target Environment

| Host | IP | Services |
|------|----|---------|
| week10-web-recon | 172.100.0.10 | HTTP (:80) — recon hints |
| week10-vuln-target | 172.100.0.11 | SSH (:22), vuln service (:9999) |

Your attacker IP: `172.100.0.2`

---

## Your Mission

Two flags are hidden on the vulnerable target — one at user level, one requiring root.  
Submit each flag in the format `flag{...}`.

### Flag 1 — user.txt

SSH credentials for a low-privilege account are discoverable from the recon web page.  
Log in and retrieve the flag from the user's home directory.

`user.txt` → `flag{________________________}`

### Flag 2 — root.txt

The service running on port 9999 contains a stack buffer overflow vulnerability.  
Exploit it to obtain a root shell, then read `/root/root.txt`.

*Hint: the service leaks a useful memory address on startup.*

`root.txt` → `flag{________________________}`

---

*No further hints. Your walkthrough will be provided at the end of the session.*
