# Project: NKP-Kong-Integration (Kongka Stack)

> Initialized: 2026-02-27 00:00
> Last updated: 2026-03-01

## Current Focus

**Full stack validated end-to-end on workload01. Tear down + fresh install: zero errors.**

## Task Queue

- [x] Add Jaeger as optional component
- [x] Deploy Jaeger on cluster and validate endpoints

Installer proven on workload01 (bugs fixed) and workload02 (clean first-run, zero manual steps).
KRaft quorum confirmed on both: ClusterId `3VgAlrpUR2e-uMprQQCBHQ`, voters [0,1,2].
verify.sh: All checks passed on both clusters.

## Task Queue

Upcoming work in priority order:

- [x] Install crawl4ai and scrape docs into `docs/reference/` — 8 files scraped + uploaded to NotebookLM
- [x] End-to-end deployment dry-run — verify full stack comes up cleanly on NKP
- [x] Confirm Kong proxy is exposed as LoadBalancer and LB IP is reachable

**Out of scope (customer does their own integration):**
- ~~Protocol/integration wiring (Kafka ↔ Kong routes, topics, consumers)~~
- ~~TLS configuration~~
- ~~CI/CD pipeline~~

## Work Log

### 2026-03-01 — Full end-to-end teardown + reinstall on workload01

- **What:** Tore down the full stack (Kafka PVCs deleted, cluster ID cleared, all namespaces
  removed) then ran `KUBECONFIG=auth/workload01.conf ./install.sh` cold.
- **Result:** Zero errors, zero warnings. All verify.sh checks passed.
  - New KRaft cluster ID: `9jYA6n8JRh-2iVUuoo023g`
  - Control Center: `http://10.55.84.59:9021`
  - Kong proxy:     `http://10.55.84.60`
  - Jaeger UI:      `http://10.55.84.61:16686`
  - OTLP gRPC:      `10.55.84.61:4317`
  - OTLP HTTP:      `http://10.55.84.61:4318`
- **Files:** No code changes — installer ran without modification
- **Next:** Stack complete and validated. Ready for customer hand-off.

### 2026-03-01 — Jaeger live deploy on workload01

- **What:** `KUBECONFIG=auth/workload01.conf ./install.sh --jaeger-only` — clean first run.
  Zero errors, zero warnings. All verify.sh checks passed including new Jaeger section.
- **Result:**
  - Jaeger 1/1 Running (pod: `jaeger-78978948c8-hfkbm`)
  - LB IP assigned: `10.55.84.61`
  - UI: `http://10.55.84.61:16686`
  - OTLP gRPC: `10.55.84.61:4317`
  - OTLP HTTP: `http://10.55.84.61:4318`
  - Thrift HTTP: `http://10.55.84.61:14268/api/traces`
- **Files:** `config.env` (added Jaeger block)
- **Next:** Stack complete — Kafka + Kong + Jaeger live on workload01

### 2026-03-01 — Jaeger bug-fix pass (chart inspection, no live cluster)

- **What:** Discovered chart is jaegertracing/jaeger v4.5.0 (Jaeger 2.15.1) — completely
  different API from Jaeger v1. All original `--set` flags were wrong. Fixed everything:
  1. **helm-values/jaeger.yaml** — Removed invalid v1 keys (`allInOne`, `collector`, `query`,
     `agent`). Correct top-level key is `jaeger.resources`. Disabled unused maintenance jobs.
  2. **scripts/install-jaeger.sh** — Removed all invalid `--set` flags (`allInOne.enabled`,
     `collector.enabled`, `query.enabled`, `agent.enabled`, `storage.type=memory`,
     `provisionDataStore.*`). Fixed service type flag to `jaeger.service.type`. Fixed pod wait
     label to actual chart labels (`app.kubernetes.io/name=jaeger,...`). Rewrote production
     mode to write a temp values file (avoids `--set-json` multiline quoting issues).
  3. **scripts/verify.sh** — Fixed service name from `${RELEASE}-query` to `${RELEASE}` (single
     service in Jaeger v2). Fixed pod label selector.
  4. **install.sh summary** — Fixed service name same as above.
  5. **config.env.example** — Replaced `JAEGER_STORAGE_TYPE` with `JAEGER_ES_URL` (production).
  6. **scripts/preflight.sh** — Skip StorageClass and Kafka resource checks when `--jaeger-only`.
     Added Jaeger repo reachability check when Jaeger is enabled.
- **Validation:** helm template dry-run passes. JSON rendered correctly. All bash -n clean.
- **Files:** All 6 files above
- **Next:** Deploy to cluster when available and validate live endpoints

### 2026-03-01 — Jaeger optional component

- **What:** Added Jaeger distributed tracing as an optional workflow.
  - `helm-values/jaeger.yaml` — static values (resources, image pin, OTLP env)
  - `scripts/install-jaeger.sh` — Helm install script; supports `allInOne` (POC, in-memory)
    and `production` (separate collector/query with Elasticsearch or Cassandra backend)
  - `install.sh` — `--jaeger-only` flag, wizard Y/N + strategy prompt, defaults,
    exports, namespace/repo/install step, endpoint summary block
  - `scripts/verify.sh` — Jaeger pod + IP section (conditional on `JAEGER_ENABLED`)
  - `config.env.example` — Jaeger section with all variables documented
- **Design:** `JAEGER_ENABLED=false` by default. Users opt in via config.env or `--jaeger-only`.
  Endpoint URLs printed after install: UI :16686, OTLP gRPC :4317, OTLP HTTP :4318.
- **Files:** `helm-values/jaeger.yaml`, `scripts/install-jaeger.sh`, `install.sh`,
  `scripts/verify.sh`, `config.env.example`
- **Next:** Deploy Jaeger on cluster and validate endpoints

### 2026-03-01 — workload02 clean install validation

#### Session — second-cluster proof

- **What:** Ran `KUBECONFIG=auth/workload02.conf ./install.sh` against fresh workload02 cluster
  (NKP K8s 1.34.1, Nutanix volumes, 7 nodes — same platform as workload01). Zero manual
  intervention. Used existing config.env and same cluster ID from `.kafka-cluster-id`.
- **Result:** `verify.sh: All checks passed.`
  - Preflight: 0 errors, 0 warnings
  - Kafka KRaft: 3/3 brokers Running, quorum confirmed (ClusterId `3VgAlrpUR2e-uMprQQCBHQ`)
  - Schema Registry: 1/1 Running
  - Control Center: 1/1 Running, LB: `10.55.84.79:9021`
  - Kong: 1/1 Running, LB: `10.55.84.80`
  - Kong CRD adoption loop handled pre-installed CRDs cleanly
  - Total time: ~6 minutes, no manual steps
- **Files:** No code changes — installer ran without modification
- **Next:** Stack validated on two clusters. Ready for customer hand-off.

### 2026-03-01 — KRaft live install + bug fixes

#### Session — live deploy to workload01, 3 bugs found and fixed

- **What:** Deployed KRaft chart to live workload01 cluster. Fixed 3 bugs:
  1. **Orphan cc-lb service**: old `kubectl apply` service blocked new Helm-managed one.
     Fix: pre-install orphan cleanup loop in install-kafka.sh.
  2. **kafka-storage format needs full KRaft config**: minimal props caused "Missing
     zookeeper.connect" fallback. Fix: write complete props incl. process.roles +
     advertised.listeners using `$HOSTNAME` (available in init container).
  3. **ext4 lost+found crash**: Nutanix volumes have `lost+found` at PVC root;
     Kafka's LogManager rejects it. Fix: `KAFKA_LOG_DIRS=/var/lib/kafka/data/logs`
     (subdirectory). Also fixed idempotency check: `meta.properties` is in
     `metadata.log.dir`, not `log.dirs`.
- **Result:** `verify.sh: All checks passed.`
  - 3 Kafka KRaft pods (1/1 Running), SR 1/1, CC 1/1, Kong 1/1
  - KRaft quorum: ClusterId `3VgAlrpUR2e-uMprQQCBHQ`, voters [0,1,2], no ZooKeeper
  - CC LB: `10.55.84.59:9021`
  - install.sh --kafka-only idempotent upgrade: exit 0
- **Files:** `scripts/install-kafka.sh`, `charts/kafka-kraft/templates/kafka-statefulset.yaml`
- **Commit:** `2e59034`
- **Next:** Stack ready for customer hand-off Monday 2026-03-03

### 2026-03-01 — KRaft chart implementation

#### Session — replace ZooKeeper with hand-crafted KRaft Helm chart

- **What:** Built `charts/kafka-kraft/` local Helm chart using `confluentinc/cp-server:7.6.0`.
  True KRaft (no ZooKeeper). Covers Kafka StatefulSet, Schema Registry, Control Center.
  Rewrote `scripts/install-kafka.sh` to use local chart (removed cp-helm-charts download/patch).
  Added cluster ID generation (UUID → base64url 22-char), migration step (detect + remove ZK release + PVCs).
  Updated `scripts/verify.sh` label selectors (`cp-kafka` → `kafka`, etc.) + KRaft quorum check.
  Updated `helm-values/kafka-kraft.yaml` as static overrides file. Removed old `schema-registry.yaml`
  and `control-center.yaml` (no longer applicable). Fixed `KAFKA_IMAGE` default to `cp-server:7.6.0`.
  CC LB service (`${KAFKA_RELEASE_NAME}-cc-lb`) templated in chart — no more kubectl apply.
- **Files:** `charts/kafka-kraft/` (12 files), `scripts/install-kafka.sh`, `scripts/verify.sh`,
  `helm-values/kafka-kraft.yaml`, `config.env.example`, `install.sh`
- **Verified:** `bash -n` all scripts pass; `helm template` renders all 12 resources cleanly
- **Next:** Deploy to workload01 cluster and run `./install.sh --kafka-only`

### 2026-03-01

#### Session — end-to-end deployment + installer fixes

- **What:** Ran full installer against workload01 (NKP K8s 1.34.1). Found and fixed 9 issues:
  1. CRLF line endings on all scripts → `sed -i 's/\r$//'` + `.gitattributes`
  2. Helm not installed → installed via official script
  3. StorageClass `default` not found → `KAFKA_STORAGE_CLASS=nutanix-volume` in config.env
  4. Wrong chart structure → rewrote install-kafka.sh to use `cp-helm-charts` umbrella chart
  5. `policy/v1beta1` PodDisruptionBudget removed in K8s 1.25+ → auto-patch on chart download
  6. ConfluentMetricsReporter ClassNotFoundException → use `cp-server:7.6.0` image
  7. JMX sidecar CrashLoopBackOff → disabled in schema-registry.yaml + control-center.yaml
  8. Schema Registry NotEnoughReplicasException → `min.insync.replicas=1` + `kafkastore.topic.replication.factor=1`
  9. Kong CRD ownership conflict → CRD adoption loop in install-kong.sh + `--skip-crds`
  10. verify.sh arithmetic error (`0\n0`) → `{ grep ... || true; } | wc -l` pattern
- **Result:** `verify.sh: All checks passed.`
  - ZooKeeper 3/3 Running, Kafka 3/3 Running, Schema Registry 1/1 Running
  - Control Center 1/1 Running, LB: `10.55.84.59:9021`
  - Kong 1/1 Running, LB: `10.55.84.60` (404 expected, no routes)
- **Files:** `.gitattributes`, `.gitignore`, `config.env.example`, `install.sh`,
  `scripts/install-kafka.sh`, `scripts/install-kong.sh`, `scripts/verify.sh`,
  `helm-values/kafka-kraft.yaml`, `helm-values/schema-registry.yaml`, `helm-values/control-center.yaml`
- **Commit:** `3b33e2e` — fix: make installer work on NKP 1.34 cluster end-to-end
- **Next:** Stack is live — ready for Monday customer hand-off

#### Session end — pre-deployment prep
- **What:** Discipline audit only (project-init). Repo is clean, docs complete, notebook
  at 10 sources. No code changes — saving real work for Sunday prep session.
- **Next:** Sunday session — tackle task queue for Monday customer deployment

### 2026-02-28

#### 13:00 — Discipline re-audit (project-init)
- **What:** Re-ran project-init. Found 2 NKP docs (nutanix-nkp-install.md,
  nutanix-nkp-infra-config.md) present in docs/reference/ but missing from NotebookLM
  (notebook had 8 sources, not 10). Uploaded both — notebook now at 10 sources.
  Added tools/ to .gitignore (WSL PowerShell scripts, not part of deployment kit).
  CLAUDE.md had minor pending changes (smart-indexer → smart-index fixes).
- **Files:** `.gitignore`, `PROGRESS.md`, `CLAUDE.md`
- **Next:** Protocol/integration wiring (Kafka ↔ Kong)

#### 12:00 — NKP docs added from GitHub mirror
- **What:** Fetched NKP 2.17 docs from icediceice/Nutanix-MD-Doc (portal is JS/auth-gated).
  Bundled 18 topic pages into 5 targeted files covering the areas this project needs:
  get-started, prerequisites, storage (for Kafka PVCs), MetalLB/LoadBalancer (for Kong),
  and Nutanix cluster creation. All 5 uploaded to NotebookLM. Notebook now has 13 sources.
- **Files:** `docs/reference/nutanix-nkp-*.md` (5 new files)
- **Next:** Protocol/integration wiring (Kafka ↔ Kong)

#### 11:30 — Discipline re-audit (project-init)
- **What:** Re-ran project-init. Found docs/reference/ fully deleted (prev scrapes had nav garbage
  from old `crwl` without `crawl` subcommand). Re-scraped all 8 docs with `crwl crawl -o markdown-fit`.
  Uploaded all 8 to NotebookLM (notebook was empty). Fixed CLAUDE.md crwl syntax.
- **Files:** `docs/reference/*.md` (8 files re-scraped), `CLAUDE.md` (crwl syntax fix), `PROGRESS.md`
- **Next:** Protocol/integration wiring (Kafka ↔ Kong)

#### 10:00 — Discipline re-audit (project-init)
- **What:** Re-ran project-init skill. All 9 CLAUDE.md sections intact. All tooling present
  (crwl, nlm). 9 docs in docs/reference/ including nutanix-nkp-get-started.md. No gaps found.
- **Files:** `PROGRESS.md`
- **Next:** Protocol/integration wiring (Kafka ↔ Kong)

#### 01:00 — Doc library scraped and uploaded
- **What:** Scraped 8 official doc sources into `docs/reference/` using crawl4ai. Uploaded
  all 8 as file sources to NotebookLM (notebook: de3d8796). crwl PATH fixed via ~/.zshrc.
  Nutanix NKP docs not scraped (login-gated portal — manual download needed if required).
- **Files:** `docs/reference/kong-kic-get-started.md`, `kong-kic-custom-resources.md`,
  `kong-dbless-config.md`, `confluent-kafka-kraft.md`, `confluent-cp-helm-charts-readme.md`,
  `confluent-schema-registry.md`, `confluent-control-center.md`, `helm-upgrade-reference.md`
- **Next:** Protocol/integration wiring (Kafka ↔ Kong)

#### 00:00 — Discipline re-audit
- **What:** Re-ran project-init skill. All 9 CLAUDE.md sections intact. Updated Documentation
  Reference section to add docs/reference/ fallback pattern and crwl source-add commands.
  Added crawl4ai install task to queue (crwl not on PATH). No other gaps found.
- **Files:** `CLAUDE.md`, `PROGRESS.md`
- **Next:** Install crawl4ai, scrape docs; then protocol/integration wiring

### 2026-02-27

#### 00:00 — Workflow discipline applied
- **What:** Enforced project-init discipline on existing project. Created .gitignore,
  PROGRESS.md, NotebookLM notebook, and appended discipline section to CLAUDE.md.
- **Files:** `.gitignore`, `PROGRESS.md`, `CLAUDE.md`
- **Next:** Awaiting direction
