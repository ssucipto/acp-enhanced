#!/usr/bin/env bash
# E2E: M63 Tier 2 — package/project/version/preferences workflow commands
# Behavioral + negative assertions on command docs and backing scripts

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${PROJECT_ROOT}/tests/common.sh"

COMMANDS_DIR="${PROJECT_ROOT}/agent/commands"
SCRIPTS_DIR="${PROJECT_ROOT}/agent/scripts"

TIER2_CMDS=(
  acp.package-install
  acp.package-publish
  acp.project-create
  acp.projects-restore
  acp.version-check
  acp.version-check-for-updates
  acp.version-update
  acp.preferences-create
  acp.preferences-get
  acp.preferences-set
  acp.preferences-show
  acp.preferences-validate
)

assert_tier2_command_doc() {
  local cmd="$1"
  local file="${COMMANDS_DIR}/${cmd}.md"
  local content

  print_test_header "T2-${cmd}: command doc exists"
  assert_file_exists "${file}" "${cmd}.md exists"

  content="$(cat "${file}")"
  assert_contains "${content}" "## Steps" "${cmd} has Steps section"
  assert_contains "${content}" "## Verification" "${cmd} has Verification section"
  assert_contains "${content}" "Agent Directive" "${cmd} has Agent Directive"
}

print_suite_header "Tier 2 Workflow — E2E Tests (M63)"

for cmd in "${TIER2_CMDS[@]}"; do
  assert_tier2_command_doc "${cmd}"
done

print_test_header "T2-script: acp.package-publish.sh syntax"
bash -n "${SCRIPTS_DIR}/acp.package-publish.sh"
assert_true "acp.package-publish.sh bash -n" $?

print_test_header "T2-script: acp.projects-restore.sh syntax"
bash -n "${SCRIPTS_DIR}/acp.projects-restore.sh"
assert_true "acp.projects-restore.sh bash -n" $?

print_test_header "T2-script: acp.preferences.sh syntax"
bash -n "${SCRIPTS_DIR}/acp.preferences.sh"
assert_true "acp.preferences.sh bash -n" $?

print_test_header "T2-negative: version-check fails without AGENTS.md or AGENT.md"
TMPDIR_ROOT="$(mktemp -d)"
(
  cd "${TMPDIR_ROOT}"
  out="$(bash "${SCRIPTS_DIR}/acp.version-check.sh" 2>&1 || true)"
  echo "${out}" | grep -qi "not found\|error\|AGENT"
)
assert_true "version-check fails in empty directory" $?
rm -rf "${TMPDIR_ROOT}"

print_test_summary "acp.tier2-workflow.test.sh"
exit $?
