# Week 12: Social Engineering

## CYB204 Ethical Hacking — Week 12

**No Docker lab this week.** This session covers human-based attack techniques, psychological principles, and social engineering defences.

---

## Learning Objectives

By the end of this week you should be able to:

- Define social engineering and explain why it is often the most effective attack vector
- Describe phishing, vishing, smishing, and pretexting with real-world examples
- Apply psychological principles (authority, urgency, scarcity) to explain why attacks succeed
- Design a basic social engineering awareness training programme
- Explain the legal constraints on social engineering as part of a pentest scope

---

## Social Engineering Attack Types

| Attack | Medium | Description |
|--------|--------|-------------|
| **Phishing** | Email | Mass or targeted (spear phishing) email impersonating a trusted entity |
| **Spear phishing** | Email | Highly targeted, personalised — uses OSINT about the specific victim |
| **Vishing** | Phone call | Voice call impersonating IT support, bank, or authority figure |
| **Smishing** | SMS | Text message with malicious link or request |
| **Pretexting** | Any | Building a fabricated scenario to extract information |
| **Baiting** | Physical/digital | Offering something enticing (USB drive, fake prize) to gain access |
| **Quid pro quo** | Phone/email | Offering a service (fake IT help) in exchange for credentials |
| **Watering hole** | Web | Compromising a website the target is known to visit |

---

## Psychological Principles (Cialdini's Influence)

Social engineers exploit well-documented cognitive biases:

| Principle | How attackers use it |
|-----------|---------------------|
| **Authority** | Impersonate IT, CEO, ATO, or police to demand compliance |
| **Urgency** | "Your account will be locked in 10 minutes — click now" |
| **Scarcity** | "Only 1 licence remaining — renew immediately" |
| **Social proof** | "Everyone in your department has already updated their password" |
| **Liking** | Build rapport before making a request |
| **Reciprocity** | Offer something small first (fake tech support) to create obligation |
| **Commitment** | Get small "yes" answers first, escalating to larger requests |

---

## Phishing Campaign Tools (for authorised testing)

| Tool | Purpose |
|------|---------|
| **GoPhish** | Open-source phishing framework — campaign management, click tracking |
| **SET (Social Engineering Toolkit)** | Kali tool — credential harvesting, spear phishing |
| **Evilginx2** | Reverse proxy for bypassing 2FA via session token theft |
| **Modlishka** | Real-time reverse proxy phishing |

**Note:** These tools are pre-installed on the `ethical-base` image or available via `apt` on Kali.

---

## Defence: Security Awareness Training

Effective training programmes address:

1. **Recognition** — How to spot phishing (sender mismatch, urgency, unexpected attachments)
2. **Process** — What to do when you receive a suspicious message (report, don't click)
3. **Simulation** — Regular internal phishing tests with immediate training on failure
4. **Culture** — "When in doubt, pick up the phone to verify" as a team norm

---

## See Also

- worksheet.md — role-play scenarios and assessment exercises for this week's class
