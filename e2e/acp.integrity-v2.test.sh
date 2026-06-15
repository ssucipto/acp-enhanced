#!/usr/bin/env bash
# E2E Tests for /acp-integrity Phase 2 (M58 v2.0)
# Structural + confidence ceiling + script behavioral checks

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${PROJECT_ROOT}/tests/common.sh"

CMD_FILE="${PROJECT_ROOT}/agent/commands/acp.integrity.md"
SKILL_FILE="${PROJECT_ROOT}/agent/skills/code-integrity.md"
WIKI_FILE="${PROJECT_ROOT}/agent/wiki/integrity-rules.md"
TAINT_FIXTURE="${PROJECT_ROOT}/agent/benchmarks/fixtures/taint-flow"

print_suite_header "/acp-integrity v2.0 — Phase 2 E2E (M58)"

print_test_header "S1 — integrity-rules.md Cat 8 with confidence columns (not DEFERRED)"
assert_not_contains "$(cat "${WIKI_FILE}")" "DEFERRED to v2.0 (M58)" "Cat 8/10 not marked DEFERRED"
assert_contains "$(cat "${WIKI_FILE}")" "Max Confidence" "Cat 8 has Max Confidence column"
assert_contains "$(cat "${WIKI_FILE}")" "IG-45" "IG-45 documented in Cat 8"

print_test_header "S2 — acp.integrity.md Phase 2 + self-protection protocol"
assert_contains "$(cat "${CMD_FILE}")" "Phase 2" "Phase 2 section present"
assert_contains "$(cat "${CMD_FILE}")" "Self-Protection Protocol" "Self-protection protocol present"
assert_contains "$(cat "${CMD_FILE}")" "REQUIRES_HUMAN_REVIEW" "Human review verdict documented"

print_test_header "S3 — code-integrity.md Phase 2 guidance"
assert_contains "$(cat "${SKILL_FILE}")" "Phase 2" "Skill mentions Phase 2"
assert_contains "$(cat "${SKILL_FILE}")" "v2.0" "Skill version v2.0"

print_test_header "B4 — Cat 8 rules: no confidence HIGH in wiki (max MEDIUM)"
cat8=$(sed -n '/Category 8/,/Category 9/p' "${WIKI_FILE}")
assert_not_contains "${cat8}" "confidence: HIGH" "Cat 8 wiki has no confidence HIGH"
assert_contains "${cat8}" "MEDIUM" "Cat 8 wiki documents MEDIUM ceiling"

print_test_header "B5 — Cat 9 v2.0 rules: confidence LOW only"
cat9=$(sed -n '/Category 9/,/Category 10/p' "${WIKI_FILE}")
assert_contains "${cat9}" "IG-53" "IG-53 present"
assert_contains "${cat9}" "LOW" "Cat 9 v2.0 rules LOW confidence"

print_test_header "B6 — Cat 10 rules: LOW except IG-61 HIGH"
cat10=$(sed -n '/Category 10/,/Category 11/p' "${WIKI_FILE}")
assert_contains "${cat10}" "IG-61" "IG-61 present"
assert_contains "${cat10}" "unicode-scan" "IG-61 script-backed"

print_test_header "B7 — Self-protection: continue scanning (do NOT self-halt)"
assert_contains "$(cat "${CMD_FILE}")" "CONTINUE" "Self-protection says CONTINUE"
assert_contains "$(cat "${CMD_FILE}")" "do NOT self-halt" "Explicit do NOT self-halt"

print_test_header "B8 — phase2 flag documented"
assert_contains "$(cat "${CMD_FILE}")" "Run Phase 2 semantic" "phase2 flag documented"

print_test_header "B9 — taint-scan.sh detects IG-45 on vulnerable fixture"
taint_out=$(bash "${PROJECT_ROOT}/agent/scripts/acp.taint-scan.sh" "${TAINT_FIXTURE}/ig-45-vulnerable.js" 2>&1; echo "EXIT:$?")
assert_contains "${taint_out}" "IG-45" "IG-45 finding on vulnerable fixture"
assert_contains "${taint_out}" "EXIT:0" "taint-scan exits 0 with findings"

print_test_header "B10 — taint-scan.sh clean on safe fixture"
safe_out=$(bash "${PROJECT_ROOT}/agent/scripts/acp.taint-scan.sh" "${TAINT_FIXTURE}/ig-45-safe.js" 2>&1; echo "EXIT:$?")
assert_contains "${safe_out}" "EXIT:0" "Safe fixture exits 0"
assert_not_contains "${safe_out}" "IG-45" "Safe fixture has no IG-45"

print_test_header "B11 — memory-scan.sh extracts constraints + memory files"
mem_out=$(bash "${PROJECT_ROOT}/agent/scripts/acp.memory-scan.sh" 2>&1; echo "EXIT:$?")
assert_contains "${mem_out}" "constraints_hard_rules" "Memory scan outputs hard rules"
assert_contains "${mem_out}" "memory_files" "Memory scan lists memory files"
assert_contains "${mem_out}" "EXIT:0" "memory-scan exits 0"

print_test_header "B12 — Phase 2 scripts pass bash -n"
for s in acp.taint-scan.sh acp.memory-scan.sh; do
  bash -n "${PROJECT_ROOT}/agent/scripts/${s}" 2>/dev/null
  assert_true "bash -n ${s}" $?
done

print_test_header "B13 — taint-flow manifest has max_confidence + ci_blocking"
manifest="${TAINT_FIXTURE}/manifest.yaml"
assert_contains "$(cat "${manifest}")" "max_confidence:" "manifest encodes max_confidence"
assert_contains "$(cat "${manifest}")" "ci_blocking: false" "manifest marks taint fixtures non-blocking in CI"

print_test_header "B14 — full taint fixture matrix (6 vulnerable rules)"
for pair in 45 46 47 48 49 50; do
  vuln="${TAINT_FIXTURE}/ig-${pair}-vulnerable.js"
  safe="${TAINT_FIXTURE}/ig-${pair}-safe.js"
  vuln_out=$(bash "${PROJECT_ROOT}/agent/scripts/acp.taint-scan.sh" "${vuln}" 2>&1; echo "EXIT:$?")
  safe_out=$(bash "${PROJECT_ROOT}/agent/scripts/acp.taint-scan.sh" "${safe}" 2>&1; echo "EXIT:$?")
  assert_contains "${vuln_out}" "IG-${pair}" "IG-${pair} finding on vulnerable fixture"
  assert_contains "${vuln_out}" "EXIT:0" "IG-${pair} vulnerable exits 0"
  assert_not_contains "${safe_out}" "IG-${pair}" "IG-${pair} clean on safe fixture"
  assert_contains "${safe_out}" "EXIT:0" "IG-${pair} safe exits 0"
done

print_test_header "B15 — taint-scan --ci does not fail on MEDIUM findings"
ci_out=$(bash "${PROJECT_ROOT}/agent/scripts/acp.taint-scan.sh" --ci "${TAINT_FIXTURE}/ig-45-vulnerable.js" 2>&1; echo "EXIT:$?")
assert_contains "${ci_out}" "MEDIUM" "Phase 2 taint finding at MEDIUM"
assert_contains "${ci_out}" "EXIT:0" "taint-scan --ci exits 0 on MEDIUM-only findings"

print_test_header "B16 — IG-50 reports LOW confidence ceiling"
ig50_out=$(bash "${PROJECT_ROOT}/agent/scripts/acp.taint-scan.sh" "${TAINT_FIXTURE}/ig-50-vulnerable.js" 2>&1)
assert_contains "${ig50_out}" "[LOW]" "IG-50 finding uses LOW confidence"

print_suite_summary
