# Week 3 Worksheet Walkthrough — INSTRUCTOR ONLY

> Verified against live containers. Do not distribute to students before the
> end of the session.

---

## Exercise 1: Define the Scope

Model answer (this is deliberately given directly in the worksheet, so
there's no discovery step):
- Target IP range: `10.10.3.0/24`
- In-scope: `week3-target` (10.10.3.10)
- Out of scope: everything else on the subnet, including `week3-wireshark`
  (10.10.3.2) and `week3-attacker` (10.10.3.3) themselves

## Exercise 2: Capture Traffic to the Target

```bash
ping 10.10.3.10
```

Run from a terminal **inside the Wireshark container** (open `http://localhost:3000`,
use its built-in terminal, or `docker exec -it week3-wireshark bash`), not
the attacker — the point is to generate traffic the Wireshark box itself can
see leaving/arriving on its own interface.

**Verified result:** ping succeeds, ~0.15ms round-trip (same Docker host).
In the live capture, filtering `icmp` shows the `Echo (ping) request` /
`Echo (ping) reply` pair repeated once per second.

## Exercise 3: Passive Reconnaissance

From the Exercise 2 capture alone (no new traffic sent):
- **Protocols visible:** ICMP only, if nothing else was running. (If a
  student leaves the capture running through Exercise 4 as well, ARP will
  also appear — Docker's bridge network does an ARP lookup the first time
  two containers on the same subnet talk to each other.)
- **Source/destination pairs:** `week3-wireshark (10.10.3.2)` ↔
  `week3-target (10.10.3.10)`, both directions.

## Exercise 4: Active Discovery

```bash
docker exec -it week3-attacker bash
nmap -sV 10.10.3.10
```

**Verified result:**
```
PORT     STATE SERVICE VERSION
8888/tcp open  http    SimpleHTTPServer 0.6 (Python 3.14.5)
```
`week3-target` runs `python3 -m http.server 8888` — a deliberately minimal,
realistic "someone left a dev server running" target.

**Live-capture alternative** (`nmap -sV 10.10.3.2`, scanning the Wireshark
box itself): verified working — a Docker bridge network only delivers
traffic to/from a container's own interface, so aiming the scan at
Wireshark's own IP is what makes the scan traffic actually show up live in
its own capture. Confirmed result scanning `week3-wireshark`:
```
PORT     STATE SERVICE  VERSION
3000/tcp open  http     nginx
3001/tcp open  ssl/http nginx
8082/tcp open  http     websockets 17.1 (Python 3.14)
```
(These three ports are the Wireshark image's own web UI/websocket backend —
not anything students need to investigate further, just confirmation the
scan reached a real host.)

## Exercise 5: Report Your Findings — model answer

- Target confirmed in scope: **Yes** — `10.10.3.10` falls within the
  documented `10.10.3.0/24` scope from Exercise 1.
- Services discovered: `8888/tcp` — Python SimpleHTTPServer (dev/test web
  server, not a production-grade service)
- Potential risks noted: an ad hoc development HTTP server exposed on the
  network is a common real-world finding — worth flagging even though (in
  this lab) it serves no sensitive content, because in a real engagement
  a "temporary" dev server like this is exactly the kind of thing that gets
  forgotten and left running with default configuration or leftover files.

---

## Notes for the Instructor

- The lab's own two target containers (`week3-wireshark`, `week3-attacker`)
  are explicitly *out of scope* per Exercise 1 — Exercise 4's "scan the
  Wireshark box instead" instruction is a deliberate, called-out exception
  for the live-capture demo, not a contradiction. Worth pointing out to
  students as a teaching moment: in a real engagement, you'd never scan an
  out-of-scope host just to see something happen.
- A CTF is available for this week (`ctf-challenge.md`) with two flags
  planted in `week3-target`'s filesystem — not required for the worksheet
  itself.
