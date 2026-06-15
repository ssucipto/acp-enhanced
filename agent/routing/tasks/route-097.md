---
id: route-097
title: "Visualizer: direct PROGRESS_YAML_PATH support + React 19 SSR fix"
task_type: bug-fix
milestone: M49
complexity: medium
executor: copilot
context_required:
  - agent/commands/acp.visualize.md
  - (visualizer repo: server/routes/api/)
files_affected:
  - agent/commands/acp.visualize.md
  - (visualizer repo: separate)
tokens_est: 300
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-06
completed:
override_reason:
---

# Route 097: Visualizer Quick-Start + React 19 Fix

## Objective

Two fixes to the ACP Visualizer (separate repo):
1. Read `PROGRESS_YAML_PATH` env var directly — no project registry required
2. Fix React 19 SSR `Expected static flag` error (V-04 from feedback-001)

## Context

Visualizer launched but showed "0 Projects" — project not in ACP registry.
Then terminated with React 19 error. Both issues reported in feedback-001 (V-01, V-04)
but remain unresolved.

## Changes

### acp.visualize.md

Update to document the direct-path mode:
```
The visualizer reads PROGRESS_YAML_PATH directly. No project registry setup
required. If the env var is set, it bypasses the registry and loads the
specified progress.yaml immediately.
```

### Visualizer Repo (separate)

1. **Direct path mode**: In `server/routes/api/progress.ts`, if `PROGRESS_YAML_PATH`
   is set, read that file directly instead of querying the project registry.
2. **React 19 fix**: Wrap SSR components in `<ClientOnly>` or disable TanStack
   Devtools in dev mode. Or upgrade to React 19 stable API.

## Verification

- [ ] `PROGRESS_YAML_PATH=/path/to/progress.yaml npm run dev` shows data immediately
- [ ] No "0 Projects" on Home page when env var is set
- [ ] No React `Expected static flag` error on cold start
- [ ] acp.visualize.md documents the direct-path mode
