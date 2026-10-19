#!/usr/bin/env python3
"""
Week 11 simulation: a minimal DuckyScript -> keystrokes translator.

A real BadUSB/Rubber Ducky device enumerates as a USB keyboard and types
a payload faster than a human ever could, into whatever is already logged
in and unlocked - it doesn't bypass any login, it automates what you'd
type if you had physical access to an unlocked machine. This script
reproduces that translation step (script -> literal keystrokes) without
needing real USB HID hardware: feed it a tiny DuckyScript-style payload,
pipe the output into the simulated workstation's exposed shell
(week11-workstation:4444), and it executes exactly as if it had been
typed live.

Supported commands (deliberately a small, real subset of DuckyScript):
  REM <text>        comment, ignored
  STRING <text>      typed literally, followed by newline when ENTER follows
  ENTER               presses Enter (emits a newline)
  DELAY <ms>          pause - ignored here (network pipe has no visible delay,
                       but kept so payloads read like real DuckyScript)

Usage:
  python3 duckify.py payload.txt > payload.sh
  nc week11-workstation 4444 < payload.sh
"""
import sys


def translate(lines):
    out = []
    for raw in lines:
        line = raw.rstrip("\n")
        if not line.strip() or line.strip().upper().startswith("REM"):
            continue
        if line.strip().upper() == "ENTER":
            out.append("\n")
        elif line.strip().upper().startswith("DELAY"):
            continue  # no-op over a network pipe; kept for script realism
        elif line.strip().upper().startswith("STRING "):
            out.append(line.split(" ", 1)[1])
        else:
            sys.stderr.write(f"[duckify] skipping unrecognised line: {line!r}\n")
    return "".join(out)


if __name__ == "__main__":
    if len(sys.argv) != 2:
        sys.stderr.write("usage: duckify.py <payload.txt>\n")
        sys.exit(1)
    with open(sys.argv[1]) as f:
        sys.stdout.write(translate(f.readlines()))
