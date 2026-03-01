#!/usr/bin/env bash
# =============================================================================
# Install Jaeger — Distributed Tracing
# Sourced by install.sh; all required variables must already be exported.
#
# Strategies:
#   allInOne   — Single pod, in-memory storage. Zero dependencies. POC default.
#   production — Separate collector/query pods with Elasticsearch backend.
#
# Variables consumed (from config.env / install.sh defaults):
#   JAEGER_NAMESPACE    JAEGER_RELEASE_NAME
#   JAEGER_STRATEGY     JAEGER_STORAGE_TYPE   (production only)
#   SERVICE_TYPE        ROLLOUT_TIMEOUT
# =============================================================================
set -euo pipefail

trap 'echo "[install-jaeger] ERROR at line $LINENO" >&2' ERR

VALUES_DIR="${SCRIPT_DIR}/helm-values"

STRATEGY="${JAEGER_STRATEGY:-allInOne}"
echo "[install-jaeger] Strategy: $STRATEGY"

# -----------------------------------------------------------------------------
# Build strategy-specific --set flags
# -----------------------------------------------------------------------------
STRATEGY_FLAGS=()

case "$STRATEGY" in
  allInOne)
    STRATEGY_FLAGS+=(
      "--set" "allInOne.enabled=true"
      "--set" "collector.enabled=false"
      "--set" "query.enabled=false"
      "--set" "agent.enabled=false"
      "--set" "storage.type=memory"
    )
    ;;
  production)
    STORAGE="${JAEGER_STORAGE_TYPE:-elasticsearch}"
    echo "[install-jaeger] Storage backend: $STORAGE"
    STRATEGY_FLAGS+=(
      "--set" "allInOne.enabled=false"
      "--set" "collector.enabled=true"
      "--set" "query.enabled=true"
      "--set" "agent.enabled=false"
      "--set" "storage.type=${STORAGE}"
    )
    case "$STORAGE" in
      elasticsearch)
        # Use the bundled Elasticsearch subchart
        STRATEGY_FLAGS+=(
          "--set" "provisionDataStore.elasticsearch=true"
        )
        ;;
      cassandra)
        STRATEGY_FLAGS+=(
          "--set" "provisionDataStore.cassandra=true"
        )
        ;;
      *)
        echo "[install-jaeger] ERROR: Unknown JAEGER_STORAGE_TYPE '${STORAGE}'." \
             "Use 'elasticsearch' or 'cassandra'." >&2
        exit 1
        ;;
    esac
    ;;
  *)
    echo "[install-jaeger] ERROR: Unknown JAEGER_STRATEGY '${STRATEGY}'." \
         "Use 'allInOne' or 'production'." >&2
    exit 1
    ;;
esac

# -----------------------------------------------------------------------------
# Expose the Jaeger UI (query service) via the cluster service type
# In allInOne mode the UI is part of the all-in-one pod; in production it's
# the separate query deployment.
# -----------------------------------------------------------------------------
if [[ "$STRATEGY" == "allInOne" ]]; then
  STRATEGY_FLAGS+=(
    "--set" "allInOne.service.type=${SERVICE_TYPE}"
  )
else
  STRATEGY_FLAGS+=(
    "--set" "query.service.type=${SERVICE_TYPE}"
  )
fi

# -----------------------------------------------------------------------------
# Deploy Jaeger
# -----------------------------------------------------------------------------
echo "[install-jaeger] Deploying Jaeger (release: $JAEGER_RELEASE_NAME," \
     "namespace: $JAEGER_NAMESPACE)..."

helm upgrade --install "$JAEGER_RELEASE_NAME" jaegertracing/jaeger \
  --namespace "$JAEGER_NAMESPACE" \
  --create-namespace \
  --values "${VALUES_DIR}/jaeger.yaml" \
  "${STRATEGY_FLAGS[@]}" \
  --timeout "${ROLLOUT_TIMEOUT}s" \
  --wait

echo "[install-jaeger] Waiting for Jaeger pods to be ready..."

if [[ "$STRATEGY" == "allInOne" ]]; then
  kubectl wait pod \
    -n "$JAEGER_NAMESPACE" \
    -l "app.kubernetes.io/instance=${JAEGER_RELEASE_NAME},app.kubernetes.io/component=all-in-one" \
    --for=condition=Ready \
    --timeout="${ROLLOUT_TIMEOUT}s" 2>/dev/null || \
  kubectl wait pod \
    -n "$JAEGER_NAMESPACE" \
    -l "app=${JAEGER_RELEASE_NAME}" \
    --for=condition=Ready \
    --timeout="${ROLLOUT_TIMEOUT}s"
else
  kubectl wait pod \
    -n "$JAEGER_NAMESPACE" \
    -l "app.kubernetes.io/instance=${JAEGER_RELEASE_NAME}" \
    --for=condition=Ready \
    --timeout="${ROLLOUT_TIMEOUT}s"
fi

echo "[install-jaeger] Jaeger ready."
