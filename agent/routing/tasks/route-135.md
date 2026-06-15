---
id: route-135
title: Update core/routing.yml with acp-review command suggestions
task_type: yaml-schema
milestone: M55
complexity: low
executor: copilot
context_required: [agent/core/routing.yml, feedback/feedback-006-acp-review-command-upstream-v3.md §5.1]
files_affected: [agent/core/routing.yml]
tokens_est: 2000
created: 2026-06-07
completed:
---

# Route 135: Add acp-review to command_suggestions

Add acp-review entry with related commands and add acp-review suggestions to acp-audit, acp-audit--pre-impl, and acp-commit per feedback-006 §5.1.
