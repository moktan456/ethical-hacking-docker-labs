# Ethical Hacking Lab

This repository contains a Docker Compose configuration to set up the required Docker containers for the Ethical Hacking Lab. This environment provides a comprehensive set of tools and services for hands-on learning and experimentation in network security.


## 💻 Two-Shell Lab Setup (Recommended)

Running two terminal windows side-by-side gives you the real attacker/victim experience:

**Terminal 1 — Start the lab (victim machines)**
```bash
# Linux / macOS / Git Bash
cd labs/week7
docker compose up -d

# Windows PowerShell
cd labs\week7
docker compose up -d
```

**Terminal 2 — Enter Kali (attacker machine)**
```bash
docker exec -it week7-attacker bash
```

> Think of Terminal 1 as the victim network running in the background, and Terminal 2 as your Kali attacking machine. All commands in the worksheets are run from Terminal 2 (inside Kali).

---

## Prerequisites

Before you begin, ensure you have the following installed on your system:
- Docker
- Docker Compose

## Getting Started

1. Clone this repository:

   ```
   git clone https://github.com/moktan456/ethical-hacking-docker-labs.git
   ```

2. Navigate to the week 7 lab directory:

   ```
   cd ethical-hacking-docker-labs/labs/week7
   ```

3. Start the Docker environment:

   ```
   docker compose up -d
   ```

   This command will download the necessary images and start all the containers.

   **Note:** The initial setup may take several minutes to complete, as Docker needs to pull all the required images. Subsequent starts will be much quicker, typically taking only a few seconds to bring up or down the entire environment.

4. Once all containers are running, you can access the various services as described in the "Available Services" section below.

## Available Services

| Service Name   | Description                                            | Access Method                                           |
|----------------|--------------------------------------------------------|----------------------------------------------------------|
| Wireshark      | Network protocol analyser                              | `http://localhost:3000` (login: `abc`/`abc` by default)  |
| Workstation    | Basic Alpine Linux workstation                         | `docker exec -it week7-workstation sh`                   |
| SecUtils       | Browser-based security toolbox desktop                 | `http://localhost:6081` (login: `root`/`rootpassword`)<br>or `docker exec -it week7-secutils bash` |
| Netshoot       | Network troubleshooting container                      | `docker exec -it week7-netshoot sh`                      |
| Ubuntu Desktop | Ubuntu LXDE desktop environment                        | VNC: `localhost:5900`<br>NoVNC (browser): `http://localhost:6080` |
| OpenLDAP       | LDAP server                                            | `ldap://localhost:389`                                   |
| MailHog        | Email testing tool                                     | `http://localhost:8025`                                  |
| MySQL          | MySQL database server                                  | `mysql -h localhost -P 3306 -u user -p`                  |
| Telnet         | Telnet server                                          | `telnet localhost 23`                                    |
| OWASP Juice Shop | Web application security training platform           | `http://localhost:3012`                                  |
| DVWA           | Damn Vulnerable Web Application                        | `http://localhost:8085`                                  |
| Attacker       | Kali-based attack box (ethical-base image)             | `docker exec -it week7-attacker bash`                    |

## Usage Guidelines

1. **Wireshark**: Access the web-based Wireshark interface to analyse network traffic.

2. **Workstation and Netshoot**: Use these containers for various command-line operations and network troubleshooting. Access them using the `docker exec` command as shown in the table above.

2b. **SecUtils**: A browser-based GUI security toolbox — see the [SecUtils GUI Box user guide](#-secutils-gui-box--security-tools-user-guide) below for its tool list and usage.

3. **Ubuntu Desktop**: Connect using a VNC client or access via a web browser for a graphical Linux environment.

4. **OpenLDAP**: Use this for experimenting with LDAP authentication and directory services.

5. **MailHog**: A useful tool for testing email functionality without sending real emails.

6. **MySQL**: Practice database security concepts and SQL injection prevention.

7. **Telnet**: Use for learning about insecure protocols and practising secure alternatives.

8. **OWASP Juice Shop and DVWA**: These intentionally vulnerable web applications are excellent for practising web application security techniques.

## Security Notice

This environment contains intentionally vulnerable applications and services for educational purposes. Do not deploy this in a production environment or on a public network. Always use this setup in a controlled, isolated environment.

---

## 🧰 SecUtils GUI Box — Security Tools User Guide

The `week7-secutils` container is a full Ubuntu XFCE desktop running in your browser (via [LinuxServer's webtop](https://docs.linuxserver.io/images/docker-webtop/)). On top of the base desktop, the following command-line security tools are automatically installed the first time the container starts:

| Tool | Purpose |
|------|---------|
| `nmap` | Port scanning / service discovery |
| `hydra` | Online password brute-forcing |
| `nikto` | Web server vulnerability scanner |
| `sqlmap` | Automated SQL injection testing |
| `netcat` (`nc`) | Reading/writing raw TCP & UDP connections |

`curl`, `wget`, and `ping` come with the base Ubuntu desktop image, so they don't need to be installed separately.

### How the install works

These packages are installed at container **startup**, not baked into the image. This is done via a small script — `labs/week7/secutils-init/10-install-security-tools.sh` — mounted read-only into the container's [`/custom-cont-init.d`](https://docs.linuxserver.io/general/container-customization/) directory, which LinuxServer.io images run automatically on every start, after their own init but before the desktop starts.

The script is deliberately **hardened** rather than assuming the base Ubuntu image has everything it needs:
1. Runs `apt-get update`.
2. Explicitly enables the `universe` and `multiverse` repositories (`nikto` and `sqlmap` live in `universe`) — it doesn't just assume they're already on, since that varies between base images.
3. Updates the package index again, then installs the tool list.
4. If any package fails to install (e.g. a flaky mirror), it logs a clear warning and lets the desktop start anyway rather than crashing the container.

To add or remove tools, edit the package list at the bottom of `labs/week7/secutils-init/10-install-security-tools.sh` and re-run `docker compose up -d` — no image rebuild needed.

> ⏱️ **First-boot delay:** the first time you run `docker compose up -d`, the `week7-secutils` container takes an extra **20–60 seconds** after startup to finish installing packages before they're usable — this is normal. A full `docker compose down` + `up` reinstalls them again (the install doesn't persist across container recreation).

> 🔍 **Troubleshooting:** if a tool seems missing, check the install log with `docker logs week7-secutils | grep secutils-init` — it'll show exactly which step ran and whether any package failed.

### Using the tools

**Option A — GUI terminal (recommended, no extra setup):**
1. Open `http://localhost:6081` and log in (`root` / `rootpassword`).
2. Open a terminal app from the desktop.
3. Run any of the tools directly, e.g.:
   ```bash
   nmap -sV 10.10.7.0/24
   nikto -h http://<target-ip>
   ```

**Option B — `docker exec` from your host terminal:**
```bash
docker exec -it week7-secutils nmap -sV 10.10.7.0/24
```

Both options run inside the same container on the same `security_net`, so either way you're scanning the actual lab network at `10.10.7.0/24`.

## Troubleshooting

If you encounter any issues:

1. Ensure all containers are running:
   ```
   docker compose ps
   ```

2. Check container logs:
   ```
   docker compose logs [service_name]
   ```

3. Restart the environment:
   ```
   docker compose down
   docker compose up -d
   ```

## Contributing

We welcome contributions to improve this learning environment. Please submit pull requests or open issues on the GitHub repository.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## Practice on VulnHub

After working through DVWA and Juice Shop in this lab, test the same techniques — SQLi, XSS, file upload, command injection — against these standalone VMs where there is no guided interface.

| Machine | URL | Why it fits |
|---------|-----|------------|
| **Web Developer: 1** | https://www.vulnhub.com/entry/webdeveloper-1,288/ | WordPress-based machine where the attack chain goes through web-application enumeration, SQLi via WPScan, and credential abuse. Covers the same SQLi and web-enumeration workflow as the Week 7 DVWA exercises. Difficulty: beginner–intermediate. |
| **Kioptrix: Level 1.2 (#3)** | https://www.vulnhub.com/entry/kioptrix-level-12-3,24/ | Hosts a vulnerable PHP gallery application with SQL injection and a MySQL backend. The exploit chain mirrors what students do in DVWA's SQLi module, then pivots into password cracking — a clean bridge between Weeks 6 and 7. Difficulty: beginner–intermediate. |
