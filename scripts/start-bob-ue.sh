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
docker exec $CONTAINER pkill -f baresip 2>/dev/null || true
sleep 1

# Write baresip config
docker exec $CONTAINER bash -c "
mkdir -p /root/.baresip

cat > /root/.baresip/accounts << EOF
sip:bob@${EXTERNAL_IP};regint=60;outbound=\"sip:${EXTERNAL_IP}:5060\"
EOF

cat > /root/.baresip/config << EOF
# SIP
sip_listen 0.0.0.0:5080
sip_tos 160

# Call
call_local_timeout 120
call_max_calls 4

# Audio
ausrc_format s16
auplay_format s16
auenc_format s16
audec_format s16
audio_buffer 20-160
audio_buffer_mode fixed
audio_telev_pt 101

# Network - force through 5G tunnel
net_interface uesimtun0

# RTP
rtp_tos 184

# Modules
module_path /usr/lib/baresip/modules
module g711.so
EOF
"

echo "=== Bob's config written ==="
echo "  Account: sip:bob@${EXTERNAL_IP}"
echo "  Listen:  0.0.0.0:5080"
echo "  Network: uesimtun0 ($UE_IP)"
echo "=== Starting baresip... ==="
echo ""
echo "  Once ready, type: /uanew sip:bob@${EXTERNAL_IP};regint=60;outbound=\"sip:${EXTERNAL_IP}:5060\""
echo ""

# Start baresip
docker exec -e HOME=/root -it $CONTAINER baresip -f /root/.baresip
