# Troubleshooting

## General

### Check all pod statuses

```bash
kubectl get pods -n kafka
kubectl get pods -n kong
```

### See events for a failing pod

```bash
kubectl describe pod <pod-name> -n <namespace>
```

### Stream pod logs

```bash
# Main container
kubectl logs -f <pod-name> -n <namespace>

# Init container (kafka-storage-format)
kubectl logs <pod-name> -n kafka -c kafka-storage-format

# Previous crash logs
kubectl logs <pod-name> -n <namespace> --previous
```

---

## Preflight Failures

### `StorageClass not found`

List available storage classes and update `KAFKA_STORAGE_CLASS` in `config.env`:

```bash
kubectl get storageclass
# Set KAFKA_STORAGE_CLASS=<name> in config.env, then re-run
```

The setup wizard auto-detects storage classes. Re-run it with `./install.sh --reconfigure`.

### `helm not found` / `kubectl not found`

Install the missing tool. Helm 3: https://helm.sh/docs/intro/install/

### `Cannot reach Kubernetes API`

```bash
kubectl config current-context
kubectl config get-contexts
kubectl config use-context <context-name>
```

If using `auth/` directory: ensure a valid `.conf` or `.yaml` kubeconfig is present in `auth/`.

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

Reduce `KAFKA_CPU_REQUEST`/`KAFKA_MEM_REQUEST` in `config.env`, or free cluster capacity.

---

### Kafka init container in `CrashLoopBackOff`

```bash
kubectl logs kafka-kafka-0 -n kafka -c kafka-storage-format
```

**`Missing required configuration zookeeper.connect`**

Indicates the init container's KRaft config file is incomplete. This should not occur with the
current chart — if it does, ensure you are running the latest chart from `charts/kafka-kraft/`.

**`advertised.listeners cannot use the nonroutable meta-address 0.0.0.0`**

The format command requires a real hostname in `advertised.listeners`. Check that `$HOSTNAME`
resolves correctly inside the init container. This is typically fixed automatically by the chart.

**`Found directory lost+found`**

Kafka's LogManager rejects non-topic directories. This occurs when `KAFKA_LOG_DIRS` points to
the PVC root (ext4 volumes have `lost+found` there). The current chart avoids this by using
`/var/lib/kafka/data/logs/` as the log directory. If you see this on a fresh install, you are
running an outdated chart version.

---

### Kafka broker pods in `CrashLoopBackOff`

```bash
kubectl logs kafka-kafka-0 -n kafka --previous
```

**`Found directory /var/lib/kafka/data/lost+found`**

See above — update to the current chart which uses a subdirectory for `KAFKA_LOG_DIRS`.

**`Inconsistent clusterID`**

The existing PVCs have a different cluster ID than what the broker is starting with.

```bash
# Option A: delete PVCs (all Kafka data is lost)
helm uninstall kafka -n kafka
kubectl delete pvc -n kafka --all --wait=true

# Option B: reuse the cluster ID that matches the existing PVCs
cat .kafka-cluster-id
# Set KAFKA_CLUSTER_ID=<value> in config.env, then re-run
```

**`Failed to load metadata` / controller election errors**

KRaft needs all 3 controllers to elect a leader. If pods start at different times, they may
log errors until quorum forms. Wait 60–90 seconds after all pods enter `Running` state.

**`Not enough replicas`**

Fewer than `min.insync.replicas` brokers are in-sync. Wait for all 3 pods to be `1/1 Running`.

---

### Verify KRaft is actually running (no ZooKeeper)

```bash
# Should show ClusterId, LeaderId, CurrentVoters: [0,1,2] — confirms KRaft quorum
kubectl exec -n kafka kafka-kafka-0 -- \
  kafka-metadata-quorum --bootstrap-server localhost:9092 describe --status

# Should show ONLY kafka and schema-registry/control-center pods — no zookeeper
kubectl get pods -n kafka
```

---

### Schema Registry in `CrashLoopBackOff`

Usually Kafka isn't ready yet. The readiness probe calls `/subjects` which fails until Kafka
is accepting connections. Schema Registry will restart a few times on first boot — this is
normal. Once all Kafka brokers are `1/1 Running`, Schema Registry stabilises.

To force a restart after Kafka is up:

```bash
kubectl rollout restart deployment kafka-schema-registry -n kafka
```

---

### `Inconsistent clusterID` after re-install

The installer auto-handles this: it reads `.kafka-cluster-id` from the previous run and reuses
the same ID so existing PVCs remain valid. If you deleted `.kafka-cluster-id` and PVCs still
exist from the old run, delete the PVCs:

```bash
kubectl delete pvc -n kafka --all --wait=true
```

Then re-run the installer — it generates a new cluster ID and formats fresh storage.

---

## Control Center Issues

### Control Center pod slow to start

Normal — it can take 3–5 minutes on first boot. Watch:

```bash
kubectl logs -f kafka-control-center-<hash> -n kafka
```

Wait for: `INFO io.confluent.controlcenter.ControlCenter - Started`

### Control Center UI shows license warning

Expected for POC. Control Center runs in 30-day evaluation mode without a license key.
The warning doesn't affect functionality during the POC period.

### Control Center shows no cluster / can't connect to Kafka

Check that all 3 Kafka pods are `1/1 Running`, then restart Control Center:

```bash
kubectl rollout restart deployment kafka-control-center -n kafka
```

---

## Kong Issues

### Kong pod in `Init:Error` or `CrashLoopBackOff`

```bash
kubectl logs -n kong <kong-pod> -c init-migrations   # init container
kubectl logs -n kong <kong-pod>                       # main container
```

**DB-less mode:** Ensure `env.database=off`. Kong will error if it tries to connect to
Postgres in DB-less mode. The default config sets this correctly.

**CRD ownership conflict:** If Kong CRDs exist on the cluster from a previous install,
helm may fail with an ownership error. The installer handles this with `--skip-crds` on
re-runs. If it still fails, force-adopt the CRDs:

```bash
kubectl annotate crd kongplugins.configuration.konghq.com \
  meta.helm.sh/release-name=kong \
  meta.helm.sh/release-namespace=kong \
  --overwrite
# Repeat for other Kong CRDs if needed, then re-run install.sh
```

### Kong proxy returns 404

Normal immediately after install — no routes are configured yet. The dev team configures
routes post-deploy via the Admin API or KongRoute CRDs.

Verify Kong itself is healthy:

```bash
KONG_POD=$(kubectl get pod -n kong -l app.kubernetes.io/name=kong -o name | head -1)
kubectl exec -n kong $KONG_POD -- kong health
```

---

### LoadBalancer services stuck in `<pending>` external IP

No LoadBalancer implementation is installed on the cluster. Options:

1. Install MetalLB on NKP with an IP pool
2. Switch to NodePort: set `SERVICE_TYPE=NodePort` in `config.env` and re-run

---

## Re-running the installer

`install.sh` is fully idempotent — safe to re-run at any point:

```bash
./install.sh

# Skip preflight on a known-good cluster
./install.sh --skip-preflight

# Reinstall only Kafka (preserves Kong)
./install.sh --kafka-only

# Reinstall only Kong (preserves Kafka)
./install.sh --kong-only
```

---

## Manual Verification Commands

```bash
# Full verify script (source config first)
source config.env && export KAFKA_NAMESPACE KAFKA_RELEASE_NAME KAFKA_BROKER_COUNT \
  SR_ENABLED CC_ENABLED KONG_NAMESPACE KONG_RELEASE_NAME && bash scripts/verify.sh

# KRaft quorum status
kubectl exec -n kafka kafka-kafka-0 -- \
  kafka-metadata-quorum --bootstrap-server localhost:9092 describe --status

# Broker API versions (counts responding brokers)
kubectl exec -n kafka kafka-kafka-0 -- \
  kafka-broker-api-versions --bootstrap-server localhost:9092 2>/dev/null | grep "id:" | wc -l

# Schema Registry health
kubectl exec -n kafka kafka-kafka-0 -- \
  curl -s http://kafka-schema-registry.kafka.svc.cluster.local:8081/subjects

# Control Center LB address
kubectl get svc -n kafka kafka-cc-lb -o jsonpath='{.status.loadBalancer.ingress[0].ip}'

# Kong proxy address
kubectl get svc -n kong kong-kong-proxy -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
```
