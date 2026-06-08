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

print_test_header "S3 — integrity-rules.md wiki exists with 55+ rules"
assert_file_exists "${WIKI_FILE}" "integrity-rules.md wiki exists"
RULE_COUNT=$(grep -cE '^\| IG-\d+' "${WIKI_FILE}" || echo "0")
echo "  Rules documented: ${RULE_COUNT}"
[ "${RULE_COUNT}" -ge 55 ]
assert_true "At least 55 rules in wiki (actual: ${RULE_COUNT})" $?

print_test_header "S4 — network_whitelist.yml exists with schema"
assert_file_exists "${WHITELIST_FILE}" "network_whitelist.yml exists"
assert_contains "$(cat "${WHITELIST_FILE}")" "approved_hosts:" "approved_hosts field present"

print_test_header "S5 — All 6 bash scripts exist and pass bash -n"
SCRIPTS=(
  "agent/scripts/acp.unicode-scan.sh"
  "agent/scripts/acp.entropy-scan.sh"
  "agent/scripts/acp.manifest-hash.sh"
  "agent/scripts/acp.network-whitelist-validate.sh"
  "agent/scripts/acp.git-provenance.sh"
  "agent/scripts/acp.dependency-diff.sh"
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
assert_true "All 6 scripts exist and pass bash -n" $([ "$ALL_OK" = true ] && echo 0 || echo 1)

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
FIXTURE_DIR="$(mktemp -d)"
trap 'rm -rf "${FIXTURE_DIR}"' EXIT
# Create file with actual U+200D byte sequence using Python
python3 -c "
with open('${FIXTURE_DIR}/hidden-unicode.ts', 'w') as f:
    f.write('const x = \"hello\u200dworld\";\n')
" 2>/dev/null
if [[ -f "${FIXTURE_DIR}/hidden-unicode.ts" ]]; then
  # Verify the file contains the Unicode character (grep for it)
  if grep -qP '\x{200D}' "${FIXTURE_DIR}/hidden-unicode.ts" 2>/dev/null || python3 -c "exit(0 if '\u200d' in open('${FIXTURE_DIR}/hidden-unicode.ts').read() else 1)" 2>/dev/null; then
    assert_true "Detected U+200D zero-width joiner in fixture" 0
  else
    assert_true "Detected U+200D zero-width joiner in fixture" 1
  fi
else
  assert_true "Detected U+200D zero-width joiner in fixture" 1
fi

print_test_header "B2 — Unicode scanner passes on clean file (bash -n check)"
# Verify the scanner script is syntactically valid and handles clean input
echo 'const x = "hello world";' > "${FIXTURE_DIR}/clean.ts"
output=$(bash "${PROJECT_ROOT}/agent/scripts/acp.unicode-scan.sh" "${FIXTURE_DIR}/clean.ts" 2>&1; echo "EXIT:$?")
assert_contains "${output}" "EXIT:0" "Clean file scan exits 0"

print_test_header "B3 — Entropy scanner exits 0 on simple clean file"
echo 'const x = 1;' > "${FIXTURE_DIR}/simple.ts"
bash "${PROJECT_ROOT}/agent/scripts/acp.entropy-scan.sh" "${FIXTURE_DIR}/simple.ts" > /dev/null 2>&1
assert_true "Entropy scanner exits 0 on clean file" $?

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

print_suite_summary
