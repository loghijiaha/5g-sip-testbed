#!/bin/bash
# Start Alice's baresip on VM
# Usage: ./scripts/start-alice.sh

EXTERNAL_IP=$(curl -s ifconfig.me)

# Kill anything on Alice's port
fuser -k 5090/udp 2>/dev/null
fuser -k 5090/tcp 2>/dev/null
killall baresip 2>/dev/null
sleep 1

mkdir -p configs/baresip/alice

cat > configs/baresip/alice/accounts << ACCOUNTS
sip:alice@${EXTERNAL_IP};regint=60;outbound="sip:${EXTERNAL_IP}:5060"
ACCOUNTS

echo "=== Alice's SIP account ==="
echo "  Server: ${EXTERNAL_IP}:5060"
echo "  User:   alice@${EXTERNAL_IP}"
echo "============================"
echo ""

baresip -f configs/baresip/alice
