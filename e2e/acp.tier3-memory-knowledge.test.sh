#!/usr/bin/env bash
# E2E: M63 Tier 3 — memory/knowledge/workflow commands
# Behavioral + negative assertions (doc quality + memory path references)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${PROJECT_ROOT}/tests/common.sh"

COMMANDS_DIR="${PROJECT_ROOT}/agent/commands"

# Tier 3 commands (memory/knowledge/workflow) — excludes tier 2 package/project/version/prefs
TIER3_CMDS=(
  acp.decide acp.status acp.resume acp.feedback acp.report acp.update
  acp.memory-sync acp.pattern-sync acp.session-sync acp.carryover-query
  acp.cost-report acp.wiki-update acp.visualize
  acp.artifact-glossary acp.artifact-reference acp.artifact-research
  acp.clarification-address acp.clarification-capture acp.clarification-create
  acp.command-create acp.design-create acp.design-reference acp.pattern-create
  acp.task acp.task-create acp.rule-file-audit
)

assert_tier3_command_doc() {
  local cmd="$1"
  local file="${COMMANDS_DIR}/${cmd}.md"
  local content steps hint=""

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
  esac

  print_test_header "T3-${cmd}: command doc quality"
  assert_file_exists "${file}" "${cmd}.md exists"

  content="$(cat "${file}")"
  assert_contains "${content}" "## Steps" "${cmd} has Steps"
  assert_contains "${content}" "## Verification" "${cmd} has Verification"

  if [ -n "${hint}" ]; then
    assert_contains "${content}" "${hint}" "${cmd} references ${hint}"
  fi
}

print_suite_header "Tier 3 Memory/Knowledge — E2E Tests (M63)"

for cmd in "${TIER3_CMDS[@]}"; do
  assert_tier3_command_doc "${cmd}"
done

print_test_header "T3-memory: agent/memory files exist"
assert_file_exists "${PROJECT_ROOT}/agent/memory/sessions.md" "sessions.md"
assert_file_exists "${PROJECT_ROOT}/agent/memory/decisions.md" "decisions.md"
assert_file_exists "${PROJECT_ROOT}/agent/memory/patterns.md" "patterns.md"
assert_file_exists "${PROJECT_ROOT}/agent/memory/lessons.md" "lessons.md"

print_test_header "T3-negative: decide doc does not reference nonexistent path"
DECIDE_CONTENT="$(cat "${COMMANDS_DIR}/acp.decide.md")"
assert_not_contains "${DECIDE_CONTENT}" "agent/core/decisions.yml" "decide uses decisions.md not yml typo"

print_test_summary "acp.tier3-memory-knowledge.test.sh"
exit $?
