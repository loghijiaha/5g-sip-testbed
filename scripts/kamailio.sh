#!/bin/bash
sudo killall kamailio 2>/dev/null; sleep 1
sudo kamailio -f configs/kamailio/kamailio.cfg -E > /tmp/kamailio.log 2>&1 &
tail -f /tmp/kamailio.log
