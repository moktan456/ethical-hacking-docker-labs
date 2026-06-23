# Week 1 CTF Challenge — Network Observation

> **Optional challenge** — attempt after completing the main worksheet exercises.  
> Instructor releases the walkthrough at the end of the session.

---

## Target Environment

| Service | Address | Port |
|---------|---------|------|
| SecUtils desktop | 10.10.1.5 | 6080 (web) |
| Wireshark | via proxy | 14500 |

---

## Your Mission

Two flags are hidden in this lab environment.  
Submit each flag in the format `flag{...}`.

### Flag 1 — user.txt

Explore the shared data volume accessible from the Wireshark container.  
Find and read the flag file.

`user.txt` → `flag{________________________}`

### Flag 2 — root.txt

Connect to the SecUtils container via its web interface (port 6080).  
Credentials: `root` / `rootpassword`  
The flag was planted during container startup. Find it.

`root.txt` → `flag{________________________}`

---

*No further hints. Your walkthrough will be provided at the end of the session.*
