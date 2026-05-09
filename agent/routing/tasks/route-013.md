---
id: route-013
title: audit-008 — feedback-001 knowledge preservation protocol fixes
task_type: command-doc-update
milestone: M38
complexity: medium
executor: Persona A (Copilot)
context_required: [agent/feedback/feedback-001-proactive-commit-and-knowledge-preservation.md, agent/memory/lessons.md]
files_affected:
  - AGENTS.md
  - CLAUDE.md
  - .github/copilot-instructions.md
  - agent/core/constraints.yml
  - agent/commands/acp.commit.md
  - agent/memory/lessons.md
  - agent/reports/audit-008-feedback-001-knowledge-preservation.md
  - agent/feedback/feedback-001-proactive-commit-and-knowledge-preservation.md
tokens_est: 8000
tokens_actual: ~12000
cost_est_usd:
cost_actual_usd:
created: 2026-05-09
completed: 2026-05-09
override_reason: Retroactively created in audit-009 compliance fix. Route was not created before the work began.
---

## Task Description

Investigate feedback-001 (TikrFlow project — 3 sessions of work lost to context overflow) and
implement all recommended fixes to the ACP Enhanced protocol.

## Acceptance Criteria

- [x] audit-008 report created at `agent/reports/audit-008-feedback-001-knowledge-preservation.md`
- [x] AGENTS.md / CLAUDE.md / .github/copilot-instructions.md: Step 4 gap-check substep added, Mid-Session Commit Triggers section added
- [x] `agent/core/constraints.yml`: 6 new knowledge-preservation rules added
- [x] `agent/commands/acp.commit.md`: v1.0.0 → v1.1.0, phase-boundary frequency, overflow risk warning
- [x] `agent/memory/lessons.md`: high-priority acp-knowledge-gap postmortem prepended

## Notes

- Commit: `4e00a90` (2026-05-09)
- R5 (rename /acp-commit → /acp-checkpoint) was explicitly rejected as too invasive
- All 6 compliance gaps identified in audit-009 were caused by skipping /acp-route and /acp-commit
