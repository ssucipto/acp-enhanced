#!/usr/bin/env bash
# E2E Tests for /acp-audit command (M60 route-165)
# Structural + negative assertions on the audit command doc

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${PROJECT_ROOT}/tests/common.sh"

CMD_FILE="${PROJECT_ROOT}/agent/commands/acp.audit.md"
REPORTS_DIR="${PROJECT_ROOT}/agent/reports"
CARRYOVERS_FILE="${PROJECT_ROOT}/agent/memory/audit-carryovers.md"

print_suite_header "/acp-audit — E2E Tests (M60)"

print_test_header "S1 — acp.audit.md exists with Agent Directive"
assert_file_exists "${CMD_FILE}" "acp.audit.md exists"
assert_contains "$(head -10 "${CMD_FILE}")" "Agent Directive" "Agent Directive header present"

print_test_header "S2 — Required sections present"
CMD_CONTENT="$(cat "${CMD_FILE}")"
assert_contains "${CMD_CONTENT}" "## Steps" "Steps section present"
assert_contains "${CMD_CONTENT}" "## Verification" "Verification section present"
assert_contains "${CMD_CONTENT}" "Namespace" "Namespace metadata present"

print_test_header "S3 — Reports directory exists"
assert_dir_exists "${REPORTS_DIR}" "agent/reports/ exists"

print_test_header "S4 — Carryovers file exists"
assert_file_exists "${CARRYOVERS_FILE}" "audit-carryovers.md exists"

print_test_header "S5 — Report naming convention referenced"
assert_contains "${CMD_CONTENT}" "audit-" "Audit report naming pattern referenced"

print_test_header "B1 — Finding severity levels documented"
assert_contains "${CMD_CONTENT}" "CRITICAL\|severity" "Severity levels referenced"

print_test_header "N1 — No TODO or TBD in Steps section"
STEPS_SECTION=$(sed -n '/## Steps/,/## Verification/p' "${CMD_FILE}")
assert_not_contains "${STEPS_SECTION}" "TODO" "No TODO in Steps section"
assert_not_contains "${STEPS_SECTION}" "TBD" "No TBD in Steps section"

print_test_header "N2 — Pre-impl vs post-impl modes documented"
assert_contains "${CMD_CONTENT}" "pre-impl\|post-impl\|pre_impl\|post_impl" "Audit mode documented"
DOC_LINES=$(wc -l < "${CMD_FILE}")
[ "${DOC_LINES}" -gt 30 ]
assert_true "Command doc has sufficient length (${DOC_LINES} lines)" $?

print_test_summary
