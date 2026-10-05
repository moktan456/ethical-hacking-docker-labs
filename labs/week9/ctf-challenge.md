# Week 9 CTF Challenge — Lateral Movement

> **Optional challenge** — attempt after completing the main worksheet exercises.
> Instructor releases the walkthrough at the end of the session.

---

## Scenario

You have a single low-privilege foothold: `netadmin` on `week9-workstation`
(`10.10.9.10`). Everything else on the network has to be earned by chaining
together what that foothold leads to — a dumped hash, a leaked key, a
reused password. No further hints are given on what each step unlocks.

```
week9-attacker (you)   10.10.9.2
week9-workstation      10.10.9.10   ← starting foothold
week9-fileserver       10.10.9.12
week9-ubuntu-desktop   10.10.9.11   ← final target
```

---

## Your Mission

Two flags are hidden. Submit each in the format `flag{...}`.

### Flag 1 — user.txt

SSH credentials for the foothold are provided: `netadmin` / `Sp1ngR3set!`.
Log in and find the flag in the user's home directory.

`user.txt` → `flag{________________________}`

### Flag 2 — root.txt

Somewhere beyond the foothold is a path to `root` on a second host. It
involves at least one credential you'll have to find rather than guess, and
at least one trust relationship you'll have to exploit rather than
brute-force.

`root.txt` → `flag{________________________}`

---

*No further hints. Your walkthrough will be provided at the end of the session.*
