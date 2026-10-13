# Alternative Midterm Examination: Penetration Test

This is the alternative sitting of the course's capstone exercise: a full,
unguided penetration test against a simulated corporate network, for
students who could not take the original midterm (`labs/midterm2026/`).
Same shape, genuinely different scenario — different company, different
credentials, different privilege-escalation vector — so it isn't solvable
by comparing notes with someone who sat the first exam. There's no
step-by-step walkthrough for the main exercise — you're expected to run
the complete recon → enumerate → exploit → escalate → report chain
yourself, using everything from Weeks 1–9.

Built with **pull-only images** and a dedicated Kali Linux attacker container.


## 💻 Two-Shell Lab Setup (Recommended)

Running two terminal windows side-by-side gives you the real attacker/victim experience:

**Terminal 1 — Start the lab (victim machines)**
```bash
# Linux / macOS / Git Bash
cd labs/altmidterm2026
docker compose up -d

# Windows PowerShell
cd labs\altmidterm2026
docker compose up -d
```

**Terminal 2 — Enter Kali (attacker machine)**
```bash
docker exec -it altmidterm2026-attacker bash
```

> Think of Terminal 1 as the victim network running in the background, and Terminal 2 as your Kali attacking machine. All commands in the worksheet are run from Terminal 2 (inside Kali).

---

## Quick Start

**All Platforms (Linux/Mac/Windows):**
```bash
docker compose up -d
docker exec -it altmidterm2026-attacker bash
```

## Architecture

**Pull-only approach** using mature Docker images:
- **Attacker**: Kali Linux with penetration testing tools
- **Web**: Apache HTTP server (httpd:2.4)
- **SSH**: Ubuntu OpenSSH with weak credentials
- **FTP**: vsftpd with anonymous access
- **Mail**: Mailpit SMTP + Dovecot POP3/IMAP

## Lab Network
All containers run in an isolated network (10.10.11.0/24) — a different
subnet from `labs/midterm2026/` (10.10.10.0/24) so both labs can run at
the same time without colliding.

## Target Services

| Service | Container | Internal Access | External Access |
|---------|-----------|-----------------|-----------------|
| HTTP | target-web | http://target-web | http://localhost:8080 |
| SSH | target-ssh | ssh user@target-ssh | ssh -p 2223 user@localhost |
| FTP | target-ftp | ftp target-ftp | ftp -p 2121 localhost |
| SMTP | target-smtp | telnet target-smtp 1025 | telnet localhost 1125 |
| POP3 | target-mail | telnet target-mail 110 | telnet localhost 1110 |
| IMAP | target-mail | telnet target-mail 143 | telnet localhost 1143 |
| Mailpit UI | target-smtp | http://target-smtp:8025 | http://localhost:8125 |

## Learning Path

**Attach to attacker container:**
```bash
docker exec -it altmidterm2026-attacker bash
```

**Inside the Kali container:**

1. **Automated recon**: `/root/tools/recon.sh`
2. **Manual enumeration**: `nmap -sC -sV target-web`
3. **FTP exploration**: `ftp target-ftp` (anonymous/anonymous)
4. **SSH brute force**: `hydra -L users.txt -P passwords.txt target-ssh ssh`
5. **Exploitation helper**: `/root/tools/exploit.sh`

## Documentation

- [INSTRUCTOR-WALKTHROUGH.md](INSTRUCTOR-WALKTHROUGH.md) - Complete answer key for instructors (not published until this sitting is over)
- [AltMidterm2026.md](AltMidterm2026.md) - Student lab worksheet
- [PENETRATION-TESTING-STRATEGY.md](PENETRATION-TESTING-STRATEGY.md) - Educational methodology guide
- [COMMAND-REFERENCE.md](COMMAND-REFERENCE.md) - Plain English explanation of all commands used
- [LINUX-BASICS.md](LINUX-BASICS.md) - Essential Linux crash course for beginners

## Cleanup

```bash
docker compose down
```

## Security Notice

**Educational use only in isolated lab environments.**
