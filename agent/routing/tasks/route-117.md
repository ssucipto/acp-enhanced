---
id: route-117
title: "Port acp.stakeholder-report.md v1.1.0 from feedback to agent/commands/"
task_type: command-doc-write
milestone: M52
complexity: low
executor: copilot
context_required:
  - agent/feedback/acp.stakeholder-report.md
  - agent/feedback/feedback-006-acp-stakeholder-report-command-upstream.md
  - agent/patterns/local.command-naming-convention.md
files_affected:
  - agent/commands/acp.stakeholder-report.md
tokens_est: 200
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-06
completed:
override_reason:
---

# Route 117: Port acp.stakeholder-report.md v1.1.0

## Objective

Copy `agent/feedback/acp.stakeholder-report.md` (v1.1.0, audit-071 hardened) to `agent/commands/acp.stakeholder-report.md`, adapting for ACP Enhanced conventions.

## Context

v1.1.0 includes 11 audit-071 changes: auto-amber RAG rule, metrics ≤4 hard limit, anti-patterns filter, artefact naming table, email subject line, severity column on blockers, sessions.md fallback, cross-command doc updates, progress.yaml staleness warning, ≤300 word executive summary. Ship v1.1.0, not v1.0.0.

## Changes

### 1. Port the command file

Copy `agent/feedback/acp.stakeholder-report.md` → `agent/commands/acp.stakeholder-report.md`

### 2. Adapt references

- **Exemplar path**: Update FIFOZ exemplar reference to `agent/feedback/` (reference-only)
- **Internal links**: Verify cross-references to `acp.report.md`, `acp.cost-report.md`, `acp.status.md`, `acp.design-spec.md` all resolve
- **`@acp.` notation**: Verify zero occurrences (v1.1.0 already uses `/acp-` prefix)
- **Five-tier model**: The command documents the reporting model internally — no adaptation needed

### 3. Verify against command naming convention

- ✅ Command directive: `agent/commands/acp.stakeholder-report.md` (dot separator)
- ✅ Invocation: `/acp-stakeholder-report` (hyphen separator)
- ✅ Agent Directive header present
- ✅ Scripts field present (`Scripts: None`)
- ✅ Audit reference: audit-071

## Verification

- [ ] `agent/commands/acp.stakeholder-report.md` exists
- [ ] Contains `🤖 Agent Directive` block
- [ ] Contains `Scripts:` field
- [ ] Contains `## Verification Checklist` (12 items)
- [ ] Auto-amber RAG rule documented: `current_blockers` non-empty → minimum Amber
- [ ] Metrics hard limit ≤4 documented
- [ ] Anti-patterns list present (no task IDs, ACP commands, emoji logs)
- [ ] Artefact naming table present (stakeholder-report-*.md vs report-*.md vs roadmap-brief-*.md)
- [ ] Suggested email subject line in header template
- [ ] Severity column on blockers table
- [ ] Executive summary ≤300 words rule in Step 4
- [ ] `sessions.md` fallback for sparse recent_work documented
- [ ] All `/acp-` invocations use hyphen (no `@acp.` dot notation)
