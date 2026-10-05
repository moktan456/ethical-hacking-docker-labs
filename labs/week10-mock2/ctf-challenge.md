# Week 10 Mock Exam 2 — CTF Challenge Format

**Alternative framing for gamification.** Same exam, same 3 flags, same
network — see [mock-exam.md](./mock-exam.md) for the full instructions,
grading rubric, and time management guide. This page is just the
flags-only quick reference.

---

## Scenario

CyberGuard Corp (`10.10.60.0/24`) has asked for a penetration test. Start
from `week10mock2-attacker` (`10.10.60.2`) and find 3 flags.

```
web         10.10.60.10   HTTP
ftp         10.10.60.11   FTP (anonymous allowed)
ssh-target  10.10.60.12   SSH — "cyberguard-app"
database    10.10.60.13   MariaDB — internal only
```

## Flags

### Flag 1 — EASY (20%)
Anonymous access to one of the two public-facing services hands this one
over directly, along with a lead toward the next step.

`flag{________________________}`

### Flag 2 — HARD (25%)
The lead from Flag 1 narrows an SSH account down to a small, specific set
of candidate passwords — build your own wordlist, don't brute-force
blind. Then escalate to root.

`flag{________________________}`

### Flag 3 — HARD (25%)
A file on the host from Flag 2 leaks credentials to a service you
haven't touched yet. What's stored there isn't a flag by itself — one
more offline step reveals what you need, and that same result is also
the key to something else that needs unlocking.

`flag{________________________}`

---

*No further hints. Walkthrough released at the end of the session —
see [mock-exam-walkthrough.md](./mock-exam-walkthrough.md).*
