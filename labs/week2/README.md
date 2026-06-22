# Week 2: Ethics, Law, and the Hacking Mindset

## CYB204 Ethical Hacking — Week 2

**No Docker lab this week.** This session is a facilitated discussion and case-study workshop.

---

## Learning Objectives

By the end of this week you should be able to:

- Explain the key Australian laws that govern computer access and cybercrime
- Distinguish between black-hat, white-hat, and grey-hat hacking
- Describe the phases of a professional penetration test engagement
- Identify what written authorisation must cover before testing begins
- Explain the concept of responsible disclosure

---

## Key Legislation (Australia)

| Act | Key Provision |
|-----|--------------|
| **Criminal Code Act 1995 (Cth) — Part 10.7** | Criminalises unauthorised access, modification, or impairment of computer data. Up to 10 years imprisonment for serious offences. |
| **Privacy Act 1988 (Cth)** | Governs handling of personal information. Breaches must be notified under the Notifiable Data Breaches scheme. |
| **Cybercrime Act 2001 (Cth)** | Introduced computer-specific offences into the Criminal Code. |
| **State/Territory equivalents** | Each state has its own computer offence legislation (e.g. Crimes Act 1900 NSW s308). |

**Key principle:** Authorisation is everything. The exact same action — scanning a server, cracking a hash — is legal with written permission and criminal without it.

---

## Penetration Testing Phases

```
1. Pre-engagement  →  Scope, rules of engagement, written authorisation
2. Reconnaissance  →  Passive and active information gathering (Week 4)
3. Scanning        →  Port/service discovery (Week 4)
4. Enumeration     →  User accounts, services, shares (Week 5)
5. Exploitation    →  Gaining access (Weeks 6–8, 10)
6. Post-exploitation → Lateral movement, persistence (Week 9)
7. Reporting       →  Written findings with remediation (Week 10)
```

---

## Responsible Disclosure

When a researcher finds a vulnerability in a system they did **not** have authorisation to test:

1. **Do not exploit** beyond confirming the vulnerability exists
2. **Contact** the affected organisation privately (security@, CERT Australia, AusCERT)
3. **Give reasonable time** to patch before publishing (typically 90 days — Google Project Zero standard)
4. **Document everything** — timestamps, communications, evidence of good faith

---

## See Also

- worksheet.md — discussion questions and case studies for this week's class
