#!/usr/bin/env bash
# E2E Tests for /acp-commit command (M60 route-165)
# Structural + negative assertions on the commit command doc

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${PROJECT_ROOT}/tests/common.sh"

CMD_FILE="${PROJECT_ROOT}/agent/commands/acp.commit.md"
SESSIONS_FILE="${PROJECT_ROOT}/agent/memory/sessions.md"

print_suite_header "/acp-commit — E2E Tests (M60)"

print_test_header "S1 — acp.commit.md exists with Agent Directive"
assert_file_exists "${CMD_FILE}" "acp.commit.md exists"
assert_contains "$(head -10 "${CMD_FILE}")" "Agent Directive" "Agent Directive header present"

print_test_header "S2 — Required sections present"
CMD_CONTENT="$(cat "${CMD_FILE}")"
assert_contains "${CMD_CONTENT}" "## Steps" "Steps section present"
assert_contains "${CMD_CONTENT}" "## Verification" "Verification section present"
assert_contains "${CMD_CONTENT}" "Namespace" "Namespace metadata present"

print_test_header "S3 — Sessions file exists"
assert_file_exists "${SESSIONS_FILE}" "sessions.md exists"

print_test_header "S4 — Compaction trigger documented"
assert_contains "${CMD_CONTENT}" "compact" "Compaction logic documented"

print_test_header "B1 — Sessions entry format documented (YAML)"
assert_contains "${CMD_CONTENT}" "yaml" "YAML format referenced"

print_test_header "N1 — No TODO or TBD in Steps section"
STEPS_SECTION=$(sed -n '/## Steps/,/## Verification/p' "${CMD_FILE}")
assert_not_contains "${STEPS_SECTION}" "TODO" "No TODO in Steps section"
assert_not_contains "${STEPS_SECTION}" "TBD" "No TBD in Steps section"

print_test_header "N2 — Sessions compaction: >15 auto-compact documented"
assert_contains "${CMD_CONTENT}" "15" "Threshold of 15 entries documented"
DOC_LINES=$(wc -l < "${CMD_FILE}")
[ "${DOC_LINES}" -gt 15 ]
assert_true "Command doc has sufficient length (${DOC_LINES} lines)" $?

print_test_summary
