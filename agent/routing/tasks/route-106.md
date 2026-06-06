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

- **Naming**: The command already uses `/acp-design-spec` format (not upstream `@acp.design-spec`). Verify all invocations use `/acp-` prefix.
- **File references**: Ensure internal links point to `agent/commands/acp.*.md` (not relative paths that may break).
- **Exemplar path**: Update the exemplar reference from FIFOZ path to note it's in `agent/feedback/` (not shipped in distribution).
- **Visualizer reference**: Keep Visualizer integration notes but mark as "if ACP Visualizer is installed."

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
