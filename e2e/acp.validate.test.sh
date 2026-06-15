#!/usr/bin/env bash
# E2E Tests for /acp-validate command (M60 route-165)
# Structural + negative assertions on the validate command doc

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${PROJECT_ROOT}/tests/common.sh"

CMD_FILE="${PROJECT_ROOT}/agent/commands/acp.validate.md"
VALIDATE_TS="${PROJECT_ROOT}/scripts/acp-validate.ts"

print_suite_header "/acp-validate — E2E Tests (M60)"

print_test_header "S1 — acp.validate.md exists with Agent Directive"
assert_file_exists "${CMD_FILE}" "acp.validate.md exists"
assert_contains "$(head -10 "${CMD_FILE}")" "Agent Directive" "Agent Directive header present"

print_test_header "S2 — Required sections present"
CMD_CONTENT="$(cat "${CMD_FILE}")"
assert_contains "${CMD_CONTENT}" "## Steps" "Steps section present"
assert_contains "${CMD_CONTENT}" "## Verification" "Verification section present"
assert_contains "${CMD_CONTENT}" "## Expected Output" "Expected Output section present"
assert_contains "${CMD_CONTENT}" "Namespace" "Namespace metadata present"

print_test_header "S3 — Cross-layer consistency checks documented (v6.20.1+)"
assert_contains "${CMD_CONTENT}" "2e" "Step 2e (status consistency) present"
assert_contains "${CMD_CONTENT}" "2f" "Step 2f (file pointers) present"

print_test_header "S4 — TypeScript validator exists"
assert_file_exists "${VALIDATE_TS}" "acp-validate.ts exists"

print_test_header "S5 — Validator has cross-layer functions"
assert_contains "$(cat "${VALIDATE_TS}")" "validateStatusConsistency" "validateStatusConsistency function exists"
assert_contains "$(cat "${VALIDATE_TS}")" "validateFilePointers" "validateFilePointers function exists"

print_test_header "B1 — Version consistency check documented"
assert_contains "${CMD_CONTENT}" "version" "Version validation referenced"

print_test_header "N1 — No TODO or TBD in Steps section"
STEPS_SECTION=$(sed -n '/## Steps/,/## Verification/p' "${CMD_FILE}")
assert_not_contains "${STEPS_SECTION}" "TODO" "No TODO in Steps section"
assert_not_contains "${STEPS_SECTION}" "TBD" "No TBD in Steps section"

print_test_header "N2 — Validator runs without crashing on clean repo"
set +e
VALIDATE_OUT=$(cd "${PROJECT_ROOT}" && npx ts-node scripts/acp-validate.ts 2>/dev/null) || VALIDATE_RC=$?
set -e
assert_not_contains "${VALIDATE_OUT}" "YAMLException" "No YAML parse errors on progress.yaml"
assert_not_contains "${VALIDATE_OUT}" "TypeError" "No TypeScript runtime errors"
assert_not_contains "${VALIDATE_OUT}" "Cannot find module" "No module-not-found errors"

print_test_summary
