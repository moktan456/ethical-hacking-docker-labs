# Week 4 Worksheet Walkthrough — INSTRUCTOR ONLY

> Verified against live containers. Do not distribute to students before the
> end of the session.

---

## Part 1: Basic Port Scanning

### Exercise 1.1: Connect-Scan

```bash
nmap 10.10.4.10
```

**Verified result:**

| Port | Protocol | State |
|------|----------|-------|
| 80 | tcp | open |

**Question — what does "filtered" mean?** The port didn't get a definitive
response (no SYN-ACK, no RST) — usually because a firewall or packet filter
is silently dropping probes rather than actively rejecting them. Nmap can't
tell if the port is open or closed, only that something is blocking the
probe.

### Exercise 1.2: Scan the Full Lab Subnet

```bash
nmap 10.10.4.0/24
```

**Verified result:** 5 hosts up, took **204.51 seconds** (vs. 2.49s for the
`-sn` ping sweep in 1.3) — the default 1000-port scan against every one of
256 addresses is what makes this slow, not host discovery itself.

| Host IP | Open Ports |
|---------|------------|
| 10.10.4.1 (gateway) | none (all 1000 ignored/closed) |
| 10.10.4.2 (kali-attacker, self) | none — all 1000 filtered (no-response) |
| 10.10.4.10 (week4-web) | 80/tcp |
| 10.10.4.11 (week4-ftp) | 21/tcp |
| 10.10.4.12 (week4-ssh) | 22/tcp |

Scanning the attacker's own container (10.10.4.2) from itself reports every
port "filtered" — Docker's loopback-via-bridge path for a container hitting
its own IP doesn't behave like a normal socket, so this is expected noise,
not a target worth investigating.

### Exercise 1.3: Ping Sweep

```bash
nmap -sn 10.10.4.0/24
```

**Verified result:** 5 hosts responded (10.10.4.1, .2, .10, .11, .12) in
2.49 seconds.

**Question — why run `-sn` first on a large network?** It skips port
scanning entirely and only checks which hosts are alive, so you don't waste
time port-scanning addresses nobody is using. On this lab's /24 that's the
difference between 2.5s and 204s for the same useful "which hosts exist"
answer.

---

## Part 2: Service Version Detection

### Exercise 2.1: Version Scan

```bash
nmap -sV 10.10.4.10
nmap -sV 10.10.4.11
nmap -sV 10.10.4.12
```

**Verified result:**

| Target IP | Port | Service | Version |
|-----------|------|---------|---------|
| 10.10.4.10 | 80 | http | nginx 1.31.6 |
| 10.10.4.11 | 21 | ftp | vsftpd 2.0.8 or later |
| 10.10.4.12 | 22 | ssh | OpenSSH 8.9p1 Ubuntu 3ubuntu0.17 |

**Question — why does the exact version matter to an attacker?** A specific
version narrows the search to CVEs and known exploits for that exact build
(e.g. a specific vsftpd or OpenSSH release with a documented backdoor or
auth bypass), instead of guessing blind. It also tells you what's patched
and what isn't — an old version is a strong signal the box hasn't been
maintained.

### Exercise 2.2: Aggressive Scan

```bash
nmap -A 10.10.4.10 10.10.4.11 10.10.4.12
```

(Full `nmap -A 10.10.4.0/24` also works but re-runs the ~200s full-subnet
port scan from 1.2 on top of OS/script detection — scanning the three known
hosts directly gets the same teaching content in ~23s.)

**Verified result — what `-A` added over `-sV`:**
- `week4-web`: `http-title: CyberCorp Intranet`, `http-server-header:
  nginx/1.31.6` (NSE scripts running against the detected service)
- `week4-ftp`: `ftp-anon` (anonymous login allowed) and `ftp-syst` (banner,
  vsFTPd 3.0.5) script output
- `week4-ssh`: `ssh-hostkey` (ECDSA + ED25519 fingerprints)
- All three: a full TCP/IP fingerprint block and a traceroute (`Network
  Distance: 1 hop` — expected, since every container sits on the same
  Docker bridge as the attacker)

**Did Nmap detect an OS?** **No** — every host returned "No exact OS matches
for host." This is expected in Docker: containers share the host machine's
real kernel rather than running their own, so Nmap's OS-fingerprinting
(which relies on subtle TCP/IP stack quirks unique to a kernel) has nothing
distinctive to match against. Worth telling students this explicitly so
they don't assume they made a mistake.

---

## Part 3: Scan Techniques and Stealth

### Exercise 3.1: TCP SYN Scan

```bash
nmap -sS 10.10.4.0/24
```

**Verified result** (spot-checked with `-p 21,22,80` for speed — same
per-host state as the full scan): 10.10.4.10 → 80 open; 10.10.4.11 → 21
open; 10.10.4.12 → 22 open; gateway (.1) → all closed; kali-attacker (.2,
self) → all filtered.

**Question — SYN scan vs. full connect scan (`-sT`)?** A connect scan
completes the full three-way handshake (SYN → SYN-ACK → ACK) using the
OS's normal `connect()` socket call, which gets logged by the target
application as a real connection. A SYN scan sends the SYN, reads the
SYN-ACK/RST, then sends a RST instead of completing the handshake — faster,
and many applications never log a connection that was never established.

**Which is harder to detect, and why?** SYN scan — because it never
completes a handshake, it often doesn't reach the application layer at all,
so it only shows up (if at all) in kernel/firewall-level logs rather than
the target service's own connection log.

### Exercise 3.2: Service Script Scan

```bash
nmap -sC -sV 10.10.4.11
nmap --script ftp-anon 10.10.4.11
```

**Verified result:** both confirm `ftp-anon: Anonymous FTP login allowed
(FTP code 230)`, with a world-readable `pub` directory listed.

**Does the FTP server allow anonymous login?** **Yes.**

**Question — risk of anonymous FTP?** Anyone on the network can read
(and on a misconfigured server, write) files with zero authentication —
no password to guess, brute-force, or leak. It's a direct, silent path to
data exposure or, if write access is also misconfigured, to planting
malicious files.

### Exercise 3.3: SSH Enumeration Scripts

```bash
nmap --script ssh-hostkey 10.10.4.12
nmap --script ssh-auth-methods --script-args="ssh.user=sysadmin" 10.10.4.12
```

**Verified result:**
```
ssh-hostkey:
  256 ...  (ECDSA)
  256 ...  (ED25519)
ssh-auth-methods:
  Supported authentication methods:
    publickey
    password
  Banner: CyberCorp Remote Management System v2.1 / Authorised access only.
```

**What authentication methods does the SSH server support?** Both
`publickey` and `password`. Password auth being enabled/advertised here is
itself a finding worth noting — it's what makes the credential-based
attacks in later weeks (e.g. Hydra brute force) possible in the first
place.

---

## Part 4: Output and Reporting

### Exercise 4.1: Save Scan Results

```bash
nmap -sV -oA /tmp/week4-scan 10.10.4.0/24
cat /tmp/week4-scan.nmap
```

**Verified:** produces `/tmp/week4-scan.nmap` (human-readable, same as
console output), `/tmp/week4-scan.xml`, and `/tmp/week4-scan.gnmap`
(grepable, one line per host).

**Question — what's `.xml` useful for?** It's structured, machine-parseable
output — tools like Metasploit, reporting frameworks, and custom scripts can
import Nmap's XML directly instead of screen-scraping text, and it's the
format most report-generation tooling expects.

### Exercise 4.2: Mini Recon Summary — model answer

**Target Network:** 10.10.4.0/24

| IP | Hostname | OS (if detected) | Open Ports | Key Services |
|----|----------|-------------------|------------|---------------|
| 10.10.4.10 | week4-web | Not detected (containerised) | 80/tcp | nginx 1.31.6 |
| 10.10.4.11 | week4-ftp | Not detected (containerised) | 21/tcp | vsftpd, anonymous login allowed |
| 10.10.4.12 | week4-ssh | Not detected (containerised) | 22/tcp | OpenSSH 8.9p1, password auth enabled |

**Notable Findings:**
1. Anonymous FTP login is enabled on `week4-ftp` — unauthenticated read
   access to `/var/ftp/pub`.
2. SSH on `week4-ssh` allows password authentication, which combined with
   the custom banner naming a specific admin account (`sysadmin`) makes it
   a credible brute-force target.
3. No service on this subnet presents TLS/HTTPS — the nginx site on
   `week4-web` is plain HTTP.

**Recommended Next Steps:** Pull the anonymous FTP directory listing for
sensitive files; attempt a targeted password list against the `sysadmin`
SSH account; browse the nginx site for further content/version disclosure.

---

## Part 5: Ethics and Legal Considerations — model answers

1. **Scope (partnercorp.com.au):** No — do not scan or test it. It wasn't
   named in the signed scope, and even if it's technically co-hosted, it
   likely belongs to a different legal entity that never authorised
   testing. Flag the discovery to the client and ask whether scope should
   be formally extended, rather than acting unilaterally.
2. **Disclosure (unexploited CVE found during recon):** Document it
   immediately with enough detail to act on later, but don't exploit it
   yet if exploitation wasn't part of the agreed scope/phase — report it to
   the client's point of contact promptly given its severity, and confirm
   whether/when you're authorised to proceed to exploitation.
3. **Documentation:** Timestamped raw output is objective, reproducible
   evidence — notes can be misremembered, disputed, or lack detail, while a
   saved Nmap file shows exactly what was run, when, and what came back,
   which matters for the client's remediation, for any legal question about
   what was and wasn't done, and for re-verifying findings later.

---

## Quick Knowledge Check — Answers

1. **A) `-sV`**
2. **B) Ping sweep only**
3. **B) `.xml`**
4. **True**
5. **C) A firewall may be blocking the probe**

---

## Notes for the Instructor

- The default `nmap 10.10.4.0/24` (Exercise 1.2) takes ~3.5 minutes because
  it full-port-scans all 256 addresses in the /24, not just the 5 that
  respond — a good live illustration of exactly what Exercise 1.3's
  discussion question is asking about.
- No target returns an OS match under `-A` — this is expected for
  Docker containers (shared host kernel, no distinctive per-container TCP
  stack), not a scan failure.
- Scanning `10.10.4.2` (the attacker's own container) shows all ports as
  "filtered" — this is a Docker networking quirk when a container's traffic
  loops back to itself via the bridge, not a real target worth chasing.
