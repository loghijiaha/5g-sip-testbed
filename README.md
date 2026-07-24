# 5G SIP Testbed - Setup & Run Guide

<video src="https://github.com/user-attachments/assets/e48444c1-8d6a-4a3b-b9a6-49b944a808d9" width="720" autoplay loop muted playsinline>
</video>

## Architecture

```
Alice (VM native) ──SIP──> Kamailio (VM native) ──SIP──> Bob (UE2, Docker)
       │                         │                          │
       │                    RTPengine                   uesimtun0
       │                         │                          │
       └────── RTP ──────────────┘──── RTP ─────── 5G tunnel (gNB → UPF)
                                                          │
                                                   Open5GS 5G Core
```

## Prerequisites

- GCP VM (Debian/Ubuntu) with Docker & Docker Compose
- Kamailio installed natively on VM (`sudo apt install kamailio kamailio-mysql-modules`)
- RTPengine installed natively on VM (`sudo apt install rtpengine`)
- baresip v4.9.0 on your Linux/Mac (`sudo apt install baresip / brew install baresip`)
- GCP firewall rules: allow UDP 5060, 30000-31000

## Quick Start

### 1. Start 5G Core

```bash
docker compose -f docker-compose.vm.yml up
```


Wait ~30 seconds for all NFs to register and UEs to connect.

### 2. Verify 5G data plane

```bash
docker exec ueransim-ue2 ping -I uesimtun0 -c 3 8.8.8.8
```

### 3. Start RTPengine (VM native)
```bash
./scripts/start-rtpengine.sh
```

### 4. Start Kamailio (VM native)

```bash
./scripts/kamailio.sh
```

### 5. Start Bob in UE2 (through 5G tunnel)

Open a new terminal:

```bash
./scripts/start-bob-ue.sh
```

Bob will register with Kamailio through the 5G data plane.

### 6. Start Alice (VM native)

On your Mac:

```bash
./scripts/start-alice.sh
```

Or manually:

```bash
baresip -f configs/baresip/alice
```

### 7. Make a call

From Alice's baresip console:

```
/dial sip:bob@<VM_EXTERNAL_IP>
```

Bob answers. Audio flows through RTPengine.


## Clean Reset

```bash
docker compose -f docker-compose.vm.yml down
sudo killall kamailio 2>/dev/null
sudo killall rtpengine 2>/dev/null
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
| Kamailio | VM native (0.0.0.0:5060) |
| UE2 tunnel | 10.45.0.x (uesimtun0) |

