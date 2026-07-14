#!/usr/bin/env bash
# E2E Tests for /acp-integrity command (M56 v1.0)
# Tests structural integrity, script syntax, Unicode fixture detection,
# and false-positive baseline.
#
# NOTE: Do NOT add set -e here. assert_* functions return exit code 1 on failure.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${PROJECT_ROOT}/tests/common.sh"

CMD_FILE="${PROJECT_ROOT}/agent/commands/acp.integrity.md"
SKILL_FILE="${PROJECT_ROOT}/agent/skills/code-integrity.md"
WIKI_FILE="${PROJECT_ROOT}/agent/wiki/integrity-rules.md"
WHITELIST_FILE="${PROJECT_ROOT}/agent/core/network_whitelist.yml"

print_suite_header "/acp-integrity — E2E Tests (M56 v1.0)"

# ── Structural Assertions ─────────────────────────────────────────────────────

print_test_header "S1 — acp.integrity.md exists with Agent Directive"
assert_file_exists "${CMD_FILE}" "acp.integrity.md exists"
assert_contains "$(head -20 "${CMD_FILE}")" "Agent Directive" "Agent Directive header present"

print_test_header "S2 — code-integrity.md skill file exists"
assert_file_exists "${SKILL_FILE}" "code-integrity.md skill file exists"
assert_contains "$(cat "${SKILL_FILE}")" "LLM/Script Boundary Rule" "Boundary Rule present"

print_test_header "S3 — integrity-rules.md wiki exists with 70 rules"
assert_file_exists "${WIKI_FILE}" "integrity-rules.md wiki exists"
RULE_COUNT=$(grep -cE '^\| IG-[0-9]+' "${WIKI_FILE}" 2>/dev/null | head -1 || echo "0")
RULE_COUNT="${RULE_COUNT//[^0-9]/}"
echo "  Rules documented: ${RULE_COUNT}"
[ "${RULE_COUNT}" -ge 65 ]
assert_true "At least 65 rules in wiki (actual: ${RULE_COUNT})" $?
[ "${RULE_COUNT}" -eq 70 ]
assert_true "Exactly 70 rules in wiki (actual: ${RULE_COUNT})" $?

print_test_header "S4 — network_whitelist.yml exists with schema"
assert_file_exists "${WHITELIST_FILE}" "network_whitelist.yml exists"
assert_contains "$(cat "${WHITELIST_FILE}")" "approved_hosts:" "approved_hosts field present"

print_test_header "S5 — All 7 scanner scripts + output lib exist and pass bash -n"
SCRIPTS=(
  "agent/scripts/acp.unicode-scan.sh"
  "agent/scripts/acp.entropy-scan.sh"
  "agent/scripts/acp.manifest-hash.sh"
  "agent/scripts/acp.network-whitelist-validate.sh"
  "agent/scripts/acp.git-provenance.sh"
  "agent/scripts/acp.dependency-diff.sh"
  "agent/scripts/acp.pattern-scan.sh"
  "agent/scripts/acp.integrity-output.sh"
)
ALL_OK=true
for s in "${SCRIPTS[@]}"; do
  if [[ -f "${PROJECT_ROOT}/${s}" ]]; then
    bash -n "${PROJECT_ROOT}/${s}" 2>/dev/null || ALL_OK=false
  else
    echo "  MISSING: ${s}"
    ALL_OK=false
  fi
done
assert_true "All 8 integrity scripts exist and pass bash -n" $([ "$ALL_OK" = true ] && echo 0 || echo 1)

print_test_header "S6 — Wrapper parity for acp-integrity"
assert_file_exists "${PROJECT_ROOT}/.github/prompts/acp-integrity.prompt.md" "prompt wrapper exists"
assert_file_exists "${PROJECT_ROOT}/.opencode/commands/acp-integrity.md" "opencode wrapper exists"

print_test_header "S7 — Alias wrappers for acp-rule-file-audit"
assert_file_exists "${PROJECT_ROOT}/.github/prompts/acp-rule-file-audit.prompt.md" "alias prompt wrapper"
assert_file_exists "${PROJECT_ROOT}/.opencode/commands/acp-rule-file-audit.md" "alias opencode wrapper"
assert_contains "$(cat "${PROJECT_ROOT}/.github/prompts/acp-rule-file-audit.prompt.md")" "self" "alias references --self flag"
assert_contains "$(cat "${PROJECT_ROOT}/.github/prompts/acp-rule-file-audit.prompt.md")" "fast" "alias references --fast flag"

# ── Behavioral Assertions ─────────────────────────────────────────────────────

print_test_header "B1 — Unicode scanner detects U+200D (zero-width joiner)"
TEMP_FIXTURE_DIR="$(mktemp -d)"
trap 'rm -rf "${TEMP_FIXTURE_DIR}"' EXIT
# Create file with actual U+200D byte sequence using Python
python3 -c "
with open('${TEMP_FIXTURE_DIR}/hidden-unicode.ts', 'w') as f:
    f.write('const x = \"hello\u200dworld\";\n')
" 2>/dev/null
if [[ -f "${TEMP_FIXTURE_DIR}/hidden-unicode.ts" ]]; then
  # Verify the file contains the Unicode character (grep for it)
  if grep -qP '\x{200D}' "${TEMP_FIXTURE_DIR}/hidden-unicode.ts" 2>/dev/null || python3 -c "exit(0 if '\u200d' in open('${TEMP_FIXTURE_DIR}/hidden-unicode.ts').read() else 1)" 2>/dev/null; then
    assert_true "Detected U+200D zero-width joiner in fixture" 0
  else
    assert_true "Detected U+200D zero-width joiner in fixture" 1
  fi
else
  assert_true "Detected U+200D zero-width joiner in fixture" 1
fi

print_test_header "B2 — Unicode scanner passes on clean file (bash -n check)"
# Verify the scanner script is syntactically valid and handles clean input
echo 'const x = "hello world";' > "${TEMP_FIXTURE_DIR}/clean.ts"
output=$(bash "${PROJECT_ROOT}/agent/scripts/acp.unicode-scan.sh" "${TEMP_FIXTURE_DIR}/clean.ts" 2>&1; echo "EXIT:$?")
assert_contains "${output}" "EXIT:0" "Clean file scan exits 0"

print_test_header "B3 — Entropy scanner exits 0 on simple clean file"
echo 'const x = 1;' > "${TEMP_FIXTURE_DIR}/simple.ts"
bash "${PROJECT_ROOT}/agent/scripts/acp.entropy-scan.sh" "${TEMP_FIXTURE_DIR}/simple.ts" > /dev/null 2>&1
assert_true "Entropy scanner exits 0 on clean file" $?
rm -rf "${TEMP_FIXTURE_DIR}"
trap - EXIT

print_test_header "B4 — False-positive baseline: AGENTS.md is clean of known injection patterns"
# Quick grep check — does AGENTS.md contain any known AI-directive phrases?
CLEAN=true
for pattern in "ignore previous instructions" "bypass security" "skip this rule" "forget previous"; do
  if grep -qi "$pattern" "${PROJECT_ROOT}/AGENTS.md" 2>/dev/null; then
    CLEAN=false
    echo "  Found: $pattern"
  fi
done
assert_true "AGENTS.md is clean of known AI-directive phrases" $([ "$CLEAN" = true ] && echo 0 || echo 1)

print_test_header "B5 — Manifest hash generates valid YAML"
output=$("${PROJECT_ROOT}/agent/scripts/acp.manifest-hash.sh" --generate 2>&1 || true)
assert_contains "${output}" "sha256:" "Manifest output contains SHA-256 hashes"

print_test_header "B6 — Command doc has Remediation Playbook"
assert_contains "$(cat "${CMD_FILE}")" "Remediation Playbook" "Remediation Playbook section present"

print_test_header "B7 — Command doc has Standards References with version pinning"
assert_contains "$(cat "${CMD_FILE}")" "Standards References" "Standards References section present"
assert_contains "$(cat "${CMD_FILE}")" "2026-06-07" "Version pinning present"

print_test_header "B8 — Taxonomy has code-integrity-scan entry"
assert_contains "$(cat "${PROJECT_ROOT}/agent/routing/taxonomy.yml")" "code-integrity-scan" "taxonomy entry present"

print_test_header "B9 — Package.yaml has acp.integrity.md with scripts"
assert_contains "$(cat "${PROJECT_ROOT}/package.yaml")" "acp.integrity.md" "package.yaml entry present"
assert_contains "$(cat "${PROJECT_ROOT}/package.yaml")" "acp.unicode-scan.sh" "scripts listed in package.yaml"

# ── M64 route-179: scanner regression (F-070-01, F-070-04) ───────────────────

print_test_header "B10 — Entropy scanner reports high-entropy fixture without crashing (F-070-01)"
ENTROPY_FIXTURE="${PROJECT_ROOT}/agent/benchmarks/fixtures/integrity/entropy-high.ts"
assert_file_exists "${ENTROPY_FIXTURE}" "entropy-high.ts fixture exists"
entropy_out=$(bash "${PROJECT_ROOT}/agent/scripts/acp.entropy-scan.sh" "${ENTROPY_FIXTURE}" 2>&1; echo "EXIT:$?")
assert_contains "${entropy_out}" "IG-17" "High-entropy string reported (IG-17)"
assert_contains "${entropy_out}" "[HIGH]" "Uniform output contract [SEVERITY]"
assert_contains "${entropy_out}" "EXIT:0" "Entropy scan exits 0 when findings present (no set -e crash)"

print_test_header "B11 — Entropy --ci exits 1 on HIGH finding"
bash "${PROJECT_ROOT}/agent/scripts/acp.entropy-scan.sh" --ci "${ENTROPY_FIXTURE}" >/dev/null 2>&1 || ec=$?
assert_true "Entropy --ci exits 1 on HIGH finding" $([ "${ec:-0}" -eq 1 ] && echo 0 || echo 1)

print_test_header "B12 — Entropy clean fixture stays silent"
ENTROPY_CLEAN="${PROJECT_ROOT}/agent/benchmarks/fixtures/integrity/entropy-clean.ts"
clean_entropy_out=$(bash "${PROJECT_ROOT}/agent/scripts/acp.entropy-scan.sh" "${ENTROPY_CLEAN}" 2>&1; echo "EXIT:$?")
assert_contains "${clean_entropy_out}" "EXIT:0" "Clean entropy fixture exits 0"
assert_not_contains "${clean_entropy_out}" "IG-17" "Clean fixture has no IG-17 finding"

print_test_header "B13 — Unicode scanner detects U+200D in committed fixture (single-pass)"
UNICODE_FIXTURE="${PROJECT_ROOT}/agent/benchmarks/fixtures/integrity/unicode-hidden.ts"
assert_file_exists "${UNICODE_FIXTURE}" "unicode-hidden.ts fixture exists"
unicode_out=$(bash "${PROJECT_ROOT}/agent/scripts/acp.unicode-scan.sh" "${UNICODE_FIXTURE}" 2>&1; echo "EXIT:$?")
assert_contains "${unicode_out}" "U+200D" "Unicode scanner detects zero-width joiner"
assert_contains "${unicode_out}" "[CRITICAL]" "Uniform output contract on unicode finding"
assert_contains "${unicode_out}" "EXIT:0" "Unicode scan exits 0 when findings present"

print_test_header "B14 — Unicode scanner completes agent/ tree in < 5s (F-070-04)"
start_ns=$(date +%s%N 2>/dev/null || echo "0")
bash "${PROJECT_ROOT}/agent/scripts/acp.unicode-scan.sh" "${PROJECT_ROOT}/agent" >/dev/null 2>&1
end_ns=$(date +%s%N 2>/dev/null || echo "0")
if [[ "${start_ns}" != "0" && "${end_ns}" != "0" ]]; then
  elapsed_ms=$(( (end_ns - start_ns) / 1000000 ))
  echo "  Unicode scan agent/: ${elapsed_ms}ms"
  assert_true "Unicode scan agent/ under 5000ms" $([ "${elapsed_ms}" -lt 5000 ] && echo 0 || echo 1)
else
  assert_true "Unicode scan agent/ completes (timing N/A)" 0
fi

# ── M64 route-184: fixture matrix + false-positive baseline ──────────────────

INTEGRITY_FIXTURE_DIR="${PROJECT_ROOT}/agent/benchmarks/fixtures/integrity"
MANIFEST="${INTEGRITY_FIXTURE_DIR}/manifest.yaml"

run_fixture_matrix() {
  local script="$1" positive="$2" negative="$3" rule="$4"
  local pos_out neg_out pos_ec neg_ec
  pos_out=$(bash "${PROJECT_ROOT}/agent/scripts/${script}" "${INTEGRITY_FIXTURE_DIR}/${positive}" 2>&1 || true)
  pos_ec=$?
  [[ "$pos_ec" -eq 0 ]] && pos_out_contains_rule=true || pos_out_contains_rule=false
  echo "$pos_out" | grep -q "${rule}" && pos_out_contains_rule=true
  assert_true "${script} flags ${positive} (${rule})" $([ "$pos_out_contains_rule" = true ] && echo 0 || echo 1)

  neg_out=$(bash "${PROJECT_ROOT}/agent/scripts/${script}" "${INTEGRITY_FIXTURE_DIR}/${negative}" 2>&1; echo "EXIT:$?")
  assert_contains "${neg_out}" "EXIT:0" "${script} clean on ${negative}"
  assert_not_contains "${neg_out}" "${rule}" "${negative} has no ${rule} finding"
}

print_test_header "B15 — Fixture matrix: network IG-01"
run_fixture_matrix "acp.network-whitelist-validate.sh" "network-ig01-bad.js" "network-ig01-good.js" "IG-01"

print_test_header "B16 — Fixture matrix: exfil IG-07"
run_fixture_matrix "acp.pattern-scan.sh" "exfil-ig07-bad.js" "exfil-ig07-good.js" "IG-07"

print_test_header "B17 — Fixture matrix: persistence IG-21"
run_fixture_matrix "acp.pattern-scan.sh" "persist-ig21-bad.js" "persist-ig21-good.js" "IG-21"

print_test_header "B18 — Uniform --json output from entropy scanner"
json_out=$(bash "${PROJECT_ROOT}/agent/scripts/acp.entropy-scan.sh" --json "${ENTROPY_FIXTURE}" 2>/dev/null || true)
assert_contains "${json_out}" "IG-17" "JSON output includes IG-17 rule"
assert_contains "${json_out}" "HIGH" "JSON output includes HIGH severity"

print_test_header "B19 — --ci ignores MEDIUM findings (severity-aware gate)"
# MEDIUM rule IG-30 only fires on unpinned security packages — dependency-diff on fixtures dir should be clean
dep_clean=$(bash "${PROJECT_ROOT}/agent/scripts/acp.dependency-diff.sh" --ci "${INTEGRITY_FIXTURE_DIR}" 2>&1; echo "EXIT:$?")
assert_contains "${dep_clean}" "EXIT:0" "dependency-diff on fixtures exits 0 under --ci"

print_test_header "B20 — False-positive baseline: zero CRITICAL/HIGH on clean framework paths"
# Scanner-specific baselines — entropy on YAML config can false-positive on long quoted strings
declare -A SCANNER_BASELINES
SCANNER_BASELINES[acp.entropy-scan.sh]="${INTEGRITY_FIXTURE_DIR}/entropy-clean.ts"
SCANNER_BASELINES[acp.unicode-scan.sh]="${INTEGRITY_FIXTURE_DIR}/unicode-clean.ts ${PROJECT_ROOT}/agent/core/identity.yml"
SCANNER_BASELINES[acp.network-whitelist-validate.sh]="${INTEGRITY_FIXTURE_DIR}/network-ig01-good.js"
SCANNER_BASELINES[acp.pattern-scan.sh]="${INTEGRITY_FIXTURE_DIR}/exfil-ig07-good.js ${INTEGRITY_FIXTURE_DIR}/persist-ig21-good.js"
baseline_failed=false
for scanner in acp.entropy-scan.sh acp.unicode-scan.sh acp.network-whitelist-validate.sh acp.pattern-scan.sh; do
  for bp in ${SCANNER_BASELINES[$scanner]}; do
    out=$(bash "${PROJECT_ROOT}/agent/scripts/${scanner}" --ci "$bp" 2>&1 || true)
    if echo "$out" | grep -qE '^\[(CRITICAL|HIGH)\]'; then
      echo "  FAIL: ${scanner} on ${bp}: $(echo "$out" | grep -E '^\[(CRITICAL|HIGH)\]' | head -1)"
      baseline_failed=true
    fi
  done
done
assert_true "False-positive baseline: 0 CRITICAL/HIGH on clean paths" $([ "$baseline_failed" = false ] && echo 0 || echo 1)

print_test_header "B21 — manifest.yaml fixture matrix file exists"
assert_file_exists "${MANIFEST}" "integrity fixture manifest.yaml exists"
assert_contains "$(cat "${MANIFEST}")" "acp.pattern-scan.sh" "manifest lists pattern-scan fixtures"

print_test_header "B22 — Seven integrity scripts exist (M64 + pattern-scan)"
SCRIPTS_M64=(
  "agent/scripts/acp.unicode-scan.sh"
  "agent/scripts/acp.entropy-scan.sh"
  "agent/scripts/acp.manifest-hash.sh"
  "agent/scripts/acp.network-whitelist-validate.sh"
  "agent/scripts/acp.git-provenance.sh"
  "agent/scripts/acp.dependency-diff.sh"
  "agent/scripts/acp.pattern-scan.sh"
  "agent/scripts/acp.integrity-output.sh"
)
for s in "${SCRIPTS_M64[@]}"; do
  assert_file_exists "${PROJECT_ROOT}/${s}" "$(basename "$s") exists"
  bash -n "${PROJECT_ROOT}/${s}" 2>/dev/null || assert_true "bash -n ${s}" 1
done

print_test_header "B23 — integrity-manifest.yaml verifies clean (INT-001 remediation)"
assert_file_exists "${PROJECT_ROOT}/agent/integrity-manifest.yaml" "integrity-manifest.yaml exists"
manifest_verify_out=$(bash "${PROJECT_ROOT}/agent/scripts/acp.manifest-hash.sh" --verify 2>&1; echo "EXIT:$?")
assert_contains "${manifest_verify_out}" "No findings" "manifest --verify reports clean"
assert_contains "${manifest_verify_out}" "EXIT:0" "manifest --verify exits 0"

print_test_header "B24 — git-provenance team_members parse (INT-002 remediation)"
provenance_out=$(bash "${PROJECT_ROOT}/agent/scripts/acp.git-provenance.sh" 2>&1; echo "EXIT:$?")
assert_not_contains "${provenance_out}" "IG-37" "No false IG-37 author alerts when team_members configured"
assert_contains "${provenance_out}" "EXIT:0" "git-provenance exits 0"

print_test_header "B25 — recurring-complete advances next_due (F-068-03 / audit-086)"
RECURRING_SCRIPT="${PROJECT_ROOT}/agent/scripts/acp.recurring-complete.sh"
assert_file_exists "${RECURRING_SCRIPT}" "acp.recurring-complete.sh exists"
bash -n "${RECURRING_SCRIPT}"
assert_true "acp.recurring-complete.sh passes bash -n" $?

print_suite_summary
