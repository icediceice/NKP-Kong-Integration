#!/usr/bin/env bash
# =============================================================================
# Install Jaeger v2 — Distributed Tracing
# Sourced by install.sh; all required variables must already be exported.
#
# Chart: jaegertracing/jaeger v4.x (Jaeger 2.x)
# Jaeger v2 is a single binary — collector + query UI + storage in one pod.
#
# Strategies:
#   allInOne   — In-memory storage. Zero dependencies. Default POC mode.
#   production — External Elasticsearch backend (requires JAEGER_ES_URL set).
#                Set JAEGER_ES_URL=http://elasticsearch:9200 in config.env.
#
# Variables consumed:
#   JAEGER_NAMESPACE    JAEGER_RELEASE_NAME
#   JAEGER_STRATEGY     JAEGER_ES_URL   (production only)
#   SERVICE_TYPE        ROLLOUT_TIMEOUT
# =============================================================================
set -euo pipefail

trap 'echo "[install-jaeger] ERROR at line $LINENO" >&2' ERR

VALUES_DIR="${SCRIPT_DIR}/helm-values"
STRATEGY="${JAEGER_STRATEGY:-allInOne}"
echo "[install-jaeger] Strategy: $STRATEGY"

# DEPLOY_FLAGS accumulates all --set overrides
DEPLOY_FLAGS=()

# Expose the Jaeger service (UI + OTLP + collector ports — all on one service)
DEPLOY_FLAGS+=("--set" "jaeger.service.type=${SERVICE_TYPE}")

# -----------------------------------------------------------------------------
# Strategy-specific configuration
# -----------------------------------------------------------------------------
case "$STRATEGY" in
  allInOne)
    echo "[install-jaeger] Storage: in-memory (no external dependencies)"
    # No extra flags needed — Jaeger v2 defaults to in-memory when no userconfig is set.
    ;;

  production)
    ES_URL="${JAEGER_ES_URL:-}"
    if [[ -z "$ES_URL" ]]; then
      echo "[install-jaeger] ERROR: JAEGER_STRATEGY=production requires JAEGER_ES_URL in config.env." >&2
      echo "[install-jaeger]   Example: JAEGER_ES_URL=http://elasticsearch-master.elasticsearch:9200" >&2
      echo "[install-jaeger]   Deploy Elasticsearch first (e.g. helm install elasticsearch elastic/elasticsearch)." >&2
      exit 1
    fi
    echo "[install-jaeger] Storage: Elasticsearch at $ES_URL"

    # Write the Jaeger v2 OTEL collector config to a temp values file.
    # The chart template mounts userconfig as a ConfigMap and uses toYaml on it,
    # so it must be a structured YAML map — not a raw string.
    JAEGER_USERCONFIG_TMP=$(mktemp /tmp/jaeger-userconfig-XXXXXX.yaml)
    trap 'rm -f "$JAEGER_USERCONFIG_TMP"' EXIT

    cat > "$JAEGER_USERCONFIG_TMP" <<EOF
userconfig:
  service:
    extensions:
      - jaeger_storage
      - jaeger_query
      - healthcheckv2
    pipelines:
      traces:
        receivers: [otlp]
        exporters: [jaeger_storage_exporter]
  extensions:
    healthcheckv2:
      use_v2: true
      http:
        endpoint: 0.0.0.0:13133
    jaeger_storage:
      backends:
        primary_store:
          elasticsearch:
            server_urls:
              - ${ES_URL}
    jaeger_query:
      storage:
        traces: primary_store
  receivers:
    otlp:
      protocols:
        grpc:
          endpoint: 0.0.0.0:4317
        http:
          endpoint: 0.0.0.0:4318
  exporters:
    jaeger_storage_exporter:
      trace_storage: primary_store
EOF

    DEPLOY_FLAGS+=("--values" "$JAEGER_USERCONFIG_TMP")
    ;;

  *)
    echo "[install-jaeger] ERROR: Unknown JAEGER_STRATEGY '${STRATEGY}'." \
         "Use 'allInOne' or 'production'." >&2
    exit 1
    ;;
esac

# -----------------------------------------------------------------------------
# Deploy Jaeger
# -----------------------------------------------------------------------------
echo "[install-jaeger] Deploying Jaeger (release: $JAEGER_RELEASE_NAME," \
     "namespace: $JAEGER_NAMESPACE)..."

helm upgrade --install "$JAEGER_RELEASE_NAME" jaegertracing/jaeger \
  --namespace "$JAEGER_NAMESPACE" \
  --create-namespace \
  --values "${VALUES_DIR}/jaeger.yaml" \
  "${DEPLOY_FLAGS[@]}" \
  --timeout "${ROLLOUT_TIMEOUT}s" \
  --wait

# -----------------------------------------------------------------------------
# Wait for pod readiness
# Jaeger v2 pod labels: app.kubernetes.io/name=jaeger + instance + component=all-in-one
# -----------------------------------------------------------------------------
echo "[install-jaeger] Waiting for Jaeger pod to be ready..."
kubectl wait pod \
  -n "$JAEGER_NAMESPACE" \
  -l "app.kubernetes.io/name=jaeger,app.kubernetes.io/instance=${JAEGER_RELEASE_NAME}" \
  --for=condition=Ready \
  --timeout="${ROLLOUT_TIMEOUT}s"

echo "[install-jaeger] Jaeger ready."
