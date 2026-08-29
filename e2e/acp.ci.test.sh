#!/usr/bin/env bash
# E2E Tests for /acp-ci (M86 task-311)
# FG contracts: unknown/empty fail-closed; dry-run ≠ verification; real static execution.
# NOTE: Do NOT add set -e here. assert_* functions return exit code 1 on failure.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${PROJECT_ROOT}/tests/common.sh"

CI_SH="${PROJECT_ROOT}/agent/scripts/acp.ci.sh"
CMD_FILE="${PROJECT_ROOT}/agent/commands/acp.ci.md"

print_suite_header "/acp-ci — E2E Tests (M86)"

print_test_header "S1 — command doc + scripts exist"
assert_file_exists "${CMD_FILE}" "acp.ci.md exists"
assert_contains "$(head -20 "${CMD_FILE}")" "Agent Directive" "Agent Directive header"
assert_file_exists "${CI_SH}" "acp.ci.sh exists"
assert_file_exists "${PROJECT_ROOT}/agent/scripts/acp.ci-steps.sh" "acp.ci-steps.sh exists (P-PATH-1)"
bash -n "${CI_SH}"
assert_true "acp.ci.sh passes bash -n" $?

print_test_header "B1 — --help / --doctor exit 0, doctor runs no gates"
HELP_OUT="$(bash "${CI_SH}" --help 2>&1)"
HELP_RC=$?
assert_equals "0" "${HELP_RC}" "--help exit 0"
assert_contains "${HELP_OUT}" "DEFAULT" "help documents default fast tier"
assert_contains "${HELP_OUT}" "CI-equivalent" "help documents full tier cost"

DOC_OUT="$(bash "${CI_SH}" --doctor 2>&1)"
DOC_RC=$?
assert_equals "0" "${DOC_RC}" "--doctor exit 0"
assert_contains "${DOC_OUT}" "runs no gates" "doctor states no gates"
assert_contains "${DOC_OUT}" "validate-ts" "doctor lists steps"

print_test_header "B2 — --only unknown → non-zero (FG-4)"
UNK_OUT="$(bash "${CI_SH}" --only bogus-step-id 2>&1 || true)"
UNK_RC=$?
# capture rc without set -e issues
if bash "${CI_SH}" --only bogus-step-id >/tmp/acp-ci-unk.out 2>&1; then UNK_RC=0; else UNK_RC=$?; fi
assert_true "--only bogus exits non-zero" "$([ "${UNK_RC}" -ne 0 ] && echo 0 || echo 1)"
assert_contains "$(cat /tmp/acp-ci-unk.out)" "unknown step" "unknown step message"

print_test_header "B3 — empty --only refuse PASS (FG-2/FG-7)"
if bash "${CI_SH}" --only '' >/tmp/acp-ci-empty.out 2>&1; then EMPTY_RC=0; else EMPTY_RC=$?; fi
assert_true "empty --only exits non-zero" "$([ "${EMPTY_RC}" -ne 0 ] && echo 0 || echo 1)"
assert_contains "$(cat /tmp/acp-ci-empty.out)" "empty --only" "empty plan message"

print_test_header "B4 — --dry-run lists steps, executes nothing (FG-6)"
DRY_OUT="$(bash "${CI_SH}" --static --dry-run 2>&1)"
DRY_RC=$?
assert_equals "0" "${DRY_RC}" "dry-run exit 0"
assert_contains "${DRY_OUT}" "dry-run" "dry-run banner"
assert_contains "${DRY_OUT}" "executed_steps: 0" "dry-run executed_steps 0"
assert_contains "${DRY_OUT}" "ci-validate" "dry-run plans ci-validate"

print_test_header "B5 — real --only npm-test execution (not dry-run)"
# Prefer a cheap gate that does not need system PyYAML
if bash "${CI_SH}" --only npm-test >/tmp/acp-ci-npm.out 2>&1; then NPM_RC=0; else NPM_RC=$?; fi
NPM_OUT="$(cat /tmp/acp-ci-npm.out)"
assert_contains "${NPM_OUT}" "executed_steps:" "reports executed_steps"
assert_contains "${NPM_OUT}" "npm-test" "ran npm-test"
# Allow PASS or FAIL depending on workspace; require real execution count ≥1
assert_contains "${NPM_OUT}" "executed_steps: 1" "exactly one step executed"
assert_true "npm-test path executed (rc 0 or 1)" "$([ "${NPM_RC}" -eq 0 ] || [ "${NPM_RC}" -eq 1 ]; echo $?)"

print_test_header "B6 — output_contains fail even when exit 0 (FG-5)"
TMPCFG="$(mktemp "${TMPDIR:-/tmp}/acp-ci-cfg.XXXXXX.yml")"
cat > "${TMPCFG}" <<'EOF'
workflow: .github/workflows/ci.yaml
node_ci_version: "20"
tiers:
  static:
    - echo-ok
  fast:
    - echo-ok
  full:
    - echo-ok
steps:
  echo-ok:
    description: "stub that exits 0 without required substring"
    command: echo-ok
    ci_job: validate
    cost_rank: 1
    ci_rank: 1
    tools: [bash]
    output_contains: ["REQUIRED_MARKER_M86"]
EOF
TMPSTEPS="$(mktemp "${TMPDIR:-/tmp}/acp-ci-steps.XXXXXX.sh")"
cat > "${TMPSTEPS}" <<'EOF'
ci_run_step() {
  echo "hello without marker"
  return 0
}
EOF
if ACP_CI_CONFIG="${TMPCFG}" ACP_CI_STEPS_LIB="${TMPSTEPS}" bash "${CI_SH}" --only echo-ok >/tmp/acp-ci-outc.out 2>&1; then OUTC_RC=0; else OUTC_RC=$?; fi
assert_true "output_contains miss exits non-zero" "$([ "${OUTC_RC}" -ne 0 ] && echo 0 || echo 1)"
assert_contains "$(cat /tmp/acp-ci-outc.out)" "missing required substring" "FG-5 message"
rm -f "${TMPCFG}" "${TMPSTEPS}"

print_test_header "B7 — soft SKIP when optional tool missing (FG-2 banner)"
TMPCFG2="$(mktemp "${TMPDIR:-/tmp}/acp-ci-cfg2.XXXXXX.yml")"
cat > "${TMPCFG2}" <<'EOF'
workflow: .github/workflows/ci.yaml
node_ci_version: "20"
tiers:
  static:
    - soft-tool
  fast:
    - soft-tool
  full:
    - soft-tool
steps:
  soft-tool:
    description: "requires missing optional binary"
    command: soft-tool
    ci_job: supply-chain
    cost_rank: 1
    ci_rank: 1
    tools: [definitely-missing-m86-tool]
    allow_skip: true
    output_contains: []
EOF
TMPSTEPS2="$(mktemp "${TMPDIR:-/tmp}/acp-ci-steps2.XXXXXX.sh")"
echo 'ci_run_step() { return 0; }' > "${TMPSTEPS2}"
if ACP_CI_CONFIG="${TMPCFG2}" ACP_CI_STEPS_LIB="${TMPSTEPS2}" bash "${CI_SH}" --only soft-tool >/tmp/acp-ci-skip.out 2>&1; then SKIP_RC=0; else SKIP_RC=$?; fi
SKIP_BODY="$(cat /tmp/acp-ci-skip.out)"
assert_contains "${SKIP_BODY}" "SKIP" "SKIP row present"
assert_true "all-SKIP does not claim full PASS" "$([ "${SKIP_RC}" -ne 0 ] && echo 0 || echo 1)"
if echo "${SKIP_BODY}" | grep -q '\[ACP CI\] PASS |'; then
  assert_true "must not claim full PASS on all-SKIP" 1
else
  assert_true "no full PASS on all-SKIP" 0
fi
rm -f "${TMPCFG2}" "${TMPSTEPS2}"

print_test_header "B9 — --only smoke is unknown (D15, not e2e-smoke)"
if bash "${CI_SH}" --only smoke >/tmp/acp-ci-only-smoke.out 2>&1; then SMOKEONLY_RC=0; else SMOKEONLY_RC=$?; fi
assert_true "--only smoke exits non-zero" "$([ "${SMOKEONLY_RC}" -ne 0 ] && echo 0 || echo 1)"
assert_contains "$(cat /tmp/acp-ci-only-smoke.out)" "unknown step" "smoke is not a ci step id"

print_suite_summary
