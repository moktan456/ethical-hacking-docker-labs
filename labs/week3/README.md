# Week 3: Scope and Proposal Development - Traffic Analysis Lab

## Overview
This lab focuses on analyzing captured network traffic using Wireshark to inform scope/proposal writing. Use the shared packet captures in `data/caps` to identify assets, potential risks, and draft engagement scopes.

## Learning Objectives
- Load and filter .cap files in Wireshark.
- Identify protocols, hosts, and anomalies (e.g., unusual ports, payloads).
- Draft a pentest scope/proposal based on analysis (e.g., target services, rules of engagement).

## Setup (2 min)
1. Ensure base built: `make build-base` (or `docker build -t ethical-base -f base.Dockerfile .` on Windows) (from root).
2. Start lab: From root, `cd labs/week3 && docker compose up -d`
3. Access Wireshark: http://localhost:3000 (default creds: **abc/abc** — the linuxserver/wireshark image's actual default; override with the `PASSWORD` env var in `docker-compose.yaml` if you want something else).
4. Sample target runs on 10.10.3.10 for live capture practice.

## Activities
1. **Static Analysis (30 min)**:
   - Open a .cap file: File > Open > /caps (e.g., sample-traffic.cap).
   - Filter: `http` or `ip.src == 192.168.x.x`.
   - Note: Hosts, ports, data volumes. Look for sensitive info (e.g., creds in cleartext).

2. **Live Capture (20 min)**:
   - Start a capture on Wireshark's own interface (the only traffic it can reliably see is traffic
     to/from its own container — see note below).
   - From a second terminal, generate traffic aimed *at* the Wireshark container so it shows up:
     `docker exec -it week3-target nmap -sV 10.10.3.2`.
   - Analyze: Identify enumeration patterns in the resulting capture.

   > **Why aimed at .2, not a scan of `sample-target` itself:** on a standard Docker bridge network,
   > a container only sees traffic addressed to/from itself — it can't passively sniff arbitrary
   > traffic between two *other* containers the way a hub or mirrored switch port would. If you want
   > students to observe traffic between two unrelated services, route it through a proxy that shares
   > Wireshark's network namespace (see Week 1's HAProxy setup) rather than relying on this network
   > to "see everything."

3. **Proposal Draft (40 min)**:
   - Based on findings, write a scope doc (use template in root/docs if exists):
     - In-scope: Specific IPs/services.
     - Out-of-scope: Production systems.
     - Rules: No DoS, report vulns immediately.
   - Example: "Scope includes HTTP/SSH analysis from cap; propose scanning ports 80,22."

## Resources
- Chapter 3: Analysing Captured Traffic.
- Wireshark docs: https://www.wireshark.org/docs/wsug_html_chunked/.
- Sample caps: Add more to data/caps (e.g., download innocent traffic from Wireshark wiki).

## Cleanup
`docker compose down`

**Ethics**: Analysis only—no active attacks. Document assumptions for proposals.

Generated with Claude Code.
---

## Practice on VulnHub

These machines generate interesting traffic profiles. Boot one, capture its traffic in the Week 3 Wireshark container, and use the findings to draft a scope statement as per the lab's Proposal Draft activity.

| Machine | URL | Why it fits |
|---------|-----|------------|
| **Metasploitable: 2** | https://www.vulnhub.com/entry/metasploitable-2,29/ | Exposes cleartext protocols (Telnet, FTP, HTTP) alongside encrypted ones. Analysing the mix is excellent practice for identifying in-scope vs out-of-scope assets from a pcap, which is exactly the Week 3 proposal exercise. |
| **PwnLab: init** | https://www.vulnhub.com/entry/pwnlab-init,158/ | PHP web application with file upload and LFI. The HTTP traffic between browser and app contains multipart form data, cookies, and redirects — good material for filtering, following streams, and documenting findings in a scope doc. |
