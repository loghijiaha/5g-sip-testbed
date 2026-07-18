# 5G SIP Testbed - Setup & Run Guide

## Architecture

```
Alice (Mac/Laptop) ──SIP/RTP──> Kamailio (VM) ──RTP──> RTPengine (Docker)
                                     │                        │
                                     └── SIP ──> Bob (UE2, Docker)
                                                   │
                                              uesimtun0 (5G tunnel)
                                                   │
                                         gNB ── UPF ── Internet
                                              (Open5GS 5G Core)
```

## Prerequisites

- GCP VM (Debian/Ubuntu) with Docker & Docker Compose
- Kamailio installed natively on VM (`apt install kamailio kamailio-rtpengine-modules`)
- baresip v4.9.0 on your Mac (`brew install baresip`)
- GCP firewall rules: allow UDP 5060, 30000-31000

## Quick Start

### 1. Start 5G Core + RTPengine (Docker)

```bash
docker compose -f docker-compose.vm.yml up -d
```

Wait ~30 seconds for all NFs to register and UEs to connect.

### 2. Verify 5G data plane

```bash
docker exec ueransim-ue2 ping -I uesimtun0 -c 3 8.8.8.8
```

### 3. Start Kamailio (VM native)

```bash
./scripts/kamailio.sh
```

### 4. Start Bob in UE2 (through 5G tunnel)

Open a new terminal:

```bash
./scripts/start-bob-ue.sh
```

Bob will register with Kamailio through the 5G data plane.

### 5. Start Alice (Mac)

On your Mac:

```bash
./scripts/start-alice.sh
```

Or manually:

```bash
baresip -f configs/baresip/alice
```

### 6. Make a call

From Alice's baresip console:

```
/dial sip:bob@<VM_EXTERNAL_IP>
```

Bob auto-answers. Audio flows through RTPengine.

## Verification

### Verify SIP through 5G

```bash
docker exec open5gs-upf tcpdump -i ogstun -n port 5060 -c 5
```

### Verify RTP through 5G

```bash
docker exec open5gs-upf tcpdump -i ogstun -n udp and not port 5060 -c 20
```

### View Kamailio logs

```bash
tail -f /tmp/kamailio.log
```

Or filter:

```bash
grep -E "REGISTER|INVITE|ACK|BYE|200" /tmp/kamailio.log
```

### View RTPengine logs

```bash
docker logs -f rtpengine
```

## Scripts

| Script | Purpose |
|--------|---------|
| `scripts/kamailio.sh` | Start Kamailio on VM |
| `scripts/start-bob-ue.sh` | Start Bob in UE2 through 5G |
| `scripts/start-alice.sh` | Start Alice on Mac |

## Troubleshooting

| Issue | Fix |
|-------|-----|
| UE2 no uesimtun0 | Wait longer or staged restart (see below) |
| RTPengine out of ports | `docker compose -f docker-compose.vm.yml restart rtpengine` |
| Kamailio can't reach RTPengine | Verify: `docker logs rtpengine --tail 3` |
| Bob not registering | Check route: `docker exec ueransim-ue2 ip route get <EXTERNAL_IP>` must show `dev uesimtun0` |
| SIP spam eating ports | Increase `--port-max` to 31000 in compose |

### Staged restart (if UEs fail to register with 5G core)

```bash
docker compose -f docker-compose.vm.yml down
docker compose -f docker-compose.vm.yml up -d mongodb
sleep 5
docker compose -f docker-compose.vm.yml up -d nrf
sleep 5
docker compose -f docker-compose.vm.yml up -d ausf udm udr pcf bsf nssf
sleep 5
docker compose -f docker-compose.vm.yml up -d amf smf
sleep 3
docker compose -f docker-compose.vm.yml up -d upf rtpengine webui
sleep 3
docker compose -f docker-compose.vm.yml up -d gnb
sleep 5
docker compose -f docker-compose.vm.yml up -d ue1 ue2
```

## Clean Reset

```bash
docker compose -f docker-compose.vm.yml down
sudo killall kamailio 2>/dev/null
docker system prune -a --volumes -f
```

## Key IPs

| Component | IP |
|-----------|-----|
| MongoDB | 10.10.0.2 |
| NRF | 10.10.0.10 |
| AMF | 10.10.0.11 |
| SMF | 10.10.0.12 |
| UPF | 10.10.0.13 |
| gNB | 10.10.0.20 |
| UE1 | 10.10.0.21 |
| UE2 | 10.10.0.22 |
| RTPengine | 10.10.0.30 |
| Kamailio | VM native (0.0.0.0:5060) |
| UE2 tunnel | 10.45.0.x (uesimtun0) |

