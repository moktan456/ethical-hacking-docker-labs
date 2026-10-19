#!/usr/bin/env python3
"""
Week 11 simulation: a keypad-controlled door.

Models two real weaknesses from the slides in a way students can actually
exploit over the network:
  1. "Lack of monitoring" -> a facilities maintenance note is exposed with
     no authentication at all (GET /maintenance-note), and it names which
     keys show visible wear - exactly the physical clue in Worksheet Task 3.
  2. "No lockout on failed attempts" (toggleable) -> with LOCKOUT_ENABLED=0
     (the default), nothing stops an unlimited brute force; with it set to
     1, repeated failures from the same client start getting throttled,
     giving a concrete before/after demo of that mitigation.

Deliberately stdlib-only (http.server) so the image needs no pip install.
"""
import json
import os
import time
from collections import defaultdict
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

PIN = os.environ.get("KEYPAD_PIN", "1531")
LOCKOUT_ENABLED = os.environ.get("LOCKOUT_ENABLED", "0") == "1"
LOCKOUT_THRESHOLD = 5
LOCKOUT_SECONDS = 20
FLAG = "flag{w11_keypad_worn_keys_cracked}"

MAINTENANCE_NOTE = (
    "Facilities maintenance log - Server Room B keypad\n"
    "------------------------------------------------\n"
    "Cleaned the keypad today. Visible finger-oil wear on buttons 1, 3 and "
    "5 - heavier use than the rest of the pad, 5 looks the worst. "
    "Recommend replacing with a unit that doesn't show wear patterns, or "
    "at minimum rotating the PIN more often. Logged for the facilities "
    "team, not security - please action when convenient.\n"
)

failures = defaultdict(list)


def locked_out(client_ip: str) -> bool:
    if not LOCKOUT_ENABLED:
        return False
    now = time.time()
    failures[client_ip] = [t for t in failures[client_ip] if now - t < LOCKOUT_SECONDS]
    return len(failures[client_ip]) >= LOCKOUT_THRESHOLD


class Handler(BaseHTTPRequestHandler):
    server_version = "KeypadDoor/1.0"

    def log_message(self, fmt, *args):
        pass  # keep container logs quiet; nothing sensitive leaks either way

    def _send(self, code, payload):
        body = json.dumps(payload).encode()
        self.send_response(code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        if self.path == "/maintenance-note":
            body = MAINTENANCE_NOTE.encode()
            self.send_response(200)
            self.send_header("Content-Type", "text/plain")
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)
        else:
            self._send(404, {"error": "not found. try GET /maintenance-note or POST /unlock"})

    def do_POST(self):
        if self.path != "/unlock":
            self._send(404, {"error": "not found"})
            return

        client_ip = self.client_address[0]
        if locked_out(client_ip):
            self._send(429, {"error": "keypad locked - too many failed attempts, try again shortly"})
            return

        length = int(self.headers.get("Content-Length", 0))
        raw = self.rfile.read(length) if length else b"{}"
        try:
            data = json.loads(raw)
            pin = str(data.get("pin", ""))
        except json.JSONDecodeError:
            self._send(400, {"error": "send JSON like {\"pin\": \"1234\"}"})
            return

        if pin == PIN:
            failures[client_ip].clear()
            self._send(200, {"result": "ACCESS GRANTED", "flag": FLAG})
        else:
            failures[client_ip].append(time.time())
            # Always 200, not 403: a brute-force script shouldn't need to
            # special-case HTTP error handling just to tell "wrong PIN"
            # apart from "network problem" - that's not the lesson here.
            self._send(200, {"result": "ACCESS DENIED"})


if __name__ == "__main__":
    print(f"[keypad] listening on :8080 (lockout={'on' if LOCKOUT_ENABLED else 'off'})", flush=True)
    ThreadingHTTPServer(("0.0.0.0", 8080), Handler).serve_forever()
