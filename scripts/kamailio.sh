sudo killall kamailio 2>/dev/null; sleep 1
sudo kamailio -f /etc/kamailio/kamailio.cfg -E > /tmp/kamailio.log 2>&1 &
tail -f /tmp/kamailio.log
