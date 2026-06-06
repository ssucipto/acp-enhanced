---
id: route-120
title: "E2E smoke test for acp-stakeholder-report — RAG/blocker rule + anti-patterns"
task_type: e2e-test-write
milestone: M52
complexity: medium
executor: copilot
context_required:
  - agent/commands/acp.stakeholder-report.md
  - agent/patterns/local.e2e-testing.md
  - e2e/acp.design-spec.test.sh
files_affected:
  - e2e/acp.stakeholder-report.test.sh
tokens_est: 400
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-06
completed:
override_reason:
---

# Route 120: E2E Smoke Test — Stakeholder Report

## Objective

Create `e2e/acp.stakeholder-report.test.sh` verifying command doc structure, template, wrappers, and the critical RAG/blocker business rule.

## Context

Per feedback-006 §5 (E2E smoke test), the test must verify v1.1.0-specific hardening: auto-amber RAG rule, metrics ≤4, anti-patterns list, email subject, artefact naming table.

## Changes

### Create `e2e/acp.stakeholder-report.test.sh`

Test assertions (14 items):

1. **Command doc exists**: `agent/commands/acp.stakeholder-report.md`
2. **Agent Directive**: Contains `🤖 Agent Directive` block
3. **Scripts field**: Contains `Scripts:` field
4. **Verification Checklist**: Contains `## Verification Checklist`
5. **RAG rule documented**: Contains "not Green" / "current_blockers" RAG rule
6. **Auto-amber rule**: Contains "Minimum 🟡 Amber" or equivalent
7. **Metrics hard limit**: Contains "2–4" and "hard limit" or "≤4"
8. **Anti-patterns section**: Contains "Anti-patterns" or task-ID filter reference
9. **Artefact naming table**: Contains "stakeholder-report-YYYY-MM-DD.md"
10. **Email subject**: Contains "Suggested email subject" or "email subject"
11. **Severity column**: Contains "Severity" on blockers
12. **Wrapper parity**: `.github/prompts/acp-stakeholder-report.prompt.md` exists
13. **Wrapper parity**: `.opencode/commands/acp-stakeholder-report.md` exists
14. **Template exists**: `agent/templates/stakeholder-report.template.md` with 9 sections
15. **RAG/blocker business rule**: Command doc contains "not Green when `current_blockers` non-empty" or "Minimum 🟡 Amber" (automated grep test per feedback-006 §5 P1 item 11)

### Test structure

- Follow `local.e2e-testing.md` conventions
- `set -euo pipefail` with ERR trap (not for assert functions)
- macOS BSD sed compatible
- Pure bash, no external deps
- Colored output (green ✅ / red ❌)
- Exit code 0 on all pass, 1 on any failure

## Verification

- [ ] Test file exists at `e2e/acp.stakeholder-report.test.sh`
- [ ] All 14 assertions defined
- [ ] `bash e2e/acp.stakeholder-report.test.sh` passes
- [ ] RAG/blocker business rule explicitly verified (not just text search)
- [ ] Metrics ≤4 hard limit verified in command doc
