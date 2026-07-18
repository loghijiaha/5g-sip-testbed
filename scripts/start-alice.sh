#!/bin/bash
# Start Alice's baresip on VM
# Usage: ./scripts/start-alice.sh

EXTERNAL_IP=$(curl -s ifconfig.me)

mkdir -p configs/baresip/alice

cat > configs/baresip/alice/accounts << ACCOUNTS
sip:alice@${EXTERNAL_IP};regint=60;outbound="sip:${EXTERNAL_IP}:5030"
ACCOUNTS

echo "=== Alice's SIP account ==="
echo "  Server: ${EXTERNAL_IP}:5030"
echo "  User:   alice@${EXTERNAL_IP}"
echo "============================"
echo ""

baresip -f configs/baresip/alice
