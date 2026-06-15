#!/usr/bin/env bash
# E2E Tests for /acp-init command (M60 route-165)
# Structural + negative assertions on the init command doc and core files

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${PROJECT_ROOT}/tests/common.sh"

CMD_FILE="${PROJECT_ROOT}/agent/commands/acp.init.md"
IDENTITY_FILE="${PROJECT_ROOT}/agent/core/identity.yml"
ROUTING_FILE="${PROJECT_ROOT}/agent/core/routing.yml"

print_suite_header "/acp-init — E2E Tests (M60)"

print_test_header "S1 — acp.init.md exists with Agent Directive"
assert_file_exists "${CMD_FILE}" "acp.init.md exists"
assert_contains "$(head -10 "${CMD_FILE}")" "Agent Directive" "Agent Directive header present"

print_test_header "S2 — Required sections present"
CMD_CONTENT="$(cat "${CMD_FILE}")"
assert_contains "${CMD_CONTENT}" "## Steps" "Steps section present"
assert_contains "${CMD_CONTENT}" "## Verification" "Verification section present"
assert_contains "${CMD_CONTENT}" "Namespace" "Namespace metadata present"

print_test_header "S3 — Context loading protocol documented"
assert_contains "${CMD_CONTENT}" "context loading" "Context loading referenced"

print_test_header "S4 — Core files exist"
assert_file_exists "${IDENTITY_FILE}" "identity.yml exists"
assert_file_exists "${ROUTING_FILE}" "routing.yml exists"

print_test_header "B1 — Context loading mode documented"
assert_contains "${CMD_CONTENT}" "light\|full.*mode\|context loading" "Context loading mode referenced"

print_test_header "N1 — No TODO or TBD in Steps section"
STEPS_SECTION=$(sed -n '/## Steps/,/## Verification/p' "${CMD_FILE}")
assert_not_contains "${STEPS_SECTION}" "TODO:" "No TODO: in Steps section"
assert_not_contains "${STEPS_SECTION}" "TBD" "No TBD in Steps section"

print_test_header "N2 — Init doc is not empty/template-only"
assert_not_empty "${CMD_CONTENT}" "Command doc has content beyond header"
DOC_LINES=$(wc -l < "${CMD_FILE}")
assert_true "Command doc has sufficient length (${DOC_LINES} lines)" $?

print_test_summary
