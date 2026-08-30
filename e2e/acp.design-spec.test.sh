#!/usr/bin/env bash
# E2E Smoke Test: /acp-design-spec command
# Verifies command doc structure, wrappers, template, and framework integration.
# 12 assertions — no real codebase needed (smoke test only).
#
# NOTE: Do NOT add set -e here. assert_* functions return exit code 1 on failure by design.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$PROJECT_ROOT/tests/common.sh"

TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

CMD_FILE="$PROJECT_ROOT/agent/commands/acp.design-spec.md"
PROMPT_FILE="$PROJECT_ROOT/.github/prompts/acp-design-spec.prompt.md"
OPENCODE_FILE="$PROJECT_ROOT/.opencode/commands/acp-design-spec.md"
TEMPLATE_FILE="$PROJECT_ROOT/agent/templates/design-spec.template.md"

# ═══════════════════════════════════════════════════════════════════════════════
# Assertion 1: Command doc exists
# ═══════════════════════════════════════════════════════════════════════════════
print_test_header "acp.design-spec.md: command doc exists"
if [[ -f "$CMD_FILE" ]]; then
  assert_true "acp.design-spec.md exists" 0
else
  assert_true "acp.design-spec.md exists" 1
fi

# ═══════════════════════════════════════════════════════════════════════════════
# Assertion 2: Agent Directive block present
# ═══════════════════════════════════════════════════════════════════════════════
print_test_header "acp.design-spec.md: contains Agent Directive block"
if grep -qi "agent directive" "$CMD_FILE"; then
  assert_true "has Agent Directive block" 0
else
  assert_true "has Agent Directive block" 1
fi

# ═══════════════════════════════════════════════════════════════════════════════
# Assertion 3: Scripts field present
# ═══════════════════════════════════════════════════════════════════════════════
print_test_header "acp.design-spec.md: contains Scripts field"
if grep -q '\*\*Scripts\*\*:' "$CMD_FILE"; then
  assert_true "has Scripts field" 0
else
  assert_true "has Scripts field" 1
fi

# ═══════════════════════════════════════════════════════════════════════════════
# Assertion 4: Verification Checklist present
# ═══════════════════════════════════════════════════════════════════════════════
print_test_header "acp.design-spec.md: contains Verification Checklist"
if grep -q '## Verification Checklist' "$CMD_FILE"; then
  assert_true "has Verification Checklist" 0
else
  assert_true "has Verification Checklist" 1
fi

# ═══════════════════════════════════════════════════════════════════════════════
# Assertion 5: Report Structure lists §1–§19
# ═══════════════════════════════════════════════════════════════════════════════
print_test_header "acp.design-spec.md: Report Structure has §1–§19"
section_count=$(grep -cE '^## [0-9]+\.' "$CMD_FILE" 2>/dev/null || echo 0)
if [[ "$section_count" -ge 17 ]]; then
  assert_true "has ≥17 report sections (found $section_count)" 0
else
  assert_true "has ≥17 report sections (found $section_count)" 1
fi

# ═══════════════════════════════════════════════════════════════════════════════
# Assertion 6: Distinction from /acp-design-create
# ═══════════════════════════════════════════════════════════════════════════════
print_test_header "acp.design-spec.md: distinguishes from /acp-design-create"
if grep -q 'Distinction From' "$CMD_FILE"; then
  assert_true "has design-create distinction table" 0
else
  assert_true "has design-create distinction table" 1
fi

# ═══════════════════════════════════════════════════════════════════════════════
# Assertion 7: .github/prompts wrapper exists
# ═══════════════════════════════════════════════════════════════════════════════
print_test_header "wrapper: .github/prompts/acp-design-spec.prompt.md exists"
if [[ -f "$PROMPT_FILE" ]]; then
  assert_true ".github/prompts wrapper exists" 0
else
  assert_true ".github/prompts wrapper exists" 1
fi

# ═══════════════════════════════════════════════════════════════════════════════
# Assertion 8: .opencode/commands wrapper exists
# ═══════════════════════════════════════════════════════════════════════════════
print_test_header "wrapper: .opencode/commands/acp-design-spec.md exists"
if [[ -f "$OPENCODE_FILE" ]]; then
  assert_true ".opencode wrapper exists" 0
else
  assert_true ".opencode wrapper exists" 1
fi

# ═══════════════════════════════════════════════════════════════════════════════
# Assertion 9: Template file exists
# ═══════════════════════════════════════════════════════════════════════════════
print_test_header "template: agent/templates/design-spec.template.md exists"
if [[ -f "$TEMPLATE_FILE" ]]; then
  assert_true "template file exists" 0
else
  assert_true "template file exists" 1
fi

# ═══════════════════════════════════════════════════════════════════════════════
# Assertion 10: Template has all 19 sections
# ═══════════════════════════════════════════════════════════════════════════════
print_test_header "template: contains all 19 sections"
if [[ -f "$TEMPLATE_FILE" ]]; then
  tpl_sections=$(grep -cE '^## [0-9]+\.' "$TEMPLATE_FILE" 2>/dev/null || echo 0)
  if [[ "$tpl_sections" -eq 19 ]]; then
    assert_true "template has 19 sections" 0
  else
    assert_true "template has 19 sections (found $tpl_sections)" 1
  fi
else
  assert_true "template has 19 sections (file missing)" 1
fi

# ═══════════════════════════════════════════════════════════════════════════════
# Assertion 11: No consumer-project hardcoded paths in command doc
# ═══════════════════════════════════════════════════════════════════════════════
print_test_header "acp.design-spec.md: no hardcoded consumer-project paths"
# The command should not contain literal consumer-project project paths as the ONLY option
# (it may mention them in stack detection examples)
consumer_project_paths=$(grep -c "frontend/store/\|backend/server.py" "$CMD_FILE" 2>/dev/null || echo 0)
if [[ "$consumer_project_paths" -le 2 ]]; then
  assert_true "consumer-project paths are examples only (found $consumer_project_paths refs)" 0
else
  assert_true "consumer-project paths are examples only (found $consumer_project_paths refs)" 1
fi

# ═══════════════════════════════════════════════════════════════════════════════
# Assertion 12: Stack detection table present
# ═══════════════════════════════════════════════════════════════════════════════
print_test_header "acp.design-spec.md: has stack-agnostic detection table"
if grep -q 'Stack detection\|stack.agnostic\|Common paths\|Detect' "$CMD_FILE"; then
  assert_true "has stack detection instructions" 0
else
  assert_true "has stack detection instructions" 1
fi

# ═══════════════════════════════════════════════════════════════════════════════
# Summary
# ═══════════════════════════════════════════════════════════════════════════════
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  acp-design-spec Smoke Test Results"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Tests run:    $TESTS_RUN"
echo "  Tests passed: $TESTS_PASSED"
echo "  Tests failed: $TESTS_FAILED"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [[ "$TESTS_FAILED" -gt 0 ]]; then
  exit 1
fi
exit 0
