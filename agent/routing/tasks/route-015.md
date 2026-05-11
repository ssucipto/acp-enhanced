---
id: route-015
title: M39 — Add Step 1b git branch safety check to context-loading protocol
task_type: command-doc-update
milestone: M39
complexity: low
executor: deepseek-v4-flash
context_required:
  - AGENTS.md
  - agent/feedback/feedback-002-acp-git-branch-awareness.md
  - agent/reports/audit-010-feedback-002-003-implementation-plan.md
files_affected:
  - AGENTS.md
  - CLAUDE.md
  - .github/copilot-instructions.md
tokens_est: 3000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-05-11
completed:
override_reason:
---

## Task Description

Add Step 1b (Git Branch Safety Check) between Step 1 and Step 2 of the context-loading protocol
in all three protocol files. The check is conditional — it only runs when `identity.yml` contains
a `git_workflow` block, making it a safe no-op for projects that don't configure it.

## Acceptance Criteria

- [ ] Step 1b added after Step 1 in `AGENTS.md`
- [ ] Step 1b added after Step 1 in `CLAUDE.md`
- [ ] Step 1b added after Step 1 in `.github/copilot-instructions.md`
- [ ] Step 1b clearly states: only run if `identity.yml` contains `git_workflow`
- [ ] Step 1b specifies: run `git branch --show-current`, compare to `default_working_branch`
- [ ] Step 1b specifies the STOP condition: on production_branch → output warning, do not proceed
- [ ] Step 1b specifies: feature/* or other branches → proceed normally
- [ ] All 3 files identical (they are synced copies of the same protocol)

## Implementation Notes

Insert between `### Step 1 — Load Core` and `### Step 2 — Identify Task Domain`:

```markdown
### Step 1b — Git Branch Safety Check (conditional)
Only run this step if `agent/core/identity.yml` contains a `git_workflow:` block.

Run: `git branch --show-current`
Compare to `identity.yml → git_workflow.default_working_branch`.

- **Matches default_working_branch** → proceed normally
- **Is the production_branch (e.g. `main`)** → STOP. Output:
  ```
  ⚠️ [ACP] You are on `main` (production branch).
  All work should target the default working branch. Switch with:
    git checkout [default_working_branch]
  Do not commit until you are on the correct branch.
  ```
  Output the warning and stop. Do not continue any task steps. The developer
  must switch branches and re-invoke the session.
- **Is `feature/*`, `fix/*`, or other** → note it in session, proceed normally
- **`git_workflow` not defined in identity.yml** → skip this step entirely
```

## Dependency

Requires route-014 (identity.yml git_workflow block) to be completed first.
