# Week 10 Mock Exams: Comparison Guide

**Choosing Between week10-mock and week10-mock2**

---

## Quick Comparison

| Feature | week10-mock | week10-mock2 |
|---------|------------|-------------|
| **Duration** | ~90 minutes | 3 hours |
| **Services** | 3 (web, FTP, SSH) | 4 (web, FTP, SSH, database) |
| **Flags** | 2 | 3 |
| **Difficulty** | Progressive | Deliberately uneven (1 easy, 2 hard) |
| **Pass Threshold** | Linear | 50% from Flag 1 + documentation alone |
| **Weeks Covered** | 4-8 | 1-9 (comprehensive) |
| **Purpose** | Quick rehearsal | Full exam simulation |
| **Documentation** | Basic | Professional report required |

---

## week10-mock (Original)

### Overview
- **Designed as:** A friendly rehearsal
- **Time:** 90 minutes recommended
- **Target Students:** Those wanting a quick practice run

### Structure
```
Flag 1: Web/FTP Recon → Easy find
Flag 2: SSH + Privilege Escalation → Medium difficulty
```

### Services
1. **Web Server** (10.10.50.10) - HTTP
2. **FTP Server** (10.10.50.11) - Anonymous access
3. **SSH Target** (10.10.50.12) - Password: `Rusty2026`

### Skills Tested
- Basic nmap scanning
- FTP enumeration
- Password discovery
- SSH access
- Sudo privilege escalation via `less`

### Best For
- First-time pentesters
- Quick confidence building
- Week 10 warm-up
- Time-constrained practice

---

## week10-mock2 (Comprehensive)

### Overview
- **Designed as:** Full exam simulation
- **Time:** 3 hours (full exam duration)
- **Target Students:** Those wanting complete preparation

### Structure
```
Flag 1: FTP Enumeration → ⭐ Easy (20%)
Flag 2: Targeted password attack + GTFOBins privesc → ⭐⭐⭐ Hard (25%)
Flag 3: Credential reuse + hash crack + decrypt → ⭐⭐⭐ Hard (25%)
+ Documentation → 30%
```
Flag 1 (20%) + documentation (30%) = 50% pass threshold, no hard flag required.

### Services
1. **Web Server** (10.10.60.10) - Corporate website (recon lead, no flag)
2. **FTP Server** (10.10.60.11) - Anonymous, Flag 1 + password-pattern hint
3. **SSH Server** (10.10.60.12) - Application server, Flag 2
4. **Database** (10.10.60.13) - MariaDB vault table, Flag 3

### Skills Tested
- Comprehensive nmap scanning (Week 4)
- Service enumeration (Week 5)
- Targeted password attacks with Hydra, built from a hint rather than
  handed outright (Week 6)
- GTFOBins privilege escalation via `sudo find` (Week 8)
- Credential reuse across services (Week 9)
- Offline hash cracking (john/hashcat) chained into an openssl decryption
  step (Week 6)
- Professional documentation (Week 10)

### Best For
- Serious exam preparation
- Comprehensive skill testing
- Professional report practice
- Realistic time constraints

---

## Difficulty Progression

### week10-mock
```
Easy Start → Medium Challenge
      ↓
   Linear Path
      ↓
  2 Flags Total
```

### week10-mock2
```
1 Easy Flag + Documentation (Pass level, 50%)
      ↓
+ 1 Hard Flag (Credit level)
      ↓
+ 2nd Hard Flag (Distinction/HD level)
      ↓
  3 Flags Total
```

---

## Pass Criteria

### week10-mock
**To Pass:** Complete both flags (50%)
- Flag 1: Basic recon (easier)
- Flag 2: Full chain (harder)
- Both required for pass

### week10-mock2
**To Pass (50%):**
- Flag 1 only (20%)
- Full methodology + evidence, including recon (30%)
- Result: **50% pass achievable without cracking anything**

**Higher Grades:**
- 60-69%: Add one hard flag (Flag 2 or Flag 3)
- 70-84%: Add the second hard flag
- 85-100%: All 3 flags + excellent documentation

---

## Time Investment

### week10-mock
**Technical Work:** 60-90 minutes
- Flag 1: 20-30 min
- Flag 2: 40-60 min

**Documentation:** Minimal (20-30 min)

**Total:** ~90-120 minutes

### week10-mock2
**Technical Work:** 2-2.5 hours
- Flag 1: 20-30 min (quick win)
- Flag 2: 45-60 min (build wordlist, Hydra, GTFOBins)
- Flag 3: 40-50 min (DB creds, hash crack, decrypt)

**Documentation:** 30-60 minutes

**Total:** 2.5-3.5 hours

---

## Concepts Coverage

### week10-mock
- ✅ Week 4: Nmap reconnaissance
- ✅ Week 5: FTP enumeration
- ✅ Week 6: Password discovery (passive)
- ✅ Week 8: Privilege escalation
- ⚠️ Limited: Active password attacks
- ⚠️ Limited: Database work
- ❌ No: SQL injection
- ❌ No: Hash cracking

### week10-mock2
- ✅ Week 1: Network tools (implicit)
- ✅ Week 3: Traffic analysis (implicit)
- ✅ Week 4: Comprehensive nmap
- ✅ Week 5: Multi-service enumeration
- ✅ Week 6: Hydra (targeted wordlist) + offline hash cracking
- ✅ Week 8: GTFOBins privilege escalation
- ✅ Week 9: Credential reuse
- ✅ Week 10: Professional reporting

---

## Use Cases

### Use week10-mock When:
1. Students need a quick confidence boost
2. Time is limited (< 2 hours)
3. First time doing penetration testing
4. Week 10 is approaching and you want a warm-up
5. You want to practice the basic chain

### Use week10-mock2 When:
1. Preparing for the actual Week 10 exam
2. You have 3+ hours available
3. You want comprehensive practice
4. You need to practice professional documentation
5. You want to test knowledge from all weeks
6. You're aiming for distinction/high distinction

---

## Teaching Recommendations

### For Instructors

**Week 8-9:** Use **week10-mock** as a formative assessment
- Gives students early confidence
- Tests fundamental chain
- Identifies weak areas
- Low stakes, high feedback

**Week 10:** Use **week10-mock2** as the summative assessment  
- Full exam simulation
- Comprehensive coverage
- Proper grading rubric
- Professional standards

### Progression Strategy

```
Week 8: Assign week10-mock as homework
        ↓
Week 9: Review results, fill gaps
        ↓
Week 10: week10-mock2 as final exam
```

---

## Student Recommendations

### Preparation Path

**Stage 1: Build Confidence (Week 8)**
1. Review Weeks 4-8 labs
2. Complete week10-mock (untimed)
3. Read walkthrough
4. Repeat week10-mock (timed)

**Stage 2: Comprehensive Practice (Week 9)**
1. Review Weeks 1-9 labs
2. Attempt week10-mock2 (untimed)
3. Identify weak areas
4. Practice specific skills

**Stage 3: Exam Simulation (Week 10)**
1. Complete week10-mock2 (timed, 3 hours)
2. No walkthrough access
3. Full documentation
4. Self-grade using rubric

---

## Difficulty Indicators

### You're Ready for week10-mock If:
- ✅ You can use nmap confidently
- ✅ You know basic FTP commands
- ✅ You can identify sudo misconfigurations
- ✅ You've completed Weeks 4-8 labs

### You're Ready for week10-mock2 If:
- ✅ You completed week10-mock successfully
- ✅ You can use Hydra for password attacks
- ✅ You're comfortable with MySQL client
- ✅ You know GTFOBins
- ✅ You can write professional documentation
- ✅ You've completed ALL Weeks 1-9 labs

---

## Grading Philosophy

### week10-mock
**Binary:** Did you complete it?
- Pass: Both flags captured
- Fail: Incomplete

### week10-mock2
**Graduated:** Multiple achievement levels
- 0-49%: Fail
- 50-59%: Pass (Flag 1 + full documentation, no hard flag needed)
- 60-69%: Credit (+ one hard flag)
- 70-84%: Distinction (+ the second hard flag)
- 85-100%: High Distinction (all 3 flags + excellent docs)

---

## Which Should You Choose?

### Choose week10-mock If:
- [ ] You have limited time
- [ ] You're new to pentesting
- [ ] You want a quick practice run
- [ ] You're in Week 8-9
- [ ] You want to build confidence

### Choose week10-mock2 If:
- [ ] You have 3+ hours
- [ ] You want full exam preparation
- [ ] You've completed week10-mock
- [ ] You're in Week 10
- [ ] You want comprehensive testing
- [ ] You're aiming for distinction

---

## Summary

**week10-mock:** Your friendly practice buddy 🎯  
**week10-mock2:** Your tough but fair exam simulator 💪

**Recommendation:** Do BOTH!
1. Start with week10-mock (build confidence)
2. Progress to week10-mock2 (comprehensive prep)

---

**Both labs are valuable. Use them strategically to maximize your learning!**
