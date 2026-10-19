# Week 11 Worksheet Walkthrough — INSTRUCTOR ONLY

> This week has no Docker lab — it's a discussion/case-study session, so
> this walkthrough is a model-answer key rather than verified command
> output. Do not distribute to students before the end of the session.

---

## Part 1: Threat Modelling Physical Space

### Exercise 1.1: Attack Surface Map

Answers below refer to the CyberCorp floor plan in `worksheet.md` and the hands-on-lab.md Challenge 5.

**Top three entry points (any three well-argued ones score):**

1. **E3 loading bay roller door** — open during business hours, no camera, no sign-in, drivers are expected strangers. A hi-vis vest and a parcel gets you in. From R5 you reach the corridor and R6.
2. **E4 side door (R9)** — propped open by smokers, opens on the unlit car park P1, no camera. Zero tools needed. Also the quiet way to reach the corridor.
3. **E1 main door** — swipe gate with no mantrap and a guard only 9–5. Tailgating at the 8:45–9:15 and 5:00–5:30 rush when the gate is held open. Cloned card works until someone checks the badge photo.

Honourable mentions: **E2** fire exit (no alarm; can be wedged open by an insider) and the **R1 air vent** onto P1 (exposes the server room to outside tampering, heat/moisture, and a possible hardware-implant route).

**Highest-value room:** **R1 server room.** Physical access converts directly into domain controller and backup NAS compromise. R3 (CEO safe + network diagram on the whiteboard) is second.

**Camera blind spots:** C2 only covers D1's door, so the corridor and D2/D3/D4 are not watched. No camera in R5–R9, so E3, E2, E4, R6 desks and R7 are all blind. C3 only covers E1/lobby. P1 and P2 have none. Quiet movement: in through E4 or E3, along the corridor to D1, never entering C3's field.

**USB drop:** P1 car park near E4 (smokers walk through it), or R9 kitchen table. Label "Q3 Salary Review - Confidential" or "CEO bonus". **Rogue device:** R7, plugged into the LAN port behind the printer, out of every camera's view. Also spare wall ports in R6. Gives an internal network foothold, often on the same VLAN as workstations.

**Attack path example:** P1 → E4 (propped open) → R9 → corridor → D1 → R1. Controls: none at E4; none in the corridor beyond C2 (which only sees D1); D1 needs the shared PIN (shoulder-surf it earlier, thermal imaging, or social-engineer it from IT). Alternative: P1 → E3 → R5 → corridor → R1.

**Cheapest fixes:** (1) door-held-open alarm + sensors on E2/E4, enforced no-prop policy; (2) lock and badge-reader the loading bay, staff meet drivers at the door, sign-in log; (3) replace the shared PIN on D1 with badge + PIN (or biometric) and extend C2 to cover the corridor. Also: lock the shred bin and move the printer LAN port to a disabled/802.1X port; fence or gate and light P1.

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

- **Premises in scope:** Named building address only (e.g. "Ground Floor, 88 Harbour Street, Sydney NSW, rooms R1–R10, doors E1–E4 and car park P1" — never "all CyberCorp offices").
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

---

## hands-on-lab.md Challenge 5 — Model Answers (CyberCorp tabletop)

**Part A recon:** Outside doors E1, E2, E3, E4. No camera/alarm: E2, E3, E4 (E1 has C3). Guard covers only E1 and only 9–5, and the gate is propped during the rush. Highest value: R1, R3, then R2 (USB drives, spare laptops) and R7 (print jobs). OSINT: Google Street View of the loading bay, LinkedIn for staff names and badge photos, job ads for the security stack (HID iCLASS vs DESFire), delivery companies seen at the dock, social posts showing the lanyard.

**Part B example attempts:**

| # | Entry | Technique | Cover | Control defeated |
|---|-------|-----------|-------|------------------|
| 1 | E4 | Walk in through propped door | Smoker, no pretext | None (no alarm/camera) |
| 2 | E3 | Walk in with parcel | Courier hi-vis | No sign-in, no badge |
| 3 | E1 | Tailgate at 8:50 | Late staff member, coffee in hands | Swipe gate, guard distracted |

**Part C path:** P1 → E4 → R9 → corridor → D1 → R1. Best time: 8:45–9:15 or 1pm lunch when staff are in R9. Risks: C2 sees D1 (it records the attempt); shared PIN unknown; guard is unaware, so detained by staff only. Single most useful control: alarmed, badge-controlled E4/E3 plus a corridor door that splits public from private zones, because every path crosses the corridor.

**Part D:** USB: P1 near E4 and R9 table, label "Q3 Salary Review - Confidential". Rogue device: R7 LAN port behind the printer, gives internal network. Evidence in R6/R7: unlocked workstation with active session (wide shot), unlocked shred bin contents, spare wall ports in R6 (live).

**Part E example ranking:**

| Rank | Fix | Plan ref | Layer |
|------|-----|----------|-------|
| 1 | Door-held-open alarms, enforce no propping | E4, E2 | Perimeter |
| 2 | Badge reader + log on loading bay, sign-in for deliveries | E3 | Perimeter |
| 3 | Replace shared PIN with badge + PIN | D1 | Intermediate |
| 4 | USB port control by GPO, 802.1X on wall/printer ports | R6, R7 | Final (device) |
| 5 | Extend camera cover over corridor, lock shred bin, light P1 | C2, R7, P1 | Detection/Intermediate |
