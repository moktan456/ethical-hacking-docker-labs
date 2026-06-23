# Week 1 Worksheet — Introduction to Network Traffic Analysis

## Overview

This week introduces Wireshark for packet capture and network protocol analysis. You will observe live traffic, identify protocols, and begin building your analyst mindset.

## Lab Environment

- **Wireshark** — GUI packet analyser (accessible via proxy on port 14500)
- **SecUtils** — Security utilities desktop (accessible on port 6080)
- **week1-attacker** — Kali-based attacker container

```bash
docker exec -it week1-attacker bash
```

## Exercises

### 1. Start a Packet Capture

Open the Wireshark interface via `http://localhost:14500` (password: `wireshark`).

Start a capture on the `eth0` interface.

### 2. Generate Traffic

From the attacker container, generate some network traffic:
```bash
ping 192.168.1.5
curl http://192.168.1.5
```

### 3. Filter and Analyse

Apply Wireshark display filters:
```
icmp
http
tcp.port == 80
```

Identify source/destination IPs, protocols, and payloads.

### 4. Export and Review

Stop the capture and export as `.pcapng`.  
Open one of the provided `.cap` files from the shared data volume.

---

## Optional: CTF Challenge

Once you have completed all exercises above, test your skills with an optional Capture The Flag challenge.

See **[ctf-challenge.md](./ctf-challenge.md)** for objectives.

Two flags to capture: `user.txt` and `root.txt`  
Flag format: `flag{...}`  
No hints — instructor walkthrough released at end of session.
