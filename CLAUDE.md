# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

Shell + Helm deployment kit for Kafka (KRaft, no ZooKeeper) + Kong OSS on Nutanix Kubernetes Platform. The entire install is driven by `install.sh` reading `config.env`. No application code — only deployment scripts and Helm values files.

## Running the Installer

```bash
# Full install (preflight → kafka → kong → verify)
./install.sh

# Common re-run scenarios
./install.sh --skip-preflight     # skip preflight on known-good cluster
./install.sh --kafka-only         # reinstall only the Kafka stack
./install.sh --kong-only          # reinstall only Kong

# Dry-run preflight without installing
bash scripts/preflight.sh
```

## Validating Scripts (no cluster needed)

```bash
# Syntax check all shell scripts
bash -n install.sh
bash -n scripts/preflight.sh
bash -n scripts/install-kafka.sh
bash -n scripts/install-kong.sh
bash -n scripts/verify.sh

# Lint with shellcheck (install: apt install shellcheck / brew install shellcheck)
shellcheck install.sh scripts/*.sh

# Dry-run Helm rendering (requires helm + valid kubeconfig)
helm template kafka confluentinc/cp-kafka \
  --values helm-values/kafka-kraft.yaml \
  --namespace kafka

helm template kong kong/kong \
  --values helm-values/kong.yaml \
  --namespace kong
```

## Architecture

### Control flow

```
install.sh
  ├── source config.env (or apply defaults)
  ├── scripts/preflight.sh     — exits non-zero on hard failures
  ├── kubectl apply (namespaces)
  ├── helm repo add/update
  ├── scripts/install-kafka.sh — Kafka KRaft → Schema Registry → Control Center
  ├── scripts/install-kong.sh  — Kong (mode/db-mode applied via --set flags)
  └── scripts/verify.sh        — pod status + reachability checks
```

`install.sh` exports all config variables so child scripts inherit them without re-sourcing.

### Variable flow

All tunables live in `config.env` (copied from `config.env.example`). `install.sh` applies defaults for every variable so the file is optional — bare `./install.sh` with no `config.env` produces a working POC.

`helm-values/*.yaml` files hold **static** Helm config with inline comments. **Dynamic** values (image tags, replica counts, storage class, resource limits, service type) are applied as `--set` overrides in the install scripts, not hardcoded in the YAML.

### Kafka cluster ID

`install-kafka.sh` generates a UUID on first run and writes it to `.kafka-cluster-id`. Subsequent runs reuse it. This prevents the `Inconsistent clusterID` crash when Kafka PVCs already exist. The `.kafka-cluster-id` file should not be committed.

### Kong modes

`KONG_MODE` and `KONG_DB_MODE` in `config.env` select the deployment variant. `install-kong.sh` translates these into `--set` flags at install time:

| `KONG_MODE` | `KONG_DB_MODE` | What deploys |
|-------------|----------------|--------------|
| `ingress`   | `dbless`       | KIC + declarative config (default) |
| `gateway`   | `dbless`       | Standalone proxy, no K8s integration |
| `ingress`   | `postgres`     | KIC + Postgres-backed Admin API |

## Key Files

| File | Purpose |
|------|---------|
| `config.env.example` | Canonical reference for all parameters |
| `helm-values/kafka-kraft.yaml` | KRaft static config (roles, listeners, retention, PDB) |
| `helm-values/kong.yaml` | Kong static config (ports, probes, resource limits) |
| `scripts/preflight.sh` | Hard failures exit 1; soft issues are warnings |
| `scripts/verify.sh` | Non-zero exit if any pod not Running or proxy unreachable |

## Idempotency Rules

All state-changing operations must be safe to re-run:
- Namespace creation: `kubectl create ns ... --dry-run=client | kubectl apply -f -`
- Helm installs: always `helm upgrade --install` (never `helm install`)
- `helm repo add` calls include `2>/dev/null || true` to suppress "already exists" errors

## Adding a New Component

1. Add Helm values file to `helm-values/`
2. Add an `--enabled` flag variable to `config.env.example` with a default
3. Add `helm upgrade --install` block to the relevant `scripts/install-*.sh`
4. Add pod readiness check to `scripts/verify.sh`
5. Document the port in `docs/ARCHITECTURE.md`

## Work Tracking & Session Discipline

### Autonomous Work Style

Work autonomously and proactively. When given a task or a set of tasks:

- Execute through the full task without stopping to ask for permission at each step.
- If a task has obvious sub-steps, just do them — don't list them out and wait for approval.
- Make reasonable decisions on implementation details instead of asking the user to choose.
- Only ask the user when there is genuine ambiguity that could lead the work in a wrong direction, or when a decision has significant trade-offs the user should weigh in on.
- After completing a task, **update PROGRESS.md immediately** (check off task, log what was
  done, update Current Focus), commit, then move to the next item in the task queue rather
  than stopping and waiting for the next instruction.
- When starting a new task, **update PROGRESS.md first** (move task to Current Focus, log
  what you're about to do) before writing any code.
- If you finish all queued tasks, update PROGRESS.md, commit, then summarize what was done
  and ask what's next.

The goal is to minimize back-and-forth. The user trusts you to make good calls — ask when you're unsure, execute when you're not.

### Context Hygiene & Smart Navigation

**Do NOT read files blindly.** Loading files into context has a real cost — it displaces
useful information and degrades your ability to stay focused on the task.

- If a `smart-index` skill or `.index` file is available, use it FIRST to understand
  codebase structure before opening any source files. It gives you a compressed map of the
  project at a fraction of the context cost.
- Only read files you actually need for the current task. If you need to understand an
  interface or function signature, read just that file — not every file in the directory.
- Prefer targeted reads (specific line ranges) over reading entire large files.
- Never read a file "just to be safe" or "for context." Know why you're reading it before
  you open it.

### Iterative Work Discipline

**Work in small, verified increments.** The biggest failure mode in long sessions is making
a chain of changes that compound into something broken, then not knowing where it went wrong.

**Build → Verify → Commit loop:**
1. Make a focused change (one logical unit)
2. Verify it works — run the relevant test, build command, linter, or at minimum read back
   what you wrote to confirm it's correct
3. Update PROGRESS.md if a task was completed or a meaningful milestone was reached
4. Commit once verified
5. Then move to the next change

**Rules for iterative work:**
- After editing a file, re-read the changed section to catch errors before moving on.
- Prefer surgical edits (find-and-replace, targeted line changes) over rewriting entire
  files. Full file rewrites risk losing work that was already correct.
- Run tests or build after each meaningful change, not just at the end. Catching errors
  early is cheaper than debugging a chain of 5 changes.
- If a change doesn't work, revert it and try a different approach. Don't layer fix on top
  of fix — that's how you get spaghetti. Use git to revert cleanly:
  - Single file: `git checkout -- <file>`
  - All uncommitted changes: `git checkout -- .`
  - Last commit: `git reset --soft HEAD~1`
  - Stash and try fresh: `git stash`
- Stay on scope. If you notice something unrelated that needs fixing, add it to the Task
  Queue in PROGRESS.md and keep going on the current task. Don't context-switch mid-task.
- When a task is complex, outline your approach in PROGRESS.md *before* coding. This helps
  you stay on track and helps the user see your plan.

### Documentation Reference via NotebookLM

A dedicated NotebookLM notebook has been set up for this project's external documentation.
Scraped documentation also lives in `docs/reference/` as clean markdown files.

**Notebook ID:** `de3d8796-6cb6-4405-877c-b52c3002c51a`

**Query docs via CLI (lowest token cost — preferred):**
```bash
nlm ask "How do I configure X?" --notebook-id de3d8796-6cb6-4405-877c-b52c3002c51a
```
This runs outside the context window — only the focused answer comes back. No context
pollution from loading entire doc files.

**Fallback — read from docs/reference/ directly:**
If NotebookLM is unavailable or `nlm` is not installed, the scraped markdown files in
`docs/reference/` can be read directly. Use targeted reads (specific sections) rather
than loading entire files. This is more expensive than `nlm ask` but still better than
reading raw HTML or re-scraping.

**When to use NotebookLM:**
- Framework/library API usage → `nlm ask`
- Vendor platform docs or best practices → `nlm ask`
- "How do I..." or "What's the correct way to..." for external tools → `nlm ask`

**When NOT to use NotebookLM:**
- Project's own source code → use smart-index + targeted file reads
- Config or env files → read directly (they're small)
- Internal project logic or business rules → read the source

**Adding new documentation sources mid-project:**
If you encounter a new framework or API not yet in the notebook, first check what the
project actually uses from it (imports, config, API calls), then scrape only relevant pages:
```bash
# Scrape specific pages with markdown-fit (strips nav/boilerplate per page)
crwl crawl <page-url> -o markdown-fit 2>/dev/null >> docs/reference/<topic>.md
# Then add to NotebookLM
nlm source add de3d8796-6cb6-4405-877c-b52c3002c51a --file docs/reference/<topic>.md
```
If scraping fails (login-gated portal, protected content), inform the developer with the
exact URL and search terms so they can download and add it manually.
Only add authoritative sources — official docs, API references, vendor specs.

### Code Hygiene

Write clean code from the start so there's less to fix later.

- **No dead code.** Don't leave commented-out blocks, unused imports, or unreachable
  branches. Delete them. Git has history if you need them back.
- **No magic values.** Extract hard-coded strings, numbers, and URLs into named constants
  or config. If a value appears more than once, it needs a single source of truth.
- **Name things clearly.** Variable and function names should describe what they hold or do.
  If you need a comment to explain what a variable is, the name is wrong.
- **Small functions, single purpose.** If a function does two things, split it. If it's
  longer than ~40 lines, it probably does too much.
- **Handle errors explicitly.** No empty catch blocks, no swallowed errors. Log or handle
  every error path. If you're intentionally ignoring an error, comment why.
- **Clean up after yourself.** When you refactor or replace a module, remove the old code,
  update imports, and delete orphaned files. Don't leave stale artifacts.
- **Consistent patterns.** Follow the conventions already established in the codebase. If
  the project uses a specific naming convention, error handling pattern, or file structure,
  match it — don't introduce a new style.
- **Never commit secrets.** API keys, tokens, passwords, and credentials go in `.env` or
  a secrets manager — never in source code or config files that get committed. If you
  accidentally stage a secret, remove it from git history, don't just delete and recommit.

### Efficient Code Audits & Reviews

When asked to review, audit, or improve the codebase, **be surgical — not exhaustive.**
The goal is to find things that matter, not generate a comprehensive report on every file.

**Scoping the audit:**
- Ask (or determine from context) what the audit focus is: bugs? security? performance?
  code quality? If unclear, prioritize in this order: bugs/errors → security → logic issues
  → performance → code style.
- Use smart-index / `.index` to understand the project structure FIRST. Identify the
  critical paths and high-risk areas before opening any source files.
- Focus on files that have **recently changed** (check git log/diff) — these are where new
  bugs live. Stable, untouched code is lower priority.
- Skip generated files, vendor directories, lock files, and boilerplate configs. Don't
  audit node_modules, build outputs, or auto-generated code.

**During the audit:**
- Work by priority tier. Report critical issues (bugs, security, data loss risks) first.
  Only move to lower-priority findings (style, minor refactors) if the user asks for them.
- Read files targeted to the scope — don't open every file in the project. If the audit is
  about auth, read the auth modules, not the CSS.
- When you find an issue, note the file, line, what's wrong, and the fix — then move on.
  Don't rewrite the code during an audit pass unless asked to fix as you go.
- Group findings by severity, not by file. The user cares about "what's broken" before
  "what could be cleaner."

**Keep it lean:**
- A good audit is 5-15 focused findings, not a 200-line report touching every file.
- If the codebase is clean, say so and stop. Don't manufacture findings to seem thorough.
- If scope is large, propose auditing in phases (e.g., "I'll start with the API layer,
  then data models") so the user can direct effort where it matters most.

### PROGRESS.md — Read First, Update Often

A `PROGRESS.md` file exists in the project root. It is the source of truth for project state.
**Updating it is not optional — it is part of the work, not an afterthought.**

**At session start:**
- Read PROGRESS.md BEFORE doing anything else.
- Use "Current Focus" and "Task Queue" to understand where things left off.
- Continue from where the last session stopped unless the user redirects.

**During work — update PROGRESS.md at EVERY transition point:**
- **Before starting a task** → move it to Current Focus, note what you're about to do
- **After each meaningful action** → add a Work Log entry (What / Files / Next)
- **After finishing a task** → check it off in Task Queue, update Current Focus to next item
- **Before starting the next task** → log the new task in Current Focus
- **After a failed attempt or revert** → log what was tried and why it didn't work
- **End of session** → ensure Current Focus and Task Queue reflect actual state

The pattern is: **every time the work state changes, PROGRESS.md changes too.**
If another Claude instance opened this file right now, it should know exactly where
things stand without reading any other context.

Keep entries concise. The Work Log is a breadcrumb trail, not documentation.

### Git Commit & Push Discipline

Git is both version control and a backup layer. Commit and push frequently.

**Commit after every meaningful unit of work:**
- A feature or function completed
- A file or module created or restructured
- A bug fixed
- A config change applied
- Any point where losing the work would be painful

**Commit message format:** `<type>: <short description>`
Types: `feat`, `fix`, `refactor`, `docs`, `chore`, `init`, `wip`

**Push as backup at minimum:**
- After completing each task from the queue
- Before switching to a different task
- Before any risky refactor or destructive operation
- At end of session

Never let more than ~3 meaningful changes accumulate without a commit.
A `wip: progress on <feature>` commit is always better than lost work.
If push fails (no remote, auth), note it and continue — don't block work.

### Session End Discipline

Before ending a session or when the conversation is wrapping up:

1. **Commit all uncommitted work** — even if incomplete, a `wip:` commit preserves progress.
2. **Push to remote** — this is the backup. Don't skip it.
3. **Update PROGRESS.md** — ensure Current Focus and Task Queue reflect the actual state.
   Write a Work Log entry for whatever was last done, with a clear "Next" pointer.
4. **Summarize to the developer** — brief list of what was done this session and what's
   queued next, so they have a clean handoff even without reading PROGRESS.md.
