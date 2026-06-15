---
id: route-134
title: Update taxonomy.yml with 4 new code-review task types
task_type: yaml-schema
milestone: M55
complexity: low
executor: copilot
context_required: [agent/routing/taxonomy.yml, feedback/feedback-006-acp-review-command-upstream-v3.md §5.2]
files_affected: [agent/routing/taxonomy.yml]
tokens_est: 3000
created: 2026-06-07
completed:
---

# Route 134: Add code-review task types to taxonomy

Add 4 new task_type entries to taxonomy.yml:
1. code-review-targeted — single file/small dir, executor: deepseek-v4-pro
2. code-review-full — codebase-wide, executor: composer-2.5
3. code-review-security — OWASP full ruleset, executor: composer-2.5
4. code-review-ci — CI pipeline high-volume, executor: qwen3-235b-a22b

Also add `code-review` skill to skills_catalog with @-mention mapping.
