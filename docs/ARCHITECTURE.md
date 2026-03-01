# Kongka — Architecture

## Helm Charts

| Chart | Source | Covers |
|---|---|---|
| `kafka-kraft` | Local — `charts/kafka-kraft/` | Kafka (KRaft) + Schema Registry + Control Center |
| `kong/kong` | `https://charts.konghq.com` | Kong Gateway (KIC or standalone) |

One Helm release per chart. Default release names: `kafka` (kafka namespace) and `kong` (kong namespace).

## Namespace Layout

```
cluster
├── namespace: kafka
│   ├── StatefulSet: kafka-kafka              (3 pods — combined broker+controller)
│   ├── Deployment:  kafka-schema-registry    (1 pod)
│   ├── Deployment:  kafka-control-center     (1 pod)
│   ├── ConfigMap:   kafka-kafka-cluster-id   (KRaft cluster UUID)
│   └── Services:
│       ├── kafka-kafka-client    ClusterIP  :9092  (Kafka clients — SR, CC, apps)
│       ├── kafka-kafka-headless  Headless   :9092,:9093  (StatefulSet pod DNS)
│       ├── kafka-schema-registry ClusterIP  :8081
│       ├── kafka-control-center  ClusterIP  :9021
│       └── kafka-cc-lb           LoadBalancer :9021  (external Control Center access)
│
└── namespace: kong
    ├── Deployment: kong-kong
    └── Services:
        ├── kong-kong-proxy  LoadBalancer :80  (proxy — external API traffic)
        └── kong-kong-admin  ClusterIP    :8001 (Admin API)
```

## Pod Names

| Pod | Kind | Count |
|---|---|---|
| `kafka-kafka-0`, `kafka-kafka-1`, `kafka-kafka-2` | StatefulSet pod | 3 |
| `kafka-schema-registry-<hash>` | Deployment pod | 1 |
| `kafka-control-center-<hash>` | Deployment pod | 1 |
| `kong-kong-<hash>` | Deployment pod | 1 |

## Component Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         NKP Cluster                             │
│                                                                 │
│  ┌─── namespace: kafka ──────────────────────────────────────┐  │
│  │                                                           │  │
│  │  ┌──────────────┐  KRaft   ┌──────────────┐              │  │
│  │  │ kafka-kafka-0│◄────────►│ kafka-kafka-1│              │  │
│  │  │ broker+ctrl  │  :9093   │ broker+ctrl  │              │  │
│  │  └──────┬───────┘          └──────┬───────┘              │  │
│  │         │                         │  ┌─────────────────┐ │  │
│  │         └─────────────────────────┴─►│  kafka-kafka-2  │ │  │
│  │                                      │  broker+ctrl    │ │  │
│  │                                      └─────────────────┘ │  │
│  │                                                           │  │
│  │  clients → kafka-kafka-client:9092                        │  │
│  │                                                           │  │
│  │  ┌──────────────────┐   ┌─────────────────────────────┐  │  │
│  │  │  Schema Registry │   │      Control Center         │  │  │
│  │  │  :8081           │   │      :9021  (LB: cc-lb)     │  │  │
│  │  └──────────────────┘   └─────────────────────────────┘  │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌─── namespace: kong ───────────────────────────────────────┐  │
│  │                                                           │  │
│  │  ┌─────────────────────────────────────────────────────┐  │  │
│  │  │  Kong (KIC + Proxy)                                 │  │  │
│  │  │  proxy  :80   (LoadBalancer) ◄── external traffic   │  │  │
│  │  │  admin  :8001 (ClusterIP)   ◄── internal config     │  │  │
│  │  └─────────────────────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

## Port Reference

| Component        | Port  | Protocol  | Access       | Purpose                        |
|------------------|-------|-----------|--------------|--------------------------------|
| Kafka broker     | 9092  | PLAINTEXT | ClusterIP    | Client connections (BROKER)    |
| Kafka controller | 9093  | PLAINTEXT | Headless     | KRaft controller quorum        |
| Schema Registry  | 8081  | HTTP      | ClusterIP    | Schema API                     |
| Control Center   | 9021  | HTTP      | LoadBalancer | Management UI (external)       |
| Kong Proxy       | 80    | HTTP      | LoadBalancer | API traffic (no TLS, POC)      |
| Kong Admin API   | 8001  | HTTP      | ClusterIP    | Route/plugin configuration     |
| Kong Status      | 8100  | HTTP      | Pod-internal | Liveness/readiness probes      |

## KRaft Topology

All 3 Kafka pods run combined `broker,controller` roles. No ZooKeeper.

- Each pod gets a node ID from its StatefulSet ordinal: `kafka-kafka-0` → `node.id=0`
- Controller quorum voters are rendered at chart template time from `replicaCount`
- Each pod advertises its own FQDN via the headless service for pod-to-pod communication
- KRaft leader election requires ≥ 2 controllers — the cluster tolerates 1 node loss

### KRaft Storage Layout (per pod)

| Path | PVC | Purpose |
|---|---|---|
| `/var/lib/kafka/data/logs/` | `data-kafka-kafka-N` (50Gi) | Topic partition data |
| `/var/lib/kafka/metadata/` | `metadata-kafka-kafka-N` (1Gi) | KRaft metadata log |

> **Note:** Topic data is at `/var/lib/kafka/data/logs/` (a subdirectory), not the PVC root.
> The PVC root is skipped to avoid the `lost+found` directory present on ext4-formatted
> Nutanix volumes, which Kafka's LogManager rejects.

### InitContainer

Before the broker starts, an InitContainer runs `kafka-storage format`:
- Idempotent: skips if `/var/lib/kafka/metadata/meta.properties` already exists
- Formats both the data and metadata directories with the cluster UUID
- Cluster UUID is read from the `kafka-kafka-cluster-id` ConfigMap

## Kafka Bootstrap Address (for app integration)

```
kafka-kafka-client.kafka.svc.cluster.local:9092
```

Schema Registry and Control Center use this address internally. External applications
running inside the cluster use the same address.

## Data Flow (future — post dev team wiring)

```
Client → Kong Proxy (:80) → [Kong routes/plugins] → upstream service
                                                      └→ may produce to Kafka
```

Kong and Kafka are independent at this stage. No integration is pre-wired.
