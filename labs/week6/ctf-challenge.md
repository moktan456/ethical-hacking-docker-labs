# Week 6 CTF Challenge — Password Cracking & Authentication

> **Optional challenge** — attempt after completing the main worksheet exercises.  
> Instructor releases the walkthrough at the end of the session.

---

## Target Environment

| Host | Container | Services |
|------|-----------|---------|
| ssh-target | `ssh-target` | SSH (:22) |

Identify the target's IP with: `nmap -sn 172.0.0.0/8` or check via `docker network inspect`.

---

## Your Mission

Two flags are hidden on the SSH target server.  
Submit each flag in the format `flag{...}`.

### Flag 1 — user.txt

A user account on the SSH server has a weak password.  
Use Hydra to crack it, then log in and retrieve the flag.  

*The `admin` account is a good starting point.*

`user.txt` → `flag{________________________}`

### Flag 2 — root.txt

Another account has an even weaker password, granting the highest level of access.  
Find and read the root flag.

`root.txt` → `flag{________________________}`

---

*No further hints. Your walkthrough will be provided at the end of the session.*
