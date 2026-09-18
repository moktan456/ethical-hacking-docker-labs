# Week 5 Worksheet Walkthrough — INSTRUCTOR ONLY

> Verified against live containers. Do not distribute to students before the
> end of the session.

---

## Part 1: LDAP Enumeration

### Exercise 1.1: Unauthenticated LDAP Listing

```bash
nmap -p 389 10.10.5.10
ldapsearch -x -H ldap://10.10.5.10 -b "dc=cybercorp,dc=local"
```

**Verified result:** port 389 open. The anonymous query returns **`result:
32 No such object`** — **no results**. This lab's OpenLDAP server does not
permit anonymous bind to actually read the tree (a deliberately more
realistic/hardened config than a wide-open directory).

**Did the anonymous query return results?** **No.**

**Base DN:** `dc=cybercorp,dc=local` (visible from the query itself and
confirmed once authenticated in 1.2 — the org entry `o: CyberCorp`).

### Exercise 1.2: Authenticated LDAP Enumeration

```bash
ldapsearch -x -H ldap://10.10.5.10 \
  -D "cn=readonly,dc=cybercorp,dc=local" \
  -w readonly123 \
  -b "dc=cybercorp,dc=local" \
  "(objectClass=*)"
```

**Verified result:** returns 2 entries — the base org entry
(`dc=cybercorp,dc=local`) and the `readonly` bind account itself
(`cn=readonly,dc=cybercorp,dc=local`, with a hashed `userPassword`).

| Username | Full Name (cn) |
|----------|---------------|
| readonly | readonly (LDAP read only user) |

**Instructor note:** this directory has no `ou=people` branch or actual
employee accounts populated in LDAP — only the readonly service account
exists here. Don't let students think they've missed something; the real
employee usernames (`jsmith`, `mjones`, `awilson`, `tbrown`) surface later,
from MySQL (Part 2), not LDAP. This is itself a fair teaching point: not
every service in an environment holds the same data, and enumeration means
checking each one rather than assuming one source has everything.

### Exercise 1.3: LDAP with Nmap Scripts

```bash
nmap -p 389 --script ldap-rootdse 10.10.5.10
nmap -p 389 --script ldap-search --script-args \
  'ldap.base="dc=cybercorp,dc=local"' 10.10.5.10
```

**Verified result:**
- `ldap-rootdse` (unauthenticated, no bind needed) reveals: `namingContexts:
  dc=cybercorp,dc=local`, `supportedLDAPVersion: 3`, and a long list of
  `supportedSASLMechanisms` (NTLM, GSSAPI, CRAM-MD5, DIGEST-MD5, etc.) — all
  without any credentials.
- `ldap-search` (which binds anonymously by default) returns **nothing**,
  consistent with 1.1 — anonymous bind can't read the tree here.

**What does `ldap-rootdse` reveal?** The naming context (confirming the
base DN without needing valid credentials), the LDAP protocol version, and
every authentication mechanism the server is willing to negotiate — useful
for an attacker deciding what kind of credential attack to attempt next.

**Question — anonymous bind risk in general:** If anonymous bind *were*
allowed (unlike this lab's server), an attacker could read the entire
directory tree without any credentials — usernames, group memberships,
email addresses, organisational structure, sometimes even password hashes
on misconfigured servers. That's a ready-made target list for password
spraying or social engineering, extracted with zero authentication
required.

---

## Part 2: MySQL Enumeration

### Exercise 2.1: Banner Grab and Port Check

```bash
nmap -p 3306 -sV 10.10.5.11
echo "" | nc -w 2 10.10.5.11 3306 | strings
```

**Verified result:** `nmap -sV` → `MySQL 8.0.46`. Raw netcat banner grab
confirms the same version string (`8.0.46`) plus the auth plugin name
(`caching_sha2_password`) visible in the initial handshake packet.

### Exercise 2.2: Nmap MySQL Scripts

```bash
nmap -p 3306 --script mysql-databases 10.10.5.11
nmap -p 3306 --script mysql-brute --script-args brute.firstonly=true 10.10.5.11
```

**Verified result:** `mysql-databases` (unauthenticated) returns **no
output** — MySQL 8 requires a successful login before it will list
databases, so this script needs valid creds to do anything useful here.
`mysql-brute` ran its full built-in wordlist (50,009 guesses in 12 seconds)
and found **no valid accounts** — the real credential (`dbuser` /
`dbpass123`) isn't in Nmap's generic default password list, which is
realistic: canned wordlists don't magically contain an org's actual
passwords.

**Did the script find any accessible databases?** **No** (with the default
wordlist).

**What credentials did mysql-brute find?** None — the worksheet supplies
the real credential directly in Exercise 2.3 instead, since a generic brute
force wouldn't realistically find it either.

### Exercise 2.3: Authenticated MySQL Enumeration

```bash
mysql -h 10.10.5.11 -u dbuser -pdbpass123 --skip-ssl
SHOW DATABASES;
USE corpdb;
SHOW TABLES;
SELECT * FROM employees;
SELECT * FROM systems;
```

**Verified result:**

Databases visible to `dbuser`: `corpdb`, `information_schema`,
`performance_schema`.

`corpdb` tables: `ctf_flags`, `employees`, `systems` (`ctf_flags` is for
the optional CTF — not queried here, per worksheet scope).

| username | department | email |
|----------|-----------|-------|
| jsmith | IT | jsmith@cybercorp.local |
| mjones | Finance | mjones@cybercorp.local |
| awilson | HR | awilson@cybercorp.local |
| tbrown | Engineering | tbrown@cybercorp.local |

`systems` table also reveals three internal hostnames/IPs/OSes
(`web01`/`db01`/`dc01`) — a bonus recon find beyond what the worksheet
explicitly asks for, worth pointing out to students who read the whole
table.

**Question — why is this dangerous even with authentication required?**
`dbuser` is a low-privilege application account, yet it has read access to
an `employees` table containing real usernames and email addresses that
have nothing to do with what an app account should need. Any compromise of
that single low-value credential (weak password, credential reuse, SQLi)
exposes a ready-made target list for phishing or password-spray attacks
against the actual organisation, and the `systems` table leaks internal
network topology on top of that.

---

## Part 3: SMB/Samba Enumeration

### Exercise 3.1: Nmap SMB Scripts

```bash
nmap -p 445 --script smb-enum-shares,smb-enum-users,smb-os-discovery 10.10.5.12
```

**Verified result:** all three scripts return **no output at all**, even
with valid credentials passed via `--script-args smbuser=alice,smbpass=alice123`.
Confirmed via direct `smbclient` that Samba here only negotiates SMB2+
(`smbXcli_negprot_smb1_done: No compatible protocol selected by server`) —
Nmap's older `smb-enum-*` NSE scripts rely on SMB1 and simply don't work
against a modern SMB2/3-only server. This is a real, common limitation
worth teaching explicitly: **when Nmap's SMB scripts go silent, that's not
"no data," it's a protocol mismatch** — fall back to `enum4linux` and
`smbclient` (3.2/3.3), which do speak SMB2/3.

**What shares are listed?** None via these NSE scripts (see instructor
note above) — see Exercise 3.2/3.3 for the shares found by tools that
actually work against this server.

**Were any users enumerated?** No, via this method — see 3.2.

### Exercise 3.2: enum4linux

```bash
enum4linux -a 10.10.5.12
```

**Verified result:**

**Workgroup/Domain:** `CYBERCORP` (from the domain SID lookup — nbtstat
itself failed with "no reply," but `srvinfo`/RID enumeration recovered it)

**Server description:** `CyberCorp File Server` (from `srvinfo`)

**User accounts found:** `alice` (RID 0x3e8), `bob` (RID 0x3e9) — recovered
twice, once via null-session `enumdomusers` and again independently via RID
cycling (500-550, 1000-1050), confirming both are real local accounts.

**Shares found:** `public` (Disk), `IPC$` (IPC) — `private` does not appear
in the null-session share listing at all, since it's `browsable = no` and
restricted to `alice` (matches the `smb.conf` in the compose file).

### Exercise 3.3: Access Shares with smbclient

```bash
smbclient -L //10.10.5.12 -N
smbclient //10.10.5.12/public -N
# ls
# get notice.txt
smbclient //10.10.5.12/private -U alice%alice123
# ls
```

**Verified result:** `public` share contains `notice.txt` (content:
"CyberCorp public share.") and `user.txt` (a CTF flag file, not opened here
— out of scope for the main worksheet). `private` share, accessed as
`alice`, contains `readme.txt` ("Internal documents - confidential.") —
alice's credentials work and she can list/read the private share's
contents.

**What files are in the public share?** `notice.txt`, `user.txt`.

**Can alice access the private share?** **Yes.**

**Question — what would an attacker do with enumerated SMB usernames?**
Feed them into a password-spray or brute-force attack (Hydra, `crackmapexec`)
against SMB itself, or reuse the same usernames against SSH/RDP/VPN/web
logins elsewhere in the organisation — this is exactly the point of Part 4
(cross-referencing usernames across services).

---

## Part 4: Cross-Service Intelligence

### Exercise 4.1: Build a User List

```bash
echo "alice
bob
jsmith
mjones
awilson
tbrown" > /tmp/users.txt
```

**How many unique usernames collected?** **6** — `alice`, `bob` (from SMB)
plus `jsmith`, `mjones`, `awilson`, `tbrown` (from MySQL). Note LDAP
contributed none this time (see the 1.2 instructor note) — a real
illustration that not every source yields the same data.

### Exercise 4.2: Cross-Reference Services — verified answer

| Username | Found in LDAP? | Found in MySQL? | Found in SMB? |
|----------|-----------------|-------------------|----------------|
| alice | No | No | Yes |
| bob | No | No | Yes |

**Question — same username in LDAP and SMB, what next (no exploitation
yet)?** Note it as a high-value target for credential reuse — try the same
username (and any known/guessed password pattern) against every other
service discovered so far (SSH, another share, a web login), since people
and organisations very commonly reuse credentials across systems. This is
recon, not exploitation, as long as no login attempt is actually made yet
without authorisation to do so.

---

## Part 5: Ethics and Reporting — model answers

1. **Passive vs. active logging:** Keep timestamped command logs and saved
   tool output (Nmap `-oA`, `ldapsearch`/`smbclient` transcripts) showing
   exactly what was queried, when, and against which IP — proof the
   activity stayed within the agreed scope and testing window, and that
   nothing beyond enumeration (e.g. no destructive writes) was attempted.
2. **Data handling:** Employee names and emails are personal information —
   handle them under the same confidentiality/data-protection obligations
   as any other client data (secure storage, no unnecessary copies, no
   sharing outside the engagement), and under Australian privacy law this
   is exactly the kind of data a breach-notification obligation would cover
   if it were ever exposed outside the authorised engagement.
3. **Least privilege:** `dbuser` shouldn't have `SELECT` on `employees` at
   all if the application only needs, say, the `systems` table — granting
   column/table-level privileges scoped to exactly what the application
   needs (not blanket database access) would have prevented this exposure
   even if the credential leaked.

---

## Quick Knowledge Check — Answers

1. **B) 389**
2. **B) Runs all SMB enumeration modules**
3. **True**
4. **B) `SHOW DATABASES;`**
5. **C) enum4linux**

---

## Notes for the Instructor

- Anonymous LDAP bind is **not** allowed on this lab's server — Exercise
  1.1/1.3's "did anonymous return results" answer is legitimately **No**.
  Don't mistake this for a broken lab; it's a deliberately more realistic,
  hardened LDAP config, and the discussion question in 1.3 asks students to
  reason about the *general* risk, not this specific server's behaviour.
- LDAP holds no actual employee accounts in this lab (only the `readonly`
  service account) — the employee usernames worksheet exercises expect
  come from MySQL, not LDAP. Worth calling out explicitly.
- Nmap's `smb-enum-shares`/`smb-enum-users`/`smb-os-discovery` NSE scripts
  return nothing against this server because Samba here only negotiates
  SMB2/3 and those scripts are SMB1-only — a genuine, common real-world
  limitation of older Nmap NSE scripts, not a lab bug. `enum4linux` and
  `smbclient` (which speak SMB2/3) are the tools that actually work, and
  the worksheet is structured to lead students there anyway.
- `mysql-brute`'s default wordlist won't find `dbuser`/`dbpass123` — this
  is expected; the worksheet hands the credential directly in 2.3 rather
  than expecting brute force to discover it.
