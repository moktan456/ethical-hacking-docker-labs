# Week 10 Mock Exam 2 — CTF Challenge Format

**Alternative framing for gamification.** Same exam, same 3 flags — see
[mock-exam.md](./mock-exam.md) for the full instructions and grading
rubric (recon and enumeration are graded step by step there, not just
pass/fail). This page is just the flags-only quick reference.

---

## Scenario

CyberGuard Corp has asked for a penetration test of their internal
network. Start from `week10mock2-attacker` and find 3 flags.

**No network range, host list, or service list is given.** Finding all
of that is part of the assessment — see mock-exam.md's Recon &
Enumeration rubric (30% of the grade on its own).

## Flags

### Flag 1 — EASY (part of Recon & Enumeration)
Thorough enumeration of what you find in your first scan — including
actually testing what access level is available to you rather than
assuming you need credentials — gets you this one directly, along with a
lead toward the next step.

`flag{________________________}`

### Flag 2 — HARD (25%)
The lead from Flag 1 narrows an account down to a small, specific set of
candidate passwords — build your own wordlist, don't brute-force blind.
Then escalate to root.

`flag{________________________}`

### Flag 3 — HARD (25%)
A file on the host from Flag 2 leaks credentials to a service you
identified earlier but hadn't touched yet. What's stored there isn't a
flag by itself — one more offline step reveals what you need, and that
same result is also the key to something else that needs unlocking.

`flag{________________________}`

---

*No further hints. Walkthrough released at the end of the session —
see [mock-exam-walkthrough.md](./mock-exam-walkthrough.md) (instructor only).*
