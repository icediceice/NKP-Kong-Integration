#!/usr/bin/env bash
# =============================================================================
# Preflight checks — validates cluster and tooling before install
# Sourced by install.sh; all required variables must already be exported.
# =============================================================================
set -euo pipefail

ERRORS=0
WARNINGS=0

fail()    { echo "[preflight] FAIL: $*" >&2;  ERRORS=$((ERRORS + 1)); }
warn()    { echo "[preflight] WARN: $*"; WARNINGS=$((WARNINGS + 1)); }
ok()      { echo "[preflight]   OK: $*"; }
section() { echo "[preflight] --- $* ---"; }

# -----------------------------------------------------------------------------
section "Tools"
# -----------------------------------------------------------------------------

# kubectl
if ! command -v kubectl &>/dev/null; then
  fail "kubectl not found in PATH"
else
  KUBECTL_VER=$(kubectl version --client -o json 2>/dev/null | grep -o '"gitVersion": "[^"]*"' | head -1 | cut -d'"' -f4)
  ok "kubectl found ($KUBECTL_VER)"
fi

# helm
if ! command -v helm &>/dev/null; then
  fail "helm not found in PATH"
else
  HELM_VER=$(helm version --short 2>/dev/null || echo "unknown")
  if [[ "$HELM_VER" != v3* ]]; then
    fail "helm 3.x required, found: $HELM_VER"
  else
    ok "helm found ($HELM_VER)"
  fi
fi

# Abort early if tools are missing — remaining checks depend on them
if [[ $ERRORS -gt 0 ]]; then
  echo "[preflight] Aborting: required tools missing." >&2
  exit 1
fi

# -----------------------------------------------------------------------------
section "Cluster connectivity"
# -----------------------------------------------------------------------------

if ! kubectl cluster-info &>/dev/null; then
  fail "Cannot reach Kubernetes API. Check kubectl context and VPN."
else
  CONTEXT=$(kubectl config current-context 2>/dev/null || echo "unknown")
  ok "Cluster reachable (context: $CONTEXT)"
fi

# Node count sanity check
NODE_COUNT=$(kubectl get nodes --no-headers 2>/dev/null | wc -l || echo 0)
if [[ "$NODE_COUNT" -lt 1 ]]; then
  fail "No nodes found in cluster"
else
  ok "$NODE_COUNT node(s) found"
  if [[ "${JAEGER_ONLY:-false}" == "false" && "$NODE_COUNT" -lt 3 ]]; then
    warn "Fewer than 3 nodes — Kafka KRaft quorum requires 3 pods; ensure they can schedule"
  fi
fi

# -----------------------------------------------------------------------------
section "StorageClass"
# -----------------------------------------------------------------------------

if [[ "${JAEGER_ONLY:-false}" == "true" ]]; then
  ok "StorageClass check skipped (--jaeger-only)"
elif ! kubectl get storageclass "$KAFKA_STORAGE_CLASS" &>/dev/null; then
  fail "StorageClass '$KAFKA_STORAGE_CLASS' not found. Update KAFKA_STORAGE_CLASS in config.env."
  echo "[preflight]       Available StorageClasses:"
  kubectl get storageclass --no-headers 2>/dev/null | awk '{print "                  " $1}' || true
else
  ok "StorageClass '$KAFKA_STORAGE_CLASS' exists"
fi

# -----------------------------------------------------------------------------
section "Node resources (advisory)"
# -----------------------------------------------------------------------------

# Total allocatable CPU across all nodes
TOTAL_CPU=$(kubectl get nodes -o jsonpath='{range .items[*]}{.status.allocatable.cpu}{"\n"}{end}' 2>/dev/null \
  | awk '{sum += $1} END {print sum}' || echo 0)

# Total allocatable memory in Ki
TOTAL_MEM_KI=$(kubectl get nodes -o jsonpath='{range .items[*]}{.status.allocatable.memory}{"\n"}{end}' 2>/dev/null \
  | sed 's/Ki//' | awk '{sum += $1} END {print sum}' || echo 0)

TOTAL_MEM_GI=$(awk "BEGIN {printf \"%.0f\", $TOTAL_MEM_KI / 1048576}")

ok "Total allocatable: ~${TOTAL_CPU} CPU cores, ~${TOTAL_MEM_GI}Gi RAM"

# Kafka alone: BROKER_COUNT * CPU_LIMIT — skip if Jaeger-only
if [[ "${JAEGER_ONLY:-false}" == "false" ]]; then
  REQ_CPU=$((KAFKA_BROKER_COUNT * KAFKA_CPU_LIMIT))
  if [[ "$TOTAL_CPU" -gt 0 ]] && [[ "$TOTAL_CPU" -lt "$REQ_CPU" ]]; then
    warn "Kafka needs ~${REQ_CPU} CPU cores; cluster has ~${TOTAL_CPU}. Pods may be pending."
  fi
fi

# -----------------------------------------------------------------------------
section "Network / registry access"
# -----------------------------------------------------------------------------

# Test Helm repo reachability
if curl -sf --max-time 10 https://confluentinc.github.io/cp-helm-charts/ &>/dev/null; then
  ok "Confluent Helm repo reachable"
else
  warn "Cannot reach Confluent Helm repo — check internet/proxy settings"
fi

if curl -sf --max-time 10 https://charts.konghq.com &>/dev/null; then
  ok "Kong Helm repo reachable"
else
  warn "Cannot reach Kong Helm repo — check internet/proxy settings"
fi

if [[ "${JAEGER_ENABLED:-false}" == "true" || "${JAEGER_ONLY:-false}" == "true" ]]; then
  if curl -sf --max-time 10 https://jaegertracing.github.io/helm-charts &>/dev/null; then
    ok "Jaeger Helm repo reachable"
  else
    warn "Cannot reach Jaeger Helm repo — check internet/proxy settings"
  fi
fi

# -----------------------------------------------------------------------------
section "Summary"
# -----------------------------------------------------------------------------

echo "[preflight] Errors:   $ERRORS"
echo "[preflight] Warnings: $WARNINGS"

if [[ $ERRORS -gt 0 ]]; then
  echo "[preflight] Preflight FAILED. Fix errors above before installing." >&2
  exit 1
fi

if [[ $WARNINGS -gt 0 ]]; then
  echo "[preflight] Preflight passed with warnings. Review warnings above."
else
  echo "[preflight] Preflight passed cleanly."
fi
