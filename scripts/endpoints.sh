#!/usr/bin/env bash
# =============================================================================
# endpoints.sh — Print all external access points for the installed stack
# Usage: bash scripts/endpoints.sh
#        Source config.env first, or run via install.sh (variables exported).
# =============================================================================
set -euo pipefail

# Load config if not already sourced
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

if [[ -z "${KAFKA_NAMESPACE:-}" ]]; then
  if [[ -f "${REPO_ROOT}/config.env" ]]; then
    # shellcheck source=/dev/null
    source "${REPO_ROOT}/config.env"
  fi
fi

# Defaults (mirrors install.sh)
KAFKA_NAMESPACE="${KAFKA_NAMESPACE:-kafka}"
KONG_NAMESPACE="${KONG_NAMESPACE:-kong}"
KAFKA_RELEASE_NAME="${KAFKA_RELEASE_NAME:-kafka}"
KONG_RELEASE_NAME="${KONG_RELEASE_NAME:-kong}"
JAEGER_NAMESPACE="${JAEGER_NAMESPACE:-observability}"
JAEGER_RELEASE_NAME="${JAEGER_RELEASE_NAME:-jaeger}"
SR_ENABLED="${SR_ENABLED:-true}"
CC_ENABLED="${CC_ENABLED:-true}"
JAEGER_ENABLED="${JAEGER_ENABLED:-false}"

KONG_DB_MODE="${KONG_DB_MODE:-dbless}"

get_lb_ip() {
  local ns="$1" svc="$2"
  kubectl get svc -n "$ns" "$svc" \
    -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo ""
}

get_secret_field() {
  local ns="$1" secret="$2" field="$3"
  kubectl get secret -n "$ns" "$secret" \
    -o jsonpath="{.data.${field}}" 2>/dev/null \
    | base64 -d 2>/dev/null || echo ""
}

hr() { echo "────────────────────────────────────────────────────────────"; }

echo ""
hr
echo "  Kongka Stack — Endpoint Summary"
hr

# ---------------------------------------------------------------------------
echo ""
echo "  KAFKA"
echo ""
echo "  Bootstrap (in-cluster only):"
echo "    kafka:  ${KAFKA_RELEASE_NAME}-kafka-client.${KAFKA_NAMESPACE}.svc.cluster.local:9092"
echo "  Credentials: none (no SASL configured — POC mode)"

if [[ "${SR_ENABLED}" == "true" ]]; then
  SR_IP=$(get_lb_ip "$KAFKA_NAMESPACE" "${KAFKA_RELEASE_NAME}-sr-lb")
  echo ""
  echo "  Schema Registry (external):"
  if [[ -n "$SR_IP" ]]; then
    echo "    REST API:  http://${SR_IP}:8081"
    echo "    Health:    http://${SR_IP}:8081/"
  else
    echo "    LB IP not assigned — kubectl get svc -n ${KAFKA_NAMESPACE} ${KAFKA_RELEASE_NAME}-sr-lb"
  fi
  echo "  Credentials: none (no basic-auth configured — POC mode)"
fi

if [[ "${CC_ENABLED}" == "true" ]]; then
  CC_IP=$(get_lb_ip "$KAFKA_NAMESPACE" "${KAFKA_RELEASE_NAME}-cc-lb")
  echo ""
  echo "  Control Center (external):"
  if [[ -n "$CC_IP" ]]; then
    echo "    UI:        http://${CC_IP}:9021"
  else
    echo "    LB IP not assigned — kubectl get svc -n ${KAFKA_NAMESPACE} ${KAFKA_RELEASE_NAME}-cc-lb"
  fi
  echo "  Credentials: none (no RBAC/LDAP configured — POC mode)"
fi

# ---------------------------------------------------------------------------
echo ""
echo "  KONG"
echo ""
KONG_PROXY_IP=$(get_lb_ip "$KONG_NAMESPACE" "${KONG_RELEASE_NAME}-kong-proxy")
if [[ -n "$KONG_PROXY_IP" ]]; then
  echo "  Proxy (external):"
  echo "    HTTP:      http://${KONG_PROXY_IP}"
  echo "    HTTPS:     https://${KONG_PROXY_IP}"

  ADMIN_IP=$(get_lb_ip "$KONG_NAMESPACE" "${KONG_RELEASE_NAME}-kong-admin" 2>/dev/null || echo "")
  if [[ -n "$ADMIN_IP" ]]; then
    echo "  Admin API (external):"
    echo "    HTTP:      http://${ADMIN_IP}:8001"
    echo "    HTTPS:     https://${ADMIN_IP}:8444"
    echo "  Credentials: none (Kong OSS Admin API has no built-in auth)"
  else
    echo "  Admin API: ClusterIP only — not exposed externally"
    echo "    Port-forward: kubectl port-forward -n ${KONG_NAMESPACE} svc/${KONG_RELEASE_NAME}-kong-admin 8001:8001"
    echo "  Credentials: none (Kong OSS Admin API has no built-in auth)"
  fi
else
  echo "  LB IP not assigned — kubectl get svc -n ${KONG_NAMESPACE}"
fi

if [[ "${KONG_DB_MODE}" == "postgres" ]]; then
  echo ""
  echo "  Kong Postgres:"
  PG_PASS=$(get_secret_field "$KONG_NAMESPACE" "${KONG_RELEASE_NAME}-postgresql" "password")
  PG_PASS_ALT=$(get_secret_field "$KONG_NAMESPACE" "${KONG_RELEASE_NAME}-postgresql" "postgres-password")
  if [[ -n "$PG_PASS" ]]; then
    echo "    Secret:    ${KONG_RELEASE_NAME}-postgresql (namespace: ${KONG_NAMESPACE})"
    echo "    User:      kong"
    echo "    Password:  ${PG_PASS}"
  elif [[ -n "$PG_PASS_ALT" ]]; then
    echo "    Secret:    ${KONG_RELEASE_NAME}-postgresql (namespace: ${KONG_NAMESPACE})"
    echo "    User:      postgres"
    echo "    Password:  ${PG_PASS_ALT}"
  else
    echo "    Secret not found — kubectl get secret -n ${KONG_NAMESPACE} ${KONG_RELEASE_NAME}-postgresql"
  fi
fi

# ---------------------------------------------------------------------------
if [[ "${JAEGER_ENABLED}" == "true" ]]; then
  echo ""
  echo "  JAEGER"
  echo ""
  JAEGER_IP=$(get_lb_ip "$JAEGER_NAMESPACE" "$JAEGER_RELEASE_NAME")
  if [[ -n "$JAEGER_IP" ]]; then
    echo "  Jaeger (external):"
    echo "    UI:        http://${JAEGER_IP}:16686"
    echo "    OTLP gRPC: ${JAEGER_IP}:4317"
    echo "    OTLP HTTP: http://${JAEGER_IP}:4318"
    echo "    Thrift:    http://${JAEGER_IP}:14268/api/traces"
  else
    echo "  LB IP not assigned — kubectl get svc -n ${JAEGER_NAMESPACE} ${JAEGER_RELEASE_NAME}"
  fi
  echo "  Credentials: none (Jaeger all-in-one has no auth)"
fi

echo ""
hr
echo ""
