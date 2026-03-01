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
# Cluster selection
# Scans auth/ for kubeconfig files and prompts the user to select one.
# Skipped if KUBECONFIG is already set in the environment.
# -----------------------------------------------------------------------------
pick_cluster() {
  local auth_dir="${SCRIPT_DIR}/auth"

  if [[ ! -d "$auth_dir" ]]; then
    echo "[install.sh] No auth/ directory found — using default kubeconfig"
    return
  fi

  mapfile -t kubeconfigs < <(find "$auth_dir" -maxdepth 1 \( -name "*.conf" -o -name "*.yaml" \) | sort)

  if [[ ${#kubeconfigs[@]} -eq 0 ]]; then
    echo "[install.sh] No kubeconfig files in auth/ — using default kubeconfig"
    return
  fi

  if [[ ${#kubeconfigs[@]} -eq 1 ]]; then
    export KUBECONFIG="${kubeconfigs[0]}"
    echo "[install.sh] Auto-selected cluster: $(basename "$KUBECONFIG")"
    return
  fi

  echo ""
  echo "Select a cluster:"
  echo ""
  local i=1
  for kc in "${kubeconfigs[@]}"; do
    local name server
    name=$(kubectl config view --kubeconfig="$kc" -o jsonpath='{.clusters[0].name}' 2>/dev/null || true)
    server=$(kubectl config view --kubeconfig="$kc" -o jsonpath='{.clusters[0].cluster.server}' 2>/dev/null || true)
    name="${name:-$(basename "$kc" .conf)}"
    server="${server:-unknown}"
    printf "  [%d] %-30s %s\n" "$i" "$(basename "$kc")" "$name  ($server)"
    (( i++ ))
  done
  echo ""

  local choice
  while true; do
    read -rp "Enter number [1-${#kubeconfigs[@]}]: " choice
    if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#kubeconfigs[@]} )); then
      export KUBECONFIG="${kubeconfigs[$((choice - 1))]}"
      echo "[install.sh] Using cluster: $(basename "$KUBECONFIG")"
      break
    fi
    echo "  Invalid — enter a number between 1 and ${#kubeconfigs[@]}."
  done
}

if [[ -n "${KUBECONFIG:-}" ]]; then
  echo "[install.sh] Using cluster from environment: $KUBECONFIG"
else
  pick_cluster
fi

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
