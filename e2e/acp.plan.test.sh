#!/usr/bin/env bash
# E2E Tests for /acp-plan command (M60 route-165)
# Structural + negative assertions on the plan command doc

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${PROJECT_ROOT}/tests/common.sh"

CMD_FILE="${PROJECT_ROOT}/agent/commands/acp.plan.md"
PROGRESS_FILE="${PROJECT_ROOT}/agent/progress.yaml"

print_suite_header "/acp-plan — E2E Tests (M60)"

print_test_header "S1 — acp.plan.md exists with Agent Directive"
assert_file_exists "${CMD_FILE}" "acp.plan.md exists"
assert_contains "$(head -10 "${CMD_FILE}")" "Agent Directive" "Agent Directive header present"

print_test_header "S2 — Required sections present"
CMD_CONTENT="$(cat "${CMD_FILE}")"
assert_contains "${CMD_CONTENT}" "## Steps" "Steps section present"
assert_contains "${CMD_CONTENT}" "## Verification" "Verification section present"
assert_contains "${CMD_CONTENT}" "## Expected Output" "Expected Output section present"
assert_contains "${CMD_CONTENT}" "Namespace" "Namespace metadata present"

print_test_header "S3 — Progress file exists for plan operations"
assert_file_exists "${PROGRESS_FILE}" "progress.yaml exists"

print_test_header "S4 — Milestone planning references"
assert_contains "${CMD_CONTENT}" "milestone" "Milestone terminology present"

print_test_header "B1 — Route creation documented"
assert_contains "${CMD_CONTENT}" "acp-task-create\|acp-milestone-create" "Subcommand creation referenced"

print_test_header "N1 — No TODO or TBD in Steps section"
STEPS_SECTION=$(sed -n '/## Steps/,/## Verification/p' "${CMD_FILE}")
assert_not_contains "${STEPS_SECTION}" "TODO" "No TODO in Steps section"
assert_not_contains "${STEPS_SECTION}" "TBD" "No TBD in Steps section"

print_test_header "N2 — Plan doc is not empty/template-only"
DOC_LINES=$(wc -l < "${CMD_FILE}")
[ "${DOC_LINES}" -gt 30 ]
assert_true "Command doc has sufficient length (${DOC_LINES} lines)" $?

print_test_summary
