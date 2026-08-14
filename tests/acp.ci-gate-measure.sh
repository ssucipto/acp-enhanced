#!/usr/bin/env bash
# acp.ci-gate-measure.sh — Wall-clock baseline for AE CI local gates (M86 task-305).
# Usage: bash tests/acp.ci-gate-measure.sh [--runs N] [--only name] [--json]
#
# Times each candidate local gate used by .github/workflows jobs.
# Reports median ms over N≥5 runs (default 5). Portable python3 clock.
# Does NOT invent tiers into configurables — measurement only.

set -euo pipefail
trap 'echo "[acp.ci-gate-measure] Error on line $LINENO" >&2; exit 1' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "${PROJECT_ROOT}"

RUNS=5
ONLY=""
JSON=false

usage() {
  cat <<'EOF'
Usage: bash tests/acp.ci-gate-measure.sh [--runs N] [--only name] [--json] [--help]

Measure wall-clock of local CI gate commands (median of N runs, default 5).

Gate names:
  acp-validate       scripts/acp-validate.ts
  review-measure     agent/scripts/acp.review-measure.sh --ci
  npm-test           scripts npm test
  ci-validate        scripts/ci-validate.sh
  shellcheck         shellcheck on agent/scripts scripts e2e tests
  integrity-e2e      e2e/acp.integrity.test.sh
  integrity-v2-e2e   e2e/acp.integrity-v2.test.sh
  e2e-smoke          run-e2e-tests.sh --skip-network
  npm-audit          scripts npm audit --audit-level=high
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --runs) RUNS="${2:?}"; shift 2 ;;
    --only) ONLY="${2:?}"; shift 2 ;;
    --json) JSON=true; shift ;;
    --help|-h) usage; exit 0 ;;
    *) echo "Unknown arg: $1" >&2; usage; exit 1 ;;
  esac
done

if [[ "${RUNS}" -lt 5 ]]; then
  echo "[acp.ci-gate-measure] REFUSE: --runs must be ≥5 (got ${RUNS})" >&2
  exit 1
fi

# Hygiene: refuse if another full e2e suite is already running (inflates wall-clock).
if pgrep -f 'run-e2e-tests\.sh' >/dev/null 2>&1; then
  echo "[acp.ci-gate-measure] REFUSE: run-e2e-tests.sh already running — kill orphans first (contended timings are invalid)." >&2
  pgrep -lf 'run-e2e-tests\.sh' >&2 || true
  exit 1
fi

# name|command (run from PROJECT_ROOT via bash -lc)
GATES=(
  "acp-validate|cd scripts && npx tsx acp-validate.ts"
  "review-measure|bash agent/scripts/acp.review-measure.sh --ci"
  "npm-test|cd scripts && npm test --silent"
  "ci-validate|bash scripts/ci-validate.sh"
  "shellcheck|SCRIPTS=\$(find agent/scripts scripts e2e tests -name '*.sh' 2>/dev/null | sort); echo \"\$SCRIPTS\" | xargs shellcheck --shell=bash --severity=error"
  "integrity-e2e|bash e2e/acp.integrity.test.sh"
  "integrity-v2-e2e|bash e2e/acp.integrity-v2.test.sh"
  "e2e-smoke|bash run-e2e-tests.sh --skip-network"
  "npm-audit|cd scripts && npm audit --audit-level=high"
)

median_ms() {
  local samples_csv="$1"
  python3 -c "
samples = sorted(int(x) for x in '${samples_csv}'.split(',') if x)
n = len(samples)
if n == 0:
  print(0)
elif n % 2:
  print(samples[n // 2])
else:
  print((samples[n // 2 - 1] + samples[n // 2]) // 2)
"
}

time_once() {
  local cmd="$1"
  # Use non-login bash -c so PATH (e.g. project venv) is preserved.
  # Prefer Homebrew bash when present (associative arrays / bash 4+ gates).
  local bash_bin
  bash_bin="$(command -v bash)"
  if [[ -x /opt/homebrew/bin/bash ]]; then
    bash_bin=/opt/homebrew/bin/bash
  elif [[ -x /usr/local/bin/bash ]]; then
    bash_bin=/usr/local/bin/bash
  fi
  python3 -c "
import os, subprocess, time, sys
cmd = sys.argv[1]
bash_bin = sys.argv[2]
env = os.environ.copy()
t0 = time.perf_counter()
r = subprocess.run([bash_bin, '-c', cmd], cwd='${PROJECT_ROOT}', env=env)
ms = int((time.perf_counter() - t0) * 1000)
print(ms)
sys.exit(r.returncode)
" "${cmd}" "${bash_bin}"
}

echo "=== ACP CI gate measure (runs=${RUNS}) ==="
echo "project: ${PROJECT_ROOT}"
printf '%-18s %8s %8s %s\n' "GATE" "MEDIAN" "LAST_RC" "SAMPLES_MS"
printf '%-18s %8s %8s %s\n' "----" "------" "-------" "----------"

RESULTS_JSON='['
FIRST=true

for entry in "${GATES[@]}"; do
  name="${entry%%|*}"
  cmd="${entry#*|}"
  if [[ -n "${ONLY}" && "${ONLY}" != "${name}" ]]; then
    continue
  fi

  samples=()
  last_rc=0
  for ((i = 1; i <= RUNS; i++)); do
    # FG-1: do NOT use `set +e` under trap ERR — capture status via if/else.
    if ms="$(time_once "${cmd}")"; then
      rc=0
    else
      rc=$?
    fi
    ms="${ms##*$'\n'}"
    samples+=("${ms}")
    last_rc="${rc}"
  done

  csv="$(IFS=,; echo "${samples[*]}")"
  med="$(median_ms "${csv}")"
  printf '%-18s %7sms %8s %s\n' "${name}" "${med}" "${last_rc}" "${csv}"

  if [[ "${FIRST}" == true ]]; then
    FIRST=false
  else
    RESULTS_JSON+=','
  fi
  RESULTS_JSON+="{\"gate\":\"${name}\",\"median_ms\":${med},\"last_rc\":${last_rc},\"samples_ms\":[${csv}]}"
done

RESULTS_JSON+=']'

if [[ "${JSON}" == true ]]; then
  echo
  echo "${RESULTS_JSON}"
fi

echo
echo "✅ measurement complete (N=${RUNS})"
