CyberGuard Corp - FTP Server
============================

Welcome to the CyberGuard file sharing service!

----------------------------------------
FLAG #1 - FTP ENUMERATION (EASY)
----------------------------------------

Nice work finding this via anonymous FTP access.

Your Flag: flag{mock2_ftp_an0nym0us_acc3ss}

----------------------------------------
NEXT STEPS HINT
----------------------------------------

Our application server (cyberguard-app) has a developer account:
username "mrahman". He set his own password against policy and
IT only knows roughly what he used — one of our old project
codenames from last year, followed by the current year:

  Codenames shortlist: Dragon, Phoenix, Falcon, Tiger, Eagle
  Year: 2025 or 2026

That's 10 combinations. Build a small wordlist yourself and try
them against SSH on 10.10.60.12 — don't just throw rockyou.txt at
it blind.

Generated: 2026-10-05
Server: cyberguard-ftp (10.10.60.11)
