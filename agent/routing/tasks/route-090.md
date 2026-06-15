---
id: route-090
title: "/acp-status --health — YAML lint + progress.yaml git drift check"
task_type: command-doc-update
milestone: M48
complexity: low
executor: copilot
context_required:
  - agent/commands/acp.status.md
  - agent/progress.yaml
files_affected:
  - agent/commands/acp.status.md
tokens_est: 250
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-04
completed:
override_reason:
---

# Route 090: /acp-status --health

## Objective

Add a `--health` flag to `/acp-status` that runs YAML validation on memory files
and checks for drift between `progress.yaml` and git state.

## Context

FIFOZ feedback-002 (B-066-02) identified recurring drift between `progress.yaml`
and git reality — tasks marked complete in progress.yaml but code uncommitted,
or vice versa. A health check would catch this before it accumulates.

## Changes

### acp.status.md — Add --health Flag

```
| `--health` | Run health checks: YAML lint memory files, check progress-vs-git drift |
```

### New Step: Health Check

When `--health` is passed, add a health check step:

1. **YAML lint**: Run equivalent of `/acp-validate --memory` on patterns.md,
   sessions.md, progress.yaml. Report pass/fail.

2. **Git drift check**: Compare `progress.yaml` task completion dates against
   git log. If tasks are marked complete but no corresponding commit exists
   within 24 hours, flag as potential drift.

3. **Uncommitted progress**: If `progress.yaml` is modified but not committed,
   warn: "progress.yaml has uncommitted changes — run /acp-commit."

**Output**:
```
🏥 Health Check:
  YAML: ✅ All memory files valid
  Git drift: ⚠️ route-085 completed 2026-06-04 but no commit found
  Progress: ⚠️ progress.yaml has uncommitted changes
```

## Verification

- [ ] `--health` flag documented in arguments
- [ ] Health check step exists in command doc
- [ ] YAML lint, git drift, and uncommitted progress checks defined

## Dependencies

- route-078 (--memory validation must exist)
