# Troubleshooting

## General

### How to see all pod statuses

```bash
kubectl get pods -n kafka
kubectl get pods -n kong
```

### How to see events for a failing pod

```bash
kubectl describe pod <pod-name> -n <namespace>
```

### How to stream pod logs

```bash
kubectl logs -f <pod-name> -n <namespace>
```

---

## Preflight Failures

### `StorageClass 'default' not found`

List available storage classes and update `KAFKA_STORAGE_CLASS` in `config.env`:

```bash
kubectl get storageclass
# Pick a class name and set: KAFKA_STORAGE_CLASS=<name>
```

### `helm not found` / `kubectl not found`

Install the missing tool. Helm 3: https://helm.sh/docs/intro/install/

### `Cannot reach Kubernetes API`

```bash
kubectl config current-context
kubectl config get-contexts
# Switch context if needed:
kubectl config use-context <context-name>
```

---

## Kafka Issues

### Kafka pods stuck in `Pending`

**Cause A: PVC can't be provisioned**

```bash
kubectl get pvc -n kafka
kubectl describe pvc <pvc-name> -n kafka
```
Check events for `storageclass not found` or `no matching volume`. Verify `KAFKA_STORAGE_CLASS`.

**Cause B: Insufficient node resources**

```bash
kubectl describe nodes | grep -A5 "Allocated resources"
```
Reduce `KAFKA_CPU_REQUEST`/`KAFKA_MEM_REQUEST` or free cluster capacity.

**Cause C: Pod anti-affinity can't schedule all replicas on same node**

KRaft requires 3 replicas. If you have fewer than 3 nodes and strict anti-affinity, pods will be pending. The default values file does not set hard anti-affinity — if you added it, remove it.

---

### Kafka pods in `CrashLoopBackOff`

Check logs:

```bash
kubectl logs kafka-cp-kafka-0 -n kafka --previous
```

**Common log errors:**

| Log message | Cause | Fix |
|---|---|---|
| `Inconsistent clusterID` | Kafka data dir has a different cluster ID than configured | Delete PVCs and reinstall, or set `KAFKA_CLUSTER_ID` to match existing data |
| `Not enough replicas` | Fewer than `min.insync.replicas` brokers up | Wait for all 3 brokers or reduce `min.insync.replicas` |
| `Failed to load metadata` | KRaft leader election hasn't completed | Wait 30–60s after all pods start |

---

### `Inconsistent clusterID` after re-install

The PVCs from the previous install still exist with the old cluster ID. Either:

```bash
# Option A: delete PVCs (data loss)
kubectl delete pvc -n kafka -l app=cp-kafka,release=kafka

# Option B: reuse the old cluster ID
cat .kafka-cluster-id
# Set KAFKA_CLUSTER_ID to that value in config.env and re-run
```

---

## Control Center Issues

### Control Center pod slow to start

Normal — it can take 3–5 minutes on first boot. Check:

```bash
kubectl logs -f control-center-cp-enterprise-control-center-0 -n kafka
```
Wait for: `[main] INFO io.confluent.controlcenter.ControlCenter - Started`

### Control Center UI shows license warning

Expected for POC. Control Center runs in 30-day evaluation mode without a license. The warning doesn't affect functionality during the POC.

---

## Schema Registry Issues

### Schema Registry `CrashLoopBackOff`

Usually Kafka isn't ready yet. Check that all Kafka brokers are Running first, then:

```bash
kubectl rollout restart deployment schema-registry-cp-schema-registry -n kafka
```

---

## Kong Issues

### Kong pod in `Init:Error` or `CrashLoopBackOff`

```bash
kubectl logs -n kong <kong-pod> -c init-migrations  # check init containers
kubectl logs -n kong <kong-pod>                      # main container
```

**DB-less mode:** Ensure `env.database=off` is set. Kong will error if it tries to connect to Postgres in DB-less mode.

**KIC mode:** The IngressController container may log errors if no Ingress resources exist yet — that's normal. The proxy container should be Running.

---

### Kong proxy returns 404 on all requests

Normal immediately after install — no routes are configured yet. The dev team configures routes post-deploy via the Admin API or KongRoute CRDs.

Verify Kong is healthy:

```bash
KONG_POD=$(kubectl get pod -n kong -l app.kubernetes.io/name=kong -o name | head -1)
kubectl exec -n kong $KONG_POD -- kong health
```

---

### LoadBalancer services stuck in `<pending>` external IP

No LoadBalancer implementation (cloud LB or MetalLB) is installed on the cluster. Options:

1. Install MetalLB on NKP with an IP pool
2. Switch to NodePort: set `SERVICE_TYPE=NodePort` in `config.env` and re-run

---

## Re-running the installer

`install.sh` is idempotent. Re-run it any time:

```bash
./install.sh
```

To skip preflight on re-run:

```bash
./install.sh --skip-preflight
```

To reinstall only Kafka or Kong:

```bash
./install.sh --kafka-only
./install.sh --kong-only
```
