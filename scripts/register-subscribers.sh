#!/bin/bash
echo "Waiting for MongoDB to be ready..."
for i in $(seq 1 30); do
    mongosh mongodb://10.10.0.2/open5gs --quiet --eval "db.runCommand('ping').ok" > /dev/null 2>&1 && break
    echo "  MongoDB not ready, retrying ($i/30)..."
    sleep 2
done

echo "Registering subscribers..."
mongosh mongodb://10.10.0.2/open5gs --quiet --eval '
db.subscribers.updateOne({imsi:"999700000000001"},{$set:{imsi:"999700000000001",security:{k:"465B5CE8B199B49FAA5F0A2EE238A6BC",amf:"8000",op:null,opc:"E8ED289DEBA952E4283B54E88E6183CA"},ambr:{downlink:{value:1,unit:3},uplink:{value:1,unit:3}},slice:[{sst:1,default_indicator:true,session:[{name:"internet",type:3,ambr:{downlink:{value:1,unit:3},uplink:{value:1,unit:3}},qos:{index:9,arp:{priority_level:8,pre_emption_capability:1,pre_emption_vulnerability:1}}}]}]}},{upsert:true});
db.subscribers.updateOne({imsi:"999700000000002"},{$set:{imsi:"999700000000002",security:{k:"465B5CE8B199B49FAA5F0A2EE238A6BC",amf:"8000",op:null,opc:"E8ED289DEBA952E4283B54E88E6183CA"},ambr:{downlink:{value:1,unit:3},uplink:{value:1,unit:3}},slice:[{sst:1,default_indicator:true,session:[{name:"internet",type:3,ambr:{downlink:{value:1,unit:3},uplink:{value:1,unit:3}},qos:{index:9,arp:{priority_level:8,pre_emption_capability:1,pre_emption_vulnerability:1}}}]}]}},{upsert:true});
print("Subscribers registered.");
'
