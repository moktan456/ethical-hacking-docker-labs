# Week 12 Worksheet Walkthrough — INSTRUCTOR ONLY

> This week has no Docker lab — it's a discussion/role-play session, so
> this walkthrough is a model-answer key rather than verified command
> output. Do not distribute to students before the end of the session.

---

## Part 1: Attack Identification

### Exercise 1.1: Classify the Attack

| Scenario | Technique | Psychological Principle |
|----------|-----------|------------------------|
| "ITHelpdesk@cybercorp-support.com" asks you to reset your VPN password via a link | Phishing (spoofed lookalike domain) | Authority |
| Caller claims to be from the ATO, tax file number compromised, press 1 | Vishing | Authority + Urgency |
| USB "HR Salary Data 2024" left in the kitchen | Baiting | Curiosity (closely tied to scarcity/temptation of confidential-looking data) |
| Caller claims to be a new IT contractor needing the WiFi password "urgently" | Pretexting | Authority + Urgency |
| "5 of your colleagues have already updated their security profile" | Phishing | Social proof |
| "Microsoft support agent" says they detected a virus, needs remote access | Vishing (tech support scam) | Authority |

### Exercise 1.2: Spot the Red Flags — model answer

1. Sender domain is a lookalike (`microsofft-accounts.net` — extra "f",
   wrong TLD pattern) rather than a real Microsoft domain.
2. Generic greeting ("Dear Valued Customer") instead of the recipient's
   actual name.
3. Artificial urgency/threat ("24 HOURS", "permanently deleted") designed
   to short-circuit careful thinking.
4. The link's display text doesn't match its real destination — hovering
   would show `microsofft-login.net`, a different lookalike domain, not a
   real Microsoft login URL.
5. Generic/mismatched sign-off ("Office of Account Protection" is not a
   real Microsoft team name), plus a call-to-action phrased with pressure
   ("must act immediately") that legitimate account-security emails avoid.

---

## Part 2: Psychological Principles

### Exercise 2.1: Map Cialdini to Attacks — model scenarios

| Principle | Example attack scenario |
|-----------|-------------------------|
| Authority | An email impersonating the CFO instructs finance to process an urgent wire transfer before end of day. |
| Urgency | "Your mailbox will be permanently deleted in 2 hours unless you re-verify your credentials now." |
| Social Proof | "94% of your team has already completed this mandatory security update — don't be the exception." |
| Liking | An attacker spends several friendly calls building rapport with a receptionist before finally asking for an internal extension list "for a project." |
| Reciprocity | A caller offers free "IT health check" tips first, then asks the employee to install a "monitoring tool" (RAT) in return. |
| Commitment | A phone caller gets the target to agree to small requests ("Can you confirm you're at your desk?", "Can you confirm your username?") before escalating to "Can you read me the code that just came through?" |

### Exercise 2.2: Why Training Fails

**Reason 1:** A single annual session relies on short-term recall; without
reinforcement, specific red-flag knowledge fades long before the next
real phishing attempt arrives, and one-off training doesn't build the
habitual "pause and verify" reflex needed in the moment.

**Reason 2:** Security-awareness retention research (e.g. Ebbinghaus-style
forgetting-curve studies applied to security training) generally shows
measurable drop-off within weeks, not months — most of the initial
learning is lost within 1–3 months without any reinforcement, which is
far shorter than a typical annual training cycle.

**Proposed fix (3-step programme):**
1. **Frequency:** Move from annual to monthly micro-training (5-minute
   modules) plus continuous, randomised simulated phishing throughout the
   year rather than one big test.
2. **Method:** Just-in-time feedback — anyone who clicks a simulated
   phish is redirected immediately to a short explainer showing exactly
   which red flags they missed, while the click is fresh in memory.
3. **What happens on a click:** No punishment on a first click — a brief,
   mandatory micro-refresher and inclusion in the next round of testing;
   repeated clicks (see Exercise 4.3) escalate to a private conversation
   and targeted coaching, not public shaming.

---

## Part 3: Role Play — Vishing Simulation (debrief guidance)

This is a live in-class exercise, so there's no single "correct"
transcript — use these as the debrief talking points:

- **Did the attacker succeed?** Whether or not they did, the technique
  that usually works is combining a plausible authority claim ("James
  from Brisbane"), a specific-sounding pretext detail (correct area code,
  correctly naming the IT manager "Sandra"), and manufactured urgency —
  the specific detail is what makes people skip the verification step,
  because it signals insider knowledge.
- **What the help desk employee should have done differently:** Followed
  the stated procedure without exception — confirm the caller's employee
  ID through an independent channel (call back the number on file, not a
  number the caller provides) regardless of how convincing or urgent the
  request sounds.
- **Technical control that removes the human judgment call entirely:**
  A password-reset process that requires MFA re-enrolment or manager
  approval through a ticketing system — i.e. one where "sounding
  convincing on the phone" is structurally incapable of resetting a
  password, because the help desk itself has no ability to bypass the
  verification step even under pressure.

---

## Part 4: Phishing Campaign Design

### Exercise 4.1: Pretext — model answer

**Subject:** Action required: IT asset audit — confirm your equipment by Friday

**Body:** As part of this quarter's IT asset audit, please confirm the
laptop and monitor currently assigned to you using the form below. Staff
who do not confirm by Friday will have their equipment flagged for
collection and reissue. [Confirm my equipment →]

(Believable because asset audits are routine and low-stakes-sounding;
obviously suspicious in hindsight because of the vague "collection and
reissue" threat and the generic external-style link for an internal IT
process.)

### Exercise 4.2: Metrics

| Metric | What it measures | Bad result threshold |
|--------|-------------------|----------------------|
| Open rate | How many recipients opened the email at all | Not very diagnostic alone — high open rate with low click rate is actually a good sign; mainly useful to confirm delivery worked |
| Click rate | How many recipients clicked the phishing link | >20-25% clicking is a red flag that basic recognition training is lacking |
| Credential submission rate | How many entered credentials on the fake landing page | Any non-trivial rate (e.g. >5%) indicates real organisational risk, since this is the step that causes actual compromise |
| Report rate | How many employees reported the email as suspicious (rather than ignoring or clicking) | A low report rate (e.g. <10%) even when click rate is low suggests employees aren't engaging with the "report" process, which matters just as much as not clicking |

### Exercise 4.3: Responsible Use

1. **Immediately:** Do not name-and-shame; quietly confirm no real
   credentials were exposed (it was a simulation, so the "credentials"
   only reached the internal test platform) and ensure the employee isn't
   left anxious that they've caused a real breach.
2. **Reporting to management:** Report aggregate/de-identified metrics by
   default; if individual follow-up is genuinely needed, frame it as a
   training/support conversation with the employee's manager, not a
   disciplinary referral, and keep the employee's name out of any
   broader report.
3. **Follow-up:** Targeted 1:1 coaching (not a group session that could
   identify them), a walkthrough of exactly what red flags were present in
   the three emails, and inclusion in more frequent (but still
   non-punitive) simulated tests to build the habit.

---

## Part 5: Legal and Ethical Constraints

### Exercise 5.1: Scope Boundaries

| Action | Needs explicit authorisation beyond the standard agreement? |
|--------|---------------------------------------------------------------|
| Sending phishing emails to company email addresses | No — standard scope for an authorised SE engagement |
| Calling employees on their personal mobile numbers | **Yes** — personal numbers are outside the corporate environment and raise separate privacy concerns |
| Impersonating a named real employee (e.g. "Hi, I'm Sandra") | **Yes** — defamation/identity risk to the real person named; needs explicit sign-off, often with that person's own knowledge |
| Sending phishing SMS to employee work phones | No, if work phones are company-issued and in the standard scope — but confirm explicitly if BYOD |
| Physically entering a building as part of the pretext | **Yes** — this crosses into physical pentest territory (Week 11) and needs its own authorisation letter |
| Recording phone calls during vishing tests | **Yes** — recording consent laws vary by state |

**Discussion — Australian recording law:** Several Australian states/
territories (including Queensland, NSW, South Australia, Western
Australia, and the ACT/NT under their respective surveillance/listening
device acts) require **all-party consent** to record a private
conversation, unlike "one-party consent" jurisdictions common in parts of
the US. This is why vishing engagement scope statements typically require
either recording under an internal-monitoring notice already known to
staff, or explicit written waiver from the specific employees who may be
called, rather than assuming the standard pentest contract alone covers
it.

---

## Quick Knowledge Check — Answers

1. B — Targeted phishing using personal OSINT about the victim
2. C — Urgency
3. B — GoPhish
4. False — a signed pentest contract authorises testing the target organisation's security, but impersonating a real government official/agency can still carry separate legal exposure (e.g. impersonation offences) and must be scoped and cleared very carefully, if attempted at all
5. B — Fabricating a scenario to extract information from a target
