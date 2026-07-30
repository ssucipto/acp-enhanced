#!/usr/bin/env bash
# Performance baseline for the YAML parser and preference layer (M85 task-297).
#
# Deliberately NOT named *.test.sh: run-e2e-tests.sh globs tests/*.test.sh into the
# timeout-sensitive parallel suite, and pre-optimisation this benchmark takes ~72s
# on an idle Mac — enough to risk the 180s per-test limit on slower runners and
# re-break the windows-latest E2E that audit-110 just fixed. It is a measurement
# tool invoked deliberately (and by task-303's gate), not a pass/fail test.
#
# NOT a gate at this stage — it measures and reports. task-303 adds the CI budget.
# Deliberately reports the MEDIAN of N runs: audit-113 (F2-03) found that single
# samples taken while other suites were running produced figures wrong by up to
# 15x, which then propagated into planning documents as facts.
#
# NOTE: Do NOT add set -e here. Timing loops tolerate individual failures.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

FIXTURE="${PROJECT_ROOT}/tests/fixtures/yaml-perf/pref-shape.yaml"
PARSER="${PROJECT_ROOT}/agent/scripts/acp.yaml-parser.sh"
PREFS="${PROJECT_ROOT}/agent/scripts/acp.preferences.sh"
REPS="${PERF_REPS:-5}"

# Portable millisecond clock. `date +%s%3N` is GNU-only; BSD date has no %N, so
# the repo's existing python3 idiom is used instead.
now_ms() { python3 -c 'import time; print(int(time.time()*1000))'; }

# Median rather than mean: one slow outlier under CI load should not define the
# baseline, and median is the more honest single number for a skewed sample.
median() {
  printf '%s\n' "$@" | sort -n | awk '{a[NR]=$1} END {
    if (NR == 0) { print 0; exit }
    if (NR % 2) print a[(NR+1)/2]; else print int((a[NR/2] + a[NR/2+1]) / 2)
  }'
}

# measure <label> <bash-snippet>
measure() {
  local label="$1" snippet="$2" i start end
  local samples=()
  for ((i = 0; i < REPS; i++)); do
    start="$(now_ms)"
    bash -c "$snippet" >/dev/null 2>&1
    end="$(now_ms)"
    samples+=( "$((end - start))" )
  done
  printf '  %-42s %6s ms   (median of %s)\n' "$label" "$(median "${samples[@]}")" "$REPS"
}

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  YAML parser / preference baseline (M85 task-297)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  fixture: tests/fixtures/yaml-perf/pref-shape.yaml ($(wc -l < "$FIXTURE" | tr -d ' ') lines)"
echo "  bash:    ${BASH_VERSION}"
echo ""

measure "yaml_parse (full AST build)" \
  "source '$PARSER' >/dev/null 2>&1; yaml_parse '$FIXTURE'"

measure "yaml_get deep key (cache cold)" \
  "source '$PARSER' >/dev/null 2>&1; yaml_get '$FIXTURE' 'acp.integrations.gitleaks.enabled'"

measure "yaml_get x4 same shell (cache warm)" \
  "source '$PARSER' >/dev/null 2>&1
   for k in acp.integrations.gitleaks.enabled acp.integrations.dupehound.enabled acp.review.enabled acp.memory.max_sessions; do
     yaml_get '$FIXTURE' \"\$k\"
   done"

measure "get_preference (walks 4 layers)" \
  "source '$PREFS' >/dev/null 2>&1; get_preference acp integrations.gitleaks.enabled"

measure "get_preference_or (wraps the above)" \
  "source '$PREFS' >/dev/null 2>&1; get_preference_or acp integrations.gitleaks.enabled auto"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Correctness snapshot — F-112-01 (| truncation)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
# Uses the UNQUOTED key: this parser retains surrounding quotes on quoted scalars
# (pre-existing contract — `plain: hello` yields `hello`, `q: "x"` yields `"x"`), so
# comparing a quoted fixture value against a bare expectation would never match and
# would report a false negative regardless of whether F-112-01 was fixed.
piped="$(bash -c "source '$PARSER' >/dev/null 2>&1; yaml_get '$FIXTURE' 'acp.pipe_bare'" 2>/dev/null)"
printf '  acp.pipe_bare   expected [a|b|c]  actual [%s]\n' "$piped"
if [[ "$piped" == "a|b|c" ]]; then
  echo "  → FIXED (task-299 landed)"
else
  echo "  → STILL TRUNCATED — F-112-01 regression"
fi

echo ""
echo "  Measurement only — no assertions. task-303 turns this into a CI budget."
exit 0
