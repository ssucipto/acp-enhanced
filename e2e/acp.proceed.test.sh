#!/usr/bin/env bash
# E2E Tests for /acp-proceed command (M60 route-165)
# Structural + negative assertions on the proceed command doc

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${PROJECT_ROOT}/tests/common.sh"

CMD_FILE="${PROJECT_ROOT}/agent/commands/acp.proceed.md"
PROGRESS_FILE="${PROJECT_ROOT}/agent/progress.yaml"

print_suite_header "/acp-proceed — E2E Tests (M60)"

print_test_header "S1 — acp.proceed.md exists with Agent Directive"
assert_file_exists "${CMD_FILE}" "acp.proceed.md exists"
assert_contains "$(head -20 "${CMD_FILE}")" "AGENT DIRECTIVE" "Agent Directive header present"

print_test_header "S2 — Required sections present"
CMD_CONTENT="$(cat "${CMD_FILE}")"
assert_contains "${CMD_CONTENT}" "## Steps" "Steps section present"
assert_contains "${CMD_CONTENT}" "## Verification" "Verification section present"
assert_contains "${CMD_CONTENT}" "## Autonomous Mode" "Autonomous mode section present"
assert_contains "${CMD_CONTENT}" "Namespace" "Namespace metadata present"

print_test_header "S3 — Arguments section documents --complete"
assert_contains "${CMD_CONTENT}" "complete\|autonomous\|--finish" "Autonomous completion flags documented"

print_test_header "S4 — Commit subroutine documented"
assert_contains "${CMD_CONTENT}" "@git.commit" "Per-task git commit referenced"

print_test_header "S5 — Error handling rules present"
assert_contains "${CMD_CONTENT}" "HALT" "Halt-on-failure rule present"

print_test_header "B1 — References progress.yaml for task selection"
assert_contains "${CMD_CONTENT}" "progress.yaml" "References progress.yaml"

print_test_header "N1 — No TODO in Steps or Autonomous sections"
STEPS_SECTION=$(sed -n '/## Steps/,/## Verification/p' "${CMD_FILE}")
assert_not_contains "${STEPS_SECTION}" "TODO" "No TODO in Steps section"
AUTO_SECTION=$(sed -n '/## Autonomous Mode/,/## Verification/p' "${CMD_FILE}")
assert_not_contains "${AUTO_SECTION}" "TODO" "No TODO in Autonomous section"

print_test_header "N2 — Verify mandatory status updates documented"
assert_contains "${CMD_CONTENT}" "in_progress" "Task status update documented"

print_test_summary
