# Kongka — Kong OSS + Kafka (KRaft) on NKP

Deploy Kong Gateway and Confluent Kafka (KRaft mode) on a Nutanix Kubernetes Platform cluster.

## Quick Start

```bash
# 1. Clone the repo
git clone <repo-url> kongka-install
cd kongka-install

# 2. Copy and edit config (or use defaults as-is for a POC)
cp config.env.example config.env
# Edit config.env if you need non-default values

# 3. Run the installer
./install.sh
```

That's it. The script handles everything: namespace creation, Helm repo registration, deployment, and health checks.

## Prerequisites

The machine running `install.sh` needs:
- `kubectl` configured and pointing at the target cluster
- `helm` 3.x
- Internet access (Docker Hub, Confluent registry, Helm repos)

## What Gets Deployed

| Component         | Namespace | Default |
|-------------------|-----------|---------|
| Kafka (KRaft)     | `kafka`   | 3 brokers |
| Control Center    | `kafka`   | Enabled |
| Schema Registry   | `kafka`   | Enabled |
| Kong Gateway      | `kong`    | KIC + DB-less |

## Configuration

All parameters live in `config.env`. See `config.env.example` for the full list with comments.

Key settings:
- `KAFKA_BROKER_COUNT` — number of Kafka brokers (min 3 for KRaft quorum)
- `KONG_MODE` — `ingress` (KIC) or `gateway` (standalone)
- `SERVICE_TYPE` — `LoadBalancer` or `NodePort`

## Re-running / Recovery

`install.sh` is idempotent — safe to re-run after a failure. Each step uses `helm upgrade --install` and `kubectl apply`.

## Post-Install

- **Control Center UI**: get the LoadBalancer IP from `kubectl get svc -n kafka`
- **Kong Proxy**: get the LoadBalancer IP from `kubectl get svc -n kong`
- Kong has no routes configured — dev team wires routes post-deploy

## Docs

- `docs/ARCHITECTURE.md` — namespace layout, port mapping, component diagram
- `docs/TROUBLESHOOTING.md` — common errors and fixes
