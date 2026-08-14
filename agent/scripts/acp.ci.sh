#!/usr/bin/env bash
# acp.ci.sh — local CI parity orchestrator (M86 / ADR-24)
#
# Predicts AE GitHub Actions gates via agent/configurables/ci.yml +
# agent/scripts/acp.ci-steps.sh. No Expo/Firebase/product stack knowledge.
#
# Usage:
#   bash agent/scripts/acp.ci.sh --doctor
#   bash agent/scripts/acp.ci.sh --static
#   bash agent/scripts/acp.ci.sh --fast
#   bash agent/scripts/acp.ci.sh --full
#   bash agent/scripts/acp.ci.sh --only shellcheck,validate-ts
#   bash agent/scripts/acp.ci.sh --dry-run
#
# False-green contracts: agent/patterns/local.false-green-contracts.md (FG-1…FG-7)
# P-PATH-1: bodies live only in agent/scripts/acp.ci-steps.sh
# P-CI-1: ci.yml is runtime matrix, not a preference registry

set -euo pipefail
trap 'echo "[acp.ci] Error on line ${LINENO}" >&2; exit 1' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
cd "${REPO_ROOT}"

CI_CONFIG="${ACP_CI_CONFIG:-${REPO_ROOT}/agent/configurables/ci.yml}"
STEPS_LIB="${ACP_CI_STEPS_LIB:-${SCRIPT_DIR}/acp.ci-steps.sh}"

TIER="fast"
DRY_RUN=false
DOCTOR=false
ONLY=""
ONLY_SET=false

RESULTS=""   # "id=STATUS" pairs
FAILED_STEP=""
EXECUTED_STEPS=0
SKIPPED_ANY=false

usage() {
  cat <<'EOF'
Usage: acp.ci.sh [tier] [options]

Run the gates GitHub Actions runs, locally, before pushing.

Tiers (wall-clock guidance from agent/reports/m86-ci-job-baseline.md):
  --static            Cheapest syntax/unit gates (~seconds)
  --fast              DEFAULT — T0+T1 (~tens of seconds to ~1–2 min).
                      Does NOT run shellcheck or full e2e-smoke.
  --full              CI-equivalent including T2. Expect shellcheck ~40s
                      plus full e2e-smoke ~4.5+ minutes (idle machine).
                      Use only when you need local PR-gate parity.

Options:
  --only ID[,ID]      Explicit step list (unknown id → exit 2)
  --dry-run           Print the plan without executing (≠ verification)
  --doctor            Probe dependencies, print matrix, run no gates
  -h, --help          Help

Agent command: /acp-ci — see agent/commands/acp.ci.md
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --static) TIER="static"; shift ;;
    --fast) TIER="fast"; shift ;;
    --full) TIER="full"; shift ;;
    --only)
      if [[ $# -lt 2 ]]; then
        echo "[acp.ci] ERROR: --only requires a comma-separated step list" >&2
        exit 2
      fi
      ONLY="${2}"
      ONLY_SET=true
      shift 2
      ;;
    --dry-run) DRY_RUN=true; shift ;;
    --doctor) DOCTOR=true; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown arg: $1" >&2; usage >&2; exit 2 ;;
  esac
done

if [[ ! -f "${CI_CONFIG}" ]]; then
  echo "[acp.ci] ERROR: missing ${CI_CONFIG}" >&2
  exit 1
fi
if [[ ! -f "${STEPS_LIB}" ]]; then
  echo "[acp.ci] ERROR: missing ${STEPS_LIB} (P-PATH-1)" >&2
  exit 1
fi

# shellcheck source=acp.ci-steps.sh
source "${STEPS_LIB}"

# ── Config load (python — nested YAML; avoids fragile grep) ─────────────
_ci_py() {
  python3 - "$@" <<'PY'
import sys, re
path, op = sys.argv[1], sys.argv[2]
text = open(path, encoding="utf-8").read()

def parse_simple(text):
    # Minimal subset parser for our ci.yml shape (no anchors).
    tiers = {"static": [], "fast": [], "full": []}
    steps = {}
    section = None
    cur_tier = None
    cur_step = None
    for raw in text.splitlines():
        line = raw.rstrip()
        if not line.strip() or line.lstrip().startswith("#"):
            continue
        if re.match(r"^tiers:\s*$", line):
            section = "tiers"; cur_tier = None; cur_step = None; continue
        if re.match(r"^steps:\s*$", line):
            section = "steps"; cur_tier = None; cur_step = None; continue
        if section == "tiers":
            m = re.match(r"^  (static|fast|full):\s*$", line)
            if m:
                cur_tier = m.group(1); continue
            m = re.match(r"^    - (\S+)\s*$", line)
            if m and cur_tier:
                tiers[cur_tier].append(m.group(1)); continue
        if section == "steps":
            m = re.match(r"^  ([a-z0-9-]+):\s*$", line)
            if m:
                cur_step = m.group(1)
                steps[cur_step] = {
                    "description": "", "command": cur_step, "ci_job": "",
                    "cost_rank": 999, "ci_rank": 999, "tools": [],
                    "output_contains": [], "allow_skip": False,
                }
                continue
            if cur_step is None:
                continue
            m = re.match(r'^    description:\s*"(.*)"\s*$', line)
            if m: steps[cur_step]["description"] = m.group(1); continue
            m = re.match(r"^    description:\s*(.+)\s*$", line)
            if m: steps[cur_step]["description"] = m.group(1).strip().strip('"'); continue
            m = re.match(r"^    command:\s*(\S+)\s*$", line)
            if m: steps[cur_step]["command"] = m.group(1); continue
            m = re.match(r"^    ci_job:\s*(\S+)\s*$", line)
            if m: steps[cur_step]["ci_job"] = m.group(1); continue
            m = re.match(r"^    cost_rank:\s*(\d+)\s*$", line)
            if m: steps[cur_step]["cost_rank"] = int(m.group(1)); continue
            m = re.match(r"^    ci_rank:\s*(\d+)\s*$", line)
            if m: steps[cur_step]["ci_rank"] = int(m.group(1)); continue
            m = re.match(r"^    allow_skip:\s*(true|false)\s*$", line)
            if m: steps[cur_step]["allow_skip"] = (m.group(1) == "true"); continue
            m = re.match(r"^    tools:\s*\[(.*)\]\s*$", line)
            if m:
                inner = m.group(1).strip()
                steps[cur_step]["tools"] = [x.strip() for x in inner.split(",") if x.strip()] if inner else []
                continue
            m = re.match(r"^    output_contains:\s*\[(.*)\]\s*$", line)
            if m:
                inner = m.group(1).strip()
                if not inner:
                    steps[cur_step]["output_contains"] = []
                else:
                    steps[cur_step]["output_contains"] = [
                        x.strip().strip('"').strip("'") for x in inner.split(",") if x.strip()
                    ]
                continue
    return tiers, steps

tiers, steps = parse_simple(text)
if op == "list-steps":
    print(" ".join(sorted(steps.keys())))
elif op == "tier":
    t = sys.argv[3]
    print(" ".join(tiers.get(t, [])))
elif op == "meta":
    sid = sys.argv[3]
    s = steps[sid]
    tools = ",".join(s["tools"])
    outs = "|".join(s["output_contains"])
    print(f"{s['cost_rank']}\t{s['ci_rank']}\t{s['ci_job']}\t{s['command']}\t{int(s['allow_skip'])}\t{tools}\t{outs}\t{s['description']}")
elif op == "cost-order":
    ids = sys.argv[3].split()
    ordered = sorted(ids, key=lambda i: (steps[i]["cost_rank"], i))
    print(" ".join(ordered))
elif op == "ci-order":
    ids = sys.argv[3].split()
    ordered = sorted(ids, key=lambda i: (steps[i]["ci_rank"], i))
    print(" ".join(ordered))
else:
    raise SystemExit(f"unknown op {op}")
PY
}

ALL_STEPS="$(_ci_py "${CI_CONFIG}" list-steps)"
# shellcheck disable=SC2206
ALL_STEPS_ARR=(${ALL_STEPS})

_is_known_step() {
  local s="$1" x
  for x in "${ALL_STEPS_ARR[@]}"; do
    [[ "${x}" == "${s}" ]] && return 0
  done
  return 1
}

# ── Step selection ───────────────────────────────────────────────────────
SELECTED=""
if [[ "${ONLY_SET}" == "true" ]]; then
  SELECTED="$(echo "${ONLY}" | tr ',' ' ')"
  UNKNOWN=""
  for s in ${SELECTED}; do
    _is_known_step "${s}" || UNKNOWN="${UNKNOWN} ${s}"
  done
  if [[ -n "${UNKNOWN}" ]]; then
    echo "[acp.ci] ERROR: unknown step id(s):${UNKNOWN}" >&2
    echo "Valid steps: ${ALL_STEPS}" >&2
    exit 2
  fi
  # FG-7 / FG-2: empty --only after parse
  if [[ -z "$(echo "${SELECTED}" | tr -d '[:space:]')" ]]; then
    echo "[acp.ci] ERROR: empty --only plan — refuse PASS" >&2
    exit 2
  fi
else
  SELECTED="$(_ci_py "${CI_CONFIG}" tier "${TIER}")"
  if [[ -z "$(echo "${SELECTED}" | tr -d '[:space:]')" ]]; then
    echo "[acp.ci] ERROR: tier '${TIER}' resolved to empty plan — refuse PASS" >&2
    exit 2
  fi
fi

COST_ORDER="$(_ci_py "${CI_CONFIG}" cost-order "${SELECTED}")"
CI_ORDER="$(_ci_py "${CI_CONFIG}" ci-order "${SELECTED}")"

_selected() {
  case " ${SELECTED} " in *" $1 "*) return 0 ;; *) return 1 ;; esac
}

_have() {
  # FG-4 / FG-7: probe in execution context, not agent interactive shell
  bash -c "command -v \"$1\" >/dev/null 2>&1"
}

_record() { RESULTS="${RESULTS} $1=$2"; }

_status_of() {
  local id="$1" pair
  for pair in ${RESULTS}; do
    case "${pair}" in "${id}="*) echo "${pair#*=}"; return 0 ;; esac
  done
  echo "-"
}

_step_meta() {
  # prints: cost ci_rank ci_job command allow_skip tools outs description
  _ci_py "${CI_CONFIG}" meta "$1"
}

# ── Preflight ────────────────────────────────────────────────────────────
SKIP_REASON=""

preflight() {
  local missing="" id meta allow tools t
  for id in ${COST_ORDER}; do
    meta="$(_step_meta "${id}")"
    allow="$(echo "${meta}" | awk -F'\t' '{print $5}')"
    tools="$(echo "${meta}" | awk -F'\t' '{print $6}')"
    IFS=',' read -r -a tool_arr <<< "${tools}"
    for t in "${tool_arr[@]}"; do
      [[ -z "${t}" ]] && continue
      if ! _have "${t}"; then
        if [[ "${allow}" == "1" ]]; then
          SKIP_REASON="${SKIP_REASON} ${id}:missing-${t}"
        else
          missing="${missing} ${t}(for:${id})"
        fi
      fi
    done
  done
  if [[ -n "${missing}" ]]; then
    echo "[acp.ci] PREFLIGHT FAIL — required tools missing:${missing}" >&2
    echo "  Install them, or narrow with --only / --static. Try --doctor." >&2
    exit 1
  fi
}

_soft_skip_reason() {
  local id="$1" pair
  for pair in ${SKIP_REASON}; do
    case "${pair}" in "${id}:"*) echo "${pair#*:}"; return 0 ;; esac
  done
  echo ""
}

doctor() {
  echo "=== ACP CI dependency matrix (AE) ==="
  echo "config: ${CI_CONFIG}"
  echo "bodies: ${STEPS_LIB}"
  echo ""
  printf "  %-18s %-12s %-8s %s\n" "STEP" "CI_JOB" "TOOLS" "STATUS"
  local id meta job tools allow t ok
  for id in ${ALL_STEPS}; do
    meta="$(_step_meta "${id}")"
    job="$(echo "${meta}" | awk -F'\t' '{print $3}')"
    allow="$(echo "${meta}" | awk -F'\t' '{print $5}')"
    tools="$(echo "${meta}" | awk -F'\t' '{print $6}')"
    ok="OK"
    IFS=',' read -r -a tool_arr <<< "${tools}"
    for t in "${tool_arr[@]}"; do
      [[ -z "${t}" ]] && continue
      if ! _have "${t}"; then
        if [[ "${allow}" == "1" ]]; then
          ok="SOFT-MISS"
        else
          ok="MISSING"
        fi
        break
      fi
    done
    printf "  %-18s %-12s %-8s %s\n" "${id}" "${job}" "${tools:--}" "${ok}"
  done
  echo ""
  echo "tiers: static / fast / full — see ${CI_CONFIG}"
  echo "(doctor runs no gates)"
}

if [[ "${DOCTOR}" == "true" ]]; then
  doctor
  exit 0
fi

echo "=== ACP CI parity ==="
echo "tier:       ${TIER}$( [[ -n "${ONLY}" ]] && echo " (--only ${ONLY})" )"
echo "repo_root:  ${REPO_ROOT}"
echo "plan:       ${COST_ORDER}"
echo "dry_run:    ${DRY_RUN}"
echo ""

preflight

TOTAL=0
for id in ${COST_ORDER}; do TOTAL=$((TOTAL + 1)); done

# FG-2: refuse empty plan after preflight
if [[ "${TOTAL}" -eq 0 ]]; then
  echo "[acp.ci] NO-OP | zero steps planned — refuse PASS" >&2
  exit 2
fi

IDX=0
for id in ${COST_ORDER}; do
  IDX=$((IDX + 1))
  reason="$(_soft_skip_reason "${id}")"
  if [[ -n "${reason}" ]]; then
    echo ">>> [${IDX}/${TOTAL}] ${id} — SKIP (${reason})"
    _record "${id}" SKIP
    SKIPPED_ANY=true
    continue
  fi

  echo ">>> [${IDX}/${TOTAL}] ${id}"
  if [[ "${DRY_RUN}" == "true" ]]; then
    echo "  (dry-run) ${id}"
    _record "${id}" "DRY-RUN"
    continue
  fi

  meta="$(_step_meta "${id}")"
  cmd_id="$(echo "${meta}" | awk -F'\t' '{print $4}')"
  outs="$(echo "${meta}" | awk -F'\t' '{print $7}')"

  out_file="$(mktemp "${TMPDIR:-/tmp}/acp-ci.${id}.XXXXXX")"
  step_rc=0
  # FG-1: if-context status capture — never set +e under trap ERR
  if ci_run_step "${cmd_id}" >"${out_file}" 2>&1; then
    step_rc=0
  else
    step_rc=$?
  fi

  # FG-3 / FG-5: optional output_contains asserts
  if [[ "${step_rc}" -eq 0 && -n "${outs}" ]]; then
    IFS='|' read -r -a need_arr <<< "${outs}"
    for need in "${need_arr[@]}"; do
      [[ -z "${need}" ]] && continue
      if ! grep -qF -- "${need}" "${out_file}"; then
        echo "  FAIL: output missing required substring: ${need}" >&2
        step_rc=1
        break
      fi
    done
  fi

  if [[ "${step_rc}" -eq 0 ]]; then
    _record "${id}" PASS
    EXECUTED_STEPS=$((EXECUTED_STEPS + 1))
  else
    echo "  (tail)" >&2
    tail -30 "${out_file}" >&2 || true
    _record "${id}" FAIL
    EXECUTED_STEPS=$((EXECUTED_STEPS + 1))
    FAILED_STEP="${id}"
    rm -f "${out_file}"
    break
  fi
  rm -f "${out_file}"
done

echo ""
echo "Summary (CI order):"
printf "  %-18s %s\n" "STEP" "STATUS"
for id in ${CI_ORDER}; do
  st="$(_status_of "${id}")"
  [[ "${st}" == "-" ]] && continue
  printf "  %-18s %s\n" "${id}" "${st}"
  [[ "${st}" == "SKIP" ]] && SKIPPED_ANY=true
done

echo ""
echo "executed_steps: ${EXECUTED_STEPS}"

if [[ -n "${FAILED_STEP}" ]]; then
  echo "[ACP CI] FAIL | tier ${TIER} | first failing step: ${FAILED_STEP}"
  exit 1
fi

if [[ "${DRY_RUN}" == "true" ]]; then
  # FG-6: dry-run is planning only
  echo "[ACP CI] dry-run | tier ${TIER} | ${TOTAL} steps planned | 0 run"
  exit 0
fi

# FG-2 / FG-3: never PASS with zero units executed
if [[ "${EXECUTED_STEPS}" -eq 0 ]]; then
  echo "[ACP CI] NO-OP | tier ${TIER} | zero steps executed — nothing was verified" >&2
  exit 2
fi

if [[ "${SKIPPED_ANY}" == "true" ]]; then
  echo "[ACP CI] PASS (with SKIPs) | tier ${TIER} — not full CI parity; see SKIP rows above"
else
  echo "[ACP CI] PASS | tier ${TIER} | safe to /acp-pr"
fi
