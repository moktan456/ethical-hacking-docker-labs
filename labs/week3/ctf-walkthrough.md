# Week 3 CTF Walkthrough — INSTRUCTOR ONLY

> **Do not distribute to students before the end of the session.**

---

## Setup

The `week3-target` container starts a Python HTTP server on port 8888 exposing two files in `/tmp/flags/`.

---

## Flag 1 — user.txt (`flag{w3_wireshark_scope_expert}`)

**Step 1 — Discover the port with Nmap (from Wireshark container or attacker):**
```bash
nmap -sV 172.30.0.3
```
Output shows port 8888 open (http / Python http.server).

**Step 2 — Retrieve the flag:**
```bash
curl http://172.30.0.3:8888/flags/user.txt
```

---

## Flag 2 — root.txt (`flag{w3_target_service_found}`)

The file `root_b64.txt` contains the flag base64-encoded.

**Step 1 — Download the encoded file:**
```bash
curl http://172.30.0.3:8888/flags/root_b64.txt
```

**Step 2 — Decode:**
```bash
echo "ZmxhZ3t3M190YXJnZXRfc2VydmljZV9mb3VuZH0=" | base64 -d
```

---

## Teaching Points

- Nmap port discovery is the first step in any engagement scope validation
- HTTP servers running on non-standard ports are common findings
- Encoded data (base64, hex) should be recognised and decoded during analysis
- Traffic between attacker and target is visible in Wireshark — students can capture the HTTP GET requests
