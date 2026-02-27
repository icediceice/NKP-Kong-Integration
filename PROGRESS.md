# Project: NKP-Kong-Integration (Kongka Stack)

> Initialized: 2026-02-27 00:00
> Last updated: 2026-02-28 12:00

## Current Focus

Workflow discipline applied. Project scaffolding is complete — all scripts, Helm values,
and config are in place. Awaiting direction for next phase of work.

## Task Queue

Upcoming work in priority order:

- [x] Install crawl4ai and scrape docs into `docs/reference/` — 8 files scraped + uploaded to NotebookLM
- [ ] Protocol/integration wiring (Kafka ↔ Kong routes, topics, consumers)
- [ ] TLS configuration for production readiness
- [ ] CI/CD pipeline setup

## Work Log

### 2026-02-28

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
