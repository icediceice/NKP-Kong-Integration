#!/usr/bin/env bash
# =============================================================================
# Install Confluent Platform: Kafka (ZooKeeper mode), Schema Registry,
# and Control Center — using confluentinc/cp-helm-charts umbrella chart.
# Sourced by install.sh; all required variables must already be exported.
# =============================================================================
set -euo pipefail

trap 'echo "[install-kafka] ERROR at line $LINENO" >&2' ERR

VALUES_DIR="${SCRIPT_DIR}/helm-values"

# -----------------------------------------------------------------------------
# Parse image strings into repo + tag components
# The chart uses separate `image` and `imageTag` fields.
# -----------------------------------------------------------------------------
KAFKA_IMAGE_REPO="${KAFKA_IMAGE%%:*}"
KAFKA_IMAGE_TAG="${KAFKA_IMAGE##*:}"
SR_IMAGE_REPO="${SR_IMAGE%%:*}"
SR_IMAGE_TAG="${SR_IMAGE##*:}"
CC_IMAGE_REPO="${CC_IMAGE%%:*}"
CC_IMAGE_TAG="${CC_IMAGE##*:}"

# -----------------------------------------------------------------------------
# Build Helm version flag
# -----------------------------------------------------------------------------
VERSION_FLAG=""
if [[ -n "${KAFKA_CHART_VERSION:-}" ]]; then
  VERSION_FLAG="--version ${KAFKA_CHART_VERSION}"
fi

# -----------------------------------------------------------------------------
# Prepare local patched chart
# cp-helm-charts 0.6.1 uses policy/v1beta1 PodDisruptionBudget, which was
# removed in Kubernetes 1.25. We download once, patch, and install locally.
# -----------------------------------------------------------------------------
CHART_CACHE="${SCRIPT_DIR}/.cache/cp-helm-charts"
if [[ ! -d "$CHART_CACHE" ]]; then
  echo "[install-kafka] Downloading and patching cp-helm-charts for K8s 1.25+ compatibility..."
  mkdir -p "${SCRIPT_DIR}/.cache"
  helm pull confluentinc/cp-helm-charts \
    --untar \
    --untardir "${SCRIPT_DIR}/.cache" \
    ${VERSION_FLAG}
  # Patch policy/v1beta1 PodDisruptionBudget → policy/v1 (K8s 1.25+ removed v1beta1)
  find "${CHART_CACHE}" -name "*.yaml" \
    -exec sed -i 's|apiVersion: policy/v1beta1|apiVersion: policy/v1|g' {} \;
  echo "[install-kafka] Chart patched and cached at .cache/cp-helm-charts"
else
  echo "[install-kafka] Using cached chart at .cache/cp-helm-charts"
fi

# -----------------------------------------------------------------------------
# Deploy Confluent Platform (Kafka + ZooKeeper + Schema Registry + Control Center)
# All components deploy as one Helm release using the umbrella chart.
# The chart uses ZooKeeper mode — KRaft is not supported in cp-helm-charts.
# -----------------------------------------------------------------------------
echo "[install-kafka] Deploying Confluent Platform (release: $KAFKA_RELEASE_NAME, namespace: $KAFKA_NAMESPACE)..."

helm upgrade --install "$KAFKA_RELEASE_NAME" "${CHART_CACHE}" \
  --namespace "$KAFKA_NAMESPACE" \
  --create-namespace \
  --values "${VALUES_DIR}/kafka-kraft.yaml" \
  --values "${VALUES_DIR}/schema-registry.yaml" \
  --values "${VALUES_DIR}/control-center.yaml" \
  --set cp-zookeeper.enabled=true \
  --set cp-kafka.enabled=true \
  --set "cp-schema-registry.enabled=${SR_ENABLED:-true}" \
  --set "cp-control-center.enabled=${CC_ENABLED:-true}" \
  --set cp-kafka-rest.enabled=false \
  --set cp-kafka-connect.enabled=false \
  --set cp-ksql-server.enabled=false \
  --set "cp-kafka.brokers=${KAFKA_BROKER_COUNT}" \
  --set "cp-kafka.image=${KAFKA_IMAGE_REPO}" \
  --set "cp-kafka.imageTag=${KAFKA_IMAGE_TAG}" \
  --set "cp-kafka.persistence.storageClass=${KAFKA_STORAGE_CLASS}" \
  --set "cp-kafka.persistence.size=${KAFKA_STORAGE_SIZE}" \
  --set "cp-kafka.resources.requests.cpu=${KAFKA_CPU_REQUEST}" \
  --set "cp-kafka.resources.limits.cpu=${KAFKA_CPU_LIMIT}" \
  --set "cp-kafka.resources.requests.memory=${KAFKA_MEM_REQUEST}" \
  --set "cp-kafka.resources.limits.memory=${KAFKA_MEM_LIMIT}" \
  --set "cp-zookeeper.persistence.dataDirStorageClass=${KAFKA_STORAGE_CLASS}" \
  --set "cp-zookeeper.persistence.dataLogDirStorageClass=${KAFKA_STORAGE_CLASS}" \
  --set "cp-schema-registry.image=${SR_IMAGE_REPO}" \
  --set "cp-schema-registry.imageTag=${SR_IMAGE_TAG}" \
  --set "cp-control-center.image=${CC_IMAGE_REPO}" \
  --set "cp-control-center.imageTag=${CC_IMAGE_TAG}" \
  ${VERSION_FLAG} \
  --timeout "${ROLLOUT_TIMEOUT}s" \
  --wait

echo "[install-kafka] Waiting for Kafka StatefulSet to be ready..."
kubectl rollout status "statefulset/${KAFKA_RELEASE_NAME}-cp-kafka" \
  -n "$KAFKA_NAMESPACE" \
  --timeout="${ROLLOUT_TIMEOUT}s"

echo "[install-kafka] Kafka ready."

# -----------------------------------------------------------------------------
# Expose Control Center via LoadBalancer
# The cp-helm-charts chart hardcodes ClusterIP for all services.
# We create an additional LoadBalancer service targeting the CC pods.
# -----------------------------------------------------------------------------
if [[ "${CC_ENABLED:-true}" == "true" ]]; then
  echo "[install-kafka] Creating LoadBalancer service for Control Center..."
  kubectl apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: ${KAFKA_RELEASE_NAME}-cc-lb
  namespace: ${KAFKA_NAMESPACE}
  labels:
    app: cp-control-center
    release: ${KAFKA_RELEASE_NAME}
spec:
  type: LoadBalancer
  ports:
    - port: 9021
      targetPort: 9021
      name: cc-http
  selector:
    app: cp-control-center
    release: ${KAFKA_RELEASE_NAME}
EOF
  echo "[install-kafka] Control Center LB service: ${KAFKA_RELEASE_NAME}-cc-lb (port 9021)"
fi
