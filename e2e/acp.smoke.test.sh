#!/usr/bin/env bash
# E2E Tests for /acp-smoke (M90 task-357)
# Fail-closed stub: unconfigured exits 2. No device, no network.
# NOTE: Do NOT add set -e here. assert_* functions return exit code 1 on failure.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
source "${PROJECT_ROOT}/tests/common.sh"

SMOKE_SH="${PROJECT_ROOT}/agent/scripts/acp.smoke.sh"
CMD="${PROJECT_ROOT}/agent/commands/acp.smoke.md"

print_suite_header "/acp-smoke — E2E Tests (M90)"

print_test_header "S1 — docs + wrappers"
assert_file_exists "${CMD}" "acp.smoke.md"
assert_contains "$(head -15 "${CMD}")" "Agent Directive" "Agent Directive"
assert_file_exists "${SMOKE_SH}" "acp.smoke.sh"
assert_file_exists "${PROJECT_ROOT}/.cursor/commands/acp-smoke.md" "cursor wrapper"
assert_file_exists "${PROJECT_ROOT}/.claude/commands/acp-smoke.md" "claude wrapper"
assert_file_exists "${PROJECT_ROOT}/.opencode/commands/acp-smoke.md" "opencode wrapper"
assert_file_exists "${PROJECT_ROOT}/.github/prompts/acp-smoke.prompt.md" "prompt wrapper"
bash -n "${SMOKE_SH}"
assert_true "acp.smoke.sh bash -n" $?

print_test_header "B1 — --help exit 0 + usage text"
HELP_OUT="$(bash "${SMOKE_SH}" --help 2>&1)"
HELP_RC=$?
assert_equals "0" "${HELP_RC}" "--help exit 0"
assert_contains "${HELP_OUT}" "Usage:" "help shows Usage"
assert_contains "${HELP_OUT}" "e2e-smoke" "help distinguishes e2e-smoke"
assert_contains "${HELP_OUT}" "Print runner status" "help documents doctor"

print_test_header "B2 — unconfigured default exits 2, not configured, no PASS"
DEFAULT_OUT="$(bash "${SMOKE_SH}" 2>&1)"
DEFAULT_RC=$?
assert_equals "2" "${DEFAULT_RC}" "unconfigured exit 2"
assert_contains "${DEFAULT_OUT}" "not configured" "prints not configured"
if echo "${DEFAULT_OUT}" | grep -q 'PASS'; then
  assert_true "must not print PASS when unconfigured" 1
else
  assert_true "no PASS when unconfigured" 0
fi

print_test_header "B3 — --dry-run unconfigured is not PASS (FG-2/FG-6)"
DRY_OUT="$(bash "${SMOKE_SH}" --dry-run 2>&1)"
DRY_RC=$?
assert_equals "2" "${DRY_RC}" "--dry-run unconfigured exit 2"
assert_contains "${DRY_OUT}" "not configured" "dry-run still says not configured"
if echo "${DRY_OUT}" | grep -q 'PASS'; then
  assert_true "dry-run must not PASS when unconfigured" 1
else
  assert_true "dry-run is not PASS" 0
fi

print_test_header "B4 — --doctor fail-closed when unconfigured"
DOC_OUT="$(bash "${SMOKE_SH}" --doctor 2>&1)"
DOC_RC=$?
assert_equals "2" "${DOC_RC}" "--doctor unconfigured exit 2"
assert_contains "${DOC_OUT}" "not configured" "doctor prints not configured"
assert_contains "${DOC_OUT}" "runner:" "doctor prints runner status"

print_test_header "B5 — configured but missing runner exits 1"
CFG="$(mktemp "${TMPDIR:-/tmp}/acp-smoke-cfg.XXXXXX.yml")"
printf 'runner: "/no/such/acp-smoke-runner-%s"\n' "$$" > "${CFG}"
MISS_OUT="$(ACP_SMOKE_CONFIG="${CFG}" bash "${SMOKE_SH}" --doctor 2>&1)"
MISS_RC=$?
rm -f "${CFG}"
assert_equals "1" "${MISS_RC}" "configured-missing doctor exit 1"
assert_contains "${MISS_OUT}" "runner exists: no" "doctor reports missing runner"

print_test_header "B6 — help does not list --host"
if echo "${HELP_OUT}" | grep -E '(^|[[:space:]])--host([[:space:]]|$)' >/dev/null; then
  assert_true "must not list --host" 1
else
  assert_true "no --host flag in help" 0
fi

print_suite_summary
