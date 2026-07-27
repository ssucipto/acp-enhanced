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
B1_OUT="$(bash "$SCAN" "$FIX/multi-a" "$FIX/multi-b" 2>&1)" || true
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
B3_OUT="$(bash "$SCAN" "$FIX/mjs-dir" 2>&1)" || true
assert_contains "$B3_OUT" "bad.mjs" ".mjs file scanned via directory traversal"
assert_contains "$B3_OUT" "bad.cjs" ".cjs file scanned via directory traversal"
B3_COUNT="$(echo "$B3_OUT" | grep -c 'SC-01' || true)"
assert_equals "2" "$B3_COUNT" "both mjs and cjs produce SC-01"

# ── B4: --ci exit codes ───────────────────────────────────────────────────────
print_test_header "B4 — --ci exits 1 on HIGH/CRITICAL, 0 on MEDIUM-only"
bash "$SCAN" --ci "$FIX/high-sh" >/dev/null 2>&1
B4_HIGH=$?
assert_equals "1" "$B4_HIGH" "--ci exits 1 on SH-01 HIGH"
bash "$SCAN" --ci "$FIX/medium-only" >/dev/null 2>&1
B4_MED=$?
assert_equals "0" "$B4_MED" "--ci exits 0 on NC-01 MEDIUM only"
bash "$SCAN" --ci "$FIX/multi-a" >/dev/null 2>&1
B4_CRIT=$?
assert_equals "1" "$B4_CRIT" "--ci exits 1 on SC-01 CRITICAL"

# ── B5: --json is parseable ───────────────────────────────────────────────────
print_test_header "B5 — --json emits jq-parseable array"
B5_JSON="$(bash "$SCAN" --json "$FIX/multi-a" 2>/dev/null)" || true
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
bash "$SCAN" "$FIX/does-not-exist" >/dev/null 2>&1
B6_RC=$?
assert_equals "2" "$B6_RC" "missing path exits 2"

# ── B7: flag after positional re-handled (F-104-06) ───────────────────────────
print_test_header "B7 — path --ci does not treat --ci as a scan target"
bash "$SCAN" "$FIX/clean" --ci >/dev/null 2>&1
B7_RC=$?
assert_equals "0" "$B7_RC" "flag after path succeeds (re-handled --ci)"
B7_ERR="$(bash "$SCAN" "$FIX/clean" --ci 2>&1)" || true
B7_BAD="$(echo "$B7_ERR" | grep -c 'Error: --ci not found' || true)"
assert_equals "0" "$B7_BAD" "does not claim --ci is a missing path"

# ── B8: SH-01 allowlist preserved (F-M82-05) ──────────────────────────────────
print_test_header "B8 — SH-01 allowlist / exemption comment"
B8_OUT="$(bash "$SCAN" "$FIX/allowlist" 2>&1)"
B8_RC=$?
assert_equals "0" "$B8_RC" "allowlisted shell files exit 0"
assert_contains "$B8_OUT" "No findings" "allowlist produces no SH-01 findings"

# ── B9: clean fixture is clean ────────────────────────────────────────────────
print_test_header "B9 — clean fixture produces no findings"
B9_OUT="$(bash "$SCAN" "$FIX/clean" 2>&1)"
B9_RC=$?
assert_equals "0" "$B9_RC" "clean fixture exits 0"
assert_contains "$B9_OUT" "No findings" "clean fixture reports no findings"

# ── B10–B14: Lexing foundation (M83 task-282 / F-103-01 / F-103-02) ────────────
print_test_header "B10 — comments/strings do not produce TS-01 (F-103-01)"
B10_OUT="$(bash "$SCAN" "$FIX/lexing/clean-false-pos.ts" 2>&1)"
B10_RC=$?
assert_equals "0" "$B10_RC" "comment/string false-pos fixture exits 0"
assert_contains "$B10_OUT" "No findings" "no TS-01 from comment or string literal"

print_test_header "B11 — real : any still flags TS-01"
B11_OUT="$(bash "$SCAN" "$FIX/lexing/true-any.ts" 2>&1)" || true
assert_contains "$B11_OUT" "TS-01" "true-positive any type still detected"

print_test_header "B12 — retry substring does not suppress EH-01 (F-103-02)"
B12_OUT="$(bash "$SCAN" "$FIX/lexing/eh01-retry.ts" 2>&1)" || true
assert_contains "$B12_OUT" "EH-01" "async with 'retry' string still flagged EH-01"
B12_OK="$(bash "$SCAN" "$FIX/lexing/eh01-has-try.ts" 2>&1)"
assert_contains "$B12_OK" "No findings" "async with real try is clean"

print_test_header "B13 — line numbers point at original source"
B13_OUT="$(bash "$SCAN" "$FIX/lexing/line-nums.ts" 2>&1)" || true
assert_contains "$B13_OUT" "line-nums.ts:4" "TS-01 reported on line 4 (not comment lines)"

print_test_header "B14 — template literals do not crash or false-positive"
B14_OUT="$(bash "$SCAN" "$FIX/lexing/template.ts" 2>&1)"
B14_RC=$?
assert_equals "0" "$B14_RC" "template literal fixture exits 0"
assert_contains "$B14_OUT" "No findings" "template string 'as any' does not fire TS-01"

print_suite_summary
