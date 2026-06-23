# Week 3 Worksheet — Scoping, Planning & Traffic Analysis

## Overview

This week covers engagement scoping, legal boundaries, and applying Wireshark to analyse network traffic within a defined scope. You will practise identifying targets, capturing traffic, and documenting findings.

## Lab Environment

- **week3-wireshark** — Wireshark GUI (port 3000)
- **week3-target** — Sample target at `172.30.0.3`

Access Wireshark at: `http://localhost:3000`

## Exercises

### 1. Define the Scope

Document your target scope:
- Target IP range: `172.30.0.0/24`
- In-scope: `week3-target (172.30.0.3)`
- Out of scope: Everything else

### 2. Capture Traffic to the Target

Start a Wireshark capture, then from the Wireshark container terminal:
```bash
ping 172.30.0.3
```

Observe ICMP packets in Wireshark.

### 3. Passive Reconnaissance

Without sending any traffic, analyse what you can see from captured packets:
- What protocols are visible?
- What source/destination pairs appear?

### 4. Active Discovery

Use Nmap from inside the Wireshark container or from the Docker host:
```bash
nmap -sV 172.30.0.3
```

Document all open ports and services.

### 5. Report Your Findings

Write a brief scope-validation report:
- Target confirmed in scope: Yes/No
- Services discovered:
- Potential risks noted:

---

## Optional: CTF Challenge

Once you have completed all exercises above, test your skills with an optional Capture The Flag challenge.

See **[ctf-challenge.md](./ctf-challenge.md)** for objectives.

Two flags to capture: `user.txt` and `root.txt`  
Flag format: `flag{...}`  
No hints — instructor walkthrough released at end of session.
