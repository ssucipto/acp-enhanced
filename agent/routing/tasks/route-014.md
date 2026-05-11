---
id: route-014
title: M39 — Add git_workflow optional block to identity.yml
task_type: yaml-schema
milestone: M39
complexity: low
executor: deepseek-v4-flash
context_required:
  - agent/core/identity.yml
  - agent/feedback/feedback-002-acp-git-branch-awareness.md
  - agent/reports/audit-010-feedback-002-003-implementation-plan.md
files_affected:
  - agent/core/identity.yml
tokens_est: 4000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-05-11
completed: 2026-05-11
override_reason:
---

## Task Description

Add an optional, commented-out `git_workflow:` block to `agent/core/identity.yml` so projects
can enable git branch awareness. The block is commented out by default — a safe no-op for
projects that don't configure it.

## Acceptance Criteria

- [ ] `git_workflow:` block added at the bottom of `agent/core/identity.yml` (commented out)
- [ ] Block includes: `default_working_branch`, `production_branch`, `branch_model` fields
- [ ] Inline comments explain each field's purpose and valid values for `branch_model`
- [ ] File header note updated: "Uncomment git_workflow to enable branch safety checks"
- [ ] No dynamic content (dates, task IDs) added — identity.yml is prompt-cached

## Implementation Notes

Add as a commented block after the last existing field:

```yaml
# Optional: configure git branch awareness (uncomment to enable)
# When set, Step 1b will warn if working on the production branch.
# git_workflow:
#   default_working_branch: develop   # branch agent commits to by default
#   production_branch: main           # never commit directly to this
#   branch_model: gitflow-lite        # gitflow-lite | trunk | github-flow
```

## Dependency

Must be completed before route-015 (Step 1b references identity.yml → git_workflow).
