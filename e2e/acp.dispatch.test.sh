#!/usr/bin/env bash
# E2E Tests for /acp-dispatch command (M60 route-165)
# Structural + negative assertions on the dispatch command doc

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${PROJECT_ROOT}/tests/common.sh"

CMD_FILE="${PROJECT_ROOT}/agent/commands/acp.dispatch.md"
ROUTING_FILE="${PROJECT_ROOT}/agent/core/routing.yml"

print_suite_header "/acp-dispatch — E2E Tests (M60)"

print_test_header "S1 — acp.dispatch.md exists with Agent Directive"
assert_file_exists "${CMD_FILE}" "acp.dispatch.md exists"
assert_contains "$(head -10 "${CMD_FILE}")" "Agent Directive" "Agent Directive header present"

print_test_header "S2 — Required sections present"
CMD_CONTENT="$(cat "${CMD_FILE}")"
assert_contains "${CMD_CONTENT}" "## Steps" "Steps section present"
assert_contains "${CMD_CONTENT}" "## Prerequisites\|Prerequisites" "Prerequisites section present"
assert_contains "${CMD_CONTENT}" "Namespace" "Namespace metadata present"

print_test_header "S3 — References routing.yml"
assert_contains "${CMD_CONTENT}" "routing.yml" "References routing.yml"

print_test_header "S4 — routing.yml has context_modes"
assert_file_exists "${ROUTING_FILE}" "routing.yml exists"
assert_contains "$(cat "${ROUTING_FILE}")" "context_modes" "context_modes field present"

print_test_header "B1 — Context budget referenced"
assert_contains "${CMD_CONTENT}" "context" "Context management referenced"

print_test_header "N1 — No TODO or TBD in Steps section"
STEPS_SECTION=$(sed -n '/## Steps/,/^## /p' "${CMD_FILE}" | head -n 100)
assert_not_contains "${STEPS_SECTION}" "TODO" "No TODO in Steps section"
assert_not_contains "${STEPS_SECTION}" "TBD" "No TBD in Steps section"

print_test_header "N2 — Non-destructive update documented"
assert_contains "${CMD_CONTENT}" "routing.yml\|update.*routing" "Update semantics documented"
DOC_LINES=$(wc -l < "${CMD_FILE}")
[ "${DOC_LINES}" -gt 15 ]
assert_true "Command doc has sufficient length (${DOC_LINES} lines)" $?

print_test_summary
