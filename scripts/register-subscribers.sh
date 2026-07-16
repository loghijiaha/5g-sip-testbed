#!/bin/bash
echo "⏳ Registering subscribers..."

docker exec mongodb mongosh open5gs --quiet --eval '
db.subscribers.insertMany([
  {
    "imsi": "999700000000001",
    "security": {
      "k": "465B5CE8B199B49FAA5F0A2EE238A6BC",
      "amf": "8000",
      "op": null,
      "opc": "E8ED289DEBA952E4283B54E88E6183CA"
    },
    "ambr": {"downlink": {"value": 1, "unit": 3}, "uplink": {"value": 1, "unit": 3}},
    "slice": [{"sst": 1, "default_indicator": true, "session": [{"name": "internet", "type": 3, "ambr": {"downlink": {"value": 1, "unit": 3}, "uplink": {"value": 1, "unit": 3}}, "qos": {"index": 9, "arp": {"priority_level": 8, "pre_emption_capability": 1, "pre_emption_vulnerability": 1}}}]}]
  },
  {
    "imsi": "999700000000002",
    "security": {
      "k": "465B5CE8B199B49FAA5F0A2EE238A6BC",
      "amf": "8000",
      "op": null,
      "opc": "E8ED289DEBA952E4283B54E88E6183CA"
    },
    "ambr": {"downlink": {"value": 1, "unit": 3}, "uplink": {"value": 1, "unit": 3}},
    "slice": [{"sst": 1, "default_indicator": true, "session": [{"name": "internet", "type": 3, "ambr": {"downlink": {"value": 1, "unit": 3}, "uplink": {"value": 1, "unit": 3}}, "qos": {"index": 9, "arp": {"priority_level": 8, "pre_emption_capability": 1, "pre_emption_vulnerability": 1}}}]}]
  }
])'

echo "✅ Two subscribers registered!"
