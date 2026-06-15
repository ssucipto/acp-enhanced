---
id: route-131
title: Create command document acp.review.md
task_type: command-doc-write
milestone: M55
complexity: medium
executor: deepseek-v4-pro
context_required: [feedback/feedback-006-acp-review-command-upstream-v3.md, wiki/domain.yml#commands, milestones/milestone-55-acp-review-command.md]
files_affected: [agent/commands/acp.review.md]
tokens_est: 8000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-07
completed:
override_reason:
---

# Route 131: Create acp.review.md

Create the full command document for `/acp-review` following ACP command doc conventions. Include:
- Agent Directive header
- All 6 arguments with descriptions (per feedback-006 §2.2)
- Embedded 54-rule reference in 6 category tables (§2.3)
- Output format specification (§2.4)
- Quality gates — 8 rules (§2.6)
- Executor selection guide (§2.7)
- Verification checklist
- Related commands section

**Source**: feedback-006 v3.0, audit-050 corrected verdict.
**Convention**: Follow existing command doc format (agent/commands/acp.audit.md as template).
