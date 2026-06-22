# Week 12: Social Engineering
## CYB204 Ethical Hacking — Discussion Worksheet

---

## Before We Start

### Important Rules
✅ **DO:** Analyse and discuss these techniques academically
✅ **DO:** Use these insights to design better defences
❌ **DON'T:** Attempt any social engineering attack against real people without explicit written authorisation
❌ **DON'T:** Use phishing tools outside a controlled, authorised lab environment

---

## Part 1: Attack Identification (20 minutes)

### Exercise 1.1: Classify the Attack

For each scenario, identify the social engineering technique used and the psychological principle being exploited.

| Scenario | Technique | Psychological Principle |
|----------|-----------|------------------------|
| An email from "ITHelpdesk@cybercorp-support.com" asks you to reset your VPN password via a link | | |
| A caller claims to be from the ATO and says your tax file number has been compromised — press 1 to speak to an agent | | |
| A USB drive labelled "HR Salary Data 2024" is left in the office kitchen | | |
| Someone calls claiming to be a new IT contractor who just joined today and needs the WiFi password "urgently" | | |
| An email says "5 of your colleagues have already updated their security profile — you are the only one who hasn't" | | |
| A "Microsoft support agent" calls saying they've detected a virus on your computer and need remote access to fix it | | |

---

### Exercise 1.2: Spot the Red Flags

Examine this fictional phishing email. Circle or list every red flag:

```
From: security-alert@microsofft-accounts.net
To: you@cybercorp.com.au
Subject: URGENT: Your account will be suspended in 24 hours

Dear Valued Customer,

We have detected suspicious activity in your Microsoft 365 account.
To prevent suspension, you must verify your identity immediately.

Click here to verify: http://microsofft-login.net/verify?token=abc123

If you do not act within 24 HOURS your account will be permanently deleted.

Regards,
Microsoft Security Team
Office of Account Protection
```

**Red flags you identified:**

1. _________________________________
2. _________________________________
3. _________________________________
4. _________________________________
5. _________________________________

---

## Part 2: Psychological Principles (20 minutes)

### Exercise 2.1: Map Cialdini to Attacks

For each Cialdini principle, write a one-sentence social engineering attack that exploits it:

| Principle | Your Attack Scenario |
|-----------|---------------------|
| Authority | |
| Urgency | |
| Social Proof | |
| Liking | |
| Reciprocity | |
| Commitment | |

---

### Exercise 2.2: Why Training Fails

A company runs annual security awareness training. Six months later, 40% of employees still click a simulated phishing link.

**Reason 1:** Why might a single annual training session be insufficient?

_________________________________

**Reason 2:** What does the research say about how quickly security awareness fades without reinforcement?

_________________________________

**Proposed fix:** Design a 3-step programme to address this. Include frequency, method, and what happens when someone clicks a simulated phish.

1. _________________________________
2. _________________________________
3. _________________________________

---

## Part 3: Role Play — Vishing Simulation (25 minutes)

Your instructor will pair you with a partner. One person plays the attacker, one plays the target (a help desk employee).

### Scenario

**Attacker's brief:** You are pretending to be "James from the Brisbane office." Your goal is to get the help desk to reset a password for the account "admin.backup" without following the normal verification process. You have done OSINT and know the company uses Microsoft 365, that the Brisbane office number starts with 07, and that the IT manager's name is "Sandra."

**Target's brief:** You work on the IT help desk. Normal procedure requires the caller to confirm their employee ID before you reset any password. You do not know this person by voice.

**After the role play, debrief:**

- Did the attacker succeed? What technique worked?

  _________________________________

- What should the help desk employee have done differently?

  _________________________________

- What technical control could have made the attacker's goal impossible regardless of the conversation?

  _________________________________

---

## Part 4: Phishing Campaign Design (20 minutes)

You have been authorised to run an internal phishing simulation for CyberCorp to assess employee awareness. Design the campaign:

### Exercise 4.1: Pretext

Write a realistic phishing email pretext (subject line + 3-line body). It must be believable to a corporate employee but obviously suspicious in hindsight.

**Subject:** _________________________________

**Body:**

_________________________________

_________________________________

_________________________________

---

### Exercise 4.2: Metrics

GoPhish tracks several metrics. Explain what each tells you and what a "bad" result looks like:

| Metric | What it measures | Bad result threshold |
|--------|-----------------|---------------------|
| Open rate | | |
| Click rate | | |
| Credential submission rate | | |
| Report rate (employees who reported it) | | |

---

### Exercise 4.3: Responsible Use

You run the campaign and find that one employee submitted their credentials three times across three different test emails.

1. What do you do immediately (before reporting)?

   _________________________________

2. How do you report this to management without shaming the employee?

   _________________________________

3. What follow-up training or support is appropriate for this employee?

   _________________________________

---

## Part 5: Legal and Ethical Constraints (10 minutes)

### Exercise 5.1: Scope Boundaries

For each action in a social engineering pentest, mark whether it requires explicit client authorisation beyond the standard pentest agreement:

| Action | Needs explicit authorisation? |
|--------|-------------------------------|
| Sending phishing emails to company email addresses | |
| Calling employees on their personal mobile numbers | |
| Impersonating a named real employee (e.g. "Hi, I'm Sandra the IT manager") | |
| Sending phishing SMS to employee work phones | |
| Physically entering a building as part of the pretext | |
| Recording phone calls during vishing tests | |

**Discussion:** Recording laws in Australia vary by state. Which states require *all parties* to consent to a phone recording?

_________________________________

---

## Quick Knowledge Check

1. What is "spear phishing"?
   - A) Mass phishing sent to thousands  B) Targeted phishing using personal OSINT about the victim  C) Phishing via SMS  D) Voice phishing

2. Which Cialdini principle does "Your account will be locked in 10 minutes" exploit?
   - A) Liking  B) Social proof  C) Urgency  D) Reciprocity

3. What open-source tool is commonly used to run authorised phishing simulations?
   - A) Metasploit  B) GoPhish  C) Nmap  D) Burp Suite

4. True/False: Impersonating an ATO officer in a vishing call is legal if you have a signed pentest contract.

5. What is pretexting?
   - A) A type of malware  B) Fabricating a scenario to extract information from a target  C) Testing before the real attack  D) A network scanning technique

---

## Course Wrap-Up

### Reflection: The Full Kill Chain

Look back over the 12 weeks. For each phase, write the tool or technique you found most valuable:

| Phase | Tool/Technique | Why it stood out |
|-------|---------------|-----------------|
| Recon (Week 4) | | |
| Enumeration (Week 5) | | |
| Password attacks (Week 6) | | |
| Network analysis (Week 7/8) | | |
| Lateral movement (Week 9) | | |
| Exploitation (Week 10) | | |
| Physical access (Week 11) | | |
| Social engineering (Week 12) | | |

---

## Summary

Today you explored:
✓ Six major social engineering attack types
✓ Cialdini's six principles of influence as they apply to attacks
✓ How to spot phishing red flags
✓ How to design a responsible internal phishing simulation
✓ Legal constraints unique to social engineering testing

**Assessment 2** (due this week): 3000-word practical pentest report. Your Week 10 lab notes and recon outputs are the raw material — synthesise them into a professional report.

**Instructor Contact:** _________________________________
