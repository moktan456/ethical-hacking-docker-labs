# Week 1 Worksheet Walkthrough — INSTRUCTOR ONLY

> Verified against live containers. Do not distribute to students before the
> end of the session.

---

## Exercise 1: Start a Packet Capture

Open `http://localhost:14500` — this is LinuxServer's Wireshark image, browser-accessible
via KasmVNC, no password by default.

Inside the browser desktop, open Wireshark (already installed), select the
**eth0** interface (the container's only interface, on the `10.10.1.0/24`
network), and click the shark-fin "start capture" icon.

## Exercise 2: Generate Traffic

```bash
docker exec -it week1-attacker bash
ping 10.10.1.5
curl http://10.10.1.5
```

**Verified result:**
- `ping 10.10.1.5` succeeds — `10.10.1.5` is the `secutils` container (static
  IP set in `docker-compose.yaml`). ICMP echo replies come back at ~0.1ms
  (same Docker host, effectively loopback speed).
- `curl http://10.10.1.5` **fails with "Connection refused" (exit code 7)**.
  `secutils` only listens on port 3000 internally (its KasmVNC desktop,
  mapped to host port 6080) — nothing is listening on port 80. This is
  expected and still useful: a refused connection still generates real
  packets (SYN, then RST/ACK), which is exactly what the next exercise's
  `tcp.port == 80` filter is built to show.

## Exercise 3: Filter and Analyse

Apply these filters in the Wireshark capture from Exercise 1:

- **`icmp`** — shows the ping exchange: `Echo (ping) request` from the
  attacker (10.10.1.13, or whatever IP Docker assigned it) to 10.10.1.5,
  and the matching `Echo (ping) reply` back.
- **`http`** — shows **nothing**. Since the curl connection was refused at
  the TCP layer, the HTTP request was never actually sent — there's no HTTP
  layer to a connection that never completed its handshake. This is worth
  pointing out to students who expect to see something here.
- **`tcp.port == 80`** — shows the two packets that *did* happen: a `SYN`
  from the attacker to 10.10.1.5:80, and a `RST, ACK` back rejecting it.

**Question for students:** why does `http` show nothing while `tcp.port ==
80` shows two packets? (Answer: TCP failed before HTTP ever got a chance to
run — protocols stack, and a lower layer failing means the layers above it
never happen.)

## Exercise 4: Export and Review

Stop the capture (red square icon), then File → Export Specified Packets →
save as `.pcapng`.

Pre-supplied capture files are already in the shared data volume
(`labs/week1/data/`, mounted read-only into both `wireshark` and `secutils`):
`ex2.cap`, `ex3.cap`, `ex4.cap`, `ex5.dmp`, `ex6.dmp`. Open any of them via
File → Open inside the Wireshark GUI to practice reading a capture someone
else made, rather than one just recorded live.

---

## Notes for the Instructor

- `secutils` is listed in the Lab Environment section but isn't used by any
  exercise — it's just available for students who want to poke around a
  browser-based Kali-adjacent desktop. Nothing above depends on it being up.
- `secutils`'s custom init script installs nmap/hydra/nikto/sqlmap/netcat on
  first boot, which takes noticeably longer than the other containers. Not
  relevant to this worksheet, but worth knowing if a student asks why that
  one container is slow to respond.
