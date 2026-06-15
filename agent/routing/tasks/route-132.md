---
id: route-132
title: Create skill file code-review.md
task_type: command-doc-write
milestone: M55
complexity: low
executor: copilot
override_reason: "audit-051 F-002 — Flash is explicitly disqualified for this skill by the proposal itself"
context_required: [feedback/feedback-006-acp-review-command-upstream-v3.md, skills/commands.md]
files_affected: [agent/skills/code-review.md]
tokens_est: 3000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-07
completed:
override_reason:
---

# Route 132: Create code-review.md skill

Create `agent/skills/code-review.md` — ≤500 tokens agent prompt for `@{code-review}` invocation.

Include:
- When to load (3 task types)
- Priority order: CRITICAL → HIGH → MEDIUM → LOW with category mapping
- Output discipline
- Executor notes: qualified (Composer 2.5, V4 Pro, Kimi K2.6, Qwen3) and disqualified (Flash, Flash-Max) with rationale
- Carryover integration
- Scope detection for ACP self-review rules (when agent/commands/ detected)

**Constraint**: Must fit within 500-token budget. OWASP mapping embedded as compact inline references.
