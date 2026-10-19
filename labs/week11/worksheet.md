# Week 11: Physical Security and Access Controls
## CYB204 Ethical Hacking — Discussion Worksheet

---

## Before We Start

### Important Rules
✅ **DO:** Discuss these techniques in an academic context
✅ **DO:** Apply this knowledge to identify physical weaknesses in your own environment (home, uni)
❌ **DON'T:** Attempt any physical bypass technique on any premises without explicit written authorisation
❌ **DON'T:** Purchase or build physical attack hardware for unsanctioned use

**Looking for the hands-on part of this week?** This worksheet is
discussion/analysis-based by design — but keypad brute force, RFID
clone-and-replay, and BadUSB payload injection are all genuinely
executable this week in **[hands-on-lab.md](./hands-on-lab.md)**, a
Docker-based simulation. Do that first if your session runs it before
this worksheet; several exercises below (Exercise 2.2's RFID discussion
in particular) land better once you've actually replayed a captured
credential yourself.

---

## Part 1: Threat Modelling Physical Space (20 minutes)

### Exercise 1.1: Attack Surface Map

Study the floor plan of the fictional CyberCorp office below. Everything you need is on the plan and in the key. Identify and annotate:

- Entry points an attacker could exploit (doors, loading docks, car parks)
- High-value target locations (server room, CEO office, reception desk, printer room)
- Cameras and their blind spots (if shown)
- Areas where a USB drop would be most effective

### Floor Plan: CyberCorp Pty Ltd — Ground Floor, 88 Harbour Street, Sydney NSW (fictional)

```
                                  N ^
+----------------------------------------------------------------------+
| R1 SERVER ROOM       | R2 IT STORE  | R3 CEO OFFICE  | R4 BOARDROOM  |
|  D1 [PIN pad]  C1    | D2 [key]     | D3 [RFID]      | D4 [RFID]     |
|  air vent -> P1      |              |                |               |
|----------------------+--------------+----------------+---------------|
|  CORRIDOR      C2 (covers D1 only)            F1 stairs ->           |
|----------------+----------------------------+------------------------|
| R5 LOADING BAY | R6 OPEN-PLAN OFFICE        | R7 PRINTER ROOM        |
|  E3 roller door| 60 desks, spare ports      | LAN port, shred bin    |
|  (no camera)   | Wi-Fi AP  (no camera)      | (no camera)            |
|----------------+----------------------------+------------------------|
| R8 BREAKOUT    | R9 KITCHEN / SMOKERS       | R10 RECEPTION          |
|  E2 fire exit  | E4 side door               | E1 main door  C3       |
|  (no alarm)    | (propped open)             | swipe gate + guard     |
+----------------------------------------------------------------------+
  P1 CAR PARK (open, unfenced, unlit west end)      P2 BIN SKIP (unlocked)
```

**Key** — **E** = entry/exit door, **D** = internal door, **C** = camera, **P** = outside area, **F** = fire stairs

| Ref | What is there |
|-----|---------------|
| **E1** | Main glass door into R10. Swipe-card gate, security guard 9am–5pm only. Visitors sign a paper book; no mantrap. Gate is held open at 8:45–9:15 and 5:00–5:30 for the rush. |
| **E2** | Fire exit from R8. Push-bar opens from inside; no door-open alarm. |
| **E3** | Loading bay roller door (R5). Delivery drivers arrive unannounced; door is open during business hours, no camera, no sign-in. |
| **E4** | Side door in R9. Smokers prop it open with a bin lid. Opens onto P1. |
| **R1** | Server room: core switches, backup NAS, domain controller. **D1** has a shared 4-digit PIN pad. **C1** is inside the room. A ground-level **air vent** in the west wall opens onto P1. |
| **R2** | IT store: spare laptops, USB drives, patch cables. Ordinary key lock, key kept in the R10 reception drawer. |
| **R3** | CEO office: personal safe, whiteboard with network diagram. **D3** RFID card only. |
| **R4** | Boardroom: projector, ceiling Wi-Fi AP, guest Wi-Fi password printed on the wall. **D4** RFID card only. |
| **R5** | Loading bay: parcels stacked by the door, unattended after 3pm. |
| **R6** | Open-plan office, 60 staff. Cable locks on laptops, but the clean-desk policy is not checked. Unused wall network ports are live. |
| **R7** | Printer/copy room: shared printer, LAN port behind it, unlocked shred bin. Out of view of every camera. |
| **R8** | Breakout space: staff lockers, fire exit E2. |
| **R9** | Kitchen/smoking door E4. |
| **R10** | Reception and lobby: guard desk, visitor book, **C3** covers the lobby and swipe gate. |
| **C1** | Inside R1, covers the racks. |
| **C2** | Corridor camera. Covers **D1 only**; lens is aimed at the door and does not see the corridor or D2/D3/D4. |
| **C3** | Lobby camera covering E1 and the swipe gate. |
| **P1** | Car park (staff + visitor). Open, no fence, no gate, west end unlit. No camera. Wraps the west and south sides of the building, where R1's air vent, E2, E4 and E1 all open onto it. |
| **P2** | Bin skip behind the building. Unlocked, emptied weekly. |

**Not shown on the plan (assume none exist):** cameras in R5–R9, door-held-open alarms, USB port restrictions, visitor badges, after-hours guard, motion sensors.


**List your top 3 physical attack entry points:**

1. _________________________________
2. _________________________________
3. _________________________________

**Which room is the highest-value physical target, and why?**

_________________________________

**Camera blind spots:** Using C1–C3, list two places an intruder can move without being seen, and say which exit or door they would use.

_________________________________

**USB drop:** Pick the best spot on the plan for a USB drop, and the best spot for planting a LAN Turtle or rogue AP. Explain each choice.

USB drop: _________________________________

Rogue device: _________________________________

**Attack path:** Trace the quietest route from the car park (P1) to the server room (R1) without passing C3. Write the room/door sequence (for example P1 → E? → R? → ...) and note what control you must defeat at each door.

_________________________________

**Quick fixes:** Name the three cheapest changes that would most reduce the exposure shown on this plan.

1. _________________________________
2. _________________________________
3. _________________________________

---

### Exercise 1.2: Access Control Inventory

Walk through the following controls and rate each one: **Strong**, **Medium**, or **Weak** for a corporate head office. Give one reason.

| Control | Rating | Reason |
|---------|--------|--------|
| PIN pad on server room door |  |  |
| RFID card access, no log of who entered |  |  |
| Security guard at reception checking ID |  |  |
| Unmonitored car park with server room air vent |  |  |
| Biometric fingerprint + PIN (two-factor physical) |  |  |
| Laptop cable locks on all workstations |  |  |
| Clean desk policy — nothing left out overnight |  |  |

---

## Part 2: Attack Techniques (25 minutes)

### Exercise 2.1: USB Drop Scenario

An attacker drops five USB drives in the car park labelled "Q3 Salary Review - Confidential". Three of five employees who find one plug it in at work.

**Question 1:** What payload could the USB deliver, and what access would the attacker gain?

_________________________________

**Question 2:** What technical control would prevent the USB payload from executing?

_________________________________

**Question 3:** What human-factors control (policy or training) would reduce the chance of an employee plugging in the USB?

_________________________________

---

### Exercise 2.2: RFID Cloning

An attacker with a Proxmark3 brushes against a target employee's bag in a coffee queue. 30 seconds later they have a cloned card.

**Question 1:** What stops Proxmark3 from cloning a modern MIFARE DESFire card?

_________________________________

**Question 2:** What physical countermeasure could the employee use?

_________________________________

**Question 3:** Even with a cloned card, what additional control could stop the attacker at the door?

_________________________________

---

### Exercise 2.3: Tailgating

An attacker waits near a secure door dressed in a high-vis vest carrying a clipboard. An employee swipes in and holds the door open.

**The "two-factor physical" solution:** Draw or describe a mantrap (airlock entry system) and explain how it defeats tailgating.

_________________________________

**Question:** Why does security training alone often fail to stop tailgating?

_________________________________

---

## Part 3: Physical Pentest Planning (20 minutes)

### Exercise 3.1: Scope a Physical Pentest

CyberCorp (the floor plan in Exercise 1.1) wants you to physically test their head office in Sydney. Write a scope statement that covers, using room and door references from the plan:

- Which premises are in scope (be specific)
- What actions are permitted (entry attempt, USB drop, RFID cloning, dumpster diving)
- What is explicitly out of scope
- What you must carry on your person at all times
- Emergency contact procedure if you are detained by security

_________________________________

_________________________________

_________________________________

---

### Exercise 3.2: Evidence and Reporting

A physical pentest report needs photo evidence. For each finding below, describe what photo evidence you would capture:

| Finding | Photo Evidence |
|---------|---------------|
| Server room door left propped open | |
| Sticky note with password on monitor | |
| Successful RFID clone entry | |
| Documents found in unsecured bin | |
| Unlocked workstation with active session | |

**Question:** Why must all physical pentest photos be timestamped and geotagged where possible?

_________________________________

---

## Part 4: Defence in Depth (15 minutes)

### Exercise 4.1: Layered Controls

The principle of "defence in depth" means no single control is relied upon. For CyberCorp's server room (R1), map out three layers and say which door or area on the plan each layer protects:

**Layer 1 (Perimeter — the building):**

_________________________________

**Layer 2 (Intermediate — the server room door):**

_________________________________

**Layer 3 (Final — the server itself):**

_________________________________

---

### Exercise 4.2: Maturity Assessment

Rate the physical security maturity of each organisation based on the description:

**Org A:** Swipe card entry, cameras at reception, clean desk policy, security guard 9–5.

Maturity: Low / Medium / High — **Reason:** _________________________________

**Org B:** Mantrap entry, 24/7 guards, biometric + PIN, motion-activated cameras, all USB ports disabled via GPO, quarterly physical pentest.

Maturity: Low / Medium / High — **Reason:** _________________________________

---

## Quick Knowledge Check

1. What is a "mantrap"?
   - A) A type of malware  B) A two-door airlock that prevents tailgating  C) A honeypot for physical intrusion  D) A type of lock pick

2. Which device is used to clone RFID cards?
   - A) Rubber Ducky  B) LAN Turtle  C) Proxmark3  D) WiFi Pineapple

3. True/False: A verbal authorisation from a receptionist is sufficient for a physical pentest.

4. What law in Australia covers trespass to premises?
   - A) Criminal Code Act 1995  B) State/Territory trespass legislation  C) Privacy Act 1988  D) Telecommunications Act

5. What is "shoulder surfing"?
   - A) Stealing a laptop bag  B) Observing someone enter credentials in a public space  C) Cloning a card from close range  D) Dumpster diving

---

## Summary

Today you explored:
✓ Common physical attack vectors (USB drop, RFID cloning, tailgating)
✓ How to map physical attack surfaces on a floor plan
✓ Legal requirements specific to physical penetration testing
✓ Evidence collection and reporting for physical findings
✓ Defence in depth for physical access controls

**Next week (Week 12):** Social engineering — the human element.

**Instructor Contact:** _________________________________
