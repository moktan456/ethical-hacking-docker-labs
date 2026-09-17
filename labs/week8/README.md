# Week 8: Privilege Escalation

This week covers turning a low-privilege foothold into full root access —
the step that follows initial access in almost every real attack chain.

## Setup

```bash
# From repo root
make run-week8

# Or from this directory
docker compose up -d
```

## Available Services

| Container | Description | Access |
|-----------|-------------|--------|
| week8-attacker | Kali-based attack box (ethical-base image) | `docker exec -it week8-attacker bash` |
| week8-workstation | Linux target — vulnerable SUID binary + writable cron job | `docker exec -it -u lowpriv week8-workstation bash` |
| week8-ubuntu-desktop | Linux target — sudo NOPASSWD GTFOBins entry + hardcoded credential | `docker exec -it -u deskuser week8-ubuntu-desktop bash` |

Both targets start you as a low-privilege user on purpose — see
[worksheet.md](./worksheet.md) for the full walkthrough.

## Why "Windows-like" commands were adapted

The source worksheet this lab is based on frames `week8-ubuntu-desktop` as a
"Windows-like" target and lists commands like `net user` and
`mimikatz.exe`. Those only work against an actual Windows host — there's no
Windows kernel inside a Linux Docker container for them to talk to. The
worksheet instead uses the real Linux equivalents (`cat /etc/passwd`,
`getent group sudo`, `ps aux`, `grep`) to practice the same enumeration and
credential-hunting concepts. Students who want to try genuine Windows
privilege escalation (DLL hijacking, mimikatz) can do so against a real VM —
see the "Optional Extension" section at the end of the worksheet.

## Security Notice

Every vulnerability here (SUID binary, writable cron job, sudo
misconfiguration, hardcoded credential) is deliberately planted for teaching
purposes and is a real, common misconfiguration pattern seen in production
systems. Never attempt these techniques against systems you don't own or
have explicit written authorization to test.
