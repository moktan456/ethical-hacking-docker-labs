# Week 3 CTF Challenge — Traffic Analysis & Scoping

> **Optional challenge** — attempt after completing the main worksheet exercises.  
> Instructor releases the walkthrough at the end of the session.

---

## Target Environment

| Host | IP | Notes |
|------|----|-------|
| week3-target | 10.10.3.10 | Sample target container |

Your Wireshark container is at `10.10.3.2`.

---

## Your Mission

Two flags are hidden on the sample target.  
Submit each flag in the format `flag{...}`.

### Flag 1 — user.txt

Scan the target with Nmap to discover all open ports and services.  
One service is serving files over HTTP. Retrieve `user.txt` from it.

`user.txt` → `flag{________________________}`

### Flag 2 — root.txt

The same service exposes a second file containing an encoded string.  
Decode it to reveal the root flag.

`root.txt` → `flag{________________________}`

---

*No further hints. Your walkthrough will be provided at the end of the session.*
