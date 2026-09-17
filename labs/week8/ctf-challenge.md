# Week 8 CTF Challenge — Privilege Escalation

> **Optional challenge** — attempt after completing the main worksheet exercises.
> Instructor releases the walkthrough at the end of the session.

---

## Target Environment

| Host | IP | Access |
|------|----|---------|
| week8-workstation | 10.10.8.10 | low-privilege user: `lowpriv` / `lowpriv` |
| week8-ubuntu-desktop | 10.10.8.11 | low-privilege user: `deskuser` / `deskuser` |

---

## Your Mission

Two flags are hidden in this lab. Both require escalating from a
low-privilege shell to root — enumeration alone won't get you there.

### Flag 1 — user.txt

On `week8-workstation`, find a privilege escalation vector that lets you read
a root-owned file. There is more than one way in.

`user.txt` → `flag{________________________}`

### Flag 2 — root.txt

On `week8-ubuntu-desktop`, a low-privilege user has more power than their
shell suggests. Find out what, and use it to become root.

`root.txt` → `flag{________________________}`

---

*No further hints. Your walkthrough will be provided at the end of the session.*
