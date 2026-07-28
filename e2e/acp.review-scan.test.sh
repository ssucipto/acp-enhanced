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
print_test_header "B5 — --json emits jq-parseable object payload"
B5_JSON="$(bash "$SCAN" --json --include-tests "$FIX/multi-a" 2>/dev/null)" || true
if command -v jq >/dev/null 2>&1; then
  echo "$B5_JSON" | jq -e 'type == "object" and (.findings | type == "array" and length >= 1) and (.summary | type == "object")' >/dev/null 2>&1
  assert_true "--json round-trips through jq" $?
  B5_RULE="$(echo "$B5_JSON" | jq -r '.findings[0].rule')"
  assert_equals "SC-01" "$B5_RULE" "--json finding has SC-01 rule"
else
  assert_contains "$B5_JSON" '"findings"' "--json payload includes findings key"
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
B12_EH01_COUNT="$(echo "$B12_OK" | grep -c 'EH-01' || true)"
assert_equals "0" "$B12_EH01_COUNT" "real try/catch no longer triggers EH-01"

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

print_test_header "B23 — baseline suppresses same finding after line shifts"
B23_DIR="$(mktemp -d)"
B23_BASELINE="${B23_DIR}/review-baseline.json"
cat > "${B23_DIR}/secret.ts" <<'TSEOF'
const token = "ghp_fixture_baseline_token";
TSEOF
B23_WRITE="$(bash "$SCAN" --json --write-baseline "$B23_BASELINE" --include-tests "${B23_DIR}/secret.ts" 2>/dev/null)" || true
assert_file_exists "$B23_BASELINE" "baseline file written"
if command -v jq >/dev/null 2>&1; then
  echo "$B23_WRITE" | jq -e '.findings | length == 1' >/dev/null 2>&1
  assert_true "baseline write keeps active finding in JSON" $?
  jq -e '.entries | length == 1 and .[0].rule == "SC-01"' "$B23_BASELINE" >/dev/null 2>&1
  assert_true "baseline file records SC-01 entry" $?
fi
B23_SUPPRESSED="$(bash "$SCAN" --json --baseline "$B23_BASELINE" --include-tests "${B23_DIR}/secret.ts" 2>/dev/null)"
if command -v jq >/dev/null 2>&1; then
  echo "$B23_SUPPRESSED" | jq -e '(.findings | length) == 0 and .summary.suppressed_baseline == 1' >/dev/null 2>&1
  assert_true "baseline suppresses matching finding" $?
else
  assert_contains "$B23_SUPPRESSED" '"suppressed_baseline": 1' "baseline suppression summary present"
fi
cat > "${B23_DIR}/secret.ts" <<'TSEOF'
// line shift should not break the baseline
const token = "ghp_fixture_baseline_token";
TSEOF
B23_SHIFTED="$(bash "$SCAN" --json --baseline "$B23_BASELINE" --include-tests "${B23_DIR}/secret.ts" 2>/dev/null)"
if command -v jq >/dev/null 2>&1; then
  echo "$B23_SHIFTED" | jq -e '(.findings | length) == 0 and .summary.suppressed_baseline == 1' >/dev/null 2>&1
  assert_true "baseline survives unrelated line-number shift" $?
else
  assert_contains "$B23_SHIFTED" '"suppressed_baseline": 1' "shifted baseline still suppresses"
fi
rm -rf "$B23_DIR"

print_test_header "B24 — inline suppression with reason is honored and summarized"
B24_DIR="$(mktemp -d)"
cat > "${B24_DIR}/suppressed.ts" <<'TSEOF'
// acp-review-ignore: SC-01 - seeded fixture secret for suppression test
const token = "ghp_inline_suppressed_token";
TSEOF
B24_OUT="$(bash "$SCAN" --include-tests "${B24_DIR}/suppressed.ts" 2>&1)"
assert_contains "$B24_OUT" "Suppressed findings: 1" "text output reports suppression summary"
B24_JSON="$(bash "$SCAN" --json --include-tests "${B24_DIR}/suppressed.ts" 2>/dev/null)"
if command -v jq >/dev/null 2>&1; then
  echo "$B24_JSON" | jq -e '(.findings | length) == 0 and .summary.suppressed_inline == 1' >/dev/null 2>&1
  assert_true "inline suppression removes active finding in JSON" $?
else
  assert_contains "$B24_JSON" '"suppressed_inline": 1' "json summary reports inline suppression"
fi
rm -rf "$B24_DIR"

print_test_header "B25 — shell comment suppression works for SH-03"
if command -v shellcheck >/dev/null 2>&1; then
  B25_DIR="$(mktemp -d)"
  cat > "${B25_DIR}/suppressed.sh" <<'SHEOF'
#!/usr/bin/env bash
set -euo pipefail
trap 'exit 3' ERR
# acp-review-ignore: SH-03 - deliberate unquoted variable in test fixture
echo $HOME
SHEOF
  B25_JSON="$(bash "$SCAN" --json --include-tests "${B25_DIR}/suppressed.sh" 2>/dev/null)"
  echo "$B25_JSON" | jq -e '(.findings | length) == 0 and .summary.suppressed_inline == 1' >/dev/null 2>&1
  assert_true "shell # suppression comment suppresses SH-03" $?
  rm -rf "$B25_DIR"
else
  assert_true "shellcheck unavailable skips shell suppression test" 0
fi

print_test_header "B26 — suppression without a reason is reported LOW"
B26_DIR="$(mktemp -d)"
cat > "${B26_DIR}/invalid.ts" <<'TSEOF'
const token = "ghp_inline_invalid_token"; // acp-review-ignore: SC-01
TSEOF
B26_JSON="$(bash "$SCAN" --json --include-tests "${B26_DIR}/invalid.ts" 2>/dev/null)" || true
if command -v jq >/dev/null 2>&1; then
  echo "$B26_JSON" | jq -e '
    (.findings | length == 2) and
    any(.findings[]; .severity == "CRITICAL" and .rule == "SC-01") and
    any(.findings[]; .severity == "LOW" and (.message | contains("invalid acp-review-ignore"))) and
    (.summary.suppressed_total == 0)
  ' >/dev/null 2>&1
  assert_true "missing suppression reason produces LOW finding and keeps original" $?
else
  assert_contains "$B26_JSON" '"invalid acp-review-ignore' "missing reason recorded in JSON"
  assert_contains "$B26_JSON" '"suppressed_total": 0' "invalid suppression does not count as suppressed"
fi
rm -rf "$B26_DIR"

print_test_header "B27 — SC-01 catches structured token prefixes"
B27_OUT="$(bash "$SCAN" --include-tests "${PROJECT_ROOT}/tests/fixtures/review-corpus/positive/sc01.ts" 2>&1)" || true
assert_contains "$B27_OUT" "positive/sc01.ts:1 SC-01" "ghp_ token flagged"
assert_contains "$B27_OUT" "positive/sc01.ts:2 SC-01" "AKIA token flagged"
assert_contains "$B27_OUT" "positive/sc01.ts:3 SC-01" "xoxb- token flagged"
assert_contains "$B27_OUT" "positive/sc01.ts:4 SC-01" "secret assignment flagged"

print_test_header "B28 — CH-05 wiring stays non-blocking via fake dupehound"
B28_DIR="$(mktemp -d "${PROJECT_ROOT}/tmp-dupehound.XXXXXX")"
mkdir -p "${B28_DIR}/src" "${B28_DIR}/fake-bin"
cat > "${B28_DIR}/src/new-helper.ts" <<'TSEOF'
export function computeTotal(items: number[]): number {
  return items.reduce((sum, item) => sum + item, 0);
}
TSEOF
cat > "${B28_DIR}/src/shared-math.ts" <<'TSEOF'
export function computeTotal(values: number[]): number {
  return values.reduce((sum, value) => sum + value, 0);
}
TSEOF
cat > "${B28_DIR}/fake-bin/dupehound" <<'SHEOF'
#!/usr/bin/env bash
cat <<EOF
{
  "version": 2,
  "findings": [
    {
      "file": "${ACP_FAKE_DUPE_FILE}",
      "line": 12,
      "similarity": 100,
      "original": {
        "file": "${ACP_FAKE_DUPE_ORIGINAL}",
        "line": 4
      },
      "suggestion": "extract shared helper"
    }
  ]
}
EOF
SHEOF
chmod +x "${B28_DIR}/fake-bin/dupehound"
B28_OUT="$(PATH="${B28_DIR}/fake-bin:/usr/bin:/bin:/usr/sbin:/sbin" ACP_FAKE_DUPE_FILE="${B28_DIR}/src/new-helper.ts" ACP_FAKE_DUPE_ORIGINAL="${B28_DIR}/src/shared-math.ts" ACP_DUPEHOUND_DIFF_BASE=HEAD~1 bash "$SCAN" --ci "${B28_DIR}/src/new-helper.ts" 2>&1)"
B28_RC=$?
assert_equals "0" "$B28_RC" "CH-05 remains non-blocking in --ci"
assert_contains "$B28_OUT" "CH-05" "fake dupehound result maps to CH-05"
rm -rf "$B28_DIR"

print_test_header "B29 — entropy reuse catches secret-like assignment without analyzers"
B29_OUT="$(PATH="/usr/bin:/bin:/usr/sbin:/sbin" bash "$SCAN" --include-tests "${PROJECT_ROOT}/tests/fixtures/review-scan/patterns/sc01-entropy.ts" 2>&1)" || true
assert_contains "$B29_OUT" "SC-01" "entropy-backed SC-01 finding emitted"
B29_HELPER="$(bash "${PROJECT_ROOT}/agent/scripts/acp.entropy-scan.sh" --review-sc01 --threshold 4.2 "${PROJECT_ROOT}/tests/fixtures/review-scan/patterns/sc01-entropy.ts" 2>&1)"
assert_contains "$B29_HELPER" "high-entropy secret-like assignment" "shared entropy helper emits SC-01 machine output"

print_test_header "B30 — review.rule_overrides can disable a rule project-wide"
B30_JSON="$(IG_RULE_OVERRIDES_JSON='{"SC-01":{"enabled":false}}' bash "$SCAN" --json --include-tests "${PROJECT_ROOT}/tests/fixtures/review-corpus/positive/sc01.ts" 2>/dev/null)" || true
if command -v jq >/dev/null 2>&1; then
  echo "$B30_JSON" | jq -e '
    ([.findings[] | select(.rule == "SC-01")] | length) == 0
    and (.summary.suppressed_rule_override >= 1)
  ' >/dev/null 2>&1
  assert_true "disabled SC-01 override suppresses findings" $?
else
  assert_contains "$B30_JSON" '"suppressed_rule_override":' "rule override summary present"
fi

print_test_header "B31 — review.rule_overrides can downgrade severity"
B31_OUT="$(IG_RULE_OVERRIDES_JSON='{"TS-01":{"severity":"LOW"}}' bash "$SCAN" --include-tests "${PROJECT_ROOT}/tests/fixtures/review-corpus/positive/ts01.ts" 2>&1)" || true
assert_contains "$B31_OUT" "[LOW]" "TS-01 severity override applied"
assert_contains "$B31_OUT" "TS-01" "TS-01 finding still reported at lowered severity"

print_test_header "B32 — IG_RULE_OVERRIDES_FILE loads JSON override file"
B32_DIR="$(mktemp -d)"
B32_PREFS="${B32_DIR}/overrides.json"
cat > "$B32_PREFS" <<'JSONEOF'
{"SC-01": {"enabled": false}}
JSONEOF
B32_JSON="$(IG_RULE_OVERRIDES_FILE="$B32_PREFS" bash "$SCAN" --json --include-tests "${PROJECT_ROOT}/tests/fixtures/review-corpus/positive/sc01.ts" 2>/dev/null)" || true
if command -v jq >/dev/null 2>&1; then
  echo "$B32_JSON" | jq -e '
    ([.findings[] | select(.rule == "SC-01")] | length) == 0
    and (.summary.suppressed_rule_override >= 1)
  ' >/dev/null 2>&1
  assert_true "JSON override file disables SC-01" $?
else
  assert_contains "$B32_JSON" '"suppressed_rule_override":' "JSON override file summary present"
fi
rm -rf "$B32_DIR"

if python3 -c 'import yaml' >/dev/null 2>&1; then
  print_test_header "B33 — project YAML rule_overrides load when PyYAML is present"
  B33_DIR="$(mktemp -d)"
  mkdir -p "${B33_DIR}/agent/preferences"
  cat > "${B33_DIR}/agent/preferences/acp.default.yaml" <<'YAMLEOF'
acp:
  review:
    rule_overrides:
      SC-01:
        enabled: false
YAMLEOF
  B33_JSON="$(IG_PREFS_ROOT="$B33_DIR" bash "$SCAN" --json --include-tests "${PROJECT_ROOT}/tests/fixtures/review-corpus/positive/sc01.ts" 2>/dev/null)" || true
  if command -v jq >/dev/null 2>&1; then
    echo "$B33_JSON" | jq -e '
      ([.findings[] | select(.rule == "SC-01")] | length) == 0
      and (.summary.suppressed_rule_override >= 1)
    ' >/dev/null 2>&1
    assert_true "project YAML rule_overrides disable SC-01 when PyYAML present" $?
  else
    assert_contains "$B33_JSON" '"suppressed_rule_override":' "YAML preference override summary present"
  fi
  rm -rf "$B33_DIR"
else
  print_test_header "B33 — skip YAML preference override test (PyYAML not installed)"
  echo "  SKIP: PyYAML not available"
fi

# ── B34–B37 — CodeRabbit PR#13 regressions (F-107-01..04) ──────────────────
# These four bugs shipped in v6.29.2 and were found downstream, not here.
# Every case below is one the pre-fix suite could not have caught.

print_test_header "B34 — scanner runs with no positional path argument (F-107-01)"
# Regression: `set -- "${IG_REMAINING_ARGS[@]:-}"` expanded an EMPTY array to a
# single empty-string argument, so $1="" became a scan target and the existence
# check aborted with "Error:  not found". Every prior test passed an explicit
# path, so a bare invocation — the most common real-world one — was untested.
B34_DIR="$(mktemp -d)"
printf 'const value = 1;\nexport default value;\n' > "${B34_DIR}/clean.ts"
B34_OUT="$( (cd "$B34_DIR" && bash "$SCAN" 2>&1) )"
B34_RC=$?
assert_true "no-arg invocation exits 0 on a clean tree" "$B34_RC"
assert_not_contains "$B34_OUT" "not found" "no-arg invocation does not abort with a path error"
rm -rf "$B34_DIR"

print_test_header "B35 — SC-15 fires when a lockfile exists but is untracked (F-107-02)"
# Regression: the tracking branch was dead code (`return 0` on both paths), so
# an untracked lockfile passed silently. Assert the NEGATIVE case.
B35_DIR="$(mktemp -d)"
(
  cd "$B35_DIR" || exit 1
  git init -q . && git config user.email t@t.t && git config user.name t
  mkdir -p tracked untracked ignored
  for d in tracked untracked ignored; do
    echo '{"name":"x"}' > "$d/package.json"
    echo '{"lockfileVersion":3}' > "$d/package-lock.json"
  done
  echo "ignored/package-lock.json" > .gitignore
  git add .gitignore tracked untracked/package.json ignored/package.json && git commit -qm init
)
B35_UNTRACKED="$(bash "$SCAN" "${B35_DIR}/untracked" 2>/dev/null || true)"
B35_TRACKED="$(bash "$SCAN" "${B35_DIR}/tracked" 2>/dev/null || true)"
B35_IGNORED="$(bash "$SCAN" "${B35_DIR}/ignored" 2>/dev/null || true)"
assert_contains "$B35_UNTRACKED" "SC-15" "untracked lockfile raises SC-15"
assert_not_contains "$B35_TRACKED" "SC-15" "tracked lockfile does not raise SC-15"
# acp.review.md SC-15 permits gitignored lockfiles in framework/protocol
# projects (M55 G-001). A deliberate .gitignore entry is not a finding — and the
# repo's own negative review-corpus fixture depends on this exemption.
assert_not_contains "$B35_IGNORED" "SC-15" "gitignored lockfile does not raise SC-15 (M55 G-001 qualifier)"
rm -rf "$B35_DIR"

print_test_header "B36 — baseline excludes inline-suppressed findings (F-107-03)"
# Regression: baseline capture ran BEFORE the inline-suppression check, so an
# acp-review-ignore'd finding was written into the baseline anyway — making the
# suppression permanent once the comment was removed.
B36_DIR="$(mktemp -d)"
cat > "${B36_DIR}/s.ts" <<'TSEOF'
// acp-review-ignore: EH-02 - intentional no-op for probe teardown
try { teardown(); } catch (e) {}
try { other(); } catch (e) {}
TSEOF
( cd "$B36_DIR" && bash "$SCAN" --write-baseline bl.json . >/dev/null 2>&1 ) || true
B36_LINES="$(python3 -c "
import json
d = json.load(open('${B36_DIR}/bl.json'))
print(','.join(str(e.get('line')) for e in d['entries'] if e.get('rule') == 'EH-02'))
" 2>/dev/null || echo ERROR)"
assert_equals "3" "$B36_LINES" "baseline records only the un-suppressed EH-02 (line 3, not line 2)"
rm -rf "$B36_DIR"

print_test_header "B37 — JSON stays valid when a message contains '},{' (F-107-04)"
# Regression: `sed 's/},{/},\n{/g'` split on the delimiter wherever it appeared,
# including INSIDE a finding message, injecting a raw newline into a JSON string
# literal. Broken on BSD sed (literal 'n') and on GNU sed (invalid JSON).
B37_BODY='{"severity":"HIGH","file":"a.ts","line":1,"rule":"X-01","message":"bad token },{ here"},{"severity":"LOW","file":"b.ts","line":2,"rule":"X-02","message":"ok"}'
# shellcheck source=../agent/scripts/acp.integrity-output.sh
source "${PROJECT_ROOT}/agent/scripts/acp.integrity-output.sh"
B37_JSON="$( { printf '{\n  "findings": [\n'; printf '%s' "$B37_BODY" | ig_format_json_array_body; printf '\n  ]\n}\n'; } )"
python3 -c "import json,sys; d=json.load(sys.stdin); sys.exit(0 if len(d['findings'])==2 else 1)" <<< "$B37_JSON" >/dev/null 2>&1
assert_true "formatted JSON array parses and preserves both findings" $?

print_suite_summary
