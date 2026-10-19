#!/usr/bin/env python3
"""
Week 11 simulation: an unencrypted RFID door + the badge it's reading.

Models RFID in a way that's actually sniffable and replayable over a
network, matching the slides' three-step "Read -> Copy -> Replay":

  - A background thread plays the part of an employee's badge sitting in
    range of the reader: every few seconds it broadcasts its (cleartext,
    unencrypted) credential over UDP on the local segment - the network
    stand-in for the RF field a real card leaks into.
  - The main thread plays the door reader: a plain TCP service on :9000
    that grants access to whoever presents that exact credential string,
    no matter how they obtained it.

Read  -> tcpdump/tshark on the attacker container, same LAN segment
Copy  -> extract the BADGE:... string from the capture
Replay -> send it straight to the TCP door port

Stdlib-only, no pip install required.
"""
import os
import socket
import threading
import time

BADGE_ID = os.environ.get("BADGE_ID", "EMP-7741-ACCT")
BROADCAST_PORT = 9100
DOOR_PORT = 9000
FLAG = "flag{w11_rfid_sniffed_and_replayed}"


def badge_beacon():
    """Stands in for the employee's card passively broadcasting into RF range."""
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)
    s.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)
    message = f"BADGE:{BADGE_ID}".encode()
    while True:
        try:
            s.sendto(message, ("255.255.255.255", BROADCAST_PORT))
        except OSError:
            pass
        time.sleep(3)


def door_reader():
    srv = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    srv.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    srv.bind(("0.0.0.0", DOOR_PORT))
    srv.listen(5)
    print(f"[badge-system] door reader listening on :{DOOR_PORT}, "
          f"beacon broadcasting on udp/{BROADCAST_PORT}", flush=True)
    while True:
        conn, _addr = srv.accept()
        with conn:
            conn.sendall(b"Server Room B door reader. Present badge credential:\n")
            data = conn.recv(256).decode(errors="replace").strip()
            presented = data.replace("BADGE:", "")
            if presented == BADGE_ID:
                conn.sendall(f"ACCESS GRANTED\n{FLAG}\n".encode())
            else:
                conn.sendall(b"ACCESS DENIED\n")


if __name__ == "__main__":
    threading.Thread(target=badge_beacon, daemon=True).start()
    door_reader()
