#!/bin/bash
sudo killall kamailio 2>/dev/null; sleep 1
EXTERNAL_IP=$(curl -s ifconfig.me)
echo "Kamailio external IP: $EXTERNAL_IP"
cp configs/kamailio/kamailio.cfg /tmp/kamailio-run.cfg
sed -i "s/EXTERNAL_IP/$EXTERNAL_IP/g" /tmp/kamailio-run.cfg
grep "advertise" /tmp/kamailio-run.cfg
sudo kamailio -f /tmp/kamailio-run.cfg -E > /tmp/kamailio.log 2>&1 &
sleep 2
tail -f /tmp/kamailio.log
