# Week 11 Worksheet Walkthrough — INSTRUCTOR ONLY

> This week has no Docker lab — it's a discussion/case-study session, so
> this walkthrough is a model-answer key rather than verified command
> output. Do not distribute to students before the end of the session.

---

## Part 1: Threat Modelling Physical Space

### Exercise 1.1: Attack Surface Map

Model answers will vary with whatever floor plan is shown, but the three
entry points students should land on are typically: the loading
dock/delivery entrance (least scrutinised, expects strangers), the main
reception (defeated by tailgating/piggybacking), and any smoker's
door/fire exit propped open for convenience. The server room is almost
always the correct "highest-value target" answer — it's where physical
access converts directly into full data/network compromise, versus
individual desks which only expose one person's access.

### Exercise 1.2: Access Control Inventory

| Control | Rating | Reason |
|---------|--------|--------|
| PIN pad on server room door | Weak | Shared PIN, no identity binding, vulnerable to shoulder-surfing/thermal imaging |
| RFID card access, no log of who entered | Medium | Stops casual walk-ins but a lost/cloned card is undetectable with no audit trail |
| Security guard at reception checking ID | Medium | Good deterrent but relies on human vigilance and can be socially engineered |
| Unmonitored car park with server room air vent | Weak | Physical access to building envelope with no oversight — a real intrusion path, not just a control gap |
| Biometric fingerprint + PIN (two-factor physical) | Strong | Combines something-you-are with something-you-know; hard to clone both |
| Laptop cable locks on all workstations | Medium | Prevents opportunistic theft, does nothing against a logged-in session or data exfiltration |
| Clean desk policy — nothing left out overnight | Strong (if enforced) | Removes the easiest information-gathering vector, but only as good as compliance checking |

---

## Part 2: Attack Techniques

### Exercise 2.1: USB Drop Scenario

1. **Payload/access:** A "BadUSB"-style keystroke injector (Rubber Ducky)
   can drop a reverse shell or credential-stealing script the moment it's
   plugged in, giving the attacker an initial foothold on the internal
   network — no phishing click or exploit needed, just curiosity.
2. **Technical control:** Disabling USB mass-storage/HID autorun via Group
   Policy (or endpoint protection that blocks unrecognised HID devices)
   stops the payload from executing even if the drive is inserted.
3. **Human-factors control:** Security awareness training specifically
   covering "found media" policy — report it to IT/security, never plug
   in an unknown device — reinforced with periodic internal USB-drop
   testing (mirroring phishing simulations).

### Exercise 2.2: RFID Cloning

1. MIFARE DESFire uses AES/3DES cryptographic authentication between card
   and reader rather than a static, freely-readable ID — a Proxmark3 can
   capture the RF exchange but can't derive the secret key from it in any
   practical timeframe, unlike the low-security MIFARE Classic or 125kHz
   prox cards Proxmark3 clones trivially.
2. An RFID-blocking sleeve/wallet prevents the card from responding to an
   unsolicited reader at all, removing the brush-past opportunity.
3. Even with a cloned card, a second factor at the door (PIN, biometric)
   or a receptionist/guard visually verifying the badge photo against the
   person stops entry — this is exactly why "two-factor physical" access
   is recommended for high-value areas.

### Exercise 2.3: Tailgating

A mantrap is a two-door airlock: the outer door must fully close and lock
before the inner door will open, and typically only one person's weight/
badge is validated per cycle. It defeats tailgating because there's no
"door held open" moment for a second person to slip through — entry is
strictly one-badge-one-body, often enforced by a sensor or interlock, not
just courtesy.

**Why training alone fails:** Tailgating exploits social politeness and
diffusion of responsibility (nobody wants to be the person who slams a
door on a colleague, and everyone assumes someone else already checked the
person's badge) — a norm training can't fully override, because refusing
to hold a door feels socially costly in the moment even to a well-trained
employee. Only a physical/procedural control (mantrap, guard actively
challenging unbadged individuals) removes the human judgment call.

---

## Part 3: Physical Pentest Planning

### Exercise 3.1: Scope a Physical Pentest — model scope statement

- **Premises in scope:** Named building address only (e.g. "Level 4, 123
  Example St, Sydney NSW" — never "all CyberCorp offices").
- **Permitted actions:** Tailgating/piggybacking attempts, RFID card
  cloning of consenting test subjects or provided test badges, USB drop
  in nominated common areas, photography of findings.
- **Explicitly out of scope:** Any action against other tenants in a
  shared building, forceful entry, testing outside agreed hours, targeting
  named executives by home address, retaining or publishing any personal
  documents found.
- **Carry at all times:** A signed, dated "get out of jail free" letter
  naming the specific premises, engagement dates, and an emergency contact
  number for the client's engagement sponsor.
- **If detained:** Immediately stop, present the authorisation letter, do
  not resist or argue, and call the named emergency contact — do not wait
  for police/security to escalate first.

### Exercise 3.2: Evidence and Reporting

| Finding | Photo Evidence |
|---------|---------------|
| Server room door left propped open | Wide shot showing the open door, the propping object, and a timestamp/clock or watch in frame |
| Sticky note with password on monitor | Close-up of the note (password redacted in the report copy, unredacted in the client-only evidence file) with the desk/location visible for context |
| Successful RFID clone entry | Photo of the cloned card next to the reader showing a green/granted light, plus the Proxmark3 capture log as supporting evidence |
| Documents found in unsecured bin | Photo of the bin location (unlocked, accessible) and the document content (sensitive fields redacted in the report) |
| Unlocked workstation with active session | Screen showing the logged-in session/desktop, plus a wide shot showing the workstation was unattended |

**Why timestamp/geotag:** It proves exactly when and where the finding
occurred, which is essential both for the client to verify the finding is
current (not stale/already fixed) and as legal evidence that the tester
was acting within the agreed engagement window and location.

---

## Part 4: Defence in Depth

### Exercise 4.1: Layered Controls (server room)

- **Layer 1 (Perimeter):** Building access control — reception check-in,
  visitor badges, exterior CCTV, locked building after hours.
- **Layer 2 (Intermediate):** Server room door — badge + PIN or biometric,
  door-held-open alarm, CCTV covering the door.
- **Layer 3 (Final):** The server itself — locked rack/cabinet, disk
  encryption, BIOS/boot password, asset tagged and inventoried so removal
  is noticed quickly.

### Exercise 4.2: Maturity Assessment

- **Org A:** **Low–Medium.** Single-factor controls throughout (swipe
  card, guard hours limited to business hours), no defence-in-depth for
  after-hours access, and no evidence of testing or review cadence.
- **Org B:** **High.** Multiple independent layers (mantrap, 24/7 guards,
  two-factor biometric, motion-triggered cameras), a technical control
  removing the most common attack vector (USB), and — critically — a
  recurring test cadence (quarterly pentest) rather than a one-off
  assessment.

---

## Quick Knowledge Check — Answers

1. B — A two-door airlock that prevents tailgating
2. C — Proxmark3
3. False — verbal authorisation is never sufficient; written, premises-specific authorisation must be carried at all times
4. B — State/Territory trespass legislation (the Commonwealth Criminal Code covers computer/system access, not physical trespass)
5. B — Observing someone enter credentials in a public space
