#!/usr/bin/env bash
# stop-multi.sh — Stop the multi-week lab and Kali attacker
# Usage: ./stop-multi.sh week1 week3 [week4 ...]

docker rm -f kali-multi 2>/dev/null || true
for week in "$@"; do
    echo "▶  Stopping $week..."
    (cd "labs/$week" && docker compose down)
done
echo "✓  Done."
