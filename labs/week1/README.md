# Docker Compose: Network Security Toolkit

This repository contains a `docker compose.yaml` file that sets up a Network Security Toolkit with HAProxy, Wireshark, and Security Utilities. The provided `docker compose.yaml` file creates a custom Docker network and connects all services to it.


## 💻 Week 1 Lab Setup

Week 1 uses **browser-based GUIs** for Wireshark and secutils — open three windows side by side:

---

### Step 1 — Start all containers (one terminal)

```bash
# Linux / macOS / Git Bash
cd labs/week1
docker compose up -d

# Windows PowerShell
cd labs\week1
docker compose up -d
```

---

### Step 2 — Open Wireshark in your browser

Open your **host machine browser** (Windows/macOS/Linux — the same computer running Docker) and go to:

```
http://localhost:14500
```
Password: **`wireshark`**

This opens the Wireshark GUI (served via Xpra through HAProxy). Use this to capture and analyse network traffic on the lab network.

> **Why does this work?** Docker maps container port 14500 → your host's `localhost:14500`, so any browser on your Windows/macOS machine can reach it directly.

---

### Step 3 — Open secutils desktop in your browser

Open a **second tab in the same host machine browser**:

```
http://localhost:6080
```
Password: **`rootpassword`**

This opens a full Linux desktop with security tools pre-installed (nmap, hydra, nikto, netcat, sqlmap, etc.) — this is your **victim/utility machine**.

---

### Step 4 — Enter Kali (attacker machine, new terminal)

```bash
docker exec -it week1-attacker bash
```

This is your **Kali attacker shell**. Run reconnaissance and attack commands from here.

---

### Window layout summary

| Window | What it is | How to access |
|--------|-----------|---------------|
| Terminal | Kali attacker | `docker exec -it week1-attacker bash` |
| Browser tab 1 (host) | Wireshark GUI | `http://localhost:14500` (pw: wireshark) |
| Browser tab 2 (host) | secutils desktop | `http://localhost:6080` (pw: rootpassword) |

---

## Services

1. **proxy** (HAProxy): A high-performance and highly-robust TCP/HTTP load balancer. The configuration file is mapped from the local `haproxy.cfg` file.
2. **wireshark** (ffeldhaus/wireshark): A Docker container running Wireshark with Xpra for remote access. It is connected to the proxy service and uses the same network.
3. **secutils** (lscr.io/linuxserver/webtop:ubuntu-xfce): A browser-accessible Ubuntu desktop, used here as the "admin box" target for this week's second CTF flag. It is also connected to the custom network.

## Usage

1. Install [Docker](https://www.docker.com/) and [Docker Compose](https://docs.docker.com/compose/).
2. Clone this repository:
```
git clone https://github.com/moktan456/ethical-hacking-docker-labs.git
```
3. Change to the week 1 lab directory:
```
cd ethical-hacking-docker-labs/labs/week1
```
4. Create and start the services with Docker Compose:
```
docker compose up -d
```

## Service Configuration

### Proxy (HAProxy)

- **IP address**: 10.10.1.2
- **Port**: 14500
- **Configuration file**: `./haproxy.cfg`

> **Note:** `haproxy.cfg` ships with every frontend/listen block commented out — this is intentional,
> not broken. Wireshark's web UI works on port 14500 without HAProxy doing anything, because the
> Wireshark container shares this proxy container's network namespace. HAProxy here is only needed
> if you want it to relay another protocol (HTTP, SMB, NFS, etc.) through itself so Wireshark can
> observe that traffic — uncomment and configure the relevant block in `haproxy.cfg` for that.

### Wireshark

- **Network**: shares the `proxy` container's network namespace (`network_mode: "service:proxy"`), so it has no IP address of its own — it's reachable via the proxy container.
- **Access password**: "wireshark"
- **Captured files**: Stored in the local `./data` directory

### Security Utilities

- **IP address**: 10.10.1.5
- **Port**: 6080
- **Username**: root
- **Password**: rootpassword
- **SSL**: false
- **Data directory**: Mapped to the local `./data` directory

## Custom Network Configuration

- **Network name**: custom_network
- **Driver**: bridge
- **Subnet**: 10.10.1.0/24

## Stopping and Removing Services

To stop and remove the services, use the following command:

```
docker compose down
```

## Connecting to the Wireshark Container

To access the Wireshark container remotely, follow these steps:

1. Open your web browser and go to `http://localhost:14500`.

2. You will be prompted to enter the Xpra username and password. Use the following credentials:

   - **Username**: wireshark
   - **Password**: wireshark

3. After successful authentication, you will be able to access the Wireshark interface remotely.

Please note that the Wireshark container is connected to the proxy service, which listens on port 14500. Make sure the proxy service is up and running before attempting to connect to the Wireshark container.

## Connecting to the Secutils Container

There are two ways to connect to the Secutils container:

### Option 1: Command Line Interface

1. Open a PowerShell or terminal window.

2. Run the following command to access the Secutils container's Bash shell:

```
docker exec -it secutils bash
```

3. You can now use the command line tools available within the container: `nmap`, `hydra`, `nikto`, `sqlmap`, `netcat`, plus the base OS utilities `curl`, `wget`, and `ping`. See the [SecUtils GUI Box user guide](#-secutils-gui-box--security-tools-user-guide) below for details.

### Option 2: Graphical User Interface

1. Open your web browser and go to `http://localhost:6080`.

2. Wait a few seconds for the graphical interface to load.

3. you will now have access to the Linux container's graphical interface, where you can use the available security tools.

Remember to ensure that the Secutils container is up and running before attempting to connect using either method.

---

## 🧰 SecUtils GUI Box — Security Tools User Guide

The `secutils` container is a full Ubuntu XFCE desktop running in your browser (via [LinuxServer's webtop](https://docs.linuxserver.io/images/docker-webtop/)). On top of the base desktop, the following command-line security tools are automatically installed the first time the container starts:

| Tool | Purpose |
|------|---------|
| `nmap` | Port scanning / service discovery |
| `hydra` | Online password brute-forcing |
| `nikto` | Web server vulnerability scanner |
| `sqlmap` | Automated SQL injection testing |
| `netcat` (`nc`) | Reading/writing raw TCP & UDP connections |

`curl`, `wget`, and `ping` come with the base Ubuntu desktop image, so they don't need to be installed separately.

### How the install works

These packages are installed at container **startup**, not baked into the image. This is done via a small script — `labs/week1/secutils-init/10-install-security-tools.sh` — mounted read-only into the container's [`/custom-cont-init.d`](https://docs.linuxserver.io/general/container-customization/) directory, which LinuxServer.io images run automatically on every start, after their own init but before the desktop starts.

The script is deliberately **hardened** rather than assuming the base Ubuntu image has everything it needs:
1. Runs `apt-get update`.
2. Explicitly enables the `universe` and `multiverse` repositories (`nikto` and `sqlmap` live in `universe`) — it doesn't just assume they're already on, since that varies between base images.
3. Updates the package index again, then installs the tool list.
4. If any package fails to install (e.g. a flaky mirror), it logs a clear warning and lets the desktop start anyway rather than crashing the container.

To add or remove tools, edit the package list at the bottom of `labs/week1/secutils-init/10-install-security-tools.sh` and re-run `docker compose up -d` — no image rebuild needed.

> ⏱️ **First-boot delay:** the first time you run `docker compose up -d` for this lab, the `secutils` container takes an extra **20–60 seconds** after startup to finish installing packages before they're usable — this is normal. Subsequent restarts of the *same* container are instant, but a full `docker compose down` + `up` reinstalls them again (the install doesn't persist across container recreation).

> 🔍 **Troubleshooting:** if a tool seems missing, check the install log with `docker logs secutils | grep secutils-init` — it'll show exactly which step ran and whether any package failed.

### Using the tools

**Option A — GUI terminal (recommended, no extra setup):**
1. Open `http://localhost:6080` and log in (`root` / `rootpassword`).
2. Open a terminal app from the desktop (right-click desktop → *Open Terminal*, or use the taskbar).
3. Run any of the tools directly, e.g.:
   ```bash
   nmap -sV 10.10.1.0/24
   nikto -h http://<target-ip>
   ```

**Option B — `docker exec` from your host terminal:**
```bash
docker exec -it secutils nmap -sV 10.10.1.0/24
```

Both options run inside the same container on the same `custom_network`, so either way you're scanning the actual lab network at `10.10.1.0/24`.

---

This project is released under the MIT License. See the [LICENSE](LICENSE) file for details.

---

## Practice on VulnHub

After completing this lab, apply your Wireshark and traffic-analysis skills against these machines. Both expose a wide range of services — run the lab environment alongside Wireshark to capture and dissect the traffic your tools generate.

| Machine | URL | Why it fits |
|---------|-----|------------|
| **Metasploitable: 2** | https://www.vulnhub.com/entry/metasploitable-2,29/ | Dozens of intentionally vulnerable services (FTP, SSH, HTTP, SMB, MySQL, IRC, etc.) — ideal for generating real multi-protocol traffic to capture and analyse. A foundational reference VM for the whole course. |
| **SickOs: 1.1** | https://www.vulnhub.com/entry/sickos-11,132/ | Traffic is routed through an HTTP CONNECT proxy, making Wireshark filtering and protocol dissection non-trivial. Good practice spotting tunnelled requests in a capture file. |

**Tip:** Boot the VulnHub VM, start a capture in Wireshark, then run `nmap -sV <target-ip>` from the attacker container. Compare the resulting pcap with the pre-supplied `.cap` files in `labs/week1/data/`.
