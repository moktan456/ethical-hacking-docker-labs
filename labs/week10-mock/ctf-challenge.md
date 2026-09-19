# Week 10 Mock Exam — CTF Challenge

> **Optional challenge** — attempt after completing the main worksheet.

---

## Network Topology

```
[Attacker 10.10.50.2] ──── 10.10.50.0/24 ────┬─── [Web 10.10.50.10]
                                              ├─── [FTP 10.10.50.11]
                                              └─── [SSH 10.10.50.12]
```

## Your Mission

Two flags are hidden on the SSH target. Submit each in the format
`flag{...}`.

### Flag 1 — user.txt

Find a way onto the SSH target as a normal user. The flag is in that
user's home directory.

`user.txt` → `flag{________________________}`

### Flag 2 — root.txt

Escalate to root on the same target. The flag is in `/root`.

`root.txt` → `flag{________________________}`

---

*No further hints.*
