#!/usr/bin/env bash
# E2E Tests for /acp-pr (M86 task-313)
# Asserts gate delegation to acp.ci.sh — no duplicated gate logic.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
source "${PROJECT_ROOT}/tests/common.sh"

PR_SH="${PROJECT_ROOT}/agent/scripts/acp.pr.sh"
CMD="${PROJECT_ROOT}/agent/commands/acp.pr.md"

print_suite_header "/acp-pr — E2E Tests (M86)"

print_test_header "S1 — docs + wrappers"
assert_file_exists "${CMD}" "acp.pr.md"
assert_contains "$(head -15 "${CMD}")" "Agent Directive" "Agent Directive"
assert_file_exists "${PR_SH}" "acp.pr.sh"
assert_file_exists "${PROJECT_ROOT}/.cursor/commands/acp-pr.md" "cursor wrapper"
assert_file_exists "${PROJECT_ROOT}/.claude/commands/acp-pr.md" "claude wrapper"
assert_file_exists "${PROJECT_ROOT}/.opencode/commands/acp-pr.md" "opencode wrapper"
assert_file_exists "${PROJECT_ROOT}/.github/prompts/acp-pr.prompt.md" "prompt wrapper"
bash -n "${PR_SH}"
assert_true "acp.pr.sh bash -n" $?

print_test_header "S2 — no inline gate bodies (D2)"
if grep -E 'shellcheck --|npm test|npx tsx|run-e2e-tests' "${PR_SH}" | grep -v 'FORBIDDEN\|delegat\|acp.ci' >/dev/null; then
  assert_true "must not embed gate commands" 1
else
  assert_true "no embedded gate commands" 0
fi
assert_contains "$(cat "${PR_SH}")" "acp.ci.sh" "delegates to acp.ci.sh"

print_test_header "B1 — --help"
HELP="$(bash "${PR_SH}" --help 2>&1)"
assert_contains "${HELP}" "strict-local" "mentions strict-local"
assert_contains "${HELP}" "acp.ci.sh" "help mentions acp.ci.sh"

print_test_header "B2 — dry-run --skip-push delegates to ci dry-run"
OUT="$(bash "${PR_SH}" --dry-run --skip-push --skip-local 2>&1)"
assert_contains "${OUT}" "Skipping local gates" "skip-local path"
OUT2="$(bash "${PR_SH}" --dry-run --skip-push 2>&1)"
assert_contains "${OUT2}" "delegating to: acp.ci.sh" "delegates"
assert_contains "${OUT2}" "dry-run" "ci dry-run"

print_test_header "S3 — does not call acp.smoke.sh (D15)"
if grep -E 'acp\.smoke\.sh' "${PR_SH}" >/dev/null; then
  assert_true "acp.pr.sh must not call acp.smoke.sh" 1
else
  assert_true "no acp.smoke.sh in acp.pr.sh" 0
fi

print_test_header "S4 — pr.yml extras are empty no-ops (D11)"
if grep -E 'local_gates' "${PROJECT_ROOT}/agent/configurables/acp.configurables.yaml" >/dev/null; then
  assert_true "must not register local_gates in configurables" 1
else
  assert_true "no local_gates in acp.configurables.yaml" 0
fi
assert_file_exists "${PROJECT_ROOT}/agent/configurables/pr.yml" "pr.yml exists"
assert_contains "$(cat "${PROJECT_ROOT}/agent/templates/coderabbit.yaml.template")" "agent/memory/" "template memory filter"
assert_contains "$(cat "${PROJECT_ROOT}/agent/templates/coderabbit.yaml.template")" "agent/reports/" "template reports filter"

print_test_header "S5 — inline local_gates array fail-closed (D11)"
INLINE_PR="$(mktemp "${TMPDIR:-/tmp}/acp-pr-inline.XXXXXX.yml")"
printf '%s\n' 'local_gates: [ci-validate]' 'coderabbit_exclude_globs: []' > "${INLINE_PR}"
if ACP_PR_CONFIG="${INLINE_PR}" bash "${PR_SH}" --dry-run --skip-push --skip-local >/tmp/acp-pr-inline.out 2>&1; then INLINE_RC=0; else INLINE_RC=$?; fi
rm -f "${INLINE_PR}"
assert_equals "2" "${INLINE_RC}" "inline local_gates exit 2"
assert_contains "$(cat /tmp/acp-pr-inline.out)" "block list" "must be a block list"

print_test_header "S6 — extra local_gates dry-run prints extra step (FG-6)"
EXTRA_PR="$(mktemp "${TMPDIR:-/tmp}/acp-pr-extra.XXXXXX.yml")"
printf '%s\n' 'local_gates:' '  - ci-validate' 'coderabbit_exclude_globs: []' > "${EXTRA_PR}"
EXTRA_OUT="$(ACP_PR_CONFIG="${EXTRA_PR}" bash "${PR_SH}" --dry-run --skip-push 2>&1)"
rm -f "${EXTRA_PR}"
assert_contains "${EXTRA_OUT}" "extra step" "prints extra step"
assert_contains "${EXTRA_OUT}" "ci-validate" "names the extra gate"
assert_contains "${EXTRA_OUT}" "not verification" "FG-6 banner on extras"

print_suite_summary
