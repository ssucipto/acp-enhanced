#!/usr/bin/env bash
# E2E Tests for exec-host (M91 task-364)
# Dry-run / help / doctor only. No emulator, no KVM, no --create-avd.
# NOTE: Do NOT add set -e here. assert_* functions return exit code 1 on failure.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
source "${PROJECT_ROOT}/tests/common.sh"

EH_SH="${PROJECT_ROOT}/agent/scripts/acp.exec-host-ssh.sh"

print_suite_header "/acp-exec-host — E2E Tests (M91)"

print_test_header "S1 — orchestrator exists; ps1 not required on Darwin"
assert_file_exists "${EH_SH}" "acp.exec-host-ssh.sh"
assert_file_exists "${PROJECT_ROOT}/agent/scripts/acp.exec-host.windows-prepare.ps1" "windows-prepare.ps1"
assert_file_exists "${PROJECT_ROOT}/agent/wiki/exec-host.md" "exec-host wiki"
bash -n "${EH_SH}"
assert_true "acp.exec-host-ssh.sh bash -n" $?
if grep -E 'CONSUMER_|consumer-project' \
  "${PROJECT_ROOT}/agent/scripts/acp.exec-host-ssh.sh" \
  "${PROJECT_ROOT}/agent/scripts/acp.exec-host.windows-prepare.ps1" \
  "${PROJECT_ROOT}/agent/scripts/acp.exec-host.windows.ps1" \
  "${PROJECT_ROOT}/agent/scripts/acp.exec-host.windows-install.ps1" >/dev/null; then
  assert_true "must not embed consumer-project prefixes" 1
else
  assert_true "no consumer-project prefixes" 0
fi

print_test_header "B1 — help exit 0 + git bundle in usage"
HELP_OUT="$(bash "${EH_SH}" --help 2>&1)"
HELP_RC=$?
assert_equals "0" "${HELP_RC}" "help exit 0"
assert_contains "${HELP_OUT}" "Usage:" "help shows Usage"
assert_contains "${HELP_OUT}" "git bundle" "help mentions git bundle"

print_test_header "B2 — dry-run windows prints bundle, no secrets, no emulator"
DRY_OUT="$(bash "${EH_SH}" --dry-run --host windows 2>&1)"
DRY_RC=$?
assert_equals "0" "${DRY_RC}" "dry-run windows exit 0"
assert_contains "${DRY_OUT}" "git bundle" "dry-run prints git bundle"
assert_contains "${DRY_OUT}" "not verification" "FG-6 banner"
if echo "${DRY_OUT}" | grep -qE 'BEGIN OPENSSH|PRIVATE KEY|emulator -avd|--create-avd'; then
  assert_true "must not print secrets or start emulator" 1
else
  assert_true "no secrets or emulator flags" 0
fi
if echo "${DRY_OUT}" | grep -q 'assembleDebug'; then
  assert_true "must not plan assembleDebug" 1
else
  assert_true "no assembleDebug" 0
fi

print_test_header "B3 — unknown host fail-closed"
if bash "${EH_SH}" --host bogus --dry-run >/tmp/acp-eh-unk.out 2>&1; then UNK_RC=0; else UNK_RC=$?; fi
assert_equals "2" "${UNK_RC}" "unknown host exit 2"
assert_contains "$(cat /tmp/acp-eh-unk.out)" "unknown host" "unknown host message"

print_test_header "B4 — missing secret file exit 1 (paths only)"
if ACP_SECRET_FILES="no-such-acp-secret.env" bash "${EH_SH}" --doctor >/tmp/acp-eh-sec.out 2>&1; then SEC_RC=0; else SEC_RC=$?; fi
SEC_OUT="$(cat /tmp/acp-eh-sec.out)"
assert_equals "1" "${SEC_RC}" "missing secret exit 1"
assert_contains "${SEC_OUT}" "secret file missing" "reports missing path"
if echo "${SEC_OUT}" | grep -qE 'BEGIN |password='; then
  assert_true "must not print secret bytes" 1
else
  assert_true "no secret bytes in output" 0
fi

print_suite_summary
