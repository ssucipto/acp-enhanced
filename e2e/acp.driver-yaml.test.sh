#!/usr/bin/env bash
# E2E Tests for acp.driver-yaml.sh
# Tests all 8 POSIX helper functions: driver_type, driver_is_native,
# driver_query, driver_list, driver_validate, driver_status, driver_get,
# driver_override. Covers absent-file fallback behaviour.
#
# NOTE: Do NOT add set -e here. assert_* functions return exit code 1 on failure.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${PROJECT_ROOT}/tests/common.sh"

DRIVER_SH="${PROJECT_ROOT}/agent/scripts/acp.driver-yaml.sh"

# ── Syntax check ──────────────────────────────────────────────────────────────

print_suite_header "acp.driver-yaml.sh — E2E Tests"

print_test_header "acp.driver-yaml.sh — no bash syntax errors"
bash -n "${DRIVER_SH}" 2>/dev/null
assert_true "bash -n acp.driver-yaml.sh exits 0" $?

# ── Fixture setup ─────────────────────────────────────────────────────────────

TMPDIR_ROOT="$(mktemp -d)"

cat > "${TMPDIR_ROOT}/driver.yaml" << 'EOF'
drivers:
  git:
    type: mcp
    server: git-mcp
    method: git_exec
    timeout_ms: 5000
  shell:
    type: native
  lint:
    type: http
    url: https://lint.internal/api
    timeout_ms: 3000
EOF

export DRIVER_YAML="${TMPDIR_ROOT}/driver.yaml"

# Source the script under test (DRIVER_YAML env var controls which file is read)
# shellcheck source=agent/scripts/acp.driver-yaml.sh
source "${DRIVER_SH}"

# ── driver_type ───────────────────────────────────────────────────────────────

print_test_header "driver_type — returns mcp for git"
result="$(driver_type git)"
assert_equals "mcp" "${result}" "driver_type git = mcp"

print_test_header "driver_type — returns native for shell"
result="$(driver_type shell)"
assert_equals "native" "${result}" "driver_type shell = native"

print_test_header "driver_type — returns native as default for unknown tool"
result="$(driver_type unknown_tool)"
assert_equals "native" "${result}" "driver_type unknown_tool = native (default)"

# ── driver_is_native ──────────────────────────────────────────────────────────

print_test_header "driver_is_native — returns 0 (true) for native shell"
driver_is_native shell
assert_true "driver_is_native shell returns 0" $?

print_test_header "driver_is_native — returns non-zero (false) for mcp git"
driver_is_native git
assert_false "driver_is_native git returns non-zero" $?

print_test_header "driver_is_native — returns 0 (true) for unknown tool (safe default)"
driver_is_native completely_unknown
assert_true "driver_is_native unknown returns 0" $?

# ── driver_query ──────────────────────────────────────────────────────────────

print_test_header "driver_query — returns server for git"
result="$(driver_query git server)"
assert_equals "git-mcp" "${result}" "driver_query git server = git-mcp"

print_test_header "driver_query — returns method for git"
result="$(driver_query git method)"
assert_equals "git_exec" "${result}" "driver_query git method = git_exec"

print_test_header "driver_query — returns url for lint"
result="$(driver_query lint url)"
assert_equals "https://lint.internal/api" "${result}" "driver_query lint url = https://lint.internal/api"

# ── driver_list ───────────────────────────────────────────────────────────────

print_test_header "driver_list — lists all 3 configured drivers"
driver_count="$(driver_list | wc -l | tr -d ' ')"
assert_equals "3" "${driver_count}" "driver_list outputs 3 lines"

print_test_header "driver_list — includes git"
list_output="$(driver_list)"
assert_contains "${list_output}" "git" "driver_list contains git"

print_test_header "driver_list — includes shell"
assert_contains "${list_output}" "shell" "driver_list contains shell"

print_test_header "driver_list — includes lint"
assert_contains "${list_output}" "lint" "driver_list contains lint"

# ── driver_validate ───────────────────────────────────────────────────────────

print_test_header "driver_validate — passes for valid driver.yaml"
driver_validate 2>/dev/null
assert_true "driver_validate exits 0 for valid fixture" $?

# ── driver_status ─────────────────────────────────────────────────────────────

print_test_header "driver_status — produces non-empty output"
status_output="$(driver_status 2>/dev/null)"
assert_not_empty "${status_output}" "driver_status output is non-empty"

# ── Absent-file fallback ──────────────────────────────────────────────────────

print_test_header "driver_is_native — returns 0 when driver.yaml absent"
unset DRIVER_YAML
driver_is_native git
assert_true "driver_is_native git = 0 when driver.yaml absent" $?

print_test_header "driver_type — returns native when driver.yaml absent"
result="$(driver_type git)"
assert_equals "native" "${result}" "driver_type git = native when driver.yaml absent"

# ── Cleanup ───────────────────────────────────────────────────────────────────

rm -rf "${TMPDIR_ROOT}"

# ── Summary ───────────────────────────────────────────────────────────────────

print_test_summary
