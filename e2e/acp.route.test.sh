#!/usr/bin/env bash
# E2E Tests for /acp-route command (M60 route-165)
# Structural + negative assertions on the route command doc

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${PROJECT_ROOT}/tests/common.sh"

CMD_FILE="${PROJECT_ROOT}/agent/commands/acp.route.md"
TAXONOMY_FILE="${PROJECT_ROOT}/agent/routing/taxonomy.yml"
RULES_FILE="${PROJECT_ROOT}/agent/routing/rules.md"
TASKS_DIR="${PROJECT_ROOT}/agent/routing/tasks"

print_suite_header "/acp-route — E2E Tests (M60)"

print_test_header "S1 — acp.route.md exists with Agent Directive"
assert_file_exists "${CMD_FILE}" "acp.route.md exists"
assert_contains "$(head -10 "${CMD_FILE}")" "Agent Directive" "Agent Directive header present"

print_test_header "S2 — Required sections present"
CMD_CONTENT="$(cat "${CMD_FILE}")"
assert_contains "${CMD_CONTENT}" "## Steps" "Steps section present"
assert_contains "${CMD_CONTENT}" "## Verification" "Verification section present"
assert_contains "${CMD_CONTENT}" "Namespace" "Namespace metadata present"

print_test_header "S3 — References taxonomy.yml"
assert_contains "${CMD_CONTENT}" "taxonomy" "Taxonomy referenced"

print_test_header "S4 — Taxonomy and rules files exist"
assert_file_exists "${TAXONOMY_FILE}" "taxonomy.yml exists"
assert_file_exists "${RULES_FILE}" "rules.md exists"

print_test_header "S5 — Tasks directory exists"
assert_dir_exists "${TASKS_DIR}" "agent/routing/tasks/ exists"

print_test_header "B1 — Route frontmatter format documented"
assert_contains "${CMD_CONTENT}" "frontmatter" "Frontmatter format referenced"
assert_contains "${CMD_CONTENT}" "route-" "Route ID prefix documented"

print_test_header "N1 — No TODO or TBD in Steps section"
STEPS_SECTION=$(sed -n '/## Steps/,/## Verification/p' "${CMD_FILE}")
assert_not_contains "${STEPS_SECTION}" "TODO" "No TODO in Steps section"
assert_not_contains "${STEPS_SECTION}" "TBD" "No TBD in Steps section"

print_test_header "N2 — Route file template has required frontmatter fields"
TASKS_EXAMPLE=$(ls "${TASKS_DIR}"/route-*.md 2>/dev/null | head -1)
test -n "${TASKS_EXAMPLE}" && assert_contains "$(head -20 "${TASKS_EXAMPLE}")" "task_type:" "Existing route has task_type field"
test -n "${TASKS_EXAMPLE}" && assert_contains "$(head -20 "${TASKS_EXAMPLE}")" "executor:" "Existing route has executor field"
test -n "${TASKS_EXAMPLE}" && assert_contains "$(head -20 "${TASKS_EXAMPLE}")" "milestone:" "Existing route has milestone field"

DOC_LINES=$(wc -l < "${CMD_FILE}")
[ "${DOC_LINES}" -gt 20 ]
assert_true "Command doc has sufficient length (${DOC_LINES} lines)" $?

print_test_summary
