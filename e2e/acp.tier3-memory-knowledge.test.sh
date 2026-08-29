#!/usr/bin/env bash
# E2E: M63 Tier 3 — memory/knowledge/workflow commands
# Behavioral assertions on ALL tier-3 command docs (not a static subset)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${PROJECT_ROOT}/tests/common.sh"

COMMANDS_DIR="${PROJECT_ROOT}/agent/commands"

# Tier 2 slugs — excluded from tier 3 loop (must match command-e2e-coverage.yaml)
is_tier2_slug() {
  case "$1" in
    package-install|package-publish|project-create|projects-restore \
      |version-check|version-update|version-check-for-updates \
      |preferences-create|preferences-get|preferences-set|preferences-show|preferences-validate)
      return 0 ;;
  esac
  return 1
}

assert_tier3_command_doc() {
  local cmd="$1"
  local file="${COMMANDS_DIR}/${cmd}.md"
  local content hint=""

  case "${cmd}" in
    acp.decide) hint="decisions.md" ;;
    acp.status) hint="progress.yaml" ;;
    acp.resume) hint="sessions" ;;
    acp.report) hint="agent/reports" ;;
    acp.update) hint="progress.yaml" ;;
    acp.memory-sync) hint="patterns.md" ;;
    acp.pattern-sync) hint="patterns.md" ;;
    acp.session-sync) hint="sessions" ;;
    acp.carryover-query) hint="audit-carryovers" ;;
    acp.cost-report) hint="ledger" ;;
    acp.wiki-update) hint="wiki" ;;
    acp.feedback) hint="feedback" ;;
    acp.task) hint="routing/tasks" ;;
    acp.handoff) hint="handoff" ;;
    acp.receive) hint="receive" ;;
    acp.commit) hint="sessions.md" ;;
    acp.audit) hint="agent/reports" ;;
    acp.sessions) hint="sessions" ;;
    acp.route) hint="routing/tasks" ;;
    acp.init) hint="progress.yaml" ;;
  esac

  print_test_header "T3-${cmd}: command doc quality"
  assert_file_exists "${file}" "${cmd}.md exists"

  content="$(cat "${file}")"
  assert_contains "${content}" "## Steps" "${cmd} has Steps"
  assert_contains "${content}" "## Verification" "${cmd} has Verification"
  echo "${content}" | grep -qi "agent directive"
  assert_true "${cmd} has Agent Directive" $?

  if [ -n "${hint}" ]; then
    assert_contains "${content}" "${hint}" "${cmd} references ${hint}"
  fi
}

print_suite_header "Tier 3 Memory/Knowledge — E2E Tests (M63)"

TIER3_COUNT=0
for _doc in "${COMMANDS_DIR}"/acp.*.md; do
  [ -e "${_doc}" ] || continue
  _base=$(basename "${_doc}")
  [ "${_base}" = "command.template.md" ] && continue
  cmd="${_base%.md}"
  slug="${cmd#acp.}"
  if is_tier2_slug "${slug}"; then
    continue
  fi
  TIER3_COUNT=$((TIER3_COUNT + 1))
  assert_tier3_command_doc "${cmd}"
done

print_test_header "T3-meta: all tier-3 commands exercised (expect 61)"
assert_equals "61" "${TIER3_COUNT}" "tier-3 command doc count"

print_test_header "T3-memory: agent/memory files exist"
assert_file_exists "${PROJECT_ROOT}/agent/memory/sessions.md" "sessions.md"
assert_file_exists "${PROJECT_ROOT}/agent/memory/decisions.md" "decisions.md"
assert_file_exists "${PROJECT_ROOT}/agent/memory/patterns.md" "patterns.md"
assert_file_exists "${PROJECT_ROOT}/agent/memory/lessons.md" "lessons.md"

print_test_header "T3-negative: decide doc does not reference nonexistent path"
DECIDE_CONTENT="$(cat "${COMMANDS_DIR}/acp.decide.md")"
assert_not_contains "${DECIDE_CONTENT}" "agent/core/decisions.yml" "decide uses decisions.md not yml typo"

print_test_header "T3-negative: status doc references progress.yaml"
assert_contains "$(cat "${COMMANDS_DIR}/acp.status.md")" "progress.yaml" "status references progress.yaml"

print_test_summary "acp.tier3-memory-knowledge.test.sh"
exit $?
