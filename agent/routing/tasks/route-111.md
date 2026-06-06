---
id: route-111
title: "Cross-link acp-design-spec in acp.report.md and acp.design-create.md Related Commands"
task_type: command-doc-update
milestone: M50
complexity: low
executor: copilot
context_required:
  - agent/commands/acp.report.md
  - agent/commands/acp.design-create.md
  - agent/commands/acp.design-spec.md
files_affected:
  - agent/commands/acp.report.md
  - agent/commands/acp.design-create.md
tokens_est: 100
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-06
completed:
override_reason:
---

# Route 111: Cross-Link in Peer Commands

## Objective

Add `/acp-design-spec` to the Related Commands sections of `acp.report.md` and `acp.design-create.md` to prevent naming collision confusion and establish the command relationship graph.

## Context

Per feedback-005 §5.4 and acceptance criteria: "No naming collision confusion with acp-design-create in docs index." The distinction table in the design-spec command itself is clear, but peer commands should also reference it.

## Changes

### 1. `agent/commands/acp.report.md` — Add to Related Commands

Find the Related Commands or "See Also" section and add:

```markdown
- [`/acp-design-spec`](acp.design-spec.md) — Interface & data-flow specification (not progress report)
```

### 2. `agent/commands/acp.design-create.md` — Add to Related Commands

Find the Related Commands or "See Also" section and add:

```markdown
- [`/acp-design-spec`](acp.design-spec.md) — Document implemented interfaces after build (not planning)
```

## Verification

- [ ] `acp.report.md` Related Commands references `acp.design-spec.md`
- [ ] `acp.design-create.md` Related Commands references `acp.design-spec.md`
- [ ] Links use correct relative paths
- [ ] Distinction from design-spec is clear in both entries
