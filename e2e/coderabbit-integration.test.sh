#!/usr/bin/env bash
# E2E Tests for CodeRabbit findings-import + optionality matrix (M81, ADR-22)
# Offline — safe under run-e2e-tests.sh --skip-network.
#
# Matrix:
#   A  enabled=false, no config  → import exit 0, no writes
#   B  enabled=true,  no config  → hint; import no-op
#   C  enabled=true,  config + fixture → import writes CR-* finding_id
#   D  enabled=false, config present → import no-op (opt-in wins)
#
# NOTE: Do NOT add `set -e` — assert_* return 1 on failure and must not abort.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${PROJECT_ROOT}/tests/common.sh"

IMP="${PROJECT_ROOT}/agent/scripts/acp.findings-import.sh"
CR="${PROJECT_ROOT}/agent/scripts/acp.coderabbit.sh"
CONFIGURABLES="${PROJECT_ROOT}/agent/configurables/acp.configurables.yaml"
FIXTURE="${PROJECT_ROOT}/tests/fixtures/coderabbit-findings-sample.json"

print_suite_header "CodeRabbit Integration — E2E (M81)"

assert_file_exists "$FIXTURE" "gate fixture present"
assert_file_exists "$IMP" "findings-import script present"

FIX="$(mktemp -d)"
trap 'rm -rf "$FIX"' EXIT
mkdir -p "$FIX/agent/configurables" "$FIX/agent/preferences" "$FIX/agent/memory"
cp "$CONFIGURABLES" "$FIX/agent/configurables/acp.configurables.yaml"
# Minimal carryovers ledger
cat > "$FIX/agent/memory/audit-carryovers.md" <<'EOF'
# Audit Carryover Tracking
carryovers:
EOF
( cd "$FIX" && git init -q && git config user.email t@t && git config user.name t )

write_pref() {
  printf 'acp:\n  integrations:\n    coderabbit:\n      enabled: %s\n      config_path: .coderabbit.yaml\n' "$1" \
    > "$FIX/agent/preferences/acp.default.yaml"
}

count_cr_ids() {
  local n
  n="$(grep -c 'finding_id: CR-' "$FIX/agent/memory/audit-carryovers.md" 2>/dev/null || true)"
  [[ -n "${n}" ]] || n=0
  echo "${n}"
}

# ── A — disabled + no config ─────────────────────────────────────────────────
print_test_header "A — enabled=false, no config → import exit 0, no writes"
write_pref false
rm -f "$FIX/.coderabbit.yaml"
BEFORE="$(count_cr_ids)"
OUT_A="$( cd "$FIX" && bash "$IMP" --input "$FIXTURE" 2>&1 )"; RC_A=$?
AFTER="$(count_cr_ids)"
assert_true "A import exit 0" $RC_A
assert_equals "$BEFORE" "$AFTER" "A no CR finding_ids written"
assert_equals "" "$( cd "$FIX" && bash "$CR" hint 2>&1 )" "A hint silent when disabled"

# ── B — enabled + no config ──────────────────────────────────────────────────
print_test_header "B — enabled=true, no config → hint; import no-op"
write_pref true
rm -f "$FIX/.coderabbit.yaml"
BEFORE="$(count_cr_ids)"
OUT_B="$( cd "$FIX" && bash "$IMP" --input "$FIXTURE" 2>&1 )"; RC_B=$?
AFTER="$(count_cr_ids)"
assert_true "B import exit 0" $RC_B
assert_equals "$BEFORE" "$AFTER" "B no writes when inactive"
HINT_B="$( cd "$FIX" && bash "$CR" hint 2>&1 )"
assert_contains "$HINT_B" "CodeRabbit is enabled but no config" "B hint fires"

# ── C — enabled + config + fixture ───────────────────────────────────────────
print_test_header "C — enabled=true + config → import writes CR-* ids"
write_pref true
cp "${PROJECT_ROOT}/agent/templates/coderabbit.yaml.template" "$FIX/.coderabbit.yaml"
BEFORE="$(count_cr_ids)"
OUT_C="$( cd "$FIX" && bash "$IMP" --input "$FIXTURE" 2>&1 )"; RC_C=$?
AFTER="$(count_cr_ids)"
assert_true "C import exit 0" $RC_C
AFTER_N="$(echo "$AFTER" | tr -d '[:space:]')"
BEFORE_N="$(echo "$BEFORE" | tr -d '[:space:]')"
if [[ "${AFTER_N}" -gt "${BEFORE_N}" ]]; then GT_RC=0; else GT_RC=1; fi
assert_true "C wrote at least one CR- id" $GT_RC
assert_contains "$OUT_C" "added=" "C reports added count"
LEDGER_C="$(cat "$FIX/agent/memory/audit-carryovers.md")"
assert_contains "$LEDGER_C" "audit_id: coderabbit-import" "C live audit_id"
assert_contains "$LEDGER_C" "planned_in: M81" "C planned_in M81 (not M81-import)"
# Idempotent re-run
OUT_C2="$( cd "$FIX" && bash "$IMP" --input "$FIXTURE" 2>&1 )"; RC_C2=$?
AFTER2="$(count_cr_ids | tr -d '[:space:]')"
assert_true "C re-run exit 0" $RC_C2
assert_equals "$AFTER_N" "$AFTER2" "C re-run does not duplicate finding_ids"
assert_contains "$OUT_C2" "skipped_dup\|nothing to add" "C re-run reports skip or nothing-to-add"

# ── D — disabled + config present ────────────────────────────────────────────
print_test_header "D — enabled=false + config → import no-op (opt-in wins)"
# Reset ledger for D
cat > "$FIX/agent/memory/audit-carryovers.md" <<'EOF'
# Audit Carryover Tracking
carryovers:
EOF
write_pref false
touch "$FIX/.coderabbit.yaml"
OUT_D="$( cd "$FIX" && bash "$IMP" --input "$FIXTURE" 2>&1 )"; RC_D=$?
AFTER_D="$(count_cr_ids | tr -d '[:space:]')"
assert_true "D import exit 0" $RC_D
assert_equals "0" "$AFTER_D" "D no writes despite config"

# ── Help rejects --pr ────────────────────────────────────────────────────────
print_test_header "Help / --pr deferred"
HELP="$( bash "$IMP" --help 2>&1 )"
assert_contains "$HELP" "input <file>" "help documents --input"
assert_contains "$HELP" "Deferred" "help mentions deferred --pr"
( bash "$IMP" --pr 1 >/dev/null 2>&1 ); assert_false "--pr exits non-zero" $?

print_test_summary
