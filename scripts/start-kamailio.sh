#!/bin/bash
EXTERNAL_IP=$(curl -s ifconfig.me)
INTERNAL_IP=$(hostname -I | awk '{print $1}')

echo "Internal IP: $INTERNAL_IP"
echo "External IP: $EXTERNAL_IP"

# Replace placeholders in config
sudo cp configs/kamailio/kamailio.cfg /etc/kamailio/kamailio.cfg
sudo sed -i "s/EXTERNAL_IP/$EXTERNAL_IP/g" /etc/kamailio/kamailio.cfg
sudo sed -i "s/INTERNAL_IP/$INTERNAL_IP/g" /etc/kamailio/kamailio.cfg

echo "Starting Kamailio..."
sudo killall kamailio 2>/dev/null; sleep 1
sudo kamailio -f /etc/kamailio/kamailio.cfg -E > /tmp/kamailio.log 2>&1 &
tail -f /tmp/kamailio.log
