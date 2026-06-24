# De-ICE S1.100 Docker Simulation

This Docker project simulates the VulnHub De-ICE S1.100 vulnerable machine using **pull-only images** with a dedicated Kali Linux attacker container.


## 💻 Two-Shell Lab Setup (Recommended)

Running two terminal windows side-by-side gives you the real attacker/victim experience:

**Terminal 1 — Start the lab (victim machines)**
```bash
# Linux / macOS / Git Bash
cd labs/week8
docker compose up -d

# Windows PowerShell
cd labs\week8
docker compose up -d
```

**Terminal 2 — Enter Kali (attacker machine)**
```bash
docker exec -it de-ice-attacker bash
```

> Think of Terminal 1 as the victim network running in the background, and Terminal 2 as your Kali attacking machine. All commands in the worksheets are run from Terminal 2 (inside Kali).

---

## Quick Start

**All Platforms (Linux/Mac/Windows):**
```bash
docker compose up -d
docker exec -it de-ice-attacker bash
```

## Architecture

**Pull-only approach** using mature Docker images:
- **Attacker**: Kali Linux with penetration testing tools
- **Web**: Apache HTTP server (httpd:2.4)
- **SSH**: LinuxServer OpenSSH with weak credentials
- **FTP**: Fauria VSFtpd with anonymous access
- **Mail**: MailHog SMTP + Dovecot POP3/IMAP

## Lab Network
All containers run in isolated network (10.10.8.0/24)

## Target Services

| Service | Container | Internal Access | External Access |
|---------|-----------|-----------------|-----------------|
| HTTP | target-web | http://target-web | http://localhost |
| SSH | target-ssh | ssh user@10.10.8.10 | ssh -p 2222 user@localhost |
| FTP | target-ftp | ftp target-ftp | ftp localhost |
| SMTP | target-smtp | telnet target-smtp 1025 | telnet localhost 1025 |
| POP3 | target-mail | telnet target-mail 110 | telnet localhost 110 |
| IMAP | target-mail | telnet target-mail 143 | telnet localhost 143 |
| MailHog UI | target-smtp | http://target-smtp:8025 | http://localhost:8025 |

## Vulnerable Credentials

- **SSH**: `aadams:smadaa`
- **FTP**: Anonymous access enabled
- **Encrypted file password**: `HeadOfSecurity`

## Learning Path

**Attach to attacker container:**
```bash
docker exec -it de-ice-attacker bash
```

**Inside the Kali container:**

1. **Automated recon**: `/root/tools/recon.sh`
2. **Manual enumeration**: `nmap -sC -sV target-web`
3. **FTP exploration**: `ftp target-ftp` (anonymous/anonymous)
4. **SSH brute force**: `hydra -L users.txt -P passwords.txt 10.10.8.10 ssh`
5. **Exploitation**: `/root/tools/exploit.sh`

## Documentation

- [INSTRUCTOR-WALKTHROUGH.md](INSTRUCTOR-WALKTHROUGH.md) - Complete answer key for instructors
- [STUDENT-WORKSHEET.md](STUDENT-WORKSHEET.md) - Student lab worksheet  
- [PENETRATION-TESTING-STRATEGY.md](PENETRATION-TESTING-STRATEGY.md) - Educational methodology guide
- [COMMAND-REFERENCE.md](COMMAND-REFERENCE.md) - Plain English explanation of all commands used
- [LINUX-BASICS.md](LINUX-BASICS.md) - Essential Linux crash course for beginners

## Benefits over Custom Build

✅ **Fast deployment** (pull vs build)  
✅ **Small footprint** (optimized images)  
✅ **Reliable** (maintained upstream images)  
✅ **Simple** (no complex Dockerfile)  

## Platform-Specific Setup

- **All platforms:** Standard Docker Compose commands work universally

## Cleanup

```bash
docker compose down
```

## Security Notice

**Educational use only in isolated lab environments.**
---

## Practice on VulnHub

Week 8 is modelled on the De-ICE series. These two machines are the closest real-world equivalents — both require the full recon → enum → exploit → report chain with no hand-holding.

| Machine | URL | Why it fits |
|---------|-----|------------|
| **De-ICE: S1.100** | https://www.vulnhub.com/entry/de-ice-s1100,8/ | The original inspiration for this lab. A simulated corporate Linux server with FTP, SSH, HTTP, and SMTP. You must enumerate services, crack a password, and escalate privileges — identical flow to the Week 8 de-ice attacker scenario. Difficulty: beginner. |
| **Basic Pentesting: 2** | https://www.vulnhub.com/entry/basic-pentesting-2,241/ | Full-chain beginner machine: web enumeration → SMB user extraction → SSH brute-force → Sudo privilege escalation. Mirrors the Week 8 multi-service workflow and produces the kind of findings you would include in a practical pentest report. Difficulty: beginner–intermediate. |
