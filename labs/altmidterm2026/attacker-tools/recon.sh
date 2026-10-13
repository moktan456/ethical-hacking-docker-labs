#!/bin/bash

# Solari Analytics Alt-Exam Reconnaissance Script
echo "=== Solari Analytics Alt-Exam Reconnaissance ==="
echo "Target: Lab network (10.10.11.0/24)"
echo ""

echo "[+] Step 1: Network Discovery"
echo "nmap -sn 10.10.11.0/24"
nmap -sn 10.10.11.0/24
echo ""

echo "[+] Step 2: Port Scanning Discovered Hosts"
echo "nmap -sC -sV 10.10.11.2 10.10.11.10 10.10.11.11 10.10.11.12 10.10.11.13"
nmap -sC -sV 10.10.11.2 10.10.11.10 10.10.11.11 10.10.11.12 10.10.11.13
echo ""

echo "[+] Step 3: Web Enumeration"
echo "curl -s http://10.10.11.10 | grep -E '(Name|Email)'"
curl -s http://10.10.11.10 | grep -E '(Name|Email)'
echo ""

echo "[+] Step 4: Generate Username List"
cat > /root/lab/users.txt << 'EOF'
nchen
opatel
pshah
qrivera
sito
root
admin
EOF
echo "Created users.txt with potential usernames"

echo ""
echo "=== Ready for Exploitation ==="
echo "Next steps:"
echo "1. FTP enumeration: ftp 10.10.11.12"
echo "2. SSH brute force: hydra -L users.txt -P passwords.txt 10.10.11.11 ssh"
echo "3. SSH access: ssh <user>@10.10.11.11"
