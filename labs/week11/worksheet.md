# Week 11: Physical Security and Access Controls
## CYB204 Ethical Hacking — Discussion Worksheet

---

## Before We Start

### Important Rules
✅ **DO:** Discuss these techniques in an academic context
✅ **DO:** Apply this knowledge to identify physical weaknesses in your own environment (home, uni)
❌ **DON'T:** Attempt any physical bypass technique on any premises without explicit written authorisation
❌ **DON'T:** Purchase or build physical attack hardware for unsanctioned use

---

## Part 1: Threat Modelling Physical Space (20 minutes)

### Exercise 1.1: Attack Surface Map

Your instructor will show a floor plan of a fictional "CyberCorp" office. Identify and annotate:

- Entry points an attacker could exploit (doors, loading docks, car parks)
- High-value target locations (server room, CEO office, reception desk, printer room)
- Cameras and their blind spots (if shown)
- Areas where a USB drop would be most effective

**List your top 3 physical attack entry points:**

1. _________________________________
2. _________________________________
3. _________________________________

**Which room is the highest-value physical target, and why?**

_________________________________

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

A client wants you to physically test their head office in Sydney. Write a scope statement that covers:

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

The principle of "defence in depth" means no single control is relied upon. For a server room, map out three layers:

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
