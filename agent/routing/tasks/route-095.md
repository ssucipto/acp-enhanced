---
id: route-095
title: "Add version line to AGENTS.md header"
task_type: docs-update
milestone: M49
complexity: low
executor: copilot
context_required:
  - AGENTS.md
  - agent/progress.yaml
files_affected:
  - AGENTS.md
tokens_est: 100
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-06
completed:
override_reason:
---

# Route 095: AGENTS.md Version Line

## Objective

Add a version line to `AGENTS.md` so all tools (Copilot, Cursor, Claude) see the
current version. Currently only `AGENT.md` has the version — `AGENTS.md` is the
protocol doc with no version indicator.

## Context

AGENTS.md says "Do NOT add project content here" — but a one-line version
annotation in the header is not project content, it's protocol metadata.
This prevents Cursor from reading stale version from AGENT.md while keeping
the protocol doc clean.

## Change

Add after the title line:
```markdown
# ACP Enhanced — Agent Context Protocol
> v6.9.1 — Context Loading Protocol (light + full modes)
```

The version should be kept in sync via `/acp-validate` Step 2c (already checks
AGENTS.md as soft requirement — this just ensures the line exists).

## Verification

- [ ] AGENTS.md header shows current version
- [ ] Version matches `agent/progress.yaml`
- [ ] No other content added (protocol doc stays clean)
