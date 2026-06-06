#!/usr/bin/env bash
# E2E Smoke Test: /acp-stakeholder-report command
# Verifies command doc structure, template, wrappers, and critical business rules.
# 15 assertions — RAG/blocker rule, metrics ≤4, anti-patterns, email subject, artefact naming.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$PROJECT_ROOT/tests/common.sh"

TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

CMD_FILE="$PROJECT_ROOT/agent/commands/acp.stakeholder-report.md"
PROMPT_FILE="$PROJECT_ROOT/.github/prompts/acp-stakeholder-report.prompt.md"
OPENCODE_FILE="$PROJECT_ROOT/.opencode/commands/acp-stakeholder-report.md"
TEMPLATE_FILE="$PROJECT_ROOT/agent/templates/stakeholder-report.template.md"

# ═══════════════════════════════════════════════════════════════
# 1. Command doc exists
# ═══════════════════════════════════════════════════════════════
print_test_header "acp.stakeholder-report.md: command doc exists"
if [[ -f "$CMD_FILE" ]]; then assert_true "command doc exists" 0; else assert_true "command doc exists" 1; fi

# ═══════════════════════════════════════════════════════════════
# 2. Agent Directive block
# ═══════════════════════════════════════════════════════════════
print_test_header "acp.stakeholder-report.md: Agent Directive block"
if grep -qi "agent directive" "$CMD_FILE"; then assert_true "has Agent Directive" 0; else assert_true "has Agent Directive" 1; fi

# ═══════════════════════════════════════════════════════════════
# 3. Scripts field
# ═══════════════════════════════════════════════════════════════
print_test_header "acp.stakeholder-report.md: Scripts field"
if grep -q '\*\*Scripts\*\*:' "$CMD_FILE"; then assert_true "has Scripts field" 0; else assert_true "has Scripts field" 1; fi

# ═══════════════════════════════════════════════════════════════
# 4. Verification Checklist
# ═══════════════════════════════════════════════════════════════
print_test_header "acp.stakeholder-report.md: Verification Checklist"
if grep -q '## Verification Checklist' "$CMD_FILE"; then assert_true "has Verification Checklist" 0; else assert_true "has Verification Checklist" 1; fi

# ═══════════════════════════════════════════════════════════════
# 5. RAG rule: not Green when blockers non-empty
# ═══════════════════════════════════════════════════════════════
print_test_header "acp.stakeholder-report.md: RAG rule — not Green when blockers"
if grep -q 'not Green.*current_blockers\|Minimum.*Amber\|never Green.*blockers' "$CMD_FILE"; then assert_true "RAG/blocker business rule present" 0; else assert_true "RAG/blocker business rule present" 1; fi

# ═══════════════════════════════════════════════════════════════
# 6. Auto-amber RAG rule
# ═══════════════════════════════════════════════════════════════
print_test_header "acp.stakeholder-report.md: auto-amber RAG rule"
if grep -q 'Minimum.*Amber\|🟡 Amber' "$CMD_FILE"; then assert_true "auto-amber rule present" 0; else assert_true "auto-amber rule present" 1; fi

# ═══════════════════════════════════════════════════════════════
# 7. Metrics hard limit ≤4
# ═══════════════════════════════════════════════════════════════
print_test_header "acp.stakeholder-report.md: metrics ≤4 hard limit"
if grep -q '2–4\|2-4\|≤4\|hard limit' "$CMD_FILE"; then assert_true "metrics hard limit documented" 0; else assert_true "metrics hard limit documented" 1; fi

# ═══════════════════════════════════════════════════════════════
# 8. Anti-patterns section
# ═══════════════════════════════════════════════════════════════
print_test_header "acp.stakeholder-report.md: anti-patterns section"
if grep -qi 'anti.pattern\|no task IDs\|task IDs' "$CMD_FILE"; then assert_true "anti-patterns present" 0; else assert_true "anti-patterns present" 1; fi

# ═══════════════════════════════════════════════════════════════
# 9. Artefact naming table
# ═══════════════════════════════════════════════════════════════
print_test_header "acp.stakeholder-report.md: artefact naming table"
if grep -q 'stakeholder-report-YYYY-MM-DD.md\|stakeholder-report-\*' "$CMD_FILE"; then assert_true "artefact naming present" 0; else assert_true "artefact naming present" 1; fi

# ═══════════════════════════════════════════════════════════════
# 10. Email subject line
# ═══════════════════════════════════════════════════════════════
print_test_header "acp.stakeholder-report.md: email subject line"
if grep -q 'Suggested email subject\|email subject' "$CMD_FILE"; then assert_true "email subject present" 0; else assert_true "email subject present" 1; fi

# ═══════════════════════════════════════════════════════════════
# 11. Severity column on blockers
# ═══════════════════════════════════════════════════════════════
print_test_header "acp.stakeholder-report.md: severity column on blockers"
if grep -q 'Severity.*Impact.*Mitigation\|Severity.*blocker' "$CMD_FILE"; then assert_true "severity column present" 0; else assert_true "severity column present" 1; fi

# ═══════════════════════════════════════════════════════════════
# 12. Prompt wrapper exists
# ═══════════════════════════════════════════════════════════════
print_test_header "wrapper: .github/prompts/acp-stakeholder-report.prompt.md"
if [[ -f "$PROMPT_FILE" ]]; then assert_true ".github/prompts wrapper exists" 0; else assert_true ".github/prompts wrapper exists" 1; fi

# ═══════════════════════════════════════════════════════════════
# 13. OpenCode wrapper exists
# ═══════════════════════════════════════════════════════════════
print_test_header "wrapper: .opencode/commands/acp-stakeholder-report.md"
if [[ -f "$OPENCODE_FILE" ]]; then assert_true ".opencode wrapper exists" 0; else assert_true ".opencode wrapper exists" 1; fi

# ═══════════════════════════════════════════════════════════════
# 14. Template exists with 9 sections
# ═══════════════════════════════════════════════════════════════
print_test_header "template: stakeholder-report.template.md exists with sections"
if [[ -f "$TEMPLATE_FILE" ]]; then
  tpl_sections=$(grep -cE '^## ' "$TEMPLATE_FILE" 2>/dev/null || echo 0)
  if [[ "$tpl_sections" -ge 8 ]]; then
    assert_true "template has $tpl_sections sections (≥8)" 0
  else
    assert_true "template has $tpl_sections sections (expected ≥8)" 1
  fi
else
  assert_true "template file exists" 1
fi

# ═══════════════════════════════════════════════════════════════
# 15. RAG/blocker business rule: automated grep test (G-048-02)
# ═══════════════════════════════════════════════════════════════
print_test_header "acp.stakeholder-report.md: RAG/blocker rule grep test"
if grep -qE 'not Green.*current_blockers|never Green.*blocker.*non-empty|Minimum.*Amber.*blocker' "$CMD_FILE"; then assert_true "RAG rule grep test pass" 0; else assert_true "RAG rule grep test pass" 1; fi

# ═══════════════════════════════════════════════════════════════
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  acp-stakeholder-report Smoke Test Results"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Tests run:    $TESTS_RUN"
echo "  Tests passed: $TESTS_PASSED"
echo "  Tests failed: $TESTS_FAILED"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
[[ "$TESTS_FAILED" -gt 0 ]] && exit 1
exit 0
