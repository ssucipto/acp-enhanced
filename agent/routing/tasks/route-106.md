---
id: route-106
title: "Port acp.design-spec.md v1.1.0 from feedback folder to agent/commands/"
task_type: command-doc-write
milestone: M50
complexity: low
executor: copilot
context_required:
  - agent/feedback/acp.design-spec.md
  - agent/feedback/feedback-005-acp-design-spec-command-upstream.md
  - agent/patterns/local.command-naming-convention.md
  - agent/patterns/local.upstream-integration-runbook.md
files_affected:
  - agent/commands/acp.design-spec.md
tokens_est: 300
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-06
completed:
override_reason:
---

# Route 106: Port acp.design-spec.md v1.1.0

## Objective

Copy `agent/feedback/acp.design-spec.md` (v1.1.0) to `agent/commands/acp.design-spec.md`, adapting any upstream-specific references for ACP Enhanced conventions.

## Context

The command was developed and validated in FIFOZ (audit-070). It is stack-agnostic with detection tables for UI/store/API roots. The v1.1.0 already addresses all 8 HIGH/MEDIUM findings from audit-070.

## Changes

### 1. Port the command file

Copy `agent/feedback/acp.design-spec.md` → `agent/commands/acp.design-spec.md`

### 2. Adapt references per upstream integration runbook

Apply these 4 explicit adaptations:

**a. Exemplar path**: The command references `agent/reports/design-spec-app-interfaces-m15-spine-v2.1.md`
as the exemplar output. Change to note that the exemplar is in `agent/feedback/` (reference-only,
not shipped in distribution):
```
**Exemplar output (FIFOZ):** `agent/feedback/design-spec-app-interfaces-m15-spine-v2.1.md` (reference only)
```

**b. Visualizer references**: The command mentions ACP Visualizer (`/acp-visualize`, `fad4492`, `v1.5.3+`).
Keep these but mark as optional with conditional language:
```
> **If ACP Visualizer is installed:** Run `/acp-visualize --update` to render diagrams in Docs tab.
```

**c. `@acp.` notation check**: The v1.1.0 command already uses `/acp-` prefix throughout.
Verify no `@acp.` dot notation remains (grep for `@acp\.`). If found, replace with `/acp-`.

**d. Internal links**: Verify all cross-references resolve in ACP Enhanced:
- `acp.design-create.md` → exists ✓
- `acp.report.md` → exists ✓
- `acp.audit.md` → exists ✓
- `acp.visualize.md` → exists ✓
- `agent/progress.yaml` → exists ✓
- `agent/memory/audit-carryovers.md` → exists ✓
- `agent/memory/decisions.md` → exists ✓
- `agent/wiki/domain.yml` → exists ✓

### 3. Verify against command naming convention

- ✅ Command directive: `agent/commands/acp.design-spec.md` (dot separator)
- ✅ Invocation: `/acp-design-spec` (hyphen separator)
- ✅ Agent Directive header present
- ✅ Scripts field present (value: `None`)

## Verification

- [ ] `agent/commands/acp.design-spec.md` exists
- [ ] Contains `🤖 Agent Directive` block
- [ ] Contains `Scripts:` field
- [ ] All `/acp-` invocations use hyphen (not `@acp.` dot notation)
- [ ] Internal links resolve to existing ACP Enhanced files
- [ ] FIFOZ-specific exemplar path noted as reference-only
- [ ] 19-section report structure (§1–§19) present
- [ ] Distinction table from `/acp-design-create` present
- [ ] Stack detection table present (not hardcoded FIFOZ paths)
