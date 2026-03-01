#!/usr/bin/env bash
# =============================================================================
# Kongka Stack — Main installer
# Usage: ./install.sh [--skip-preflight] [--kafka-only] [--kong-only]
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Trap to surface which step failed
trap 'echo "[install.sh] ERROR: install failed at line $LINENO. Check output above." >&2' ERR

# -----------------------------------------------------------------------------
# Cluster selection
# Scans auth/ for kubeconfig files and prompts the user to select one.
# Skipped if KUBECONFIG is already set in the environment.
# -----------------------------------------------------------------------------
pick_cluster() {
  local auth_dir="${SCRIPT_DIR}/auth"

  if [[ ! -d "$auth_dir" ]]; then
    echo "[install.sh] No auth/ directory found — using default kubeconfig"
    return
  fi

  mapfile -t kubeconfigs < <(find "$auth_dir" -maxdepth 1 \( -name "*.conf" -o -name "*.yaml" \) | sort)

  if [[ ${#kubeconfigs[@]} -eq 0 ]]; then
    echo "[install.sh] No kubeconfig files in auth/ — using default kubeconfig"
    return
  fi

  if [[ ${#kubeconfigs[@]} -eq 1 ]]; then
    export KUBECONFIG="${kubeconfigs[0]}"
    echo "[install.sh] Auto-selected cluster: $(basename "$KUBECONFIG")"
    return
  fi

  echo ""
  echo "Select a cluster:"
  echo ""
  local i=1
  for kc in "${kubeconfigs[@]}"; do
    local name server
    name=$(kubectl config view --kubeconfig="$kc" -o jsonpath='{.clusters[0].name}' 2>/dev/null || true)
    server=$(kubectl config view --kubeconfig="$kc" -o jsonpath='{.clusters[0].cluster.server}' 2>/dev/null || true)
    name="${name:-$(basename "$kc" .conf)}"
    server="${server:-unknown}"
    printf "  [%d] %-30s %s\n" "$i" "$(basename "$kc")" "$name  ($server)"
    (( i++ ))
  done
  echo ""

  local choice
  while true; do
    read -rp "Enter number [1-${#kubeconfigs[@]}]: " choice
    if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#kubeconfigs[@]} )); then
      export KUBECONFIG="${kubeconfigs[$((choice - 1))]}"
      echo "[install.sh] Using cluster: $(basename "$KUBECONFIG")"
      break
    fi
    echo "  Invalid — enter a number between 1 and ${#kubeconfigs[@]}."
  done
}

if [[ -n "${KUBECONFIG:-}" ]]; then
  echo "[install.sh] Using cluster from environment: $KUBECONFIG"
else
  pick_cluster
fi

# -----------------------------------------------------------------------------
# Setup wizard
# Runs automatically when config.env is absent, or when --reconfigure is passed.
# Probes the cluster for topology, available storage classes, LoadBalancer
# support, existing Helm releases, and chart versions. Every prompt is
# pre-populated from the existing config.env so --reconfigure is fast.
# Writes all answers to config.env.
# -----------------------------------------------------------------------------
run_setup_wizard() {
  local config_file="$1"
  local choice yn

  # Read a value from existing config file; return default if absent
  _cfg() { grep -m1 "^${1}=" "$config_file" 2>/dev/null | cut -d= -f2- || echo "${2}"; }

  # ── 1. Cluster probe (silent, informs suggestions throughout) ─────────────
  echo ""
  echo "[install.sh] ── Setup wizard ──────────────────────────────────────────"
  echo ""
  echo "  Probing cluster..."

  local all_nodes worker_count
  all_nodes=$(kubectl get nodes --no-headers 2>/dev/null | wc -l); all_nodes=$((all_nodes + 0))
  worker_count=$(kubectl get nodes -l '!node-role.kubernetes.io/control-plane' \
    --no-headers 2>/dev/null | wc -l); worker_count=$((worker_count + 0))
  local cp_count=$(( all_nodes - worker_count ))

  # Smallest worker CPU (cores) and memory (GiB) — used for resource suggestions
  local min_cpu=0 min_mem_gib=0
  while IFS=$'\t' read -r cpu mem; do
    [[ -z "$cpu" ]] && continue
    local cores; [[ "$cpu" == *m ]] && cores=$(( ${cpu%m} / 1000 )) || cores=$cpu
    local gib=$(( ${mem%Ki} / 1048576 ))
    (( min_cpu    == 0 || cores < min_cpu    )) && min_cpu=$cores
    (( min_mem_gib == 0 || gib   < min_mem_gib )) && min_mem_gib=$gib
  done < <(kubectl get nodes -l '!node-role.kubernetes.io/control-plane' \
    -o jsonpath='{range .items[*]}{.status.capacity.cpu}{"\t"}{.status.capacity.memory}{"\n"}{end}' \
    2>/dev/null)

  printf "  Cluster: %d nodes (%d control-plane, %d workers)\n" "$all_nodes" "$cp_count" "$worker_count"
  [[ $min_cpu -gt 0 ]] && printf "  Smallest worker: %d CPU cores, %dGi memory\n" "$min_cpu" "$min_mem_gib"

  # Derived resource suggestions
  local sug_brokers=3
  (( worker_count > 0 && worker_count < 3 )) && sug_brokers=$worker_count

  local sug_cpu_req=1 sug_cpu_lim=2
  (( min_cpu > 0 && min_cpu < 4 )) && sug_cpu_lim=$min_cpu

  local sug_mem_req="4Gi" sug_mem_lim="8Gi"
  if (( min_mem_gib > 0 )); then
    local r=$(( min_mem_gib / 4 )); (( r < 2 )) && r=2
    local l=$(( min_mem_gib / 2 )); (( l < 4 )) && l=4
    sug_mem_req="${r}Gi"; sug_mem_lim="${l}Gi"
  fi

  local sug_timeout=300; (( all_nodes > 5 )) && sug_timeout=600

  # ── 2. Helm repos (Kong chart needed for version queries below) ───────────
  echo "  Adding Helm repositories..."
  helm repo add kong https://charts.konghq.com 2>/dev/null || true
  helm repo update -q 2>/dev/null || true

  # ── 3. Namespaces ─────────────────────────────────────────────────────────
  echo ""
  echo "  ── Namespaces ──────────────────────────────────────────────────────"

  # Show existing non-system namespaces as reference
  local existing_ns=()
  mapfile -t existing_ns < <(kubectl get ns --no-headers 2>/dev/null \
    | awk '{print $1}' \
    | grep -vE '^(kube-|cattle-|fleet-|calico-|cert-manager|kommander|local$|default$)' \
    | sort)
  if [[ ${#existing_ns[@]} -gt 0 ]]; then
    printf "  Existing namespaces: %s\n" "$(IFS=', '; echo "${existing_ns[*]}")"
  fi

  local cur_kafka_ns; cur_kafka_ns="$(_cfg KAFKA_NAMESPACE kafka)"
  local cur_kong_ns;  cur_kong_ns="$(_cfg  KONG_NAMESPACE  kong)"
  local wiz_kafka_ns wiz_kong_ns
  read -rp "  Kafka namespace [$cur_kafka_ns]: " wiz_kafka_ns; wiz_kafka_ns="${wiz_kafka_ns:-$cur_kafka_ns}"
  read -rp "  Kong namespace  [$cur_kong_ns]: "  wiz_kong_ns;  wiz_kong_ns="${wiz_kong_ns:-$cur_kong_ns}"

  # ── 4. Storage class ──────────────────────────────────────────────────────
  echo ""
  local sc_names=() sc_is_default=()
  while IFS=$'\t' read -r name is_default; do
    [[ -z "$name" ]] && continue
    sc_names+=("$name"); sc_is_default+=("${is_default:-false}")
  done < <(kubectl get sc \
    -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.metadata.annotations.storageclass\.kubernetes\.io/is-default-class}{"\n"}{end}' \
    2>/dev/null)

  local wiz_storage_class cur_sc sc_default_name=""
  cur_sc="$(_cfg KAFKA_STORAGE_CLASS "")"
  for i in "${!sc_names[@]}"; do
    [[ "${sc_is_default[$i]}" == "true" ]] && sc_default_name="${sc_names[$i]}" && break
  done

  if [[ ${#sc_names[@]} -eq 0 ]]; then
    read -rp "  Storage class (none detected) [${cur_sc:-default}]: " wiz_storage_class
    wiz_storage_class="${wiz_storage_class:-${cur_sc:-default}}"
  elif [[ ${#sc_names[@]} -eq 1 ]]; then
    wiz_storage_class="${sc_names[0]}"
    echo "  Storage class: $wiz_storage_class (auto-selected, only option)"
  elif [[ -n "$sc_default_name" && ( -z "$cur_sc" || "$cur_sc" == "default" || "$cur_sc" == "$sc_default_name" ) ]]; then
    # Cluster has a clear default and config doesn't override it — auto-select, no prompt
    wiz_storage_class="$sc_default_name"
    echo "  Storage class: $wiz_storage_class (cluster default, auto-selected)"
  else
    # Multiple options, no unambiguous winner — show list and prompt
    local sc_default_idx=0 sc_cur_idx=0
    echo "  Storage class for Kafka PVCs:"
    for i in "${!sc_names[@]}"; do
      local tag=""
      [[ "${sc_is_default[$i]}" == "true" ]] && tag+=" (cluster default)" && sc_default_idx=$(( i + 1 ))
      [[ "${sc_names[$i]}" == "$cur_sc" ]]    && tag+=" (current)"        && sc_cur_idx=$(( i + 1 ))
      printf "    [%d] %s%s\n" "$(( i + 1 ))" "${sc_names[$i]}" "$tag"
    done
    echo ""
    local sc_hint=$(( sc_cur_idx > 0 ? sc_cur_idx : sc_default_idx ))
    local sc_prompt="  Enter number [1-${#sc_names[@]}]"
    [[ $sc_hint -gt 0 ]] && sc_prompt+=" (Enter for [$sc_hint])"
    sc_prompt+=": "
    while true; do
      read -rp "$sc_prompt" choice
      [[ -z "$choice" && $sc_hint -gt 0 ]] && choice=$sc_hint
      if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#sc_names[@]} )); then
        wiz_storage_class="${sc_names[$((choice - 1))]}"; echo "  → $wiz_storage_class"; break
      fi
      echo "    Invalid — enter a number between 1 and ${#sc_names[@]}."
    done
  fi

  # ── 5. Service type ───────────────────────────────────────────────────────
  echo ""
  local wiz_service_type lb_available=false
  kubectl get crd ipaddresspools.metallb.io &>/dev/null 2>&1 && lb_available=true
  if [[ "$lb_available" == "false" ]]; then
    kubectl get svc -A \
      -o jsonpath='{range .items[?(@.spec.type=="LoadBalancer")]}{.status.loadBalancer.ingress[0].ip}{"\n"}{end}' \
      2>/dev/null | grep -qE "^[0-9]+\.[0-9]" && lb_available=true
  fi

  if [[ "$lb_available" == "true" ]]; then
    wiz_service_type="LoadBalancer"
    echo "  Service type: LoadBalancer (provisioner detected)"
  else
    echo "  Service type (no LoadBalancer provisioner detected):"
    echo "    [1] NodePort      — works on any cluster, access via node IP + port"
    echo "    [2] LoadBalancer  — requires MetalLB or cloud load balancer"
    echo ""
    read -rp "  Enter number [1-2] (Enter for [1]): " choice
    case "${choice:-1}" in
      2) wiz_service_type="LoadBalancer" ;;
      *) wiz_service_type="NodePort" ;;
    esac
    echo "  → $wiz_service_type"
  fi

  # ── 6. Kafka ──────────────────────────────────────────────────────────────
  echo ""
  echo "  ── Kafka ───────────────────────────────────────────────────────────"
  echo "  Chart: kafka-kraft (local — charts/kafka-kraft/)"

  # Release name — detect existing releases in namespace
  local wiz_kafka_rel cur_kafka_rel
  cur_kafka_rel="$(_cfg KAFKA_RELEASE_NAME kafka)"
  local kafka_releases=()
  mapfile -t kafka_releases < <(helm list -n "$wiz_kafka_ns" --short 2>/dev/null || true)
  if [[ ${#kafka_releases[@]} -gt 0 ]]; then
    echo ""
    echo "  Existing Helm releases in '$wiz_kafka_ns':"
    local cur_rel_idx=0
    for i in "${!kafka_releases[@]}"; do
      local tag=""; [[ "${kafka_releases[$i]}" == "$cur_kafka_rel" ]] && tag=" (current)" && cur_rel_idx=$(( i + 1 ))
      printf "    [%d] %s%s\n" "$(( i + 1 ))" "${kafka_releases[$i]}" "$tag"
    done
    printf "    [%d] New release\n" "$(( ${#kafka_releases[@]} + 1 ))"
    echo ""
    local rel_hint=$(( cur_rel_idx > 0 ? cur_rel_idx : 1 ))
    local total_rel=$(( ${#kafka_releases[@]} + 1 ))
    while true; do
      read -rp "  Enter number [1-${total_rel}] (Enter for [$rel_hint]): " choice
      [[ -z "$choice" ]] && choice=$rel_hint
      if [[ "$choice" =~ ^[0-9]+$ ]]; then
        if (( choice >= 1 && choice <= ${#kafka_releases[@]} )); then
          wiz_kafka_rel="${kafka_releases[$((choice - 1))]}"; echo "  → upgrade: $wiz_kafka_rel"; break
        elif (( choice == total_rel )); then
          read -rp "  New release name [$cur_kafka_rel]: " wiz_kafka_rel
          wiz_kafka_rel="${wiz_kafka_rel:-$cur_kafka_rel}"; echo "  → new: $wiz_kafka_rel"; break
        fi
      fi
      echo "    Invalid — enter a number between 1 and ${total_rel}."
    done
  else
    read -rp "  Kafka release name [$cur_kafka_rel]: " wiz_kafka_rel
    wiz_kafka_rel="${wiz_kafka_rel:-$cur_kafka_rel}"
  fi

  # Broker count
  echo ""
  local cur_brokers; cur_brokers="$(_cfg KAFKA_BROKER_COUNT "$sug_brokers")"
  (( worker_count > 0 )) && printf "  Worker nodes: %d  →  recommended: %d (≤ worker count)\n" \
    "$worker_count" "$sug_brokers"
  local wiz_brokers
  read -rp "  Broker count [$cur_brokers]: " wiz_brokers; wiz_brokers="${wiz_brokers:-$cur_brokers}"

  # Storage per broker
  local cur_storage; cur_storage="$(_cfg KAFKA_STORAGE_SIZE 50Gi)"; local wiz_storage
  read -rp "  Storage per broker [$cur_storage]: " wiz_storage; wiz_storage="${wiz_storage:-$cur_storage}"

  # CPU per broker
  local cur_cpu_req; cur_cpu_req="$(_cfg KAFKA_CPU_REQUEST "$sug_cpu_req")"
  local cur_cpu_lim; cur_cpu_lim="$(_cfg KAFKA_CPU_LIMIT   "$sug_cpu_lim")"
  (( min_cpu > 0 )) && printf "  Smallest worker: %d CPU cores\n" "$min_cpu"
  local cpu_input wiz_cpu_req wiz_cpu_lim
  read -rp "  CPU per broker — request/limit [${cur_cpu_req}/${cur_cpu_lim}]: " cpu_input
  if [[ -z "$cpu_input" ]]; then
    wiz_cpu_req="$cur_cpu_req"; wiz_cpu_lim="$cur_cpu_lim"
  else
    wiz_cpu_req="${cpu_input%%/*}"; wiz_cpu_lim="${cpu_input##*/}"
  fi

  # Memory per broker
  local cur_mem_req; cur_mem_req="$(_cfg KAFKA_MEM_REQUEST "$sug_mem_req")"
  local cur_mem_lim; cur_mem_lim="$(_cfg KAFKA_MEM_LIMIT   "$sug_mem_lim")"
  (( min_mem_gib > 0 )) && printf "  Smallest worker: %dGi memory\n" "$min_mem_gib"
  local mem_input wiz_mem_req wiz_mem_lim
  read -rp "  Memory per broker — request/limit [${cur_mem_req}/${cur_mem_lim}]: " mem_input
  if [[ -z "$mem_input" ]]; then
    wiz_mem_req="$cur_mem_req"; wiz_mem_lim="$cur_mem_lim"
  else
    wiz_mem_req="${mem_input%%/*}"; wiz_mem_lim="${mem_input##*/}"
  fi

  # ── 7. Components ─────────────────────────────────────────────────────────
  echo ""
  echo "  ── Components ──────────────────────────────────────────────────────"
  local cur_cc; cur_cc="$(_cfg CC_ENABLED true)"; local wiz_cc
  local cur_sr; cur_sr="$(_cfg SR_ENABLED true)"; local wiz_sr
  local cur_jaeger; cur_jaeger="$(_cfg JAEGER_ENABLED false)"; local wiz_jaeger
  local cur_jaeger_strategy; cur_jaeger_strategy="$(_cfg JAEGER_STRATEGY allInOne)"
  local wiz_jaeger_strategy

  local cc_hint="Y/n"; [[ "$cur_cc" == "false" ]] && cc_hint="y/N"
  read -rp "  Enable Control Center (Kafka management UI)? [$cc_hint]: " yn
  if   [[ -z "$yn" ]];                            then wiz_cc="$cur_cc"
  elif [[ "${yn,,}" == "n" || "${yn,,}" == "no" ]]; then wiz_cc="false"
  else wiz_cc="true"; fi

  local sr_hint="Y/n"; [[ "$cur_sr" == "false" ]] && sr_hint="y/N"
  read -rp "  Enable Schema Registry? [$sr_hint]: " yn
  if   [[ -z "$yn" ]];                            then wiz_sr="$cur_sr"
  elif [[ "${yn,,}" == "n" || "${yn,,}" == "no" ]]; then wiz_sr="false"
  else wiz_sr="true"; fi

  local jaeger_hint="y/N"; [[ "$cur_jaeger" == "true" ]] && jaeger_hint="Y/n"
  read -rp "  Enable Jaeger (distributed tracing)? [$jaeger_hint]: " yn
  if   [[ -z "$yn" ]];                            then wiz_jaeger="$cur_jaeger"
  elif [[ "${yn,,}" == "n" || "${yn,,}" == "no" ]]; then wiz_jaeger="false"
  else wiz_jaeger="true"; fi

  wiz_jaeger_strategy="$cur_jaeger_strategy"
  if [[ "$wiz_jaeger" == "true" ]]; then
    local jaeger_strat_def=1; [[ "$cur_jaeger_strategy" == "production" ]] && jaeger_strat_def=2
    echo "  Jaeger strategy:"
    echo "    [1] allInOne   — Single pod, in-memory storage (POC default)"
    echo "    [2] production — Separate components with Elasticsearch backend"
    read -rp "  Enter number [1-2] (Enter for [$jaeger_strat_def]): " choice
    case "${choice:-$jaeger_strat_def}" in
      2) wiz_jaeger_strategy="production" ;;
      *) wiz_jaeger_strategy="allInOne" ;;
    esac
    echo "  → $wiz_jaeger_strategy"
  fi

  # ── 8. Kong ───────────────────────────────────────────────────────────────
  echo ""
  echo "  ── Kong ────────────────────────────────────────────────────────────"

  # Chart version
  local wiz_kong_ver="" kong_versions=()
  mapfile -t kong_versions < <(
    helm search repo kong/kong --versions 2>/dev/null | awk 'NR>1 {print $2}' | head -5)
  if [[ ${#kong_versions[@]} -gt 0 ]]; then
    local cur_kong_ver; cur_kong_ver="$(_cfg KONG_CHART_VERSION "")"; local cur_kgv_idx=0
    echo "  Chart version (kong/kong):"
    for i in "${!kong_versions[@]}"; do
      local tag=""; [[ $i -eq 0 ]] && tag+=" (latest)"
      [[ "${kong_versions[$i]}" == "$cur_kong_ver" ]] && tag+=" (current)" && cur_kgv_idx=$(( i + 1 ))
      printf "    [%d] %s%s\n" "$(( i + 1 ))" "${kong_versions[$i]}" "$tag"
    done
    echo ""
    local kgv_hint=$(( cur_kgv_idx > 0 ? cur_kgv_idx : 1 ))
    read -rp "  Enter number [1-${#kong_versions[@]}] (Enter for [$kgv_hint]): " choice
    [[ -z "$choice" ]] && choice=$kgv_hint
    if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#kong_versions[@]} )); then
      wiz_kong_ver="${kong_versions[$((choice - 1))]}"
      [[ "$wiz_kong_ver" == "${kong_versions[0]}" ]] && wiz_kong_ver=""
    fi
    echo "  → ${wiz_kong_ver:-${kong_versions[0]} (latest)}"
  fi

  # Release name — detect existing releases
  local wiz_kong_rel cur_kong_rel
  cur_kong_rel="$(_cfg KONG_RELEASE_NAME kong)"
  local kong_releases=()
  mapfile -t kong_releases < <(helm list -n "$wiz_kong_ns" --short 2>/dev/null || true)
  if [[ ${#kong_releases[@]} -gt 0 ]]; then
    echo ""
    echo "  Existing Helm releases in '$wiz_kong_ns':"
    local cur_kong_rel_idx=0
    for i in "${!kong_releases[@]}"; do
      local tag=""; [[ "${kong_releases[$i]}" == "$cur_kong_rel" ]] && tag=" (current)" && cur_kong_rel_idx=$(( i + 1 ))
      printf "    [%d] %s%s\n" "$(( i + 1 ))" "${kong_releases[$i]}" "$tag"
    done
    printf "    [%d] New release\n" "$(( ${#kong_releases[@]} + 1 ))"
    echo ""
    local kong_hint=$(( cur_kong_rel_idx > 0 ? cur_kong_rel_idx : 1 ))
    local total_kong=$(( ${#kong_releases[@]} + 1 ))
    while true; do
      read -rp "  Enter number [1-${total_kong}] (Enter for [$kong_hint]): " choice
      [[ -z "$choice" ]] && choice=$kong_hint
      if [[ "$choice" =~ ^[0-9]+$ ]]; then
        if (( choice >= 1 && choice <= ${#kong_releases[@]} )); then
          wiz_kong_rel="${kong_releases[$((choice - 1))]}"; echo "  → upgrade: $wiz_kong_rel"; break
        elif (( choice == total_kong )); then
          read -rp "  New release name [$cur_kong_rel]: " wiz_kong_rel
          wiz_kong_rel="${wiz_kong_rel:-$cur_kong_rel}"; echo "  → new: $wiz_kong_rel"; break
        fi
      fi
      echo "    Invalid — enter a number between 1 and ${total_kong}."
    done
  else
    read -rp "  Kong release name [$cur_kong_rel]: " wiz_kong_rel
    wiz_kong_rel="${wiz_kong_rel:-$cur_kong_rel}"
  fi

  # Kong mode — suggest ingress if CRDs already present
  echo ""
  local crd_present=false
  kubectl get crd kongplugins.configuration.konghq.com &>/dev/null 2>&1 && crd_present=true
  local cur_kong_mode; cur_kong_mode="$(_cfg KONG_MODE ingress)"
  local kong_mode_def=1; [[ "$cur_kong_mode" == "gateway" ]] && kong_mode_def=2
  echo "  Deployment mode:"
  local crd_note=""; [[ "$crd_present" == "true" ]] && crd_note=" ← Kong CRDs detected on cluster"
  printf "    [1] ingress  — Kong Ingress Controller, Kubernetes-native%s\n" "$crd_note"
  echo "    [2] gateway  — Standalone proxy, no Kubernetes integration"
  read -rp "  Enter number [1-2] (Enter for [$kong_mode_def]): " choice
  local wiz_kong_mode="ingress"; [[ "${choice:-$kong_mode_def}" == "2" ]] && wiz_kong_mode="gateway"

  # Kong DB mode
  local cur_kong_db; cur_kong_db="$(_cfg KONG_DB_MODE dbless)"
  local kong_db_def=1; [[ "$cur_kong_db" == "postgres" ]] && kong_db_def=2
  echo "  Database mode:"
  echo "    [1] dbless   — Declarative config, no database needed"
  echo "    [2] postgres — Postgres-backed, supports live Admin API writes"
  read -rp "  Enter number [1-2] (Enter for [$kong_db_def]): " choice
  local wiz_kong_db="dbless"; [[ "${choice:-$kong_db_def}" == "2" ]] && wiz_kong_db="postgres"

  # ── 9. Timeouts ───────────────────────────────────────────────────────────
  echo ""
  local cur_timeout; cur_timeout="$(_cfg ROLLOUT_TIMEOUT "$sug_timeout")"
  (( all_nodes > 5 )) && echo "  Large cluster detected — suggesting ${sug_timeout}s timeout"
  local wiz_timeout
  read -rp "  Rollout timeout seconds [$cur_timeout]: " wiz_timeout
  wiz_timeout="${wiz_timeout:-$cur_timeout}"

  # ── 10. Summary + confirmation ────────────────────────────────────────────
  echo ""
  echo "  ── Summary ─────────────────────────────────────────────────────────"
  printf "  Cluster       : %s\n"  "$(basename "${KUBECONFIG:-default}")"
  printf "  Namespaces    : kafka=%s  kong=%s\n" "$wiz_kafka_ns" "$wiz_kong_ns"
  printf "  Storage class : %s\n"  "$wiz_storage_class"
  printf "  Service type  : %s\n"  "$wiz_service_type"
  echo   "  Kafka"
  printf "    Release     : %s  (chart: kafka-kraft, local)\n" "$wiz_kafka_rel"
  printf "    Brokers     : %s × CPU %s/%s  Memory %s/%s  Storage %s\n" \
    "$wiz_brokers" "$wiz_cpu_req" "$wiz_cpu_lim" "$wiz_mem_req" "$wiz_mem_lim" "$wiz_storage"
  printf "    Components  : control-center=%s  schema-registry=%s\n" "$wiz_cc" "$wiz_sr"
  printf "  Jaeger        : enabled=%s  strategy=%s\n" "$wiz_jaeger" "$wiz_jaeger_strategy"
  echo   "  Kong"
  printf "    Release     : %s  (chart: %s)\n" "$wiz_kong_rel" "${wiz_kong_ver:-latest}"
  printf "    Mode        : %s / %s\n"          "$wiz_kong_mode" "$wiz_kong_db"
  printf "  Timeout       : %ss\n"              "$wiz_timeout"
  echo ""
  read -rp "  Save to config.env and proceed? [Y/n]: " yn
  if [[ "${yn,,}" == "n" || "${yn,,}" == "no" ]]; then
    echo "  Aborted — run './install.sh --reconfigure' to restart the wizard."
    exit 0
  fi

  # ── 11. Write config.env ──────────────────────────────────────────────────
  echo ""
  cat > "$config_file" <<EOF
# Generated by install.sh wizard — $(date -u +"%Y-%m-%d %H:%M UTC")
# Cluster: $(basename "${KUBECONFIG:-default}")
# Re-run wizard: ./install.sh --reconfigure

KAFKA_NAMESPACE=${wiz_kafka_ns}
KONG_NAMESPACE=${wiz_kong_ns}

KAFKA_BROKER_COUNT=${wiz_brokers}
KAFKA_IMAGE=confluentinc/cp-server:7.6.0
KAFKA_STORAGE_CLASS=${wiz_storage_class}
KAFKA_STORAGE_SIZE=${wiz_storage}
KAFKA_CPU_REQUEST=${wiz_cpu_req}
KAFKA_CPU_LIMIT=${wiz_cpu_lim}
KAFKA_MEM_REQUEST=${wiz_mem_req}
KAFKA_MEM_LIMIT=${wiz_mem_lim}
KAFKA_CLUSTER_ID=
KAFKA_RELEASE_NAME=${wiz_kafka_rel}

CC_ENABLED=${wiz_cc}
CC_IMAGE=confluentinc/cp-enterprise-control-center:7.6.0

SR_ENABLED=${wiz_sr}
SR_IMAGE=confluentinc/cp-schema-registry:7.6.0

KONG_MODE=${wiz_kong_mode}
KONG_DB_MODE=${wiz_kong_db}
KONG_RELEASE_NAME=${wiz_kong_rel}
KONG_CHART_VERSION=${wiz_kong_ver}

JAEGER_ENABLED=${wiz_jaeger}
JAEGER_NAMESPACE=observability
JAEGER_RELEASE_NAME=jaeger
JAEGER_STRATEGY=${wiz_jaeger_strategy}
JAEGER_STORAGE_TYPE=elasticsearch

SERVICE_TYPE=${wiz_service_type}
ROLLOUT_TIMEOUT=${wiz_timeout}
EOF

  echo "[install.sh] Configuration saved to $(basename "$config_file")"
  echo "[install.sh] ────────────────────────────────────────────────────────"
  echo ""
}

# -----------------------------------------------------------------------------
# Flags
# -----------------------------------------------------------------------------
SKIP_PREFLIGHT=false
KAFKA_ONLY=false
KONG_ONLY=false
JAEGER_ONLY=false
RECONFIGURE=false

for arg in "$@"; do
  case "$arg" in
    --skip-preflight) SKIP_PREFLIGHT=true ;;
    --kafka-only)     KAFKA_ONLY=true ;;
    --kong-only)      KONG_ONLY=true ;;
    --jaeger-only)    JAEGER_ONLY=true ;;
    --reconfigure)    RECONFIGURE=true ;;
    *) echo "[install.sh] Unknown argument: $arg" >&2; exit 1 ;;
  esac
done

# -----------------------------------------------------------------------------
# Load config  (wizard runs first if config.env is absent or --reconfigure set)
# -----------------------------------------------------------------------------
CONFIG_FILE="${SCRIPT_DIR}/config.env"

if [[ "$RECONFIGURE" == "true" || ! -f "$CONFIG_FILE" ]]; then
  run_setup_wizard "$CONFIG_FILE"
fi

if [[ -f "$CONFIG_FILE" ]]; then
  echo "[install.sh] Loading config from $CONFIG_FILE"
  # shellcheck source=/dev/null
  source "$CONFIG_FILE"
else
  echo "[install.sh] No config.env found — using built-in defaults"
fi

# Apply defaults for any unset variables
KAFKA_NAMESPACE="${KAFKA_NAMESPACE:-kafka}"
KONG_NAMESPACE="${KONG_NAMESPACE:-kong}"
KAFKA_BROKER_COUNT="${KAFKA_BROKER_COUNT:-3}"
KAFKA_IMAGE="${KAFKA_IMAGE:-confluentinc/cp-server:7.6.0}"
KAFKA_STORAGE_CLASS="${KAFKA_STORAGE_CLASS:-default}"
KAFKA_STORAGE_SIZE="${KAFKA_STORAGE_SIZE:-50Gi}"
KAFKA_CPU_REQUEST="${KAFKA_CPU_REQUEST:-1}"
KAFKA_CPU_LIMIT="${KAFKA_CPU_LIMIT:-2}"
KAFKA_MEM_REQUEST="${KAFKA_MEM_REQUEST:-4Gi}"
KAFKA_MEM_LIMIT="${KAFKA_MEM_LIMIT:-8Gi}"
KAFKA_CLUSTER_ID="${KAFKA_CLUSTER_ID:-}"
KAFKA_RELEASE_NAME="${KAFKA_RELEASE_NAME:-kafka}"
CC_ENABLED="${CC_ENABLED:-true}"
CC_IMAGE="${CC_IMAGE:-confluentinc/cp-enterprise-control-center:7.6.0}"
SR_ENABLED="${SR_ENABLED:-true}"
SR_IMAGE="${SR_IMAGE:-confluentinc/cp-schema-registry:7.6.0}"
KONG_MODE="${KONG_MODE:-ingress}"
KONG_DB_MODE="${KONG_DB_MODE:-dbless}"
KONG_RELEASE_NAME="${KONG_RELEASE_NAME:-kong}"
KONG_CHART_VERSION="${KONG_CHART_VERSION:-}"
JAEGER_ENABLED="${JAEGER_ENABLED:-false}"
JAEGER_NAMESPACE="${JAEGER_NAMESPACE:-observability}"
JAEGER_RELEASE_NAME="${JAEGER_RELEASE_NAME:-jaeger}"
JAEGER_STRATEGY="${JAEGER_STRATEGY:-allInOne}"
JAEGER_STORAGE_TYPE="${JAEGER_STORAGE_TYPE:-elasticsearch}"
SERVICE_TYPE="${SERVICE_TYPE:-LoadBalancer}"
ROLLOUT_TIMEOUT="${ROLLOUT_TIMEOUT:-300}"

# --jaeger-only: force Jaeger on and skip Kafka/Kong installs
[[ "$JAEGER_ONLY" == "true" ]] && JAEGER_ENABLED="true"

export KAFKA_NAMESPACE KONG_NAMESPACE KAFKA_BROKER_COUNT KAFKA_IMAGE
export KAFKA_STORAGE_CLASS KAFKA_STORAGE_SIZE KAFKA_CPU_REQUEST KAFKA_CPU_LIMIT
export KAFKA_MEM_REQUEST KAFKA_MEM_LIMIT KAFKA_CLUSTER_ID KAFKA_RELEASE_NAME
export CC_ENABLED CC_IMAGE SR_ENABLED SR_IMAGE
export KONG_MODE KONG_DB_MODE KONG_RELEASE_NAME KONG_CHART_VERSION
export JAEGER_ENABLED JAEGER_NAMESPACE JAEGER_RELEASE_NAME JAEGER_STRATEGY JAEGER_STORAGE_TYPE
export SERVICE_TYPE ROLLOUT_TIMEOUT JAEGER_ONLY
export SCRIPT_DIR

# -----------------------------------------------------------------------------
# Cluster settings reconciliation
# Always runs after cluster selection, even when reusing an existing config.env.
# Ensures KAFKA_STORAGE_CLASS and SERVICE_TYPE are valid for the chosen cluster.
# Handles the common case of switching clusters without re-running the wizard.
# -----------------------------------------------------------------------------
detect_cluster_settings() {
  # ── Storage class ──────────────────────────────────────────────────────────
  local sc_names=() sc_is_default=() sc_default_name=""
  while IFS=$'\t' read -r name is_default; do
    [[ -z "$name" ]] && continue
    sc_names+=("$name")
    sc_is_default+=("${is_default:-false}")
    [[ "${is_default:-false}" == "true" ]] && sc_default_name="$name"
  done < <(kubectl get sc \
    -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.metadata.annotations.storageclass\.kubernetes\.io/is-default-class}{"\n"}{end}' \
    2>/dev/null)

  if [[ ${#sc_names[@]} -eq 0 ]]; then
    echo "[install.sh] WARNING: No storage classes found — using KAFKA_STORAGE_CLASS=${KAFKA_STORAGE_CLASS}"
  else
    # Check if configured value exists on this cluster
    local sc_valid=false
    for sc in "${sc_names[@]}"; do
      [[ "$sc" == "$KAFKA_STORAGE_CLASS" ]] && sc_valid=true && break
    done

    if [[ "$sc_valid" == "true" ]]; then
      echo "[install.sh] Storage class: $KAFKA_STORAGE_CLASS (confirmed on cluster)"
    elif [[ ${#sc_names[@]} -eq 1 ]]; then
      echo "[install.sh] Storage class: ${sc_names[0]} (auto-selected — '${KAFKA_STORAGE_CLASS}' not found on cluster)"
      KAFKA_STORAGE_CLASS="${sc_names[0]}"
      export KAFKA_STORAGE_CLASS
    elif [[ -n "$sc_default_name" ]]; then
      echo "[install.sh] Storage class: $sc_default_name (cluster default — '${KAFKA_STORAGE_CLASS}' not found on cluster)"
      KAFKA_STORAGE_CLASS="$sc_default_name"
      export KAFKA_STORAGE_CLASS
    else
      # Multiple classes, none matching, no cluster default → must ask
      echo ""
      echo "[install.sh] '${KAFKA_STORAGE_CLASS}' not found on this cluster. Select a storage class:"
      echo ""
      local i=1
      for sc in "${sc_names[@]}"; do
        printf "  [%d] %s\n" "$i" "$sc"
        (( i++ ))
      done
      echo ""
      local choice
      while true; do
        read -rp "Enter number [1-${#sc_names[@]}]: " choice
        if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#sc_names[@]} )); then
          KAFKA_STORAGE_CLASS="${sc_names[$((choice - 1))]}"
          export KAFKA_STORAGE_CLASS
          echo "[install.sh] Storage class: $KAFKA_STORAGE_CLASS"
          break
        fi
        echo "  Invalid — enter a number between 1 and ${#sc_names[@]}."
      done
    fi
  fi

  # ── Service type ───────────────────────────────────────────────────────────
  local lb_available=false
  if kubectl get crd ipaddresspools.metallb.io &>/dev/null 2>&1; then
    lb_available=true
  elif kubectl get svc -A \
      -o jsonpath='{range .items[?(@.spec.type=="LoadBalancer")]}{.status.loadBalancer.ingress[0].ip}{"\n"}{end}' \
      2>/dev/null | grep -qE "^[0-9]+\.[0-9]"; then
    lb_available=true
  fi

  if [[ "$lb_available" == "true" && "$SERVICE_TYPE" != "LoadBalancer" ]]; then
    echo "[install.sh] Service type: LoadBalancer (provisioner detected; overriding config value '$SERVICE_TYPE')"
    SERVICE_TYPE="LoadBalancer"
    export SERVICE_TYPE
  elif [[ "$lb_available" == "false" && "$SERVICE_TYPE" == "LoadBalancer" ]]; then
    echo "[install.sh] WARNING: SERVICE_TYPE=LoadBalancer but no provisioner detected — services may stay Pending"
    echo "[install.sh]   If this is wrong, re-run with --reconfigure to update config.env"
  else
    echo "[install.sh] Service type: $SERVICE_TYPE"
  fi
}

detect_cluster_settings

# -----------------------------------------------------------------------------
# Preflight
# -----------------------------------------------------------------------------
if [[ "$SKIP_PREFLIGHT" == "false" ]]; then
  echo "[install.sh] Running preflight checks..."
  bash "${SCRIPT_DIR}/scripts/preflight.sh"
  echo "[install.sh] Preflight passed."
fi

# -----------------------------------------------------------------------------
# Create namespaces (idempotent)
# -----------------------------------------------------------------------------
echo "[install.sh] Creating namespaces..."
kubectl create namespace "$KAFKA_NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace "$KONG_NAMESPACE"  --dry-run=client -o yaml | kubectl apply -f -
if [[ "$JAEGER_ENABLED" == "true" ]]; then
  kubectl create namespace "$JAEGER_NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -
fi

# -----------------------------------------------------------------------------
# Add Helm repos
# -----------------------------------------------------------------------------
echo "[install.sh] Adding Helm repositories..."
helm repo add kong https://charts.konghq.com 2>/dev/null || true
if [[ "$JAEGER_ENABLED" == "true" ]]; then
  helm repo add jaegertracing https://jaegertracing.github.io/helm-charts 2>/dev/null || true
fi
helm repo update

# -----------------------------------------------------------------------------
# Install Kafka stack
# -----------------------------------------------------------------------------
if [[ "$KONG_ONLY" == "false" && "$JAEGER_ONLY" == "false" ]]; then
  echo "[install.sh] Installing Kafka stack..."
  bash "${SCRIPT_DIR}/scripts/install-kafka.sh"
  echo "[install.sh] Kafka stack installed."
fi

# -----------------------------------------------------------------------------
# Install Kong
# -----------------------------------------------------------------------------
if [[ "$KAFKA_ONLY" == "false" && "$JAEGER_ONLY" == "false" ]]; then
  echo "[install.sh] Installing Kong..."
  bash "${SCRIPT_DIR}/scripts/install-kong.sh"
  echo "[install.sh] Kong installed."
fi

# -----------------------------------------------------------------------------
# Install Jaeger (optional)
# -----------------------------------------------------------------------------
if [[ "$JAEGER_ENABLED" == "true" ]]; then
  echo "[install.sh] Installing Jaeger (strategy: ${JAEGER_STRATEGY})..."
  bash "${SCRIPT_DIR}/scripts/install-jaeger.sh"
  echo "[install.sh] Jaeger installed."
fi

# -----------------------------------------------------------------------------
# Verify
# -----------------------------------------------------------------------------
echo "[install.sh] Running post-install verification..."
bash "${SCRIPT_DIR}/scripts/verify.sh"

echo ""
echo "[install.sh] ============================================================"
echo "[install.sh]  Kongka stack installation complete."
echo "[install.sh] ============================================================"
echo ""

if [[ "$JAEGER_ONLY" == "false" ]]; then
  echo "  Kafka namespace : $KAFKA_NAMESPACE"
  echo "  Kong namespace  : $KONG_NAMESPACE"
  echo ""
  echo "  Endpoints:"
  if [[ "${CC_ENABLED:-true}" == "true" ]]; then
    CC_IP=$(kubectl get svc -n "$KAFKA_NAMESPACE" "${KAFKA_RELEASE_NAME}-cc-lb" \
      -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "")
    if [[ -n "$CC_IP" ]]; then
      echo "    Control Center  : http://${CC_IP}:9021"
    else
      echo "    Control Center  : kubectl get svc -n $KAFKA_NAMESPACE ${KAFKA_RELEASE_NAME}-cc-lb"
    fi
  fi
  KONG_IP=$(kubectl get svc -n "$KONG_NAMESPACE" "${KONG_RELEASE_NAME}-kong-proxy" \
    -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "")
  if [[ -n "$KONG_IP" ]]; then
    echo "    Kong proxy      : http://${KONG_IP}"
  else
    echo "    Kong proxy      : kubectl get svc -n $KONG_NAMESPACE ${KONG_RELEASE_NAME}-kong-proxy"
  fi
fi

if [[ "$JAEGER_ENABLED" == "true" ]]; then
  echo "  Jaeger namespace: $JAEGER_NAMESPACE"
  JAEGER_IP=$(kubectl get svc -n "$JAEGER_NAMESPACE" "${JAEGER_RELEASE_NAME}-query" \
    -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "")
  echo ""
  echo "  Jaeger endpoints:"
  if [[ -n "$JAEGER_IP" ]]; then
    echo "    UI (traces)     : http://${JAEGER_IP}:16686"
    echo "    OTLP gRPC       : ${JAEGER_IP}:4317"
    echo "    OTLP HTTP       : http://${JAEGER_IP}:4318"
    echo "    Thrift HTTP     : http://${JAEGER_IP}:14268/api/traces"
  else
    echo "    kubectl get svc -n $JAEGER_NAMESPACE ${JAEGER_RELEASE_NAME}-query"
  fi
fi

echo ""
