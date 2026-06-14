#!/usr/bin/env bash
# E2E Tests for Recurring Tasks Scheduler (M57 / v6.12.1)
#
# Validates:
#   - progress.yaml recurring_tasks block schema
#   - AGENTS.md/CLAUDE.md/copilot-instructions.md Step 4.5 presence
#   - constraints.yml hooks block
#   - progress.template.yaml recurring_tasks section
#   - acp.validate.md Step 2d
#
# NOTE: Do NOT add set -e here. assert_* functions return exit code 1 on failure.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${PROJECT_ROOT}/tests/common.sh"

PROGRESS="${PROJECT_ROOT}/agent/progress.yaml"
PROGRESS_TEMPLATE="${PROJECT_ROOT}/agent/progress.template.yaml"
CONSTRAINTS="${PROJECT_ROOT}/agent/core/constraints.yml"
AGENTS_MD="${PROJECT_ROOT}/AGENTS.md"
CLAUDE_MD="${PROJECT_ROOT}/CLAUDE.md"
COPILOT_MD="${PROJECT_ROOT}/.github/copilot-instructions.md"
VALIDATE_MD="${PROJECT_ROOT}/agent/commands/acp.validate.md"

# ── Structural Assertions (12) ────────────────────────────────────────────────

print_suite_header "Recurring Tasks Scheduler — E2E Tests"

# T1: progress.yaml has recurring_tasks block
print_test_header "T1 — progress.yaml has recurring_tasks block"
assert_contains "$(cat "${PROGRESS}")" "recurring_tasks:" "recurring_tasks block present"

# T2: All 5 default tasks present
print_test_header "T2 — All 5 default recurring tasks present"
assert_contains "$(cat "${PROGRESS}")" "weekly-code-review" "weekly-code-review task"
assert_contains "$(cat "${PROGRESS}")" "weekly-integrity-scan" "weekly-integrity-scan task"
assert_contains "$(cat "${PROGRESS}")" "pre-commit-rule-audit" "pre-commit-rule-audit task"
assert_contains "$(cat "${PROGRESS}")" "monthly-dependency-audit" "monthly-dependency-audit task"
assert_contains "$(cat "${PROGRESS}")" "quarterly-deep-scan" "quarterly-deep-scan task"

# T3: AGENTS.md has Step 4.5
print_test_header "T3 — AGENTS.md has Step 4.5 scheduled review check"
assert_contains "$(cat "${AGENTS_MD}")" "Step 4.5 — Scheduled Review Due Check" "Step 4.5 in AGENTS.md"

# T4: CLAUDE.md has Step 4.5
print_test_header "T4 — CLAUDE.md has Step 4.5 scheduled review check"
assert_contains "$(cat "${CLAUDE_MD}")" "Step 4.5 — Scheduled Review Due Check" "Step 4.5 in CLAUDE.md"

# T5: copilot-instructions.md has Step 4.5
print_test_header "T5 — copilot-instructions.md has Step 4.5 scheduled review check"
assert_contains "$(cat "${COPILOT_MD}")" "Step 4.5 — Scheduled Review Due Check" "Step 4.5 in copilot-instructions.md"

# T6: constraints.yml has hooks block
print_test_header "T6 — constraints.yml has hooks block with pre_commit"
assert_contains "$(cat "${CONSTRAINTS}")" "hooks:" "hooks block present"
assert_contains "$(cat "${CONSTRAINTS}")" "pre_commit:" "pre_commit hook section"
assert_contains "$(cat "${CONSTRAINTS}")" "pre-commit-rule-audit" "pre-commit-rule-audit hook"

# T7: progress.template.yaml has recurring_tasks section
print_test_header "T7 — progress.template.yaml has recurring_tasks section"
assert_contains "$(cat "${PROGRESS_TEMPLATE}")" "recurring_tasks:" "recurring_tasks in template"

# T8: acp.validate.md has Step 2d for recurring tasks
print_test_header "T8 — acp.validate.md has Step 2d recurring tasks validation"
assert_contains "$(cat "${VALIDATE_MD}")" "2d. Validate Recurring Tasks" "Step 2d in validate.md"

# T9: recurring_tasks has at least 4 entries
print_test_header "T9 — At least 4 recurring tasks defined"
# Count "  - id:" lines from recurring_tasks: to end of file (last block)
TASK_COUNT=$(awk '/^recurring_tasks:/{found=1} found && /^  - id:/{count++} END{print count+0}' "${PROGRESS}")
if [ "${TASK_COUNT}" -ge 4 ]; then
  echo "✓ At least 4 recurring tasks defined (${TASK_COUNT})"
else
  echo "✗ Expected >= 4, got ${TASK_COUNT}"
  exit 1
fi

# T10: All tasks have command field starting with /acp-
print_test_header "T10 — All tasks have /acp- command"
COMMAND_COUNT=$(awk '/^recurring_tasks:/{found=1} found && /command: \/acp-/{count++} END{print count+0}' "${PROGRESS}")
if [ "${COMMAND_COUNT}" -ge 5 ]; then
  echo "✓ At least 5 /acp- commands (${COMMAND_COUNT})"
else
  echo "✗ Expected >= 5, got ${COMMAND_COUNT}"
  exit 1
fi

# T11: At least one event-based task (trigger instead of frequency)
print_test_header "T11 — At least one event-based task (trigger: on-commit)"
assert_contains "$(cat "${PROGRESS}")" "trigger:" "Event trigger present"

# T12: Step 4.5 mentions progress.yaml as the source
print_test_header "T12 — Step 4.5 references agent/progress.yaml as source"
assert_contains "$(grep -A 2 "Step 4.5" "${AGENTS_MD}")" "progress.yaml" "progress.yaml referenced in Step 4.5"

# ── Summary ───────────────────────────────────────────────────────────────────

print_test_summary
