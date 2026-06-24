#!/usr/bin/env bash
# run-multi.sh — Start multiple weeks + shared Kali attacker
# Usage: ./run-multi.sh week1 week3 week4
# The Kali container (kali-multi) is connected to every requested week network.

set -e

declare -A WEEK_NETWORKS=(
    [week1]="week1_custom_network"
    [week3]="week3_traffic_net"
    [week4]="week4_week4-scannet"
    [week5]="week5_week5-enumnet"
    [week6]="week6_week6-labnet"
    [week7]="week7_security_net"
    [week8]="week8_lab_network"
    [week9]="week9_week9-external"
    [week10]="week10_week10-exploitnet"
)

WEEKS=("$@")
if [ ${#WEEKS[@]} -eq 0 ]; then
    echo "Usage: $0 week1 week3 [week4 ...]"
    exit 1
fi

# Start each week stack
for week in "${WEEKS[@]}"; do
    echo "▶  Starting $week..."
    (cd "labs/$week" && docker compose up -d)
done

# Remove old kali-multi if it exists
docker rm -f kali-multi 2>/dev/null || true

# Start Kali on the first week network
FIRST=${WEEKS[0]}
FIRST_NET="${WEEK_NETWORKS[$FIRST]}"
echo ""
echo "▶  Starting Kali attacker on $FIRST_NET..."
docker run -d --rm \
    --name kali-multi \
    --hostname kali \
    --network "$FIRST_NET" \
    --cap-add=NET_RAW \
    --cap-add=NET_ADMIN \
    ethical-base tail -f /dev/null

# Connect Kali to remaining week networks
for week in "${WEEKS[@]:1}"; do
    NET="${WEEK_NETWORKS[$week]}"
    echo "▶  Connecting Kali to $NET..."
    docker network connect "$NET" kali-multi
done

echo ""
echo "✓  All started. Enter Kali with:"
echo "     docker exec -it kali-multi bash"
echo ""
echo "Networks available inside Kali:"
for week in "${WEEKS[@]}"; do
    echo "     $week — ${WEEK_NETWORKS[$week]}"
done
