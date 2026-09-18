# Week 2 Worksheet Walkthrough — INSTRUCTOR ONLY

> Discussion/legal-analysis worksheet — no lab environment. Model answers
> below; discussion questions have no single "correct" answer, but should
> hit the reasoning shown.

---

## Part 1: Legal Framework

### Exercise 1.1: Spot the Offence

| Scenario | Legal or Illegal? | Which law? | Why? |
|----------|------------------|-----------|------|
| Unlocked admin panel, browsing without logging in | **Illegal / high-risk** | Criminal Code Act 1995 (Cth), Part 10.7, s478.1 (unauthorised access to restricted data) | Australian law bases the offence on lack of *authorisation*, not on whether a technical barrier was bypassed. "No login required" doesn't mean "authorised." |
| Company hires you, you scan their IP range with Nmap | **Legal** | N/A (authorised activity) | Written authorisation from the system owner is the entire basis for legality — this is a properly scoped, consented engagement. |
| Using employer credentials after being fired | **Illegal** | Part 10.7, s478.1 / s477.1 | Authorisation is revoked the moment employment ends, regardless of whether the credentials still technically work. This is a very common real prosecution pattern. |
| Cracking a hash in a CTF challenge on a dedicated platform | **Legal** | N/A | The platform is explicitly built and authorised for this activity — no unauthorised system is touched. |
| Port-scanning a competitor "just to see" | **Legally risky, not clearly criminal on its own** | Part 10.7 (potential precursor offence) | Scanning alone doesn't access or modify data, but doing it against a system you have no authorisation for is inadvisable and could support other offences or civil action (e.g. under the competitor's terms of service). |
| SQLi found on a bank site, confirmed with one query, then reported | **Technically illegal despite good intent** | Part 10.7, s478.1 (unauthorised access) | Ethically this is a textbook example of good-faith responsible disclosure, but running even one unauthorised test query against a bank's live system is still unauthorised access under Australian law. Good intent isn't a legal defence. |

### Exercise 1.2: Elements of Authorisation

**Essential:** Client's full legal name and ABN; exact IP ranges/systems in
scope; systems explicitly out of scope; permitted testing hours; what to do
if a critical vulnerability is found mid-test; emergency contact for
client's IT team; signature of someone authorised to grant access; how long
the tester can retain evidence.

**Not essential:** tester's favourite tools; tester's LinkedIn profile.

**Discussion — why is "out of scope" as important as "in scope"?** Anything
not explicitly in scope is, by default, unauthorised — testing it removes
your legal protection entirely, even if it was an honest mistake (e.g. a
shared hosting IP that also serves a third party's site). Out-of-scope
systems are often the most sensitive ones (production databases, systems
belonging to a different legal entity), so the cost of getting this wrong
is high.

---

## Part 2: Hacker Ethics

### Exercise 2.1: The Hat Spectrum

```
BLACK ←──────────────────────────────────────────────────────→ WHITE
Nation-state critical    Hacktivist    Student Nmap'ing    Bug bounty (in-   Freelancer under
infra compromise         defacement    campus "for fun"    scope XSS find)   signed contract,
                                                                              Bank's internal
                                                                              red team
```

- Bank's internal red team — **White** (fully authorised, employed for this purpose)
- Hacktivist defacing a government website — **Black** (unauthorised, destructive, no consent)
- Bug bounty hunter, in-scope XSS — **White** (authorised by the program's terms)
- Student running Nmap on campus network "for fun" — **Grey** (no malicious intent, but no authorisation either)
- Nation-state actor compromising critical infrastructure — **Black** (most severe end of the spectrum)
- Freelancer under signed contract — **White**

**Discussion — where does grey hat sit, and why is it risky even when
well-intentioned?** Grey hat sits between "no authorisation, no malice" and
"authorised." It's legally risky specifically *because* Australian law (like
most jurisdictions) determines legality by authorisation, not intent — a
well-meaning unauthorised scan is, legally, in the same category as a
malicious one; only enforcement discretion (not the law itself) tends to
differ.

### Exercise 2.2: Case Study — The WannaCry Researcher

1. **Legal under Australian law?** Registering an unclaimed domain is not,
   itself, "accessing," "modifying," or "impairing" a computer system under
   Part 10.7 — Hutchins didn't break into WannaCry's infrastructure, he
   simply registered a domain name the malware's own code was already
   configured to check. This sits in a genuine grey zone the Criminal Code
   wasn't written with in mind — a good discussion point about how
   cybercrime law struggles to anticipate novel technical scenarios.
2. **Ethical counterargument:** the action was defensive, stopped an
   active, globally damaging ransomware outbreak, required no unauthorised
   access to any system, and was disclosed openly and immediately —
   textbook "responsible" behaviour even without prior authorisation.
3. **Safest legal path today:** contact the ACSC (Australian Cyber Security
   Centre) or a national CERT immediately with the finding *before* acting
   where possible; if the situation is too time-critical to wait, act, then
   immediately and fully document what was done and why, and disclose to
   the relevant authority without delay — the paper trail proving defensive
   intent is what matters most after the fact.

---

## Part 3: Penetration Testing Process

### Exercise 3.1: Order the Phases

1. Meet with client to define scope, rules of engagement, and emergency contacts
2. Obtain signed authorisation letter defining scope
3. Gather OSINT — public DNS records, WHOIS, LinkedIn staff
4. Scan identified hosts for open ports and service versions
5. Attempt to exploit a discovered vulnerability
6. Attempt to escalate privileges on a compromised host
7. Deliver written report with findings and remediation recommendations

### Exercise 3.2: Scope Definition Practice — sample answer

> This engagement covers external network penetration testing of
> `cybercorp.com.au` and all subdomains hosted on IP ranges provided in
> Appendix A, limited to black-box testing of publicly reachable services.
> Out of scope: any third-party-hosted services (e.g. SaaS platforms,
> CDN-fronted assets not owned by CyberCorp), physical security testing,
> social engineering of staff, and denial-of-service testing of any kind.
> Testing will occur only during the agreed window (weekdays, 9am–5pm
> AEST). If a vulnerability is found that provides access to systems
> containing customer PII, or that could cause a service outage if
> exploited further, testing will stop immediately and the emergency
> contact will be notified within one hour.

---

## Part 4: Responsible Disclosure

### Exercise 4.1: Disclosure Timeline — sample answers

- **Day 0:** Stop testing immediately, document the finding in detail
  (steps to reproduce, screenshots, timestamps), do not access or exfiltrate
  any real customer data beyond the minimum needed to prove the
  vulnerability exists, and do not disclose publicly.
- **Day 1–3:** Contact the vendor's security team directly (security@
  address, or a listed security.txt / bug bounty program if one exists),
  including a clear technical writeup, proof of concept, potential impact,
  and a proposed disclosure timeline (commonly 90 days).
- **Day 90:** If the vendor hasn't responded or fixed the issue, options
  include: extending the deadline if the vendor is actively engaged and
  making progress, escalating through a national CERT/ACSC as an
  intermediary, or proceeding with limited public disclosure (technical
  details withheld) to warn users while still giving the vendor a final
  window.
- **Day 91:** Respond professionally — restate the original timeline was
  shared on Day 1–3, that 90 days is an industry-standard window (matching
  Google Project Zero's policy), and that the goal throughout was
  protecting users, not causing harm. Avoiding public disclosure entirely
  under vendor pressure, with no fix in place, generally isn't defensible.

### Exercise 4.2: Bug Bounty vs. Responsible Disclosure

| | Bug Bounty Program | Responsible Disclosure |
|---|---|---|
| Formal agreement before testing? | Yes — program terms/legal safe harbor | No — informal, ad hoc |
| Are you paid? | Often yes | Usually no |
| Scope defined in advance? | Yes | No — found opportunistically |
| Legally protected? | Yes, if you stay within the program's stated scope and rules | Not guaranteed — depends on the vendor's own policy, if any |
| Example platform | HackerOne, Bugcrowd | Direct vendor contact, national CERT/AusCERT coordination |

---

## Part 5: Assessment 1 Prep

No fixed answer — this is a personal brainstorm students carry into Week 4.
When reviewing, check for: a plausible industry, at least one detail that
implies attack surface (e.g. "runs a customer portal," "has retail
locations with POS systems"), and a fictional name that doesn't collide
with a real company.

---

## Quick Knowledge Check — Answers

1. **C) 10 years** — the more serious offences under Part 10.7 of the
   Criminal Code Act 1995 (Cth) carry maximum penalties of up to 10 years.
2. **B) Notifying affected individuals and the OAIC** — the Notifiable Data
   Breaches scheme under the Privacy Act 1988.
3. **C) Enumeration** — recon → scanning → enumeration → exploitation.
4. **False** — authorisation must be in writing, signed by someone with
   the authority to grant it; a verbal okay from an administrator provides
   no legal protection.
5. **C) Google Project Zero** — well known for popularising the 90-day
   coordinated disclosure window.
