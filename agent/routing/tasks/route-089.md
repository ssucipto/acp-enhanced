---
id: route-089
title: "Audit-first workflow documentation in wiki"
task_type: docs-update
milestone: M48
complexity: low
executor: copilot
context_required:
  - agent/wiki/architecture.md
  - agent/commands/acp.audit.md
files_affected:
  - agent/wiki/architecture.md
tokens_est: 200
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-04
completed:
override_reason:
---

# Route 089: Audit-First Workflow Documentation

## Objective

Document the audit-first workflow pattern observed in FIFOZ production usage
(64 audits vs 4 plans) as a recommended practice in the wiki.

## Context

FIFOZ feedback-002 (B-066-01) found that audits substitute for clarifications
and specs in practice. The team runs `/acp-audit` before implementation to
catch plan/code mismatches, and audit reports serve as durable knowledge
artifacts. This pattern should be documented as a recommended workflow.

## Changes

### agent/wiki/architecture.md — New Section

Add after the dual-store section:

```markdown
## Audit-First Workflow

ACP Enhanced supports an audit-first development pattern where `/acp-audit`
serves as the primary planning and review mechanism:

### Pattern
1. `/acp-audit --pre-impl <route>` — catch gaps before coding
2. Implement the task
3. `/acp-audit` (post-impl) — verify deliverables and catch regressions
4. Carryovers written to `agent/memory/audit-carryovers.md` for tracking

### When to Use
- High-complexity tasks with multiple files affected
- Schema changes that affect multiple command docs
- Feedback-driven improvements (validate external input before implementing)
- Cross-cutting concerns that span multiple domains

### Benefits
- Pre-impl audits prevent bugs that would require full rework
- Audit reports serve as durable knowledge artifacts (findable via `agent/reports/`)
- Carryover tracking prevents findings from being lost between sessions
- Production data (FIFOZ): 64 audits prevented CI/CD bugs in pre-impl mode
```

## Verification

- [ ] Audit-first workflow section exists in architecture.md
- [ ] Pattern is described with steps
- [ ] When-to-use guidance is clear
- [ ] Benefits are backed by production data

## Dependencies

None.
