#!/usr/bin/env bash
# =============================================================================
# Kongka Stack — Diagnostic Collector
#
# Captures the full state of the Kafka + Kong stack into a single text file
# that can be shared with Claude for rapid diagnosis and fixes.
#
# Usage:
#   bash scripts/diag.sh                  # uses config.env
#   bash scripts/diag.sh --namespace kafka  # override namespace
#
# Output: diag-<timestamp>.txt in the repo root
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

# ---------------------------------------------------------------------------
# Load config
# ---------------------------------------------------------------------------
CONFIG_FILE="${REPO_DIR}/config.env"
if [[ -f "$CONFIG_FILE" ]]; then
  # shellcheck source=/dev/null
  source "$CONFIG_FILE"
fi

KAFKA_NAMESPACE="${KAFKA_NAMESPACE:-kafka}"
KONG_NAMESPACE="${KONG_NAMESPACE:-kong}"
KAFKA_RELEASE_NAME="${KAFKA_RELEASE_NAME:-kafka}"
KONG_RELEASE_NAME="${KONG_RELEASE_NAME:-kong}"
KAFKA_BROKER_COUNT="${KAFKA_BROKER_COUNT:-3}"
SR_ENABLED="${SR_ENABLED:-true}"
CC_ENABLED="${CC_ENABLED:-true}"

# Parse any CLI overrides
for arg in "$@"; do
  case "$arg" in
    --namespace=*) KAFKA_NAMESPACE="${arg#*=}" ;;
  esac
done

OUTFILE="${REPO_DIR}/diag-$(date -u +"%Y%m%d-%H%M%S").txt"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
section() { printf '\n\n════════════════════════════════════════\n%s\n════════════════════════════════════════\n' "$1" >> "$OUTFILE"; }
cmd()     { printf '\n$ %s\n' "$*" >> "$OUTFILE"; "$@" >> "$OUTFILE" 2>&1 || true; }
info()    { echo "$*" >> "$OUTFILE"; }

echo "[diag] Collecting diagnostics..."

# ---------------------------------------------------------------------------
# Header
# ---------------------------------------------------------------------------
{
  echo "Kongka Stack — Diagnostic Report"
  echo "Generated : $(date -u)"
  echo "Cluster   : ${KUBECONFIG:-default kubeconfig}"
  echo "Config    : ${CONFIG_FILE}"
  echo ""
  echo "KAFKA_NAMESPACE    = ${KAFKA_NAMESPACE}"
  echo "KONG_NAMESPACE     = ${KONG_NAMESPACE}"
  echo "KAFKA_RELEASE_NAME = ${KAFKA_RELEASE_NAME}"
  echo "KONG_RELEASE_NAME  = ${KONG_RELEASE_NAME}"
  echo "KAFKA_BROKER_COUNT = ${KAFKA_BROKER_COUNT}"
  echo "SR_ENABLED         = ${SR_ENABLED}"
  echo "CC_ENABLED         = ${CC_ENABLED}"
  echo "KAFKA_CLUSTER_ID   = ${KAFKA_CLUSTER_ID:-<not set — auto-generated>}"
  CLUSTER_ID_FILE="${REPO_DIR}/.kafka-cluster-id"
  if [[ -f "$CLUSTER_ID_FILE" ]]; then
    echo ".kafka-cluster-id  = $(cat "$CLUSTER_ID_FILE")"
  else
    echo ".kafka-cluster-id  = <file missing>"
  fi
} > "$OUTFILE"

# ---------------------------------------------------------------------------
# Cluster info
# ---------------------------------------------------------------------------
section "CLUSTER NODES"
cmd kubectl get nodes -o wide

section "STORAGE CLASSES"
cmd kubectl get storageclass

# ---------------------------------------------------------------------------
# Helm releases
# ---------------------------------------------------------------------------
section "HELM RELEASES — kafka namespace"
cmd helm list -n "$KAFKA_NAMESPACE"

section "HELM RELEASES — kong namespace"
cmd helm list -n "$KONG_NAMESPACE"

section "HELM STATUS — kafka release"
cmd helm status "$KAFKA_RELEASE_NAME" -n "$KAFKA_NAMESPACE"

# ---------------------------------------------------------------------------
# Kafka namespace — overview
# ---------------------------------------------------------------------------
section "PODS — kafka namespace"
cmd kubectl get pods -n "$KAFKA_NAMESPACE" -o wide

section "PVCS — kafka namespace"
cmd kubectl get pvc -n "$KAFKA_NAMESPACE"

section "SERVICES — kafka namespace"
cmd kubectl get svc -n "$KAFKA_NAMESPACE"

section "EVENTS — kafka namespace (last 40, sorted by time)"
cmd kubectl get events -n "$KAFKA_NAMESPACE" \
  --sort-by='.lastTimestamp' | tail -40

# ---------------------------------------------------------------------------
# Kafka broker pods — logs + describe
# ---------------------------------------------------------------------------
for i in $(seq 0 $(( KAFKA_BROKER_COUNT - 1 ))); do
  POD="${KAFKA_RELEASE_NAME}-kafka-${i}"
  section "POD: ${POD}"

  info "--- describe ---"
  cmd kubectl describe pod "$POD" -n "$KAFKA_NAMESPACE"

  info ""
  info "--- init container: kafka-storage-format (last 30 lines) ---"
  cmd kubectl logs "$POD" -n "$KAFKA_NAMESPACE" \
    -c kafka-storage-format --tail=30

  info ""
  info "--- main container: kafka (last 60 lines) ---"
  cmd kubectl logs "$POD" -n "$KAFKA_NAMESPACE" \
    -c kafka --tail=60

  info ""
  info "--- previous crash logs (if any) ---"
  kubectl logs "$POD" -n "$KAFKA_NAMESPACE" -c kafka --previous --tail=40 \
    >> "$OUTFILE" 2>&1 || info "(no previous crash logs)"
done

# ---------------------------------------------------------------------------
# Schema Registry
# ---------------------------------------------------------------------------
if [[ "${SR_ENABLED}" == "true" ]]; then
  section "SCHEMA REGISTRY"

  SR_POD=$(kubectl get pod -n "$KAFKA_NAMESPACE" \
    -l "app=schema-registry,release=${KAFKA_RELEASE_NAME}" \
    -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")

  if [[ -n "$SR_POD" ]]; then
    info "Pod: $SR_POD"
    cmd kubectl describe pod "$SR_POD" -n "$KAFKA_NAMESPACE"
    info ""
    info "--- logs (last 40 lines) ---"
    cmd kubectl logs "$SR_POD" -n "$KAFKA_NAMESPACE" --tail=40
    info ""
    info "--- previous crash logs (if any) ---"
    kubectl logs "$SR_POD" -n "$KAFKA_NAMESPACE" --previous --tail=30 \
      >> "$OUTFILE" 2>&1 || info "(no previous crash logs)"
  else
    info "No Schema Registry pod found."
  fi
fi

# ---------------------------------------------------------------------------
# Control Center
# ---------------------------------------------------------------------------
if [[ "${CC_ENABLED}" == "true" ]]; then
  section "CONTROL CENTER"

  CC_POD=$(kubectl get pod -n "$KAFKA_NAMESPACE" \
    -l "app=control-center,release=${KAFKA_RELEASE_NAME}" \
    -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")

  if [[ -n "$CC_POD" ]]; then
    info "Pod: $CC_POD"
    cmd kubectl describe pod "$CC_POD" -n "$KAFKA_NAMESPACE"
    info ""
    info "--- logs (last 40 lines) ---"
    cmd kubectl logs "$CC_POD" -n "$KAFKA_NAMESPACE" --tail=40
    info ""
    info "--- previous crash logs (if any) ---"
    kubectl logs "$CC_POD" -n "$KAFKA_NAMESPACE" --previous --tail=30 \
      >> "$OUTFILE" 2>&1 || info "(no previous crash logs)"
  else
    info "No Control Center pod found."
  fi
fi

# ---------------------------------------------------------------------------
# KRaft health (only if at least one broker is running)
# ---------------------------------------------------------------------------
section "KRAFT QUORUM STATUS"
KAFKA_POD=$(kubectl get pod -n "$KAFKA_NAMESPACE" \
  -l "app=kafka,release=${KAFKA_RELEASE_NAME}" \
  -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")

if [[ -n "$KAFKA_POD" ]]; then
  info "Querying from pod: $KAFKA_POD"
  cmd kubectl exec -n "$KAFKA_NAMESPACE" "$KAFKA_POD" -- \
    kafka-metadata-quorum --bootstrap-server localhost:9092 describe --status
  info ""
  info "--- broker API versions (visible broker count) ---"
  cmd kubectl exec -n "$KAFKA_NAMESPACE" "$KAFKA_POD" -- \
    bash -c "kafka-broker-api-versions --bootstrap-server localhost:9092 2>/dev/null | grep 'id:' | wc -l"
else
  info "No Kafka pod available for KRaft health check."
fi

# ---------------------------------------------------------------------------
# Kong namespace
# ---------------------------------------------------------------------------
section "PODS — kong namespace"
cmd kubectl get pods -n "$KONG_NAMESPACE" -o wide

section "SERVICES — kong namespace"
cmd kubectl get svc -n "$KONG_NAMESPACE"

section "EVENTS — kong namespace (last 20)"
cmd kubectl get events -n "$KONG_NAMESPACE" \
  --sort-by='.lastTimestamp' | tail -20

KONG_POD=$(kubectl get pod -n "$KONG_NAMESPACE" \
  -l "app.kubernetes.io/name=kong,app.kubernetes.io/instance=${KONG_RELEASE_NAME}" \
  -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")

if [[ -n "$KONG_POD" ]]; then
  section "POD: ${KONG_POD}"
  cmd kubectl describe pod "$KONG_POD" -n "$KONG_NAMESPACE"
  info ""
  info "--- logs (last 40 lines) ---"
  cmd kubectl logs "$KONG_POD" -n "$KONG_NAMESPACE" --tail=40
fi

# ---------------------------------------------------------------------------
# ConfigMap — cluster ID
# ---------------------------------------------------------------------------
section "CONFIGMAP — kafka-cluster-id"
cmd kubectl get configmap \
  "${KAFKA_RELEASE_NAME}-kafka-cluster-id" \
  -n "$KAFKA_NAMESPACE" -o yaml

# ---------------------------------------------------------------------------
# Helm chart values (what was actually deployed)
# ---------------------------------------------------------------------------
section "HELM VALUES — kafka release (computed)"
cmd helm get values "$KAFKA_RELEASE_NAME" -n "$KAFKA_NAMESPACE" --all

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
section "QUICK SUMMARY"
{
  echo "Kafka pods:"
  kubectl get pods -n "$KAFKA_NAMESPACE" \
    -l "app=kafka,release=${KAFKA_RELEASE_NAME}" \
    --no-headers 2>/dev/null || echo "  (none found)"

  echo ""
  echo "Schema Registry:"
  kubectl get pods -n "$KAFKA_NAMESPACE" \
    -l "app=schema-registry,release=${KAFKA_RELEASE_NAME}" \
    --no-headers 2>/dev/null || echo "  (none found)"

  echo ""
  echo "Control Center:"
  kubectl get pods -n "$KAFKA_NAMESPACE" \
    -l "app=control-center,release=${KAFKA_RELEASE_NAME}" \
    --no-headers 2>/dev/null || echo "  (none found)"

  echo ""
  echo "Kong:"
  kubectl get pods -n "$KONG_NAMESPACE" \
    -l "app.kubernetes.io/name=kong,app.kubernetes.io/instance=${KONG_RELEASE_NAME}" \
    --no-headers 2>/dev/null || echo "  (none found)"

  echo ""
  echo "LoadBalancer IPs:"
  CC_IP=$(kubectl get svc "${KAFKA_RELEASE_NAME}-cc-lb" -n "$KAFKA_NAMESPACE" \
    -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "pending")
  KONG_IP=$(kubectl get svc "${KONG_RELEASE_NAME}-kong-proxy" -n "$KONG_NAMESPACE" \
    -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "pending")
  echo "  Control Center : ${CC_IP:-pending}:9021"
  echo "  Kong proxy     : ${KONG_IP:-pending}:80"
} >> "$OUTFILE"

# ---------------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------------
echo "[diag] Done."
echo ""
echo "  Output: ${OUTFILE}"
echo ""
echo "  Paste the contents of this file to Claude with a description of the"
echo "  issue you are seeing. Claude will diagnose and provide a targeted fix."
echo ""
echo "  cat ${OUTFILE}"
