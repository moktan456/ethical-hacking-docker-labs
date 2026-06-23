# Week 5 CTF Challenge — Service Enumeration

> **Optional challenge** — attempt after completing the main worksheet exercises.  
> Instructor releases the walkthrough at the end of the session.

---

## Target Environment

| Host | IP | Services |
|------|----|---------|
| week5-ldap | 172.50.0.10 | LDAP (:389) |
| week5-mysql | 172.50.0.11 | MySQL (:3306) |
| week5-smb | 172.50.0.12 | SMB (:445) |

Your attacker IP: `172.50.0.2`

---

## Your Mission

Two flags are hidden across the enumeration targets.  
Submit each flag in the format `flag{...}`.

### Flag 1 — user.txt

The SMB server has a publicly accessible share. Connect to it as a guest and retrieve the flag.

`user.txt` → `flag{________________________}`

### Flag 2 — root.txt

The MySQL database contains a hidden table not visible in the main schema.  
Enumerate all tables and extract the flag.

`root.txt` → `flag{________________________}`

---

*No further hints. Your walkthrough will be provided at the end of the session.*
