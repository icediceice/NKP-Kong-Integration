#!/usr/bin/env bash
# =============================================================================
# Install Kafka (KRaft, no ZooKeeper) + Schema Registry + Control Center
# using the hand-crafted local Helm chart at charts/kafka-kraft/.
# Sourced by install.sh; all required variables must already be exported.
# =============================================================================
set -euo pipefail

trap 'echo "[install-kafka] ERROR at line $LINENO" >&2' ERR

CHART_DIR="${SCRIPT_DIR}/charts/kafka-kraft"

# -----------------------------------------------------------------------------
# Parse image strings into repo + tag components
# -----------------------------------------------------------------------------
KAFKA_IMAGE_REPO="${KAFKA_IMAGE%%:*}"
KAFKA_IMAGE_TAG="${KAFKA_IMAGE##*:}"
SR_IMAGE_REPO="${SR_IMAGE%%:*}"
SR_IMAGE_TAG="${SR_IMAGE##*:}"
CC_IMAGE_REPO="${CC_IMAGE%%:*}"
CC_IMAGE_TAG="${CC_IMAGE##*:}"

# -----------------------------------------------------------------------------
# Resolve or generate KRaft cluster ID
#
# KRaft requires a UUID encoded as 22 base64url characters (16 bytes, no padding).
# Priority:
#   1. .kafka-cluster-id file (persists across re-runs)
#   2. KAFKA_CLUSTER_ID env var (from config.env; UUID or base64url accepted)
#   3. Auto-generate from /proc/sys/kernel/random/uuid
# -----------------------------------------------------------------------------
CLUSTER_ID_FILE="${SCRIPT_DIR}/.kafka-cluster-id"

uuid_to_base64url() {
  # Convert a UUID string (36-char with hyphens) to 22-char base64url
  local hex
  hex=$(echo "$1" | tr -d '-')
  if command -v python3 &>/dev/null; then
    python3 -c "
import base64
data = bytes.fromhex('${hex}')
print(base64.urlsafe_b64encode(data).rstrip(b'=').decode())
"
  elif command -v xxd &>/dev/null; then
    echo "$hex" | xxd -r -p | base64 -w 0 | tr '+/' '-_' | tr -d '='
  else
    echo "[install-kafka] ERROR: python3 or xxd required for cluster ID generation" >&2
    exit 1
  fi
}

if [[ -f "$CLUSTER_ID_FILE" ]]; then
  CLUSTER_ID=$(cat "$CLUSTER_ID_FILE")
  echo "[install-kafka] Using existing cluster ID from .kafka-cluster-id: $CLUSTER_ID"
elif [[ -n "${KAFKA_CLUSTER_ID:-}" ]]; then
  if [[ ${#KAFKA_CLUSTER_ID} -eq 36 ]]; then
    # UUID format — convert to base64url
    CLUSTER_ID=$(uuid_to_base64url "$KAFKA_CLUSTER_ID")
  else
    # Assume already base64url
    CLUSTER_ID="$KAFKA_CLUSTER_ID"
  fi
  echo "$CLUSTER_ID" > "$CLUSTER_ID_FILE"
  echo "[install-kafka] Using configured cluster ID: $CLUSTER_ID"
else
  RAW_UUID=$(cat /proc/sys/kernel/random/uuid)
  CLUSTER_ID=$(uuid_to_base64url "$RAW_UUID")
  echo "$CLUSTER_ID" > "$CLUSTER_ID_FILE"
  echo "[install-kafka] Generated new cluster ID: $CLUSTER_ID (saved to .kafka-cluster-id)"
fi

# Validate: must be exactly 22 chars
if [[ ${#CLUSTER_ID} -ne 22 ]]; then
  echo "[install-kafka] ERROR: cluster ID must be 22 base64url chars, got: ${#CLUSTER_ID} (${CLUSTER_ID})" >&2
  exit 1
fi

# -----------------------------------------------------------------------------
# Migration: remove old ZooKeeper-based release before installing KRaft
#
# ZK-formatted PVCs are incompatible with KRaft storage format.
# Only uninstall if the existing release uses ZooKeeper (cp-zookeeper key present).
# -----------------------------------------------------------------------------
if helm status "$KAFKA_RELEASE_NAME" -n "$KAFKA_NAMESPACE" &>/dev/null; then
  if helm get values "$KAFKA_RELEASE_NAME" -n "$KAFKA_NAMESPACE" 2>/dev/null | grep -q 'cp-zookeeper'; then
    echo "[install-kafka] Detected ZooKeeper-based Helm release — migrating to KRaft..."
    helm uninstall "$KAFKA_RELEASE_NAME" -n "$KAFKA_NAMESPACE"
    echo "[install-kafka] Deleting ZK-formatted PVCs (incompatible with KRaft)..."
    kubectl delete pvc -n "$KAFKA_NAMESPACE" --all --wait=true 2>/dev/null || true
    echo "[install-kafka] Migration cleanup complete."
  else
    echo "[install-kafka] Existing KRaft release found — upgrading in place."
  fi
fi

# -----------------------------------------------------------------------------
# Deploy: Kafka (KRaft) + Schema Registry + Control Center
# Single Helm release from the local chart.
# -----------------------------------------------------------------------------
echo "[install-kafka] Deploying KRaft stack (release: $KAFKA_RELEASE_NAME, namespace: $KAFKA_NAMESPACE)..."

helm upgrade --install "$KAFKA_RELEASE_NAME" "$CHART_DIR" \
  --namespace "$KAFKA_NAMESPACE" \
  --create-namespace \
  --values "${SCRIPT_DIR}/helm-values/kafka-kraft.yaml" \
  --set "kafka.clusterId=${CLUSTER_ID}" \
  --set "kafka.replicaCount=${KAFKA_BROKER_COUNT}" \
  --set "kafka.image.repository=${KAFKA_IMAGE_REPO}" \
  --set "kafka.image.tag=${KAFKA_IMAGE_TAG}" \
  --set "kafka.storage.class=${KAFKA_STORAGE_CLASS}" \
  --set "kafka.storage.size=${KAFKA_STORAGE_SIZE}" \
  --set "kafka.resources.requests.cpu=${KAFKA_CPU_REQUEST}" \
  --set "kafka.resources.limits.cpu=${KAFKA_CPU_LIMIT}" \
  --set "kafka.resources.requests.memory=${KAFKA_MEM_REQUEST}" \
  --set "kafka.resources.limits.memory=${KAFKA_MEM_LIMIT}" \
  --set "schemaRegistry.enabled=${SR_ENABLED:-true}" \
  --set "schemaRegistry.image.repository=${SR_IMAGE_REPO}" \
  --set "schemaRegistry.image.tag=${SR_IMAGE_TAG}" \
  --set "controlCenter.enabled=${CC_ENABLED:-true}" \
  --set "controlCenter.image.repository=${CC_IMAGE_REPO}" \
  --set "controlCenter.image.tag=${CC_IMAGE_TAG}" \
  --timeout "${ROLLOUT_TIMEOUT}s" \
  --wait

echo "[install-kafka] Waiting for Kafka StatefulSet to be ready..."
kubectl rollout status "statefulset/${KAFKA_RELEASE_NAME}-kafka" \
  -n "$KAFKA_NAMESPACE" \
  --timeout="${ROLLOUT_TIMEOUT}s"

echo "[install-kafka] Kafka KRaft stack ready."
echo "[install-kafka] Control Center LB: ${KAFKA_RELEASE_NAME}-cc-lb (port 9021)"
