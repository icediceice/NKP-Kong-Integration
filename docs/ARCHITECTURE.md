# Kongka — Architecture

## Namespace Layout

```
cluster
├── namespace: kafka
│   ├── StatefulSet: kafka-cp-kafka          (3 pods — broker+controller)
│   ├── Deployment:  schema-registry-cp-schema-registry
│   ├── Deployment:  control-center-cp-enterprise-control-center
│   └── Services:
│       ├── kafka-cp-kafka           ClusterIP   :9092 (PLAINTEXT)
│       ├── kafka-cp-kafka-headless  Headless    :9092
│       ├── schema-registry          ClusterIP   :8081
│       └── control-center           LoadBalancer :9021
│
└── namespace: kong
    ├── Deployment: kong-kong
    └── Services:
        ├── kong-kong-proxy          LoadBalancer :80 (proxy)
        └── kong-kong-admin          ClusterIP    :8001 (admin API)
```

## Component Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         NKP Cluster                             │
│                                                                 │
│  ┌─── namespace: kafka ──────────────────────────────────────┐  │
│  │                                                           │  │
│  │  ┌────────────┐   KRaft    ┌────────────┐                │  │
│  │  │  Kafka     │◄──────────►│  Kafka     │                │  │
│  │  │  broker-0  │  consensus │  broker-1  │                │  │
│  │  └─────┬──────┘            └────┬───────┘                │  │
│  │        │                        │   ┌───────────────┐    │  │
│  │        └────────────────────────┴──►│   Kafka       │    │  │
│  │                                     │   broker-2    │    │  │
│  │                                     └───────────────┘    │  │
│  │                                                           │  │
│  │  bootstrap: kafka-cp-kafka:9092                           │  │
│  │                                                           │  │
│  │  ┌─────────────────┐    ┌──────────────────────────────┐ │  │
│  │  │  Schema Registry│    │     Control Center           │ │  │
│  │  │  :8081          │    │     :9021 (LB)               │ │  │
│  │  └─────────────────┘    └──────────────────────────────┘ │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌─── namespace: kong ───────────────────────────────────────┐  │
│  │                                                           │  │
│  │  ┌─────────────────────────────────────────────────────┐  │  │
│  │  │  Kong (KIC + Proxy)                                 │  │  │
│  │  │                                                     │  │  │
│  │  │  proxy  :80  (LoadBalancer) ◄── external traffic    │  │  │
│  │  │  admin  :8001 (ClusterIP)   ◄── internal config     │  │  │
│  │  └─────────────────────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

## Port Reference

| Component        | Port  | Protocol  | Access       | Purpose                    |
|------------------|-------|-----------|--------------|----------------------------|
| Kafka            | 9092  | PLAINTEXT | ClusterIP    | Client connections         |
| Kafka KRaft      | 9093  | PLAINTEXT | ClusterIP    | Controller-to-controller   |
| Schema Registry  | 8081  | HTTP      | ClusterIP    | Schema API                 |
| Control Center   | 9021  | HTTP      | LoadBalancer | Management UI              |
| Kong Proxy       | 80    | HTTP      | LoadBalancer | API traffic (no TLS, POC)  |
| Kong Admin API   | 8001  | HTTP      | ClusterIP    | Route/plugin config        |
| Kong Status      | 8100  | HTTP      | Pod-internal | Liveness/readiness probes  |

## KRaft Topology

All Kafka pods run combined `broker,controller` roles. In a 3-node KRaft cluster:
- All 3 participate in Raft leader election for partition leadership
- All 3 hold a copy of the cluster metadata log
- Quorum requires ≥ 2 controllers — the cluster tolerates 1 node loss

For production, consider separating controller-only and broker-only nodes.

## Data Flow (future — post dev team wiring)

```
Client → Kong Proxy (:80) → [Kong routes/plugins] → upstream service
                                                       └→ may produce to Kafka
```

Kong and Kafka are independent at this stage. No integration is pre-wired.
