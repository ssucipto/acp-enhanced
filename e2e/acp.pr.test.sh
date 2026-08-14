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

print_suite_summary
