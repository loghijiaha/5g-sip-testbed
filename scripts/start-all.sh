#!/bin/bash
set -e
cd "$(dirname "$0")/.."

echo "🚀 Starting 5G Testbed..."
echo ""

# Step 1: Build images
echo "📦 Building Docker images (first time takes ~15 min)..."
docker compose build

# Step 2: Start core infra
echo ""
echo "🗄️  Starting MongoDB..."
docker compose up -d mongodb
sleep 3

echo "📡 Starting NRF..."
docker compose up -d nrf
sleep 2

echo "🔐 Starting AUSF, UDM, UDR, PCF, BSF..."
docker compose up -d ausf udm udr pcf bsf
sleep 3

echo "🧠 Starting AMF, SMF, UPF..."
docker compose up -d amf smf upf
sleep 5

echo "🌐 Starting WebUI..."
docker compose up -d webui

# Step 3: Register subscribers
echo ""
echo "📝 Registering subscribers..."
./scripts/register-subscribers.sh

# Step 4: Start RAN
echo ""
echo "📡 Starting gNB..."
docker compose up -d gnb
sleep 3

echo "📱 Starting UE1 and UE2..."
docker compose up -d ue1 ue2
sleep 8

# Step 5: Start RTPengine
echo ""
echo "🎵 Starting RTPengine..."
docker compose up -d rtpengine
sleep 2

# Step 6: Verify
echo ""
echo "═══════════════════════════════════════"
echo "🔍 VERIFICATION"
echo "═══════════════════════════════════════"
echo ""

echo "📱 UE1 tunnel:"
docker exec ueransim-ue1 ip addr show uesimtun0 2>/dev/null | grep "inet " || echo "  ❌ UE1 not attached yet (wait a few seconds and re-check)"

echo ""
echo "📱 UE2 tunnel:"
docker exec ueransim-ue2 ip addr show uesimtun0 2>/dev/null | grep "inet " || echo "  ❌ UE2 not attached yet (wait a few seconds and re-check)"

echo ""
echo "🔗 RTPengine port check:"
docker port rtpengine 22222/udp 2>/dev/null && echo "  ✅ RTPengine reachable at 127.0.0.1:22222" || echo "  ❌ RTPengine port not mapped"

echo ""
echo "═══════════════════════════════════════"
echo "✅ Docker setup complete!"
echo ""
echo "Next steps (run in separate terminals on macOS):"
echo ""
echo "  Terminal 1: Start Kamailio"
echo "    sudo kamailio -f $(pwd)/configs/kamailio/kamailio.cfg -E -dd"
echo ""
echo "  Terminal 2: Start Baresip (Alice)"
echo "    baresip -f $(pwd)/configs/baresip/alice"
echo ""
echo "  Terminal 3: Start Baresip (Bob)"
echo "    baresip -f $(pwd)/configs/baresip/bob"
echo ""
echo "  Then in Alice's terminal:"
echo "    d sip:bob@127.0.0.1"
echo ""
echo "  In Bob's terminal:"
echo "    a"
echo ""
echo "═══════════════════════════════════════"
