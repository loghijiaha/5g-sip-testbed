#!/bin/bash
# Start RTPengine natively on VM (userspace mode)

INTERFACE="10.10.0.1"
NG_PORT="127.0.0.1:22222"
PORT_MIN=30000
PORT_MAX=31000
LOG_LEVEL=7

# Kill any existing RTPengine process
if pgrep -x rtpengine > /dev/null; then
    echo "[*] Stopping existing RTPengine..."
    sudo killall -9 rtpengine
    sleep 1
fi

echo "[*] Starting RTPengine..."
echo "    Interface:  $INTERFACE"
echo "    NG listen:  $NG_PORT"
echo "    RTP ports:  $PORT_MIN - $PORT_MAX"
echo "    Log level:  $LOG_LEVEL"
echo ""

sudo rtpengine --foreground \
    --interface=$INTERFACE \
    --listen-ng=$NG_PORT \
    --port-min=$PORT_MIN \
    --port-max=$PORT_MAX \
    --log-level=$LOG_LEVEL \
    --log-stderr \
    --no-cli \
    --table=-1
