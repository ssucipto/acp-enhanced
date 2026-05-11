---
id: route-016
title: M39 — Add Step 0 branch guard to acp.commit.md v1.2.0
task_type: command-doc-update
milestone: M39
complexity: low
executor: deepseek-v4-flash
context_required:
  - agent/commands/acp.commit.md
  - agent/feedback/feedback-002-acp-git-branch-awareness.md
  - agent/reports/audit-010-feedback-002-003-implementation-plan.md
files_affected:
  - agent/commands/acp.commit.md
tokens_est: 3000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-05-11
completed:
override_reason:
---

## Task Description

Add Step 0 (Pre-commit Branch Guard) to `acp.commit.md` as the first step before any session
memory is written. Also add an optional `branch:` field to the sessions.md entry schema in Step 2.
Bump version from v1.1.0 to v1.2.0.

## Acceptance Criteria

- [ ] `acp.commit.md` version field: `1.1.0` → `1.2.0`
- [ ] `Last Updated:` field set to `2026-05-11`
- [ ] New Step 0 inserted before existing Step 1 (Identify Completed Tasks)
- [ ] Step 0 is conditional — only runs if `agent/core/identity.yml` contains `git_workflow`
- [ ] Step 0 reads `git branch --show-current` and compares to `git_workflow.production_branch`
- [ ] Step 0 outputs a clear STOP message if on production branch; does not proceed to Step 1
- [ ] Sessions.md YAML schema in Step 2 includes optional `branch: [current branch | omit if git_workflow not configured]`
- [ ] Existing Steps 1–7 renumbered to Steps 1–7 (Step 0 is pre-flight, does not shift numbering)

## Implementation Notes

Step 0 content:

```markdown
### 0. Pre-commit Branch Guard (conditional)
Only run if `agent/core/identity.yml` contains `git_workflow:`.

1. Run `git branch --show-current`
2. Read `git_workflow.production_branch` from `identity.yml` (e.g., `main`)
3. If current branch equals production_branch:
   Output: "⚠️ [ACP] Refusing to commit on `[production_branch]` (production). Switch to `[default_working_branch]` first."
   STOP. Do not write sessions.md. Do not make a git commit.
4. If current branch equals default_working_branch or is `feature/*` / `fix/*` → proceed to Step 1
```

Step 2 YAML schema addition:

```yaml
- date: [today]
  executor: [executor]
  branch: [current branch — omit if git_workflow not configured in identity.yml]
  tasks: [...]
```
