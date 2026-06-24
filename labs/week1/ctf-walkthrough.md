# Week 1 CTF Walkthrough — INSTRUCTOR ONLY

> **Do not distribute to students before the end of the session.**

---

## Flag 1 — user.txt (`flag{w1_network_traffic_analyst}`)

The flag lives in the shared data volume mounted into the Wireshark container at `/home/wireshark/user.txt` and into SecUtils at `/root/Desktop/data/user.txt`.

**Path via Wireshark container:**
```bash
docker exec -it wireshark cat /home/wireshark/user.txt
```

**Path via SecUtils noVNC:**
1. Browse to `http://localhost:6080`
2. Login: `root` / `rootpassword`
3. Open a terminal on the desktop
4. `cat /root/Desktop/data/user.txt`

---

## Flag 2 — root.txt (`flag{w1_secutils_admin_access}`)

Planted at `/root/root.txt` inside the SecUtils container during startup via the modified `command` in docker compose.

**Via SecUtils noVNC terminal:**
```bash
cat /root/root.txt
```

**Via docker exec:**
```bash
docker exec -it secutils cat /root/root.txt
```

---

## Teaching Points

- Shared volumes create implicit data exposure between containers
- Even "display-only" containers (like Wireshark/SecUtils) can be entry points if credentials are weak or known
- Container startup commands run as root and can write anywhere in the filesystem
