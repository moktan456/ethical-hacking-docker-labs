# Week 11: Physical Security and Access Controls

## CYB204 Ethical Hacking — Week 11

**No Docker lab this week.** This session covers physical attack vectors, access control systems, and on-site social engineering techniques.

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

## See Also

- worksheet.md — case studies and assessment exercises for this week's class
