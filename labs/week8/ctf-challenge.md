# Week 8 CTF Challenge — Full Pentest Chain

> **Optional challenge** — attempt after completing the main worksheet exercises.  
> Instructor releases the walkthrough at the end of the session.

---

## Target Environment

| Host | Container | Services |
|------|-----------|---------|
| target-ftp | `de-ice-ftp` | FTP (:21, anonymous) |
| target-ssh | `de-ice-ssh` | SSH (:2222) |
| target-web | `de-ice-web` | HTTP (:80) |

---

## Your Mission

Two flags are hidden on the target systems.  
Submit each flag in the format `flag{...}`.

### Flag 1 — user.txt

The FTP server allows anonymous access and contains a file drop from a user.  
Retrieve it — the flag is inside.

`user.txt` → `flag{________________________}`

### Flag 2 — root.txt

SSH credentials for a user named `aadams` can be derived from information in the lab (the username reversed is the password).  
After logging in, escalate privileges to read the root flag using a permitted sudo command.

`root.txt` → `flag{________________________}`

---

*No further hints. Your walkthrough will be provided at the end of the session.*
