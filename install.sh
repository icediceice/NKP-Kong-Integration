#!/usr/bin/env bash
# =============================================================================
# Kongka Stack — Main installer
# Usage: ./install.sh [--skip-preflight] [--kafka-only] [--kong-only]
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Trap to surface which step failed
trap 'echo "[install.sh] ERROR: install failed at line $LINENO. Check output above." >&2' ERR

# -----------------------------------------------------------------------------
# Flags
# -----------------------------------------------------------------------------
SKIP_PREFLIGHT=false
KAFKA_ONLY=false
KONG_ONLY=false

for arg in "$@"; do
  case "$arg" in
    --skip-preflight) SKIP_PREFLIGHT=true ;;
    --kafka-only)     KAFKA_ONLY=true ;;
    --kong-only)      KONG_ONLY=true ;;
    *) echo "[install.sh] Unknown argument: $arg" >&2; exit 1 ;;
  esac
done

# -----------------------------------------------------------------------------
# Load config
# -----------------------------------------------------------------------------
CONFIG_FILE="${SCRIPT_DIR}/config.env"

if [[ -f "$CONFIG_FILE" ]]; then
  echo "[install.sh] Loading config from $CONFIG_FILE"
  # shellcheck source=/dev/null
  source "$CONFIG_FILE"
else
  echo "[install.sh] No config.env found — using built-in defaults"
fi

# Apply defaults for any unset variables
KAFKA_NAMESPACE="${KAFKA_NAMESPACE:-kafka}"
KONG_NAMESPACE="${KONG_NAMESPACE:-kong}"
KAFKA_BROKER_COUNT="${KAFKA_BROKER_COUNT:-3}"
KAFKA_IMAGE="${KAFKA_IMAGE:-confluentinc/cp-kafka:7.6.0}"
KAFKA_STORAGE_CLASS="${KAFKA_STORAGE_CLASS:-default}"
KAFKA_STORAGE_SIZE="${KAFKA_STORAGE_SIZE:-50Gi}"
KAFKA_CPU_REQUEST="${KAFKA_CPU_REQUEST:-1}"
KAFKA_CPU_LIMIT="${KAFKA_CPU_LIMIT:-2}"
KAFKA_MEM_REQUEST="${KAFKA_MEM_REQUEST:-4Gi}"
KAFKA_MEM_LIMIT="${KAFKA_MEM_LIMIT:-8Gi}"
KAFKA_CLUSTER_ID="${KAFKA_CLUSTER_ID:-}"
KAFKA_RELEASE_NAME="${KAFKA_RELEASE_NAME:-kafka}"
KAFKA_CHART_VERSION="${KAFKA_CHART_VERSION:-}"
CC_ENABLED="${CC_ENABLED:-true}"
CC_IMAGE="${CC_IMAGE:-confluentinc/cp-enterprise-control-center:7.6.0}"
CC_STORAGE_SIZE="${CC_STORAGE_SIZE:-10Gi}"
CC_RELEASE_NAME="${CC_RELEASE_NAME:-control-center}"
SR_ENABLED="${SR_ENABLED:-true}"
SR_IMAGE="${SR_IMAGE:-confluentinc/cp-schema-registry:7.6.0}"
SR_RELEASE_NAME="${SR_RELEASE_NAME:-schema-registry}"
KONG_MODE="${KONG_MODE:-ingress}"
KONG_DB_MODE="${KONG_DB_MODE:-dbless}"
KONG_RELEASE_NAME="${KONG_RELEASE_NAME:-kong}"
KONG_CHART_VERSION="${KONG_CHART_VERSION:-}"
SERVICE_TYPE="${SERVICE_TYPE:-LoadBalancer}"
ROLLOUT_TIMEOUT="${ROLLOUT_TIMEOUT:-300}"

export KAFKA_NAMESPACE KONG_NAMESPACE KAFKA_BROKER_COUNT KAFKA_IMAGE
export KAFKA_STORAGE_CLASS KAFKA_STORAGE_SIZE KAFKA_CPU_REQUEST KAFKA_CPU_LIMIT
export KAFKA_MEM_REQUEST KAFKA_MEM_LIMIT KAFKA_CLUSTER_ID KAFKA_RELEASE_NAME
export KAFKA_CHART_VERSION CC_ENABLED CC_IMAGE CC_STORAGE_SIZE CC_RELEASE_NAME
export SR_ENABLED SR_IMAGE SR_RELEASE_NAME KONG_MODE KONG_DB_MODE
export KONG_RELEASE_NAME KONG_CHART_VERSION SERVICE_TYPE ROLLOUT_TIMEOUT
export SCRIPT_DIR

# -----------------------------------------------------------------------------
# Preflight
# -----------------------------------------------------------------------------
if [[ "$SKIP_PREFLIGHT" == "false" ]]; then
  echo "[install.sh] Running preflight checks..."
  bash "${SCRIPT_DIR}/scripts/preflight.sh"
  echo "[install.sh] Preflight passed."
fi

# -----------------------------------------------------------------------------
# Create namespaces (idempotent)
# -----------------------------------------------------------------------------
echo "[install.sh] Creating namespaces..."
kubectl create namespace "$KAFKA_NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace "$KONG_NAMESPACE"  --dry-run=client -o yaml | kubectl apply -f -

# -----------------------------------------------------------------------------
# Add Helm repos
# -----------------------------------------------------------------------------
echo "[install.sh] Adding Helm repositories..."
helm repo add confluentinc https://confluentinc.github.io/cp-helm-charts/ 2>/dev/null || true
helm repo add kong          https://charts.konghq.com                      2>/dev/null || true
helm repo update

# -----------------------------------------------------------------------------
# Install Kafka stack
# -----------------------------------------------------------------------------
if [[ "$KONG_ONLY" == "false" ]]; then
  echo "[install.sh] Installing Kafka stack..."
  bash "${SCRIPT_DIR}/scripts/install-kafka.sh"
  echo "[install.sh] Kafka stack installed."
fi

# -----------------------------------------------------------------------------
# Install Kong
# -----------------------------------------------------------------------------
if [[ "$KAFKA_ONLY" == "false" ]]; then
  echo "[install.sh] Installing Kong..."
  bash "${SCRIPT_DIR}/scripts/install-kong.sh"
  echo "[install.sh] Kong installed."
fi

# -----------------------------------------------------------------------------
# Verify
# -----------------------------------------------------------------------------
echo "[install.sh] Running post-install verification..."
bash "${SCRIPT_DIR}/scripts/verify.sh"

echo ""
echo "[install.sh] ============================================================"
echo "[install.sh]  Kongka stack installation complete."
echo "[install.sh] ============================================================"
echo ""
echo "  Kafka namespace : $KAFKA_NAMESPACE"
echo "  Kong namespace  : $KONG_NAMESPACE"
echo ""
echo "  Control Center  : kubectl get svc -n $KAFKA_NAMESPACE ${KAFKA_RELEASE_NAME}-cc-lb"
echo "  Kong proxy      : kubectl get svc -n $KONG_NAMESPACE $KONG_RELEASE_NAME-kong-proxy"
echo ""
