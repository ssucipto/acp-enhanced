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

print_test_header "B6 — help documents host values (M91)"
assert_contains "${HELP_OUT}" "github|windows|local" "help documents host values"

print_test_header "B7 — missing smoke.yml is not configured (D16)"
MISSFILE_OUT="$(ACP_SMOKE_CONFIG="/tmp/acp-smoke-missing-$$.yml" bash "${SMOKE_SH}" 2>&1)"
MISSFILE_RC=$?
assert_equals "2" "${MISSFILE_RC}" "missing file exit 2"
assert_contains "${MISSFILE_OUT}" "not configured" "missing file prints not configured"

print_test_header "B8 — unknown option is not the unconfigured contract (FG-3)"
if bash "${SMOKE_SH}" --bogus >/tmp/acp-smoke-unk.out 2>&1; then UNK_RC=0; else UNK_RC=$?; fi
UNK_OUT="$(cat /tmp/acp-smoke-unk.out)"
assert_equals "2" "${UNK_RC}" "unknown option fail-closed"
assert_contains "${UNK_OUT}" "unknown option" "prints unknown option"
if echo "${UNK_OUT}" | grep -q 'not configured'; then
  assert_true "unknown option must not print not configured" 1
else
  assert_true "unknown option does not collide with not configured" 0
fi

print_test_header "B9 — configured dry-run does not exec runner (FG-6)"
SENTINEL="$(mktemp "${TMPDIR:-/tmp}/acp-smoke-sent.XXXXXX")"
rm -f "${SENTINEL}"
RUNNER="$(mktemp "${TMPDIR:-/tmp}/acp-smoke-runner.XXXXXX.sh")"
printf '#!/bin/sh\ntouch "%s"\n' "${SENTINEL}" > "${RUNNER}"
chmod +x "${RUNNER}"
CFG_DRY="$(mktemp "${TMPDIR:-/tmp}/acp-smoke-cfg.XXXXXX.yml")"
printf 'runner: "%s"\n' "${RUNNER}" > "${CFG_DRY}"
DRYCFG_OUT="$(ACP_SMOKE_CONFIG="${CFG_DRY}" bash "${SMOKE_SH}" --dry-run 2>&1)"
DRYCFG_RC=$?
if [[ -f "${SENTINEL}" ]]; then
  assert_true "dry-run must not exec runner" 1
else
  assert_true "dry-run did not create sentinel" 0
fi
assert_equals "0" "${DRYCFG_RC}" "configured dry-run exit 0"
assert_contains "${DRYCFG_OUT}" "not verification" "FG-6 banner"
rm -f "${CFG_DRY}" "${RUNNER}" "${SENTINEL}"

print_test_header "B10 — catalog lists /acp-smoke"
assert_contains "$(sed -n '/Workflow \/ Quality/,/Task \& Project/p' "${PROJECT_ROOT}/agent/scripts/acp.common.sh")" "/acp-smoke" "common.sh lists /acp-smoke"

print_test_header "B11 — dry-run host windows prints bundle, not assembleDebug"
if bash "${SMOKE_SH}" --dry-run --host windows >/tmp/acp-smoke-host.out 2>&1; then HOST_RC=0; else HOST_RC=$?; fi
HOST_OUT="$(cat /tmp/acp-smoke-host.out)"
assert_equals "2" "${HOST_RC}" "unconfigured host dry-run still exit 2"
assert_contains "${HOST_OUT}" "git bundle" "prints git bundle plan"
assert_contains "${HOST_OUT}" "not configured" "still unconfigured"
if echo "${HOST_OUT}" | grep -q 'assembleDebug'; then
  assert_true "must not plan assembleDebug" 1
else
  assert_true "no assembleDebug on Darwin dry-run" 0
fi

print_test_header "B12 — remote requires host local"
if bash "${SMOKE_SH}" --remote >/tmp/acp-smoke-remote.out 2>&1; then REM_RC=0; else REM_RC=$?; fi
assert_equals "2" "${REM_RC}" "remote without local fail-closed"
assert_contains "$(cat /tmp/acp-smoke-remote.out)" "requires" "remote requires local host"

print_test_header "B13 — ACP_EXEC_HOST without --host still plans that host"
if ACP_EXEC_HOST=local bash "${SMOKE_SH}" --dry-run >/tmp/acp-smoke-envhost.out 2>&1; then ENVH_RC=0; else ENVH_RC=$?; fi
ENVH_OUT="$(cat /tmp/acp-smoke-envhost.out)"
assert_equals "2" "${ENVH_RC}" "unconfigured env-host dry-run still exit 2"
assert_contains "${ENVH_OUT}" "plan host=local" "ACP_EXEC_HOST selects local"
assert_contains "${ENVH_OUT}" "not configured" "still unconfigured"

print_suite_summary
