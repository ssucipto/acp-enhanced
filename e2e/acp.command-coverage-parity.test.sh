#!/usr/bin/env bash
# E2E: M63 command↔test parity — registry completeness (0 untested commands)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${PROJECT_ROOT}/tests/common.sh"

COVERAGE_YAML="${PROJECT_ROOT}/agent/schemas/command-e2e-coverage.yaml"
COMMANDS_DIR="${PROJECT_ROOT}/agent/commands"

print_suite_header "Command E2E Coverage Parity — M63"

print_test_header "P1 — coverage registry exists"
assert_file_exists "${COVERAGE_YAML}" "command-e2e-coverage.yaml exists"

print_test_header "P2 — acp-validate command E2E coverage passes"
out="$(cd "${PROJECT_ROOT}" && npx tsx scripts/acp-validate.ts 2>&1)"
assert_contains "${out}" "Command E2E coverage" "validate reports command E2E coverage"
assert_contains "${out}" "0 untested" "0 untested commands"
echo "${out}" | grep -q "❌.*E2E coverage" && _cov_fail=1 || _cov_fail=0
assert_true "no command E2E coverage errors" "${_cov_fail}"

CMD_COUNT=$(find "${COMMANDS_DIR}" -maxdepth 1 -name 'acp.*.md' ! -name 'command.template.md' | wc -l | tr -d ' ')
REGISTRY_COUNT=$(grep -c '^  acp\.' "${COVERAGE_YAML}" || true)

print_test_header "P3 — registry maps all command docs (${CMD_COUNT})"
assert_equals "${CMD_COUNT}" "${REGISTRY_COUNT}" "registry entry count matches command docs"

print_test_header "P4 — tier2 and tier3 suite files exist"
assert_file_exists "${PROJECT_ROOT}/e2e/acp.tier2-workflow.test.sh" "tier2 suite"
assert_file_exists "${PROJECT_ROOT}/e2e/acp.tier3-memory-knowledge.test.sh" "tier3 suite"

print_test_header "P5-negative: every registry suite path exists on disk"
_missing=0
while IFS= read -r suite; do
  [ -z "${suite}" ] && continue
  if [ ! -f "${PROJECT_ROOT}/${suite}" ]; then
    echo "  missing suite: ${suite}"
    _missing=$((_missing + 1))
  fi
done < <(grep 'e2e/' "${COVERAGE_YAML}" | sed 's/.*- //;s/ *$//' | sort -u)
assert_equals "0" "${_missing}" "all referenced E2E suites exist"

print_test_summary "acp.command-coverage-parity.test.sh"
exit $?
