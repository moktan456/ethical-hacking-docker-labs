# Week 11: Physical Security and Access Controls

## CYB204 Ethical Hacking — Week 11

**There's a Docker lab this week after all** — not of the physical
attacks themselves (there's no simulating a real lock or a real RF
field), but of the *logic* underneath three of them: keypad brute force,
RFID clone-and-replay, and BadUSB keystroke injection, each genuinely
executed over a network rather than just discussed. See
**[hands-on-lab.md](./hands-on-lab.md)**. Lockpicking and biometric
spoofing stay discussion/theory this week — see the notes below on why,
and on a low-cost way to make lockpicking hands-on too if you want it.

---

## Session Delivery Plan (~3 hours)

| Time | Segment | Material |
|---|---|---|
| 0:00–0:35 | Lecture: slide deck, start to finish | `week11-slides-physical.md` (types of controls, common weaknesses, tools, mitigation strategies) |
| 0:35–1:05 | **Hands-on Challenge 1 & 2:** keypad brute force, RFID clone & replay | `hands-on-lab.md` Challenges 1–2 |
| 1:05–1:15 | Break | — |
| 1:15–1:45 | **Hands-on Challenge 3:** BadUSB / Rubber Ducky payload | `hands-on-lab.md` Challenge 3 (+ Challenge 4 for early finishers) |
| 1:45–2:15 | Discussion worksheet, Parts 1–2 (threat modelling, attack techniques) | `worksheet.md` |
| 2:15–2:45 | Discussion worksheet, Parts 3–4 (pentest planning, defence in depth) + slide deck's Group Discussion scenario | `worksheet.md` + slides |
| 2:45–3:00 | Wrap-up, Quick Knowledge Check, Q&A | `worksheet.md` + slides |

Running short on time: cut Challenge 4 (it's explicitly an optional
extension) and worksheet Part 3.2 (evidence/reporting) before cutting
anything else — the three hands-on challenges and the core attack/
mitigation pairing in Parts 1–2 are the material students are least
likely to get anywhere else.

---

## Learning Objectives

By the end of this week you should be able to:

- Identify common physical security weaknesses in corporate environments
- Explain how physical access enables technical attacks (USB drops, rogue devices)
- Describe tailgating, piggybacking, and lock-picking as attack techniques
- Assess physical security controls as part of a penetration test scope
- Understand the legal boundaries of physical penetration testing in Australia

---

## Physical Attack Vectors

### Direct Access Attacks

| Attack | Description | Tool/Method |
|--------|-------------|-------------|
| **USB drop** | Malicious USB left in car park/reception; curiosity drives insertion | Rubber Ducky, Bad USB |
| **Rogue access point** | WiFi Pineapple planted in server room or under a desk | WiFi Pineapple, hostapd |
| **Rogue Ethernet** | LAN Turtle plugged into a spare port behind a printer | LAN Turtle, Bash Bunny |
| **Evil maid** | Attacker with brief physical access to an unlocked device | Cold boot attack, bootkit |
| **Dumpster diving** | Recovering documents, credentials, hardware from bins | Physical access |
| **Shoulder surfing** | Observing someone enter credentials in a public space | Line of sight |

### Access Control Bypass

| Control | Bypass Technique |
|---------|-----------------|
| PIN pad | Thermal imaging camera reveals recently-pressed digits |
| RFID/NFC card | Proxmark3 clones card from < 10 cm through a wallet |
| Biometric (fingerprint) | Lifted latent print reproduced in gelatin |
| Tailgating | Following an authorised person through a door before it closes |
| Piggybacking | Authorised person intentionally holds door for attacker |
| Lock (pin tumbler) | Lock picks, bump key, or bypass shimming |

---

## Physical Pentest Methodology

A physical penetration test follows the same phases as a network test:

```
1. Pre-engagement   →  Define physical scope (which buildings, floors, rooms)
2. Reconnaissance   →  Dumpster diving, OSINT (building plans, Google Maps), observation
3. Entry attempt    →  Tailgating, social engineering at reception, cloned RFID
4. On-site actions  →  USB drop, rogue AP placement, document photography
5. Exfiltration     →  Remove evidence, document findings with timestamped photos
6. Reporting        →  Physical security report with photo evidence and recommendations
```

---

## Applicable Law

Physical penetration testing carries **higher legal risk** than network testing because it may intersect with:

- **Criminal Code Act 1995 (Cth) s477.1** — Unauthorised access to computer systems
- **Criminal Code Act 1995 (Cth) s132** — Theft (if any item is removed)
- **State trespass laws** — Entry to premises without authorisation
- **Security Industry Act** (state/territory) — Conducting "security assessments" may require a licence

**Critical rule:** Your authorisation letter for a physical pentest must be carried on your person at all times and must name the specific premises. If security detains you, present it immediately. Never rely on verbal authorisation.

---

## Making Lockpicking Hands-On Too (Optional)

The hands-on lab explicitly leaves lockpicking as theory-only, because
there's no honest digital stand-in for a skill that's entirely mechanical
feel (tension + pin stacks). If you want it hands-on, the standard,
low-cost, fully legal way ethical hacking courses do this:

- A **practice padlock set with clear/cutaway bodies** (so students can
  see the pin stacks move) — inexpensive, widely sold specifically for
  training, no different legally from owning any other padlock.
- A **basic pick set** (tension wrench + a few hook/rake picks) —
  legal to own and use on locks you own or have explicit permission to
  pick; check your state's specifics if in doubt, since a few
  jurisdictions regulate possession of picking tools in public without
  reasonable excuse (owning them for a declared training exercise is
  the reasonable excuse).
- Run it as a **supervised 15-minute station** during the break or
  alongside Challenge 3, not as a whole-class activity — one or two
  practice locks per 4–5 students is plenty, since most of the learning
  is watching the pins set one at a time under instructor guidance.
- **Document it as an authorised classroom exercise** on your own
  equipment, consistent with the "Ethical Considerations" principle on
  the slides and the Applicable Law section above — it's the same
  authorisation principle as everything else in this unit, just applied
  to a padlock instead of a network.

This is a procurement/facilities decision for you, not something that
can be scripted — nothing in this repo depends on it.

---

## See Also

- **hands-on-lab.md** — the digital simulation lab (keypad, RFID, BadUSB), with real flags to capture
- **hands-on-lab-walkthrough.md** — instructor-only verified walkthrough and answer key
- worksheet.md — case studies and assessment exercises for this week's class (includes the CyberCorp floor plan used in Challenge 5 of the lab)
