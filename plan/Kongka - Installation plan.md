# Kongka Stack — Kong OSS + Kafka (KRaft) on NKP

## Overview

Deploy a generic Kong + Kafka platform on a Nutanix Kubernetes Platform (NKP) cluster. Both components are standalone — no integration wiring at this stage. The install is designed to be executed via `git clone` + single script on a terminal with no clipboard access (remote Zoom session).

## Deployment Method

- Helm charts for both stacks
- Single entrypoint `install.sh` that reads `config.env` for all parameters
- Script must be **idempotent** — safe to re-run after failures
- All configurable values externalized to `config.env` with sane defaults
- Preflight checks before any install step

## Git Repo Structure

```
kongka-install/
├── README.md                  # Quick start instructions (git clone → edit config → run)
├── config.env.example         # Template with all parameters and comments
├── install.sh                 # Main entrypoint
├── scripts/
│   ├── preflight.sh           # Cluster validation checks
│   ├── install-kafka.sh       # Kafka KRaft deployment
│   ├── install-kong.sh        # Kong OSS deployment
│   └── verify.sh              # Post-install health checks
├── helm-values/
│   ├── kafka-kraft.yaml       # Confluent Kafka Helm values (KRaft mode)
│   ├── control-center.yaml    # Confluent Control Center Helm values
│   ├── schema-registry.yaml   # Schema Registry Helm values (optional, disabled by default)
│   └── kong.yaml              # Kong Helm values
└── docs/
    ├── TROUBLESHOOTING.md     # Common errors and fixes
    └── ARCHITECTURE.md        # Component diagram, port mapping, namespace layout
```

## Components

### Kafka — KRaft Mode (no ZooKeeper)

- **Image**: `confluentinc/cp-kafka:7.6.0`
- **Mode**: KRaft (Kafka Raft consensus, ZooKeeper-free)
- **Helm chart**: `confluentinc/cp-helm-charts` or CFK (Confluent for Kubernetes) — evaluate which supports KRaft better for 7.6.0
- **Topology**: Combined controller+broker roles (simplest for initial deploy, can separate later)
- **Replicas**: Configurable, default 3 (minimum for KRaft quorum)
- **Storage**: PVC via NKP default StorageClass
- **Config considerations**:
  - `process.roles=broker,controller`
  - `controller.quorum.voters` auto-generated from replica count
  - `cluster.id` generated once and persisted
  - Listeners: PLAINTEXT internal, configurable external access

### Control Center

- **Image**: `confluentinc/cp-enterprise-control-center:7.6.0`
- **Purpose**: Kafka management UI
- **Enabled by default**: yes
- **Access**: via LoadBalancer service
- **Note**: Control Center is enterprise licensed — confirm if customer has license or is using evaluation

### Schema Registry

- **Image**: `confluentinc/cp-schema-registry:7.6.0`
- **Enabled by default**: yes (confirmed as part of full stack)
- **Connects to**: Kafka bootstrap servers

### Kong OSS

- **Helm chart**: `kong/kong` (official)
- **Two mode options** (configurable):
  - `ingress` — deploys as Kong Ingress Controller (KIC), Kubernetes-native
  - `gateway` — deploys as standalone Kong Gateway
- **DB mode**: DB-less by default (declarative config), Postgres optional
- **Default**: KIC + DB-less (lightest footprint, most NKP-native)
- **No routes/services configured** — generic platform ready for later wiring

## config.env Parameters

```bash
# Namespaces
KAFKA_NAMESPACE=kafka
KONG_NAMESPACE=kong

# Kafka KRaft
KAFKA_BROKER_COUNT=3
KAFKA_IMAGE=confluentinc/cp-kafka:7.6.0
KAFKA_STORAGE_CLASS=default
KAFKA_STORAGE_SIZE=50Gi
KAFKA_CPU_REQUEST=1
KAFKA_CPU_LIMIT=2
KAFKA_MEM_REQUEST=4Gi
KAFKA_MEM_LIMIT=8Gi

# Control Center
CC_ENABLED=true
CC_IMAGE=confluentinc/cp-enterprise-control-center:7.6.0
CC_STORAGE_SIZE=10Gi

# Schema Registry
SR_ENABLED=true
SR_IMAGE=confluentinc/cp-schema-registry:7.6.0

# Kong
KONG_MODE=ingress          # ingress | gateway
KONG_DB_MODE=dbless        # dbless | postgres

# Ingress/Access
SERVICE_TYPE=LoadBalancer   # LoadBalancer | NodePort
```

## install.sh Behavior

1. **Load config** — source `config.env`, fail if missing required values (e.g., `KAFKA_STORAGE_CLASS`)
2. **Preflight checks** (`scripts/preflight.sh`):
   - `kubectl` connectivity and correct context
   - `helm` 3.x available
   - StorageClass exists on cluster
   - Sufficient node resources (warn if below recommended)
   - Internet access (can reach Helm repos and container registries)
3. **Create namespaces** — idempotent via `kubectl apply`
4. **Add Helm repos** — confluent + kong
5. **Install Kafka** (`scripts/install-kafka.sh`):
   - Render `helm-values/kafka-kraft.yaml` with config values
   - `helm upgrade --install` into kafka namespace
   - Wait for broker pods ready
6. **Install Control Center** (if CC_ENABLED):
   - Point to Kafka bootstrap servers
   - `helm upgrade --install` or deploy as part of same chart
7. **Install Schema Registry** (if SR_ENABLED):
   - Point to Kafka bootstrap servers
   - `helm upgrade --install`
8. **Install Kong** (`scripts/install-kong.sh`):
   - Render `helm-values/kong.yaml` with config values
   - `helm upgrade --install` into kong namespace
   - Wait for kong pods ready
9. **Verify** (`scripts/verify.sh`):
   - All pods running
   - Kafka cluster metadata shows correct broker count
   - Control Center UI reachable
   - Kong proxy responding

## Confirmed

- [x] NKP StorageClass — use `default`
- [x] Worker node resources — POC setup, assumed sufficient
- [x] Schema Registry — yes, full Confluent stack
- [x] Ingress strategy — LoadBalancer services for Control Center and Kong
- [x] Control Center licensing — evaluation mode for POC
- [x] Container registry — direct internet access, pull from Docker Hub / Confluent registry
- [x] Kong's role — install only, dev team will configure post-deploy
- [x] TLS — plaintext for POC, may revisit later

## Sonnet Implementation Notes

- **Portability**: Script must work on any Kubernetes cluster with zero config changes for the common case (default StorageClass, internet access, sufficient resources). `config.env` is optional — all defaults should produce a working POC deploy out of the box.
- Use `helm upgrade --install` everywhere for idempotency
- Use `kubectl rollout status` for wait logic with configurable timeout
- All `echo` output should be prefixed with step name for easy screenshot debugging
- Exit on first error (`set -euo pipefail`) but trap to show which step failed
- The customer will be typing `git clone` + `./install.sh` manually — keep the README dead simple
- Helm values files should have inline comments explaining each setting
- KRaft cluster.id generation: use `kafka-storage random-uuid` or pre-generate and store in config
