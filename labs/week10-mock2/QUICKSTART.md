# Week 10 Mock Exam 2: Quick Start Guide

**⚡ Get up and running in 2 minutes**

---

## Prerequisites

✅ Docker Desktop installed and running  
✅ `ethical-base` image built (from repo root)  
✅ At least 4GB free RAM  
✅ 3 hours available for exam  

---

## Quick Setup

### Step 1: Navigate to Lab Directory

```bash
# From repo root
cd labs/week10-mock2
```

### Step 2: Start the Lab

```bash
# Start all containers
docker compose up -d

# Wait 10-15 seconds for services to initialize
```

### Step 3: Access Attacker Machine

```bash
# Enter the Kali attacker container
docker exec -it week10mock2-attacker bash
```

### Step 4: Verify Network

```bash
# From inside the attacker container
ping -c 2 10.10.60.10
```

**If you see ping responses, you're ready to start! 🎯**

---

## What You'll See

When the containers start, you'll see:
```
========================================
Week 10 Mock Exam 2 - CyberGuard Corp
========================================

SCENARIO:
You have been hired to test CyberGuard Corp's internal network.
Your goal: Find 3 flags (1 easy, 2 hard) and document your methodology.

Network: 10.10.60.0/24
Time limit: 3 hours

Access the attacker machine:
  docker exec -it week10mock2-attacker bash
```

---

## First Commands to Run

```bash
# 1. Discover active hosts
nmap -sn 10.10.60.0/24

# 2. Quick port scan
nmap -F 10.10.60.0/24

# 3. Detailed service scan
nmap -sV 10.10.60.10-13
```

---

## Network Layout

```
Your Position: 10.10.60.2 (attacker)

Targets:
├── 10.10.60.10 (Web Server)
├── 10.10.60.11 (FTP Server)  
├── 10.10.60.12 (SSH Server)
└── 10.10.60.13 (Database)
```

---

## 3 Flags to Capture

1. **Flag 1** ⭐ - FTP Enumeration (Easy, 20%)
2. **Flag 2** ⭐⭐⭐ - Targeted Password Attack + GTFOBins Privesc (Hard, 25%)
3. **Flag 3** ⭐⭐⭐ - Credential Reuse + Hash Crack + Decrypt (Hard, 25%)

**Minimum to Pass:** Flag 1 + full documentation (incl. recon) = 50%.
No hard flag is required to pass.

---

## Essential Tools (Pre-installed)

- `nmap` - Network scanning
- `ftp` - FTP client
- `hydra` - Password attacks
- `ssh` - SSH client
- `mysql` - Database client
- `curl` / `wget` - Web tools
- `john` / `hashcat` - Hash cracking

---

## Time Management

```
⏰ Hour 1: Recon + Flag 1 (easy win)
⏰ Hour 2: Build the wordlist, crack SSH, privesc → Flag 2
⏰ Hour 3: DB creds → hash crack → decrypt → Flag 3, then documentation
```

**Pro Tip:** Document as you go, not at the end!

---

## Important Files

- **README.md** - Full overview and marking guide
- **mock-exam.md** - Official exam instructions
- **mock-exam-walkthrough.md** - Complete solution (use after attempt)
- **ctf-challenge.md** - CTF-style version
- **ctf-walkthrough.md** - CTF solution guide

---

## If Something Goes Wrong

### Check Container Status
```bash
docker compose ps
```

All containers should show "Up" status.

### Restart Services
```bash
docker compose restart
```

### Complete Reset
```bash
docker compose down
docker compose up -d
```

### View Logs
```bash
docker compose logs [container-name]
```

---

## Stop the Lab

```bash
# Stop all containers
docker compose down
```

---

## Need Help?

1. **Stuck on a flag?** Check the hints in mock-exam.md
2. **Technical issues?** See README.md troubleshooting section
3. **Want the solution?** See mock-exam-walkthrough.md (after attempting!)

---

## Ready to Start?

✅ Containers running  
✅ Attacker access confirmed  
✅ Timer started  
✅ Documentation template ready  

**Good luck! Remember: methodology and documentation are 50% of your grade!**

---

## One-Liner Full Setup

```bash
# From repo root, run everything at once:
cd labs/week10-mock2 && docker compose up -d && sleep 10 && docker exec -it week10mock2-attacker bash
```

**Happy hacking! 🚀**
