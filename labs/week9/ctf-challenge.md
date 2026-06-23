# Week 9 CTF Challenge — Lateral Movement & Pivoting

> **Optional challenge** — attempt after completing the main worksheet exercises.  
> Instructor releases the walkthrough at the end of the session.

---

## Network Topology

```
[Attacker 172.90.10.2] ──── EXTERNAL ──── [Pivot 172.90.10.10]
                                                    │
                                              INTERNAL
                                                    │
                                    [Internal Web 172.90.20.20]
```

The internal network (`172.90.20.0/24`) is **not directly reachable** from the attacker.  
You must pivot through the pivot host.

---

## Your Mission

Two flags are hidden — one on the pivot host, one deep inside the internal network.  
Submit each flag in the format `flag{...}`.

### Flag 1 — user.txt

SSH credentials for the pivot host are provided in the lab (`pivotuser` / `pivot123`).  
Log in and find the flag in the user's home directory.

`user.txt` → `flag{________________________}`

### Flag 2 — root.txt

Set up SSH port forwarding through the pivot host to reach the internal web server.  
The flag is served at the web root of `172.90.20.20`.

`root.txt` → `flag{________________________}`

---

*No further hints. Your walkthrough will be provided at the end of the session.*
