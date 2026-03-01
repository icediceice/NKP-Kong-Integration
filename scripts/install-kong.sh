#!/usr/bin/env bash
# =============================================================================
# Install Kong OSS (KIC or standalone gateway)
# Sourced by install.sh; all required variables must already be exported.
# =============================================================================
set -euo pipefail

trap 'echo "[install-kong] ERROR at line $LINENO" >&2' ERR

VALUES_DIR="${SCRIPT_DIR}/helm-values"

# -----------------------------------------------------------------------------
# Build Helm flags based on mode
# -----------------------------------------------------------------------------

VERSION_FLAG=""
if [[ -n "${KONG_CHART_VERSION:-}" ]]; then
  VERSION_FLAG="--version ${KONG_CHART_VERSION}"
fi

# Mode-specific overrides applied on top of the values file
MODE_FLAGS=()

case "${KONG_MODE:-ingress}" in
  ingress)
    echo "[install-kong] Mode: KIC (Kong Ingress Controller)"
    MODE_FLAGS+=(
      "--set" "ingressController.enabled=true"
      "--set" "proxy.enabled=true"
    )
    ;;
  gateway)
    echo "[install-kong] Mode: Standalone Gateway"
    MODE_FLAGS+=(
      "--set" "ingressController.enabled=false"
      "--set" "proxy.enabled=true"
    )
    ;;
  *)
    echo "[install-kong] ERROR: Unknown KONG_MODE '${KONG_MODE}'. Use 'ingress' or 'gateway'." >&2
    exit 1
    ;;
esac

# DB mode
case "${KONG_DB_MODE:-dbless}" in
  dbless)
    echo "[install-kong] DB mode: DB-less (declarative)"
    MODE_FLAGS+=(
      "--set" "env.database=off"
    )
    ;;
  postgres)
    echo "[install-kong] DB mode: Postgres"
    MODE_FLAGS+=(
      "--set" "env.database=postgres"
      "--set" "postgresql.enabled=true"
    )
    ;;
  *)
    echo "[install-kong] ERROR: Unknown KONG_DB_MODE '${KONG_DB_MODE}'. Use 'dbless' or 'postgres'." >&2
    exit 1
    ;;
esac

# -----------------------------------------------------------------------------
# Adopt pre-existing Kong CRDs (NKP pre-installs Kong CRDs via kubernetes-dashboard)
# Helm requires ownership labels on any CRD it manages. CRDs installed outside
# Helm lack these labels and cause "cannot be imported" errors on install.
# This step is idempotent — --overwrite silently skips already-labeled CRDs.
# -----------------------------------------------------------------------------
echo "[install-kong] Adopting existing Kong CRDs for Helm management..."
KONG_CRDS=$(kubectl get crd -o name 2>/dev/null | grep "konghq.com" || true)
if [[ -n "$KONG_CRDS" ]]; then
  for crd in $KONG_CRDS; do
    kubectl label "$crd" "app.kubernetes.io/managed-by=Helm" --overwrite 2>/dev/null || true
    kubectl annotate "$crd" \
      "meta.helm.sh/release-name=${KONG_RELEASE_NAME}" \
      "meta.helm.sh/release-namespace=${KONG_NAMESPACE}" \
      --overwrite 2>/dev/null || true
  done
  echo "[install-kong] Kong CRDs adopted."
fi

# -----------------------------------------------------------------------------
# Deploy Kong
# -----------------------------------------------------------------------------
echo "[install-kong] Deploying Kong (release: $KONG_RELEASE_NAME, namespace: $KONG_NAMESPACE)..."

helm upgrade --install "$KONG_RELEASE_NAME" kong/kong \
  --namespace "$KONG_NAMESPACE" \
  --create-namespace \
  --skip-crds \
  --values "${VALUES_DIR}/kong.yaml" \
  --set "proxy.type=${SERVICE_TYPE}" \
  "${MODE_FLAGS[@]}" \
  ${VERSION_FLAG} \
  --timeout "${ROLLOUT_TIMEOUT}s" \
  --wait

echo "[install-kong] Waiting for Kong pods to be ready..."
kubectl rollout status deployment \
  -n "$KONG_NAMESPACE" \
  -l "app.kubernetes.io/name=kong,app.kubernetes.io/instance=${KONG_RELEASE_NAME}" \
  --timeout="${ROLLOUT_TIMEOUT}s" 2>/dev/null || \
kubectl wait pod \
  -n "$KONG_NAMESPACE" \
  -l "app.kubernetes.io/name=kong,app.kubernetes.io/instance=${KONG_RELEASE_NAME}" \
  --for=condition=Ready \
  --timeout="${ROLLOUT_TIMEOUT}s"

echo "[install-kong] Kong ready."
