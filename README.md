# Kongka — Kong OSS + Kafka (KRaft) on NKP

Deploy Kong Gateway and Confluent Kafka in true **KRaft mode (no ZooKeeper)** on a Nutanix Kubernetes Platform cluster.

## Quick Start

```bash
# 1. Clone the repo
git clone <repo-url> kongka-install
cd kongka-install

# 2. Add your kubeconfig to auth/
cp /path/to/kubeconfig auth/workload01.conf

# 3. Run the installer — setup wizard runs automatically on first install
./install.sh
```

The setup wizard probes the cluster (nodes, storage classes, LoadBalancer support) and prompts for any settings that need cluster-specific values. All answers are written to `config.env`. Re-run the wizard any time:

```bash
./install.sh --reconfigure
```

Or skip the wizard by copying and editing the example config manually:

```bash
cp config.env.example config.env
# edit config.env
./install.sh
```

## Prerequisites

The machine running `install.sh` needs:
- `kubectl` configured and pointing at the target cluster (or a kubeconfig file in `auth/`)
- `helm` 3.x
- `python3` (for KRaft cluster ID generation — available on all modern Linux)
- Internet access (Docker Hub, Confluent registry, Helm repos)

## What Gets Deployed

| Component         | Namespace | Default    | Image                                        |
|-------------------|-----------|------------|----------------------------------------------|
| Kafka (KRaft)     | `kafka`   | 3 brokers  | `confluentinc/cp-server:7.6.0`               |
| Schema Registry   | `kafka`   | Enabled    | `confluentinc/cp-schema-registry:7.6.0`      |
| Control Center    | `kafka`   | Enabled    | `confluentinc/cp-enterprise-control-center:7.6.0` |
| Kong Gateway      | `kong`    | KIC+DBless | `kong/kong` (via kong/kong Helm chart)       |

Kafka runs as a **local Helm chart** (`charts/kafka-kraft/`) — no third-party chart dependency.
Kong runs from the official `kong/kong` Helm chart.

## Configuration

All parameters live in `config.env`. See `config.env.example` for the full list with comments.

Key settings:

| Variable             | Default              | Description                                       |
|----------------------|----------------------|---------------------------------------------------|
| `KAFKA_BROKER_COUNT` | `3`                  | Number of brokers (min 3 for KRaft quorum)        |
| `KAFKA_STORAGE_CLASS`| `default`            | StorageClass for PVCs — auto-detected by wizard   |
| `KAFKA_CLUSTER_ID`   | *(auto-generated)*   | 22-char base64url UUID, saved to `.kafka-cluster-id` |
| `KONG_MODE`          | `ingress`            | `ingress` (KIC) or `gateway` (standalone)         |
| `KONG_DB_MODE`       | `dbless`             | `dbless` or `postgres`                            |
| `SERVICE_TYPE`       | `LoadBalancer`       | `LoadBalancer` or `NodePort`                      |
| `ROLLOUT_TIMEOUT`    | `300`                | Seconds to wait for pod readiness                 |

## Common Re-run Scenarios

```bash
# Full reinstall (preflight → kafka → kong → verify)
./install.sh

# Skip preflight checks on a known-good cluster
./install.sh --skip-preflight

# Reinstall only the Kafka stack (preserves Kong)
./install.sh --kafka-only

# Reinstall only Kong (preserves Kafka)
./install.sh --kong-only

# Re-run the setup wizard to update config
./install.sh --reconfigure
```

## Post-Install

```bash
# Control Center UI (Kafka management)
kubectl get svc -n kafka kafka-cc-lb
# → open http://<EXTERNAL-IP>:9021

# Kong proxy address
kubectl get svc -n kong kong-kong-proxy
# → http://<EXTERNAL-IP> (returns 404 until routes are configured — that's healthy)

# Verify the full stack
source config.env && export $(cut -d= -f1 config.env | grep -v '#') && bash scripts/verify.sh
```

Kong has no routes configured at install time — the dev team wires routes post-deploy via the Admin API or KongRoute CRDs.

## Upgrading from ZooKeeper (cp-helm-charts) to KRaft

If you have an existing `kafka` release based on `confluentinc/cp-helm-charts`, the installer
detects it automatically and migrates:

1. Detects the old ZooKeeper-based Helm release
2. Runs `helm uninstall` to remove it
3. Deletes all PVCs in the kafka namespace (ZK-formatted storage is incompatible with KRaft)
4. Installs the new KRaft chart

**This is a destructive migration — all existing Kafka data is lost.** Back up any data before running.

## Diagnostics

If something goes wrong, run the diagnostic collector:

```bash
bash scripts/diag.sh
```

This captures the full cluster state — all pod statuses, logs (including init container
and previous crash logs), PVC/service status, KRaft quorum health, Helm values, and events
— into a single timestamped file (`diag-<timestamp>.txt`).

Paste that file to Claude with a description of the issue. Claude can diagnose and produce
a targeted fix without needing cluster access.

## Docs

- `docs/ARCHITECTURE.md` — namespace layout, resource names, port reference
- `docs/TROUBLESHOOTING.md` — common errors and fixes
- `config.env.example` — annotated reference for all config variables
