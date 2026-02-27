#!/usr/bin/env bash
# =============================================================================
# Install Kafka (KRaft), Control Center, and Schema Registry
# Sourced by install.sh; all required variables must already be exported.
# =============================================================================
set -euo pipefail

trap 'echo "[install-kafka] ERROR at line $LINENO" >&2' ERR

VALUES_DIR="${SCRIPT_DIR}/helm-values"

# -----------------------------------------------------------------------------
# Resolve cluster ID
# -----------------------------------------------------------------------------

if [[ -z "${KAFKA_CLUSTER_ID:-}" ]]; then
  # Generate a stable cluster ID and cache it so re-runs use the same value
  CLUSTER_ID_FILE="${SCRIPT_DIR}/.kafka-cluster-id"
  if [[ -f "$CLUSTER_ID_FILE" ]]; then
    KAFKA_CLUSTER_ID=$(cat "$CLUSTER_ID_FILE")
    echo "[install-kafka] Using existing cluster ID from .kafka-cluster-id"
  else
    # Use uuidgen if available, otherwise fall back to /proc/sys/kernel/random/uuid
    if command -v uuidgen &>/dev/null; then
      KAFKA_CLUSTER_ID=$(uuidgen | tr '[:lower:]' '[:upper:]')
    else
      KAFKA_CLUSTER_ID=$(cat /proc/sys/kernel/random/uuid | tr '[:lower:]' '[:upper:]')
    fi
    echo "$KAFKA_CLUSTER_ID" > "$CLUSTER_ID_FILE"
    echo "[install-kafka] Generated new cluster ID: $KAFKA_CLUSTER_ID (saved to .kafka-cluster-id)"
  fi
fi

# KRaft requires the cluster ID encoded in base64 URL-safe format
# Format: base64url of the UUID bytes (16 bytes → 22 chars without padding)
# The cp-helm-charts chart accepts the raw UUID string for clusterID.
export KAFKA_CLUSTER_ID

# -----------------------------------------------------------------------------
# Build Helm version flag
# -----------------------------------------------------------------------------
VERSION_FLAG=""
if [[ -n "${KAFKA_CHART_VERSION:-}" ]]; then
  VERSION_FLAG="--version ${KAFKA_CHART_VERSION}"
fi

# -----------------------------------------------------------------------------
# Install Kafka (KRaft)
# -----------------------------------------------------------------------------
echo "[install-kafka] Deploying Kafka KRaft (release: $KAFKA_RELEASE_NAME, namespace: $KAFKA_NAMESPACE)..."

helm upgrade --install "$KAFKA_RELEASE_NAME" confluentinc/cp-kafka \
  --namespace "$KAFKA_NAMESPACE" \
  --create-namespace \
  --values "${VALUES_DIR}/kafka-kraft.yaml" \
  --set cp-kafka.brokers="$KAFKA_BROKER_COUNT" \
  --set cp-kafka.image="$KAFKA_IMAGE" \
  --set "cp-kafka.persistence.storageClass=${KAFKA_STORAGE_CLASS}" \
  --set "cp-kafka.persistence.size=${KAFKA_STORAGE_SIZE}" \
  --set "cp-kafka.resources.requests.cpu=${KAFKA_CPU_REQUEST}" \
  --set "cp-kafka.resources.limits.cpu=${KAFKA_CPU_LIMIT}" \
  --set "cp-kafka.resources.requests.memory=${KAFKA_MEM_REQUEST}" \
  --set "cp-kafka.resources.limits.memory=${KAFKA_MEM_LIMIT}" \
  --set "cp-kafka.configurationOverrides.cluster\.id=${KAFKA_CLUSTER_ID}" \
  --set "cp-kafka.services.type=${SERVICE_TYPE}" \
  ${VERSION_FLAG} \
  --timeout "${ROLLOUT_TIMEOUT}s" \
  --wait

echo "[install-kafka] Waiting for Kafka brokers to be ready..."
kubectl rollout status statefulset \
  -n "$KAFKA_NAMESPACE" \
  -l "app=cp-kafka,release=${KAFKA_RELEASE_NAME}" \
  --timeout="${ROLLOUT_TIMEOUT}s" 2>/dev/null || \
kubectl wait pod \
  -n "$KAFKA_NAMESPACE" \
  -l "app=cp-kafka,release=${KAFKA_RELEASE_NAME}" \
  --for=condition=Ready \
  --timeout="${ROLLOUT_TIMEOUT}s"

echo "[install-kafka] Kafka ready."

# Kafka bootstrap service used by downstream components
KAFKA_BOOTSTRAP="${KAFKA_RELEASE_NAME}-cp-kafka:9092"

# -----------------------------------------------------------------------------
# Install Schema Registry (optional)
# -----------------------------------------------------------------------------
if [[ "${SR_ENABLED:-true}" == "true" ]]; then
  echo "[install-kafka] Deploying Schema Registry (release: $SR_RELEASE_NAME)..."

  helm upgrade --install "$SR_RELEASE_NAME" confluentinc/cp-schema-registry \
    --namespace "$KAFKA_NAMESPACE" \
    --values "${VALUES_DIR}/schema-registry.yaml" \
    --set cp-schema-registry.image="$SR_IMAGE" \
    --set "cp-schema-registry.kafka.bootstrapServers=PLAINTEXT://${KAFKA_BOOTSTRAP}" \
    --set "cp-schema-registry.service.type=${SERVICE_TYPE}" \
    --timeout "${ROLLOUT_TIMEOUT}s" \
    --wait

  echo "[install-kafka] Schema Registry ready."
else
  echo "[install-kafka] Skipping Schema Registry (SR_ENABLED=false)."
fi

# -----------------------------------------------------------------------------
# Install Control Center (optional)
# -----------------------------------------------------------------------------
if [[ "${CC_ENABLED:-true}" == "true" ]]; then
  echo "[install-kafka] Deploying Control Center (release: $CC_RELEASE_NAME)..."

  helm upgrade --install "$CC_RELEASE_NAME" confluentinc/cp-enterprise-control-center \
    --namespace "$KAFKA_NAMESPACE" \
    --values "${VALUES_DIR}/control-center.yaml" \
    --set cp-enterprise-control-center.image="$CC_IMAGE" \
    --set "cp-enterprise-control-center.kafka.bootstrapServers=PLAINTEXT://${KAFKA_BOOTSTRAP}" \
    --set "cp-enterprise-control-center.persistence.size=${CC_STORAGE_SIZE}" \
    --set "cp-enterprise-control-center.persistence.storageClass=${KAFKA_STORAGE_CLASS}" \
    --set "cp-enterprise-control-center.service.type=${SERVICE_TYPE}" \
    --timeout "${ROLLOUT_TIMEOUT}s" \
    --wait

  echo "[install-kafka] Control Center ready."
else
  echo "[install-kafka] Skipping Control Center (CC_ENABLED=false)."
fi
