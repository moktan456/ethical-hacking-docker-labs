# Week 8 CTF Challenge — Privilege Escalation

> **Optional challenge** — attempt after completing the main worksheet exercises.
> Instructor releases the walkthrough at the end of the session.

---

## Target Environment

| Host | IP | Services |
|------|----|---------|
| week8-workstation | 10.10.8.10 | SSH |
| week8-ubuntu-desktop | 10.10.8.11 | SSH, SMB |

Neither target hands you a shell. You'll need to get in yourself first.

---

## Your Mission

Two flags are hidden in this lab. Both require two stages: gaining a
low-privilege shell on the target, then escalating that to root. Enumeration
alone won't get you either flag.

### Flag 1 — user.txt

`week8-workstation` has one local account. You don't have its password —
find a way to it, then find a privilege escalation vector that lets you read
a root-owned file. There is more than one way in for both stages.

`user.txt` → `flag{________________________}`

### Flag 2 — root.txt

`week8-ubuntu-desktop` is leaking something it shouldn't be. Find it, use it
to get in, then find out why that low-privilege user has more power than
their shell suggests.

`root.txt` → `flag{________________________}`

---

*No further hints. Your walkthrough will be provided at the end of the session.*
