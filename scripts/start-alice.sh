#!/bin/bash
# Start Alice's baresip SIP client
# Usage: ./scripts/start-alice.sh

EXTERNAL_IP=35.231.170.222

mkdir -p configs/baresip/alice

cat > configs/baresip/alice/accounts << EOF
sip:alice@${EXTERNAL_IP};regint=60;outbound="sip:${EXTERNAL_IP}:5060"
EOF

echo "=== Alice's SIP account ==="
echo "  Server: ${EXTERNAL_IP}:5060"
echo "  User:   alice@${EXTERNAL_IP}"
echo "============================"
echo ""

baresip -f configs/baresip/alice
