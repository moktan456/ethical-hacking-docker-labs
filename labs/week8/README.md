# Week 8: Privilege Escalation

This week covers the full chain, not just the end of it: gaining a
low-privilege foothold through real weak-credential attacks (SSH password
brute force, an SMB share leaking a login), then turning that foothold into
full root access. As with every other week, you work from the attacker
container and reach the targets over the network — nothing is handed to you
directly via `docker exec` into a target.

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
| week8-workstation | Linux target — SSH weak password, then SUID binary + writable cron job | earn it: find the username via web recon on port 80, Hydra-crack its SSH password, then SSH in |
| week8-ubuntu-desktop | Linux target — SMB credential leak, then sudo NOPASSWD GTFOBins entry + hardcoded credential | earn it: pull `deskuser`'s password from the `notices` SMB share, then `ssh deskuser@10.10.8.11` |

Neither target hands you a shell for free — see [worksheet.md](./worksheet.md)
for the full walkthrough, initial access through root.

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

## Practice on VulnHub: Real Windows Privilege Escalation

Everything in this lab uses Linux containers, because Docker on a Mac/Linux
host can't run Windows containers — there's no Windows kernel underneath for
them to talk to. If you want to practice the Windows-side techniques from the
slides (`net user`, `mimikatz`, service DLL hijacking) against a real target,
that requires an actual Windows virtual machine.

**Persistence: 1** on VulnHub (search "Persistence: 1 VulnHub" — built by
Rasta Mouse specifically for privilege escalation practice) is a good fit:
unlike this Docker lab, it's a genuine Windows host, so the slide techniques
apply directly rather than needing a Linux adaptation. Setup (importing the
VM into VirtualBox/VMware, networking it so it's reachable) is a different
workflow from `docker compose up` and will be walked through separately.

## Security Notice

Every vulnerability here (weak SSH password, anonymous SMB share leaking a
credential, SUID binary, writable cron job, sudo misconfiguration, hardcoded
credential) is deliberately planted for teaching purposes and is a real,
common misconfiguration pattern seen in production systems. Never attempt
these techniques against systems you don't own or have explicit written
authorization to test.
