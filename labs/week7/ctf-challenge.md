# Week 7 CTF Challenge — Web Application & Protocol Exploitation

> **Optional challenge** — attempt after completing the main worksheet exercises.  
> Instructor releases the walkthrough at the end of the session.

---

## Target Environment

| Host | IP | Services |
|------|----|---------|
| week7-mysql | 10.10.7.9 | MySQL (:3306) |
| week7-telnet | 10.10.7.10 | Telnet (:23) |
| week7-dvwa | 10.10.7.12 | HTTP (:8085) |
| week7-juice-shop | 10.10.7.11 | HTTP (:3012) |

---

## Your Mission

Two flags are hidden in this lab.  
Submit each flag in the format `flag{...}`.

### Flag 1 — user.txt

Connect to the MySQL database and enumerate all tables in `exampledb`.  
One of the tables is not part of the normal schema. Query it to retrieve the flag.

Credentials: `user` / `userpassword`

`user.txt` → `flag{________________________}`

### Flag 2 — root.txt

A legacy Telnet service is running on the network. A user account has been created on it.  
Discover the credentials, connect via Telnet, and read the flag in the user's home directory.

`root.txt` → `flag{________________________}`

---

*No further hints. Your walkthrough will be provided at the end of the session.*
