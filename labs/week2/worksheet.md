# Week 2: Ethics, Law, and the Hacking Mindset
## CYB204 Ethical Hacking — Discussion Worksheet

---

## Part 1: Legal Framework (20 minutes)

### Exercise 1.1: Spot the Offence

For each scenario, identify which Australian law applies and whether the act is a criminal offence. Be specific about what makes it legal or illegal.

| Scenario | Legal or Illegal? | Which law? | Why? |
|----------|------------------|-----------|------|
| You find an unlocked admin panel on a website you do not own and browse it without logging in | | | |
| A company hires you to test their network and you scan their IP range with Nmap | | | |
| You use your employer's credentials to access a system after you have been fired | | | |
| You crack a hash found in a CTF challenge on a dedicated CTF platform | | | |
| You run a port scan against a competitor's public-facing server "just to see what's there" | | | |
| You discover a SQL injection on a bank's website, confirm it works with a single test query, then stop and email their security team | | | |

---

### Exercise 1.2: Elements of Authorisation

A penetration testing engagement letter must cover specific elements to be legally protective. Circle which items below are **essential** (the engagement is legally risky without them):

- [ ] Client's full legal name and ABN
- [ ] Tester's favourite tools
- [ ] Exact IP ranges and systems in scope
- [ ] Systems explicitly **out of scope**
- [ ] Permitted testing hours (e.g. business hours only)
- [ ] What to do if a critical vulnerability is found mid-test
- [ ] Emergency contact for the client's IT team
- [ ] Signature of someone authorised to grant access
- [ ] How long the tester can retain copies of evidence
- [ ] The tester's LinkedIn profile

**Discussion:** Why might "out of scope" be just as important as "in scope"?

_________________________________

---

## Part 2: Hacker Ethics (20 minutes)

### Exercise 2.1: The Hat Spectrum

Place each description on the hat spectrum below:

```
BLACK ←─────────────────────────────────────────────────────→ WHITE
       (criminal)                                (fully authorised)
```

- A security researcher at a bank running internal red team exercises
- A hacktivist defacing a government website to protest a policy
- A bug bounty hunter finding an XSS vulnerability in a web app within the program's scope
- A university student running Nmap against their campus network "for fun"
- A nation-state actor compromising critical infrastructure
- A freelancer conducting a pentest under a signed contract

**Discussion:** Where does "grey hat" sit, and why is it legally risky even when well-intentioned?

_________________________________

---

### Exercise 2.2: Case Study — The Wannacry Researcher

In 2017, Marcus Hutchins (MalwareTech) accidentally stopped the WannaCry ransomware attack by registering an unregistered domain used as a kill switch. He did this without any formal authorisation.

1. Was his action legal under Australian law? Consider the Criminal Code Act carefully.

   _________________________________

2. What is the counterargument — why do many people consider what he did ethical?

   _________________________________

3. If you discovered a similar kill switch today, what would the "safest legal path" be?

   _________________________________

---

## Part 3: Penetration Testing Process (20 minutes)

### Exercise 3.1: Order the Phases

Number these activities in the correct order for a professional pentest engagement:

___ Deliver written report with findings and remediation recommendations  
___ Obtain signed authorisation letter defining scope  
___ Attempt to escalate privileges on a compromised host  
___ Scan identified hosts for open ports and service versions  
___ Gather OSINT — public DNS records, WHOIS, LinkedIn staff  
___ Meet with client to define scope, rules of engagement, and emergency contacts  
___ Attempt to exploit a discovered vulnerability  

---

### Exercise 3.2: Scope Definition Practice

You have been asked to test `cybercorp.com.au`. Write a one-paragraph scope statement that is specific enough to be legally protective. Include at minimum: what IS in scope, what is NOT in scope, and one condition under which you would stop and call the client immediately.

_________________________________

_________________________________

_________________________________

---

## Part 4: Responsible Disclosure (15 minutes)

### Exercise 4.1: Disclosure Timeline

You have found a critical remote code execution vulnerability in a popular Australian payroll SaaS product used by 500+ businesses. Draft a responsible disclosure plan:

**Day 0:** What do you do immediately after confirming the vulnerability?

_________________________________

**Day 1–3:** Who do you contact, how, and what do you include?

_________________________________

**Day 90:** The vendor has not responded. What are your options?

_________________________________

**Day 91:** You publish. The vendor contacts you angry, saying you should have waited longer. How do you respond?

_________________________________

---

### Exercise 4.2: Bug Bounty vs. Responsible Disclosure

Fill in the comparison table:

| | Bug Bounty Program | Responsible Disclosure |
|---|---|---|
| Is there a formal agreement before testing? | | |
| Are you paid? | | |
| Is scope defined in advance? | | |
| Are you legally protected? | | |
| Example platform | | |

---

## Part 5: Assessment 1 Prep (10 minutes)

Assessment 1 (due Week 4) is a 1500-word **ethical hacking engagement proposal**.

Your proposal must include:
- Scope definition (what you will and won't test)
- Legal and ethical considerations
- Reconnaissance methodology
- Tools you plan to use
- Deliverables and timeline

**Brainstorm:** Choose a fictional company for your proposal target. Write 3 bullet points describing their IT environment (what systems they might have, what industry they're in). You'll use this in Week 4 when you write the recon section.

1. _________________________________
2. _________________________________
3. _________________________________

---

## Quick Knowledge Check

1. Under the Criminal Code Act 1995, what is the maximum penalty for "serious computer offences"?
   - A) 2 years  B) 5 years  C) 10 years  D) 20 years

2. What does the Notifiable Data Breaches scheme require?
   - A) Publishing breach details publicly  B) Notifying affected individuals and the OAIC  C) Paying a fine within 30 days  D) Shutting down affected systems

3. Which phase comes BEFORE exploitation in a pentest?
   - A) Reporting  B) Post-exploitation  C) Enumeration  D) Remediation

4. True/False: A verbal agreement from a system administrator is sufficient authorisation for a penetration test.

5. The 90-day disclosure deadline is associated with which organisation?
   - A) ACSC  B) AusCERT  C) Google Project Zero  D) OWASP

---

## Summary

Today you explored:
✓ Australian laws governing computer access and cybercrime
✓ The difference between black, white, and grey hat hacking
✓ The phases of a professional penetration testing engagement
✓ How responsible disclosure works in practice
✓ What a legally sound scope statement must contain

**Next week (Week 3):** Passive reconnaissance — gathering information without touching the target.

**Instructor Contact:** _________________________________
