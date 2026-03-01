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
# Setup wizard
# Runs automatically when config.env is absent, or when --reconfigure is passed.
# Detects cluster topology (storage classes, LoadBalancer availability) and asks
# for all stack configuration values. Writes results to config.env.
# Pre-populates every prompt from the existing config.env so --reconfigure is fast.
# -----------------------------------------------------------------------------
run_setup_wizard() {
  local config_file="$1"
  local choice yn

  # Read a value from existing config file; return default if absent
  _cfg() { grep -m1 "^${1}=" "$config_file" 2>/dev/null | cut -d= -f2- || echo "${2}"; }

  local cur_broker_count;  cur_broker_count="$(_cfg  KAFKA_BROKER_COUNT  3)"
  local cur_storage_size;  cur_storage_size="$(_cfg  KAFKA_STORAGE_SIZE  50Gi)"
  local cur_mem_request;   cur_mem_request="$(_cfg   KAFKA_MEM_REQUEST   4Gi)"
  local cur_mem_limit;     cur_mem_limit="$(_cfg     KAFKA_MEM_LIMIT     8Gi)"
  local cur_cc_enabled;    cur_cc_enabled="$(_cfg    CC_ENABLED          true)"
  local cur_sr_enabled;    cur_sr_enabled="$(_cfg    SR_ENABLED          true)"
  local cur_kong_mode;     cur_kong_mode="$(_cfg     KONG_MODE           ingress)"
  local cur_kong_db;       cur_kong_db="$(_cfg       KONG_DB_MODE        dbless)"
  local cur_timeout;       cur_timeout="$(_cfg       ROLLOUT_TIMEOUT     300)"

  echo ""
  echo "[install.sh] ── Setup wizard ──────────────────────────────────────────"

  # ── Storage class ──────────────────────────────────────────────────────────
  echo ""
  local sc_names=() sc_is_default=()
  while IFS=$'\t' read -r name is_default; do
    [[ -z "$name" ]] && continue
    sc_names+=("$name")
    sc_is_default+=("${is_default:-false}")
  done < <(kubectl get sc \
    -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.metadata.annotations.storageclass\.kubernetes\.io/is-default-class}{"\n"}{end}' \
    2>/dev/null)

  local wiz_storage_class
  if [[ ${#sc_names[@]} -eq 0 ]]; then
    local cur_sc; cur_sc="$(_cfg KAFKA_STORAGE_CLASS default)"
    read -rp "  Storage class (none detected, enter manually) [$cur_sc]: " wiz_storage_class
    wiz_storage_class="${wiz_storage_class:-$cur_sc}"
  elif [[ ${#sc_names[@]} -eq 1 ]]; then
    wiz_storage_class="${sc_names[0]}"
    echo "  Storage class: $wiz_storage_class (only option)"
  else
    local default_idx=0 cur_sc_idx=0
    local cur_sc; cur_sc="$(_cfg KAFKA_STORAGE_CLASS "")"
    echo "  Storage class for Kafka PVCs:"
    for i in "${!sc_names[@]}"; do
      local tag=""
      [[ "${sc_is_default[$i]}" == "true" ]] && tag+=" (cluster default)" && default_idx=$(( i + 1 ))
      [[ "${sc_names[$i]}" == "$cur_sc" ]]    && tag+=" (current)" && cur_sc_idx=$(( i + 1 ))
      printf "    [%d] %s%s\n" "$(( i + 1 ))" "${sc_names[$i]}" "$tag"
    done
    echo ""
    local hint=$(( cur_sc_idx > 0 ? cur_sc_idx : default_idx ))
    local sc_prompt="  Enter number [1-${#sc_names[@]}]"
    [[ $hint -gt 0 ]] && sc_prompt+=" (Enter for [$hint])"
    sc_prompt+=": "
    while true; do
      read -rp "$sc_prompt" choice
      [[ -z "$choice" && $hint -gt 0 ]] && choice=$hint
      if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#sc_names[@]} )); then
        wiz_storage_class="${sc_names[$((choice - 1))]}"
        echo "  → $wiz_storage_class"
        break
      fi
      echo "    Invalid — enter a number between 1 and ${#sc_names[@]}."
    done
  fi

  # ── Service type ───────────────────────────────────────────────────────────
  echo ""
  local wiz_service_type lb_available=false
  if kubectl get crd ipaddresspools.metallb.io &>/dev/null 2>&1; then
    lb_available=true
  elif kubectl get svc -A \
      -o jsonpath='{range .items[?(@.spec.type=="LoadBalancer")]}{.status.loadBalancer.ingress[0].ip}{"\n"}{end}' \
      2>/dev/null | grep -qE "^[0-9]+\.[0-9]"; then
    lb_available=true
  fi

  if [[ "$lb_available" == "true" ]]; then
    wiz_service_type="LoadBalancer"
    echo "  Service type: LoadBalancer (provisioner detected)"
  else
    echo "  Service exposure (no LoadBalancer provisioner detected):"
    echo "    [1] NodePort      — works on any cluster, access via node IP + port"
    echo "    [2] LoadBalancer  — requires MetalLB or cloud load balancer"
    echo ""
    read -rp "  Enter number [1-2] (Enter for [1]): " choice
    case "${choice:-1}" in
      2) wiz_service_type="LoadBalancer" ;;
      *) wiz_service_type="NodePort" ;;
    esac
    echo "  → $wiz_service_type"
  fi

  # ── Kafka ──────────────────────────────────────────────────────────────────
  echo ""
  echo "  ── Kafka ──────────────────────────────────────────────────────────"
  local wiz_broker_count wiz_storage_size wiz_mem_request wiz_mem_limit mem_input

  read -rp "  Broker count [$cur_broker_count]: " wiz_broker_count
  wiz_broker_count="${wiz_broker_count:-$cur_broker_count}"

  read -rp "  Storage per broker [$cur_storage_size]: " wiz_storage_size
  wiz_storage_size="${wiz_storage_size:-$cur_storage_size}"

  read -rp "  Memory request/limit [${cur_mem_request}/${cur_mem_limit}]: " mem_input
  if [[ -z "$mem_input" ]]; then
    wiz_mem_request="$cur_mem_request"
    wiz_mem_limit="$cur_mem_limit"
  else
    wiz_mem_request="${mem_input%%/*}"
    wiz_mem_limit="${mem_input##*/}"
  fi

  # ── Components ─────────────────────────────────────────────────────────────
  echo ""
  echo "  ── Components ─────────────────────────────────────────────────────"
  local wiz_cc_enabled wiz_sr_enabled

  local cc_hint="Y/n"; [[ "$cur_cc_enabled" == "false" ]] && cc_hint="y/N"
  read -rp "  Enable Control Center (Kafka management UI)? [$cc_hint]: " yn
  if [[ -z "$yn" ]]; then
    wiz_cc_enabled="$cur_cc_enabled"
  elif [[ "${yn,,}" == "n" || "${yn,,}" == "no" ]]; then
    wiz_cc_enabled="false"
  else
    wiz_cc_enabled="true"
  fi

  local sr_hint="Y/n"; [[ "$cur_sr_enabled" == "false" ]] && sr_hint="y/N"
  read -rp "  Enable Schema Registry? [$sr_hint]: " yn
  if [[ -z "$yn" ]]; then
    wiz_sr_enabled="$cur_sr_enabled"
  elif [[ "${yn,,}" == "n" || "${yn,,}" == "no" ]]; then
    wiz_sr_enabled="false"
  else
    wiz_sr_enabled="true"
  fi

  # ── Kong ───────────────────────────────────────────────────────────────────
  echo ""
  echo "  ── Kong ───────────────────────────────────────────────────────────"
  local wiz_kong_mode wiz_kong_db

  local kong_mode_def=1; [[ "$cur_kong_mode" == "gateway" ]] && kong_mode_def=2
  echo "  Deployment mode:"
  echo "    [1] ingress  — Kong Ingress Controller, Kubernetes-native"
  echo "    [2] gateway  — Standalone proxy"
  read -rp "  Enter number [1-2] (Enter for [$kong_mode_def]): " choice
  case "${choice:-$kong_mode_def}" in
    2) wiz_kong_mode="gateway" ;;
    *) wiz_kong_mode="ingress" ;;
  esac

  local kong_db_def=1; [[ "$cur_kong_db" == "postgres" ]] && kong_db_def=2
  echo "  Database mode:"
  echo "    [1] dbless   — Declarative, no database needed"
  echo "    [2] postgres — Postgres-backed, supports live Admin API writes"
  read -rp "  Enter number [1-2] (Enter for [$kong_db_def]): " choice
  case "${choice:-$kong_db_def}" in
    2) wiz_kong_db="postgres" ;;
    *) wiz_kong_db="dbless" ;;
  esac

  # ── Timeouts ───────────────────────────────────────────────────────────────
  echo ""
  local wiz_timeout
  read -rp "  Rollout timeout seconds [$cur_timeout]: " wiz_timeout
  wiz_timeout="${wiz_timeout:-$cur_timeout}"

  # ── Write config.env ───────────────────────────────────────────────────────
  echo ""
  cat > "$config_file" <<EOF
# Generated by install.sh wizard — $(date -u +"%Y-%m-%d %H:%M UTC")
# Cluster: $(basename "${KUBECONFIG:-default}")
# Re-run wizard: ./install.sh --reconfigure

KAFKA_NAMESPACE=kafka
KONG_NAMESPACE=kong

KAFKA_BROKER_COUNT=${wiz_broker_count}
KAFKA_IMAGE=confluentinc/cp-server:7.6.0
KAFKA_STORAGE_CLASS=${wiz_storage_class}
KAFKA_STORAGE_SIZE=${wiz_storage_size}
KAFKA_CPU_REQUEST=1
KAFKA_CPU_LIMIT=2
KAFKA_MEM_REQUEST=${wiz_mem_request}
KAFKA_MEM_LIMIT=${wiz_mem_limit}
KAFKA_CLUSTER_ID=
KAFKA_RELEASE_NAME=kafka
KAFKA_CHART_VERSION=

CC_ENABLED=${wiz_cc_enabled}
CC_IMAGE=confluentinc/cp-enterprise-control-center:7.6.0
CC_STORAGE_SIZE=10Gi
CC_RELEASE_NAME=control-center

SR_ENABLED=${wiz_sr_enabled}
SR_IMAGE=confluentinc/cp-schema-registry:7.6.0
SR_RELEASE_NAME=schema-registry

KONG_MODE=${wiz_kong_mode}
KONG_DB_MODE=${wiz_kong_db}
KONG_RELEASE_NAME=kong
KONG_CHART_VERSION=

SERVICE_TYPE=${wiz_service_type}
ROLLOUT_TIMEOUT=${wiz_timeout}
EOF

  echo "[install.sh] Configuration saved to $(basename "$config_file")"
  echo "[install.sh] ────────────────────────────────────────────────────────"
  echo ""
}

# -----------------------------------------------------------------------------
# Flags
# -----------------------------------------------------------------------------
SKIP_PREFLIGHT=false
KAFKA_ONLY=false
KONG_ONLY=false
RECONFIGURE=false

for arg in "$@"; do
  case "$arg" in
    --skip-preflight) SKIP_PREFLIGHT=true ;;
    --kafka-only)     KAFKA_ONLY=true ;;
    --kong-only)      KONG_ONLY=true ;;
    --reconfigure)    RECONFIGURE=true ;;
    *) echo "[install.sh] Unknown argument: $arg" >&2; exit 1 ;;
  esac
done

# -----------------------------------------------------------------------------
# Load config  (wizard runs first if config.env is absent or --reconfigure set)
# -----------------------------------------------------------------------------
CONFIG_FILE="${SCRIPT_DIR}/config.env"

if [[ "$RECONFIGURE" == "true" || ! -f "$CONFIG_FILE" ]]; then
  run_setup_wizard "$CONFIG_FILE"
fi

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
# Cluster settings reconciliation
# Always runs after cluster selection, even when reusing an existing config.env.
# Ensures KAFKA_STORAGE_CLASS and SERVICE_TYPE are valid for the chosen cluster.
# Handles the common case of switching clusters without re-running the wizard.
# -----------------------------------------------------------------------------
detect_cluster_settings() {
  # ── Storage class ──────────────────────────────────────────────────────────
  local sc_names=() sc_is_default=() sc_default_name=""
  while IFS=$'\t' read -r name is_default; do
    [[ -z "$name" ]] && continue
    sc_names+=("$name")
    sc_is_default+=("${is_default:-false}")
    [[ "${is_default:-false}" == "true" ]] && sc_default_name="$name"
  done < <(kubectl get sc \
    -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.metadata.annotations.storageclass\.kubernetes\.io/is-default-class}{"\n"}{end}' \
    2>/dev/null)

  if [[ ${#sc_names[@]} -eq 0 ]]; then
    echo "[install.sh] WARNING: No storage classes found — using KAFKA_STORAGE_CLASS=${KAFKA_STORAGE_CLASS}"
  else
    # Check if configured value exists on this cluster
    local sc_valid=false
    for sc in "${sc_names[@]}"; do
      [[ "$sc" == "$KAFKA_STORAGE_CLASS" ]] && sc_valid=true && break
    done

    if [[ "$sc_valid" == "true" ]]; then
      echo "[install.sh] Storage class: $KAFKA_STORAGE_CLASS (confirmed on cluster)"
    elif [[ ${#sc_names[@]} -eq 1 ]]; then
      echo "[install.sh] Storage class: ${sc_names[0]} (auto-selected — '${KAFKA_STORAGE_CLASS}' not found on cluster)"
      KAFKA_STORAGE_CLASS="${sc_names[0]}"
      export KAFKA_STORAGE_CLASS
    elif [[ -n "$sc_default_name" ]]; then
      echo "[install.sh] Storage class: $sc_default_name (cluster default — '${KAFKA_STORAGE_CLASS}' not found on cluster)"
      KAFKA_STORAGE_CLASS="$sc_default_name"
      export KAFKA_STORAGE_CLASS
    else
      # Multiple classes, none matching, no cluster default → must ask
      echo ""
      echo "[install.sh] '${KAFKA_STORAGE_CLASS}' not found on this cluster. Select a storage class:"
      echo ""
      local i=1
      for sc in "${sc_names[@]}"; do
        printf "  [%d] %s\n" "$i" "$sc"
        (( i++ ))
      done
      echo ""
      local choice
      while true; do
        read -rp "Enter number [1-${#sc_names[@]}]: " choice
        if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#sc_names[@]} )); then
          KAFKA_STORAGE_CLASS="${sc_names[$((choice - 1))]}"
          export KAFKA_STORAGE_CLASS
          echo "[install.sh] Storage class: $KAFKA_STORAGE_CLASS"
          break
        fi
        echo "  Invalid — enter a number between 1 and ${#sc_names[@]}."
      done
    fi
  fi

  # ── Service type ───────────────────────────────────────────────────────────
  local lb_available=false
  if kubectl get crd ipaddresspools.metallb.io &>/dev/null 2>&1; then
    lb_available=true
  elif kubectl get svc -A \
      -o jsonpath='{range .items[?(@.spec.type=="LoadBalancer")]}{.status.loadBalancer.ingress[0].ip}{"\n"}{end}' \
      2>/dev/null | grep -qE "^[0-9]+\.[0-9]"; then
    lb_available=true
  fi

  if [[ "$lb_available" == "true" && "$SERVICE_TYPE" != "LoadBalancer" ]]; then
    echo "[install.sh] Service type: LoadBalancer (provisioner detected; overriding config value '$SERVICE_TYPE')"
    SERVICE_TYPE="LoadBalancer"
    export SERVICE_TYPE
  elif [[ "$lb_available" == "false" && "$SERVICE_TYPE" == "LoadBalancer" ]]; then
    echo "[install.sh] WARNING: SERVICE_TYPE=LoadBalancer but no provisioner detected — services may stay Pending"
    echo "[install.sh]   If this is wrong, re-run with --reconfigure to update config.env"
  else
    echo "[install.sh] Service type: $SERVICE_TYPE"
  fi
}

detect_cluster_settings

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
