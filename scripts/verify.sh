#!/usr/bin/env bash
# =============================================================================
# Post-install verification
# Sourced by install.sh; all required variables must already be exported.
# =============================================================================
set -euo pipefail

ERRORS=0
pass()    { echo "[verify]   PASS: $*"; }
fail()    { echo "[verify]   FAIL: $*" >&2; ERRORS=$((ERRORS + 1)); }
info()    { echo "[verify]   INFO: $*"; }
section() { echo "[verify] --- $* ---"; }

# -----------------------------------------------------------------------------
section "Kafka pods"
# -----------------------------------------------------------------------------

NOT_READY=$(kubectl get pods -n "$KAFKA_NAMESPACE" \
  -l "app=cp-kafka,release=${KAFKA_RELEASE_NAME}" \
  --no-headers 2>/dev/null \
  | grep -v -E "Running|Completed" | wc -l || echo 0)

if [[ "$NOT_READY" -gt 0 ]]; then
  fail "$NOT_READY Kafka pod(s) not Running"
  kubectl get pods -n "$KAFKA_NAMESPACE" -l "app=cp-kafka,release=${KAFKA_RELEASE_NAME}" 2>/dev/null || true
else
  RUNNING=$(kubectl get pods -n "$KAFKA_NAMESPACE" \
    -l "app=cp-kafka,release=${KAFKA_RELEASE_NAME}" --no-headers 2>/dev/null | wc -l)
  pass "$RUNNING Kafka pod(s) Running"
fi

# -----------------------------------------------------------------------------
section "Kafka cluster metadata"
# -----------------------------------------------------------------------------

# Try to exec into a broker and check broker count
KAFKA_POD=$(kubectl get pod -n "$KAFKA_NAMESPACE" \
  -l "app=cp-kafka,release=${KAFKA_RELEASE_NAME}" \
  -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")

if [[ -n "$KAFKA_POD" ]]; then
  BROKER_IDS=$(kubectl exec -n "$KAFKA_NAMESPACE" "$KAFKA_POD" -- \
    bash -c "kafka-broker-api-versions --bootstrap-server localhost:9092 2>/dev/null | grep 'id:' | wc -l" \
    2>/dev/null || echo "unknown")
  info "Brokers visible from $KAFKA_POD: $BROKER_IDS"
  if [[ "$BROKER_IDS" == "$KAFKA_BROKER_COUNT" ]]; then
    pass "All $KAFKA_BROKER_COUNT brokers responding"
  elif [[ "$BROKER_IDS" == "unknown" ]]; then
    info "Could not verify broker count (exec unavailable)"
  else
    fail "Expected $KAFKA_BROKER_COUNT brokers, found $BROKER_IDS"
  fi
else
  info "No Kafka pod found to exec into for metadata check"
fi

# -----------------------------------------------------------------------------
section "Schema Registry"
# -----------------------------------------------------------------------------

if [[ "${SR_ENABLED:-true}" == "true" ]]; then
  NOT_READY=$(kubectl get pods -n "$KAFKA_NAMESPACE" \
    -l "app=cp-schema-registry,release=${SR_RELEASE_NAME}" \
    --no-headers 2>/dev/null | grep -v -E "Running|Completed" | wc -l || echo 0)
  if [[ "$NOT_READY" -gt 0 ]]; then
    fail "Schema Registry pod not Running"
  else
    pass "Schema Registry pod Running"
  fi
fi

# -----------------------------------------------------------------------------
section "Control Center"
# -----------------------------------------------------------------------------

if [[ "${CC_ENABLED:-true}" == "true" ]]; then
  NOT_READY=$(kubectl get pods -n "$KAFKA_NAMESPACE" \
    -l "app=cp-enterprise-control-center,release=${CC_RELEASE_NAME}" \
    --no-headers 2>/dev/null | grep -v -E "Running|Completed" | wc -l || echo 0)
  if [[ "$NOT_READY" -gt 0 ]]; then
    fail "Control Center pod not Running"
  else
    pass "Control Center pod Running"
    CC_SVC_IP=$(kubectl get svc -n "$KAFKA_NAMESPACE" \
      -l "app=cp-enterprise-control-center,release=${CC_RELEASE_NAME}" \
      -o jsonpath='{.items[0].status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "")
    if [[ -n "$CC_SVC_IP" ]]; then
      info "Control Center LoadBalancer IP: $CC_SVC_IP (port 9021)"
    else
      info "Control Center LB IP not yet assigned — run: kubectl get svc -n $KAFKA_NAMESPACE"
    fi
  fi
fi

# -----------------------------------------------------------------------------
section "Kong pods"
# -----------------------------------------------------------------------------

NOT_READY=$(kubectl get pods -n "$KONG_NAMESPACE" \
  -l "app.kubernetes.io/name=kong,app.kubernetes.io/instance=${KONG_RELEASE_NAME}" \
  --no-headers 2>/dev/null | grep -v -E "Running|Completed" | wc -l || echo 0)

if [[ "$NOT_READY" -gt 0 ]]; then
  fail "$NOT_READY Kong pod(s) not Running"
  kubectl get pods -n "$KONG_NAMESPACE" 2>/dev/null || true
else
  RUNNING=$(kubectl get pods -n "$KONG_NAMESPACE" \
    -l "app.kubernetes.io/name=kong,app.kubernetes.io/instance=${KONG_RELEASE_NAME}" \
    --no-headers 2>/dev/null | wc -l)
  pass "$RUNNING Kong pod(s) Running"
fi

# -----------------------------------------------------------------------------
section "Kong proxy reachability"
# -----------------------------------------------------------------------------

KONG_PROXY_IP=$(kubectl get svc -n "$KONG_NAMESPACE" \
  "${KONG_RELEASE_NAME}-kong-proxy" \
  -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "")

if [[ -n "$KONG_PROXY_IP" ]]; then
  if curl -sf --max-time 5 "http://${KONG_PROXY_IP}" &>/dev/null; then
    pass "Kong proxy responding at http://${KONG_PROXY_IP}"
  else
    # Kong returns 404 on root with no routes — that's healthy
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "http://${KONG_PROXY_IP}" 2>/dev/null || echo 0)
    if [[ "$HTTP_CODE" == "404" ]]; then
      pass "Kong proxy responding at http://${KONG_PROXY_IP} (404 expected — no routes configured)"
    else
      fail "Kong proxy not responding at http://${KONG_PROXY_IP} (HTTP $HTTP_CODE)"
    fi
  fi
else
  info "Kong proxy LB IP not yet assigned — run: kubectl get svc -n $KONG_NAMESPACE"
fi

# -----------------------------------------------------------------------------
section "Summary"
# -----------------------------------------------------------------------------

if [[ $ERRORS -gt 0 ]]; then
  echo "[verify] Verification FAILED with $ERRORS error(s)." >&2
  echo "[verify] See docs/TROUBLESHOOTING.md for common fixes."
  exit 1
else
  echo "[verify] All checks passed."
fi
