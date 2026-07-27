#!/usr/bin/env bash
# E2E Tests for acp.review-scan.sh (M83 task-281 / F-102-08)
# Executes the scanner against committed fixtures — behavioural, not doc assertions.
# Must fail if task-280 multi-path / --self / .mjs fixes are reverted.
#
# NOTE: Do NOT add set -e — assert_* return 1 on failure and must not abort the suite.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${PROJECT_ROOT}/tests/common.sh"

SCAN="${PROJECT_ROOT}/agent/scripts/acp.review-scan.sh"
FIX="${PROJECT_ROOT}/tests/fixtures/review-scan"

print_suite_header "/acp-review-scan — Executing E2E (M83)"

# ── B1: Multi-path accumulation (F-102-01) ────────────────────────────────────
print_test_header "B1 — two dirs each seeding one finding → 2 findings"
B1_OUT="$(bash "$SCAN" --include-tests "$FIX/multi-a" "$FIX/multi-b" 2>&1)" || true
B1_COUNT="$(echo "$B1_OUT" | grep -c 'SC-01' || true)"
assert_equals "2" "$B1_COUNT" "multi-path yields findings from both directories"
assert_contains "$B1_OUT" "multi-a/secret.ts" "finding from multi-a"
assert_contains "$B1_OUT" "multi-b/secret.ts" "finding from multi-b"

# ── B2: --self expands + skips missing dirs (F-102-02) ────────────────────────
print_test_header "B2 — --self scans present paths, skips missing silently"
SELF_FIX="$(mktemp -d)"
mkdir -p "$SELF_FIX/scripts" "$SELF_FIX/agent/scripts" "$SELF_FIX/agent/commands"
# omit e2e/ deliberately — must skip silently
printf '%s\n' 'export function ok(): void {}' > "$SELF_FIX/scripts/ok.ts"
SELF_OUT="$(cd "$SELF_FIX" && bash "$SCAN" --self 2>&1)"
SELF_RC=$?
assert_equals "0" "$SELF_RC" "--self exits 0 with clean partial tree"
assert_contains "$SELF_OUT" "No findings" "--self clean scan reports no findings"
rm -rf "$SELF_FIX"

# ── B3: .mjs / .cjs directory traversal (F-102-03) ────────────────────────────
print_test_header "B3 — directory find reaches .mjs and .cjs"
B3_OUT="$(bash "$SCAN" --include-tests "$FIX/mjs-dir" 2>&1)" || true
assert_contains "$B3_OUT" "bad.mjs" ".mjs file scanned via directory traversal"
assert_contains "$B3_OUT" "bad.cjs" ".cjs file scanned via directory traversal"
B3_COUNT="$(echo "$B3_OUT" | grep -c 'SC-01' || true)"
assert_equals "2" "$B3_COUNT" "both mjs and cjs produce SC-01"

# ── B4: --ci exit codes ───────────────────────────────────────────────────────
print_test_header "B4 — --ci exits 1 on HIGH/CRITICAL, 0 on MEDIUM-only"
bash "$SCAN" --ci --include-tests "$FIX/high-sh" >/dev/null 2>&1
B4_HIGH=$?
assert_equals "1" "$B4_HIGH" "--ci exits 1 on SH-01 HIGH"
bash "$SCAN" --ci --include-tests "$FIX/medium-only" >/dev/null 2>&1
B4_MED=$?
assert_equals "0" "$B4_MED" "--ci exits 0 on NC-01 MEDIUM only"
bash "$SCAN" --ci --include-tests "$FIX/multi-a" >/dev/null 2>&1
B4_CRIT=$?
assert_equals "1" "$B4_CRIT" "--ci exits 1 on SC-01 CRITICAL"

# ── B5: --json is parseable ───────────────────────────────────────────────────
print_test_header "B5 — --json emits jq-parseable array"
B5_JSON="$(bash "$SCAN" --json --include-tests "$FIX/multi-a" 2>/dev/null)" || true
if command -v jq >/dev/null 2>&1; then
  echo "$B5_JSON" | jq -e 'type == "array" and length >= 1' >/dev/null 2>&1
  assert_true "--json round-trips through jq" $?
  B5_RULE="$(echo "$B5_JSON" | jq -r '.[0].rule')"
  assert_equals "SC-01" "$B5_RULE" "--json finding has SC-01 rule"
else
  assert_contains "$B5_JSON" '"rule":"SC-01"' "--json contains SC-01 (jq unavailable)"
fi

# ── B6: missing path exits 2 ──────────────────────────────────────────────────
print_test_header "B6 — missing path exits 2"
bash "$SCAN" --include-tests "$FIX/does-not-exist" >/dev/null 2>&1
B6_RC=$?
assert_equals "2" "$B6_RC" "missing path exits 2"

# ── B7: flag after positional re-handled (F-104-06) ───────────────────────────
print_test_header "B7 — path --ci does not treat --ci as a scan target"
bash "$SCAN" --include-tests "$FIX/clean" --ci >/dev/null 2>&1
B7_RC=$?
assert_equals "0" "$B7_RC" "flag after path succeeds (re-handled --ci)"
B7_ERR="$(bash "$SCAN" --include-tests "$FIX/clean" --ci 2>&1)" || true
B7_BAD="$(echo "$B7_ERR" | grep -c 'Error: --ci not found' || true)"
assert_equals "0" "$B7_BAD" "does not claim --ci is a missing path"

# ── B8: SH-01 allowlist preserved (F-M82-05) ──────────────────────────────────
print_test_header "B8 — SH-01 allowlist / exemption comment"
B8_OUT="$(bash "$SCAN" --include-tests "$FIX/allowlist" 2>&1)"
B8_RC=$?
assert_equals "0" "$B8_RC" "allowlisted shell files exit 0"
assert_contains "$B8_OUT" "No findings" "allowlist produces no SH-01 findings"

# ── B9: clean fixture is clean ────────────────────────────────────────────────
print_test_header "B9 — clean fixture produces no findings"
B9_OUT="$(bash "$SCAN" --include-tests "$FIX/clean" 2>&1)"
B9_RC=$?
assert_equals "0" "$B9_RC" "clean fixture exits 0"
assert_contains "$B9_OUT" "No findings" "clean fixture reports no findings"

# ── B10–B14: Lexing foundation (M83 task-282 / F-103-01 / F-103-02) ────────────
print_test_header "B10 — comments/strings do not produce TS-01 (F-103-01)"
B10_OUT="$(bash "$SCAN" --include-tests "$FIX/lexing/clean-false-pos.ts" 2>&1)"
B10_RC=$?
assert_equals "0" "$B10_RC" "comment/string false-pos fixture exits 0"
assert_contains "$B10_OUT" "No findings" "no TS-01 from comment or string literal"

print_test_header "B11 — real : any still flags TS-01"
B11_OUT="$(bash "$SCAN" --include-tests "$FIX/lexing/true-any.ts" 2>&1)" || true
assert_contains "$B11_OUT" "TS-01" "true-positive any type still detected"

print_test_header "B12 — retry substring does not suppress EH-01 (F-103-02)"
B12_OUT="$(bash "$SCAN" --include-tests "$FIX/lexing/eh01-retry.ts" 2>&1)" || true
assert_contains "$B12_OUT" "EH-01" "async with 'retry' string still flagged EH-01"
B12_OK="$(bash "$SCAN" --include-tests "$FIX/lexing/eh01-has-try.ts" 2>&1)"
assert_contains "$B12_OK" "No findings" "async with real try is clean"

print_test_header "B13 — line numbers point at original source"
B13_OUT="$(bash "$SCAN" --include-tests "$FIX/lexing/line-nums.ts" 2>&1)" || true
assert_contains "$B13_OUT" "line-nums.ts:4" "TS-01 reported on line 4 (not comment lines)"

print_test_header "B14 — template literals do not crash or false-positive"
B14_OUT="$(bash "$SCAN" --include-tests "$FIX/lexing/template.ts" 2>&1)"
B14_RC=$?
assert_equals "0" "$B14_RC" "template literal fixture exits 0"
assert_contains "$B14_OUT" "No findings" "template string 'as any' does not fire TS-01"

print_test_header "B15 — TS-01 catches generic any positions"
B15_OUT="$(bash "$SCAN" --include-tests "$FIX/patterns/ts01-generics.ts" 2>&1)" || true
B15_COUNT="$(echo "$B15_OUT" | grep -c 'TS-01' || true)"
assert_equals "2" "$B15_COUNT" "Record<string, any> and Promise<any> both flagged"

print_test_header "B16 — TS-02 catches exported arrow function"
B16_OUT="$(bash "$SCAN" --include-tests "$FIX/patterns/ts02-export-arrow.ts" 2>&1)" || true
assert_contains "$B16_OUT" "TS-02" "export const arrow missing return type flagged"

print_test_header "B17 — TS-02 catches export default and generic function"
B17_DEFAULT="$(bash "$SCAN" --include-tests "$FIX/patterns/ts02-export-default.ts" 2>&1)" || true
assert_contains "$B17_DEFAULT" "TS-02" "export default function missing return type flagged"
B17_GENERIC="$(bash "$SCAN" --include-tests "$FIX/patterns/ts02-export-generic.ts" 2>&1)" || true
assert_contains "$B17_GENERIC" "TS-02" "export generic function missing return type flagged"

print_test_header "B18 — TS-02 catches multiline parameters"
B18_OUT="$(bash "$SCAN" --include-tests "$FIX/patterns/ts02-export-multiline.ts" 2>&1)" || true
assert_contains "$B18_OUT" "TS-02" "multiline exported function missing return type flagged"

print_test_header "B19 — NC-01 catches indented declarations"
B19_OUT="$(bash "$SCAN" --include-tests "$FIX/patterns/nc01-indented.ts" 2>&1)" || true
assert_contains "$B19_OUT" "NC-01" "indented snake_case variable flagged"

print_test_header "B20 — fixtures are skipped by default without --include-tests"
B20_OUT="$(bash "$SCAN" "$FIX/multi-a" 2>&1)"
B20_RC=$?
assert_equals "0" "$B20_RC" "default exclusion exits 0"
assert_contains "$B20_OUT" "No findings" "default exclusion suppresses fixture finding"

print_test_header "B21 — SH-03 uses shellcheck when present"
B21_OUT="$(bash "$SCAN" --include-tests "$FIX/patterns/sh03-unquoted.sh" 2>&1)"
if command -v shellcheck >/dev/null 2>&1; then
  assert_contains "$B21_OUT" "SH-03" "shellcheck-backed SH-03 finding emitted"
else
  assert_contains "$B21_OUT" "No findings" "scanner stays silent when shellcheck absent"
fi

print_test_header "B22 — SH-03 stays silent when shellcheck is hidden"
SHELLCHECK_PATH="$(command -v shellcheck || true)"
if [[ -n "$SHELLCHECK_PATH" ]]; then
  SHELLCHECK_DIR="$(cd "$(dirname "$SHELLCHECK_PATH")" && pwd)"
  PATH_NO_SHELLCHECK=""
  OLD_IFS="$IFS"
  IFS=':'
  for entry in $PATH; do
    if [[ "$entry" != "$SHELLCHECK_DIR" ]]; then
      PATH_NO_SHELLCHECK="${PATH_NO_SHELLCHECK:+${PATH_NO_SHELLCHECK}:}${entry}"
    fi
  done
  IFS="$OLD_IFS"
  B22_OUT="$(PATH="$PATH_NO_SHELLCHECK" /bin/bash "$SCAN" --include-tests "$FIX/patterns/sh03-unquoted.sh" 2>&1)"
  assert_contains "$B22_OUT" "No findings" "hidden shellcheck path produces no SH-03 finding"
else
  assert_true "shellcheck already absent" 0
fi

print_suite_summary
