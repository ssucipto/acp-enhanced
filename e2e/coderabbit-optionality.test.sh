#!/usr/bin/env bash
# E2E Tests for CodeRabbit optionality foundation (M78, ADR-21)
# Exercises agent/scripts/acp.coderabbit.sh across all degradation states.
# Offline (pure config-file detection) — safe under run-e2e-tests.sh --skip-network.
# Auto-discovered by run-e2e-tests.sh:90 (e2e/*.test.sh) — no CI registration needed.
#
# NOTE: Do NOT add `set -e` — assert_* return 1 on failure and must not abort the suite.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${PROJECT_ROOT}/tests/common.sh"

CR="${PROJECT_ROOT}/agent/scripts/acp.coderabbit.sh"
CONFIGURABLES="${PROJECT_ROOT}/agent/configurables/acp.configurables.yaml"

print_suite_header "CodeRabbit Optionality Foundation — E2E (M78)"

# ── Fixture: isolated project dir where we control the preference file + CWD ──
FIX="$(mktemp -d)"
trap 'rm -rf "$FIX"' EXIT
mkdir -p "$FIX/agent/configurables" "$FIX/agent/preferences"
cp "$CONFIGURABLES" "$FIX/agent/configurables/acp.configurables.yaml"
# Make the fixture a git repo so repo-root detection (F-099-05) resolves from subdirs
( cd "$FIX" && git init -q 2>/dev/null && git config user.email t@t && git config user.name t ) || true

# Helper: write the project preference file with a given enabled value
write_pref() {
  printf 'acp:\n  integrations:\n    coderabbit:\n      enabled: %s\n      config_path: .coderabbit.yaml\n' "$1" \
    > "$FIX/agent/preferences/acp.default.yaml"
}

# ── S1 — default (enabled=false, no config): silent no-op ────────────────────
print_test_header "S1 — disabled + no config → inactive, silent"
write_pref false
rm -f "$FIX/.coderabbit.yaml"
( cd "$FIX" && bash "$CR" active >/dev/null 2>&1 ); assert_false "coderabbit active is false (disabled)" $?
S1_HINT="$( cd "$FIX" && bash "$CR" hint 2>&1 )"
assert_equals "" "$S1_HINT" "hint is silent when disabled"

# ── S2 — enabled + absent: unavailable, hint fires once ──────────────────────
print_test_header "S2 — enabled + no config → unavailable, hint fires"
write_pref true
rm -f "$FIX/.coderabbit.yaml"
( cd "$FIX" && bash "$CR" available >/dev/null 2>&1 ); assert_false "available is false (no config)" $?
( cd "$FIX" && bash "$CR" active >/dev/null 2>&1 ); assert_false "active is false (no config)" $?
S2_HINT="$( cd "$FIX" && bash "$CR" hint 2>&1 )"
assert_contains "$S2_HINT" "CodeRabbit is enabled but no config" "hint fires when enabled+absent"

# ── S3 — enabled + present: available and active ─────────────────────────────
print_test_header "S3 — enabled + config present → available, active"
write_pref true
touch "$FIX/.coderabbit.yaml"
S3_AVAIL="$( cd "$FIX" && bash "$CR" available 2>/dev/null )"; A_RC=$?
assert_equals "available" "$S3_AVAIL" "available prints 'available'"
assert_true "available exit 0 (config present)" $A_RC
( cd "$FIX" && bash "$CR" active >/dev/null 2>&1 ); assert_true "active is true (enabled + present)" $?
S3_HINT="$( cd "$FIX" && bash "$CR" hint 2>&1 )"
assert_equals "" "$S3_HINT" "hint silent when enabled + present"

# ── S4 — opt-in precedence: disabled + config present → inactive (F-098-03) ──
print_test_header "S4 — disabled + config present → inactive (opt-in wins)"
write_pref false
touch "$FIX/.coderabbit.yaml"
( cd "$FIX" && bash "$CR" available >/dev/null 2>&1 ); assert_true "available true (config present)" $?
( cd "$FIX" && bash "$CR" active >/dev/null 2>&1 ); assert_false "active false despite config (opt-in precedence)" $?

# ── S5 — repo-root detection from a subdirectory (F-099-05) ──────────────────
print_test_header "S5 — detection works from a subdirectory (repo-root resolved)"
write_pref true
touch "$FIX/.coderabbit.yaml"
mkdir -p "$FIX/deep/nested"
( cd "$FIX/deep/nested" && bash "$CR" available >/dev/null 2>&1 ); assert_true "available from subdir (config at repo root)" $?
( cd "$FIX/deep/nested" && bash "$CR" active >/dev/null 2>&1 ); assert_true "active from subdir (enabled + repo-root config)" $?

print_test_summary
