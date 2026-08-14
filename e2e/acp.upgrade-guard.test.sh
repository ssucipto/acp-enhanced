#!/usr/bin/env bash
# E2E Tests for acp.upgrade-guard.sh (M86 task-315)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
source "${PROJECT_ROOT}/tests/common.sh"

UG="${PROJECT_ROOT}/agent/scripts/acp.upgrade-guard.sh"
DELTA="${PROJECT_ROOT}/agent/upstream-delta.yml"

print_suite_header "/acp-upgrade-guard — E2E Tests (M86)"

print_test_header "S1 — files exist"
assert_file_exists "${UG}" "upgrade-guard script"
assert_file_exists "${DELTA}" "upstream-delta.yml"
assert_file_exists "${PROJECT_ROOT}/agent/upstream-delta.template.yml" "template"
assert_file_exists "${PROJECT_ROOT}/docs/acp-fork-upgrade-checklist.md" "fork checklist"
bash -n "${UG}"
assert_true "bash -n upgrade-guard" $?

print_test_header "B1 — live register PASSes"
if bash "${UG}" >/tmp/ug-live.out 2>&1; then UG_RC=0; else UG_RC=$?; fi
assert_equals "0" "${UG_RC}" "live guard exit 0"
assert_contains "$(cat /tmp/ug-live.out)" "PASS" "PASS banner"
assert_contains "$(cat /tmp/ug-live.out)" "executed_steps:" "executed_steps"

print_test_header "B2 — missing sentinel HARD fails (P-UG-1)"
TMPD="$(mktemp -d)"
cp "${DELTA}" "${TMPD}/upstream-delta.yml"
# Break one sentinel string in a temp copy of routing via fake register pointing at a temp file
echo 'hello' > "${TMPD}/fake.yml"
cat > "${TMPD}/upstream-delta.yml" <<EOF
acp_core_version: 0.0.0
collisions:
  - path: fake.yml
    sentinel: "THIS_SENTINEL_DOES_NOT_EXIST_M86"
local_only: {}
EOF
# Run guard with REGISTER override by cwd trick — script hardcodes path.
# Use a subshell with a patched copy in a temp repo layout:
mkdir -p "${TMPD}/agent/scripts" "${TMPD}/agent"
cp "${UG}" "${TMPD}/agent/scripts/"
cp "${TMPD}/upstream-delta.yml" "${TMPD}/agent/"
echo 'nope' > "${TMPD}/fake.yml"
# Fix path in delta to be relative to TMPD
cat > "${TMPD}/agent/upstream-delta.yml" <<EOF
acp_core_version: 0.0.0
collisions:
  - path: fake.yml
    sentinel: "THIS_SENTINEL_DOES_NOT_EXIST_M86"
local_only: {}
EOF
if ( cd "${TMPD}" && bash agent/scripts/acp.upgrade-guard.sh >/tmp/ug-fail.out 2>&1 ); then FAIL_RC=0; else FAIL_RC=$?; fi
assert_true "missing sentinel exits non-zero" "$([ "${FAIL_RC}" -ne 0 ] && echo 0 || echo 1)"
assert_contains "$(cat /tmp/ug-fail.out)" "REVERTED" "REVERTED row"
rm -rf "${TMPD}"

print_suite_summary
