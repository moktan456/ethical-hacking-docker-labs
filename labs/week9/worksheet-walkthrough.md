# Week 9 Worksheet Walkthrough — INSTRUCTOR ONLY

> Verified against live containers. Do not distribute to students before the
> end of the session.

---

## Setup

```bash
cd labs/week9 && docker compose up -d
docker exec -it week9-attacker bash
ping -c 1 10.10.90.20
```

**Verified result:** ping to `10.10.90.20` fails (100% packet loss) from
`week9-attacker` — the `week9-internal` Docker network is `internal: true`,
so there is no route to it at all except through `week9-pivot`, which sits
on both networks.

---

## Part 1: Foothold — SSH to the Pivot Host

### Exercise 1.1

```bash
ping -c 2 10.10.9.10
nmap -p 22 10.10.9.10
```
**Verified result:** pivot reachable, `22/tcp open ssh`.

### Exercise 1.2

```bash
ssh pivotuser@10.10.9.10
hostname
ip addr show
```
**Verified result:** `hostname` → `pivot-host`.

| Interface | IP |
|-----------|-----|
| eth0 | 10.10.9.10/24 (external) |
| eth1 | 10.10.90.10/24 (internal) |

**Question — why two IPs?** The pivot container is attached to both the
`week9-external` and `week9-internal` Docker networks, giving it one
interface (and routable address) on each — that's what makes it usable as a
pivot point at all; a host with only one interface can't bridge the two
segments.

### Exercise 1.3

```bash
ip route
ping -c 1 10.10.90.20
ping -c 1 10.10.90.21
```
**Verified result:**
```
default via 10.10.9.1 dev eth0
10.10.9.0/24 dev eth0 proto kernel scope link src 10.10.9.10
10.10.90.0/24 dev eth1 proto kernel scope link src 10.10.90.10
```
Both internal pings succeed (0% loss) — the pivot has a direct route to
`10.10.90.0/24` via its own `eth1`, which the attacker does not.

---

## Part 2: SSH Port Forwarding

### Exercise 2.1

```bash
ssh -L 8080:10.10.90.20:80 pivotuser@10.10.9.10 -N -f
curl http://127.0.0.1:8080
```
**Verified result:** returns the internal admin portal HTML —
"CyberCorp Internal Admin Portal ... If you can see this, you have
successfully pivoted!"

**Question — what would you look for on an internal admin portal?**
Model answer: default/leftover admin credentials, exposed configuration or
backup files, internal-only API endpoints, version banners revealing
exploitable software, or links to further internal-only systems that widen
the pivot.

### Exercise 2.2

```bash
ssh -L 3307:10.10.90.21:3306 pivotuser@10.10.9.10 -N -f
mysql -h 127.0.0.1 -P 3307 -u appuser -papppass456
```
**Verified result:** the `mysql` client available in the attacker container
(Alpine's `mysql-client`, actually MariaDB's client under the hood) fails
against MySQL 8.0's default auth plugin:
```
ERROR 1045 (28000): Plugin caching_sha2_password could not be loaded
```
This is expected and not a lab bug — MariaDB's client doesn't ship the
`caching_sha2_password` plugin MySQL 8 uses by default. Fall back to the
worksheet's suggested nmap check instead:
```bash
nmap -p 3307 127.0.0.1
```
**Verified result:** `3307/tcp open` — the tunnel itself works fine; only
the specific client/server auth-plugin combination is incompatible.

---

## Part 3: SOCKS Proxy (Dynamic Port Forwarding)

### Exercise 3.1

```bash
ssh -D 1080 pivotuser@10.10.9.10 -N -f
ss -tlnp | grep 1080
```
**Verified result:** `LISTEN ... 127.0.0.1:1080 ... users:(("ssh",...))` —
proxy is up.

### Exercise 3.2

```bash
proxychains curl http://10.10.90.20
proxychains nmap -sT -Pn -p 22,80,443,3306,8080 10.10.90.0/24
```
**Verified result:** curl returns the internal portal page through the
proxy chain (`Strict chain ... 127.0.0.1:1080 ... 10.10.90.20:80 ... OK`).
Scoped nmap finds:

| Host | Open Ports |
|------|------------|
| 10.10.90.10 (pivot, internal iface) | 22 |
| 10.10.90.20 | 80 |
| 10.10.90.21 | 3306 |

**Question — why `-sT` not `-sS` with proxychains?** proxychains only
intercepts userspace `connect()` calls made through libc — it cannot craft
or receive raw SYN/RST packets the way a `-sS` half-open scan needs, so only
a full-connect (`-sT`) scan, which is just ordinary `connect()` calls, can
be tunneled through a SOCKS proxy.

**Note for the instructor:** the worksheet as originally written told
students to run `proxychains nmap -sT -Pn 10.10.90.0/24` with no `-p`
scoping. A default nmap top-1000-port scan across all 254 hosts, fully
serialized through one proxychains SOCKS tunnel, does not finish in a
reasonable classroom window (confirmed: still running with no output after
several minutes; killed and reran scoped to `-p 22,80,443,3306,8080`, which
completed in well under a second). The worksheet has been updated to scope
the port list — flag this if teaching from an older printout.

---

## Part 4: Metasploit Route and Pivot

### Exercise 4.2 — SSH login module

```
use auxiliary/scanner/ssh/ssh_login
set RHOSTS 10.10.9.10
set USERNAME pivotuser
set PASSWORD pivot123
run
```
**Verified result:**
```
[+] Success: 'pivotuser:pivot123' 'uid=1000(pivotuser) ...'
[*] SSH session 1 opened (10.10.9.2:43185 -> 10.10.9.10:22)
```
Session ID: **1**.

**Note:** `msfconsole` is not on `$PATH` in the
`metasploitframework/metasploit-framework` image when the container's
default entrypoint is overridden (as this lab's `docker-compose.yaml`
does, to print the banner and idle on `tail -f /dev/null`). Run it via its
full path instead: `/usr/src/metasploit-framework/msfconsole`.

### Exercise 4.3 — Add route

```
route add 10.10.90.0 255.255.255.0 1
route print
```
**Verified result:**
```
Subnet          Netmask         Gateway
10.10.90.0      255.255.255.0   Session 1
```

### Exercise 4.4 — Scan through the route

```
use auxiliary/scanner/portscan/tcp
set RHOSTS 10.10.90.0/24
set PORTS 22,80,443,3306,8080
set THREADS 5
run
```
**Verified result:**
```
[+] 10.10.90.10 - 10.10.90.10:22 - TCP OPEN
[+] 10.10.90.20 - 10.10.90.20:80 - TCP OPEN
[+] 10.10.90.21 - 10.10.90.21:3306 - TCP OPEN
```

| Host | Open Ports |
|------|------------|
| 10.10.90.20 | 80 |
| 10.10.90.21 | 3306 |

(10.10.90.10 — the pivot's own internal-facing interface — also shows 22
open, which is expected and worth mentioning to students who ask why a
"third host" showed up: it's the pivot itself, reachable on the internal
subnet too.)

**Note for the instructor:** partway through this scan, the SSH session
died (`SSH Command Stream encountered an error: closed stream` /
`SSH session 1 closed. Reason: Died`) — the portscan module opens many
parallel SSH channels through a single session and the channel occasionally
drops under load, especially with this lab running under x86_64→arm64
emulation (see general note below). The scan still completed and returned
correct results before/around the point of the drop; if students see the
session die, reassure them the scan results already collected are valid,
and they can re-run `ssh_login` to get a fresh session if they need to run
further modules.

---

## Optional CTF

Both flags verified live and match `ctf-walkthrough.md`:
- `user.txt` (on pivot, via `ssh pivotuser@10.10.9.10` →
  `cat /home/pivotuser/user.txt`): **`flag{w9_pivot_host_accessed}`**
- `root.txt` (via `ssh -L 8080:10.10.90.20:80 ...` →
  `curl http://127.0.0.1:8080/root.txt`): **`flag{w9_internal_net_breached}`**

---

## Notes for the Instructor

Several lab-environment bugs were found and fixed while verifying this
worksheet live; all fixes are already committed to
`labs/week9/docker-compose.yaml` and `labs/week9/worksheet.md`. Documenting
them here so whoever teaches this session understands what changed and why:

1. **Pivot host restart-loop (fixed).** `week9-pivot`'s boot command was a
   single `&&`-chained shell string ending in `sshd -D`, with
   `restart: unless-stopped`. On any restart of the *same* container (a
   host reboot, Docker Desktop restart, etc. — not a fresh `docker compose
   up`), the chain re-ran from the top against a filesystem that already
   had the changes from the first successful boot: `useradd -m ... pivotuser`
   failed with "user already exists", aborting the chain **before** `sshd -D`
   ever ran. The container then looped forever, incrementing
   `RestartCount`, with SSH never coming up and no obvious error unless you
   read the full container logs. Fixed by guarding `useradd` with
   `id -u pivotuser &>/dev/null ||` and the `sshd_config` appends with
   `grep -q ... ||`, so the boot script is now idempotent across restarts.
2. **`ip_forward` write also aborted the chain (fixed).** The same boot
   script did `echo 1 > /proc/sys/net/ipv4/ip_forward`, which fails
   (`Read-only file system`) on Docker Desktop for Mac even with
   `cap_add: NET_ADMIN` added. This isn't actually needed for any exercise
   in this worksheet — all the pivoting techniques taught (SSH `-L`/`-D`,
   Metasploit `route`) operate in userspace and don't rely on kernel IP
   forwarding — so it's now wrapped as non-fatal:
   `(echo 1 > /proc/sys/net/ipv4/ip_forward 2>/dev/null || true)`.
3. **Attacker image is missing basic client tools (fixed).** The
   `metasploitframework/metasploit-framework` image is Alpine-based and
   ships with none of `ssh`, `mysql` (client), `proxychains`, or `ss`
   (`iproute2`) — every one of which Exercises 1.2 through 3.2 requires.
   As originally written, a student's very first `ssh pivotuser@...` in
   Exercise 1.2 would fail with `ssh: command not found`. Fixed by adding
   `apk add --no-cache openssh-client mysql-client proxychains-ng iproute2`
   to the attacker container's startup command.
4. **Pivot host missing `ping` (fixed).** `iputils-ping` wasn't in the
   pivot's `apt-get install` list, so Exercise 1.3's `ping -c 1 10.10.90.20`
   *from the pivot* would fail with `ping: command not found`, even though
   the network path itself was fine. Added to the package list.
5. **proxychains.conf points at Tor by default (worksheet updated).** The
   `proxychains-ng` package ships pre-configured for `socks4 127.0.0.1
   9050` (the standard Tor SOCKS port), not port 1080 where this lab's SOCKS5
   proxy actually listens. Without editing this file, every command in
   Exercise 3.2 fails with a proxy connection error even though the SOCKS
   tunnel from 3.1 is working correctly. This was deliberately fixed in
   `worksheet.md` itself (a new step before Exercise 3.2), not silently
   pre-baked into `docker-compose.yaml` — configuring proxychains to point
   at the right proxy is part of the skill this section is teaching.
6. **Unscoped `/24` nmap sweep through proxychains never finishes in a
   classroom window (worksheet updated).** See the Part 3 note above —
   `worksheet.md`'s Exercise 3.2 now scopes the nmap command to
   `-p 22,80,443,3306,8080` instead of a full-port sweep.
7. **General flakiness under emulation.** This Mac is Apple Silicon
   (arm64), and `metasploitframework/metasploit-framework` is only
   published for `linux/amd64`, so `week9-attacker` runs under Docker
   Desktop's Rosetta/QEMU emulation. This lab's first container boot after
   a Docker Desktop restart intermittently exited with code 99 for no
   logged reason; simply restarting the container (`docker start
   week9-attacker`) succeeded immediately. If a container looks like it
   failed to start with no useful log output on Apple Silicon, retry once
   before assuming something is actually broken.
