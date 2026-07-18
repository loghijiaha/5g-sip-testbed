#!/bin/bash
# Start Bob's baresip inside UE2 container (through 5G tunnel)
# Usage: ./scripts/start-bob-ue.sh

set -e

CONTAINER="ueransim-ue2"
EXTERNAL_IP=$(curl -s ifconfig.me)
echo "=== External IP: $EXTERNAL_IP ==="

# Wait for uesimtun0
echo "=== Waiting for 5G connection... ==="
for i in $(seq 1 30); do
    UE_IP=$(docker exec $CONTAINER ip -4 addr show uesimtun0 2>/dev/null | grep -oP 'inet \K[\d.]+')
    if [ -n "$UE_IP" ]; then
        echo "=== UE2 connected: $UE_IP ==="
        break
    fi
    sleep 2
done

if [ -z "$UE_IP" ]; then
    echo "ERROR: uesimtun0 not ready after 60s"
    exit 1
fi

# Add route through 5G tunnel
docker exec $CONTAINER ip route add $EXTERNAL_IP dev uesimtun0 2>/dev/null || true
echo "=== Route to $EXTERNAL_IP via uesimtun0 ==="

# Kill any existing baresip
docker exec $CONTAINER sh -c 'kill $(pidof baresip) 2>/dev/null' || true
sleep 1

# Copy config into container
docker exec $CONTAINER mkdir -p /root/.baresip
docker cp configs/baresip/bob/config $CONTAINER:/root/.baresip/config
docker cp configs/baresip/bob/tx.wav $CONTAINER:/tmp/tx.wav

# Write accounts with actual IP
docker exec $CONTAINER sh -c "echo 'sip:bob@${EXTERNAL_IP};regint=60;outbound=\"sip:${EXTERNAL_IP}:5060\"' > /root/.baresip/accounts"

# Create empty rx.wav placeholder
docker exec $CONTAINER touch /tmp/rx.wav

echo "=== Bob's config ==="
echo "  Account: sip:bob@${EXTERNAL_IP}"
echo "  Listen:  0.0.0.0:5080"
echo "  Network: uesimtun0 ($UE_IP)"
echo "=== Starting baresip... ==="

# Start baresip
docker exec -e HOME=/root -it $CONTAINER baresip -f /root/.baresip
