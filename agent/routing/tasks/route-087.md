---
id: route-087
title: "Atomicity in sync operations — temp-file + atomic rename"
task_type: command-doc-update
milestone: M48
complexity: medium
executor: copilot
context_required:
  - agent/commands/acp.commit.md
  - agent/commands/acp.pattern-sync.md
  - agent/commands/acp.session-sync.md
files_affected:
  - agent/commands/acp.commit.md
tokens_est: 300
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-04
completed:
override_reason:
---

# Route 087: Atomicity in Sync Operations

## Objective

Add atomicity guarantees to the commit auto-sync steps (2b, 3b, 6b) and repair
tools to prevent partial state on failure.

## Context

Current sync design writes files directly to `agent/sessions/` and `agent/patterns/`.
If sync fails mid-operation, some documents may be written while others are not.
While the idempotent design allows recovery on re-run, the intermediate state
is inconsistent. Industry standard: use temp-file + atomic rename pattern.

## Changes

### acp.commit.md — Steps 2b, 3b, 6b

Add atomicity directive to all three sync steps:

```
> **Atomicity**: Write to a temporary file first, then atomically rename to the
> target path. This prevents partial writes from leaving corrupted or incomplete
> documents visible to agents or the visualizer.
>
> Pattern:
> 1. Write content to agent/sessions/.tmp.{date}-{slug}.md
> 2. mv agent/sessions/.tmp.{date}-{slug}.md agent/sessions/{date}-{slug}.md
> 3. On failure: the .tmp file is cleaned up on next sync run
```

### acp.pattern-sync.md / acp.session-sync.md

Same atomicity directive added to the repair tools' sync steps.

### Edge Cases

- **Crash during write**: `.tmp` file exists but target doesn't → next sync run cleans up `.tmp` and retries.
- **Crash during rename**: `.tmp` and target both absent → next sync run recreates from registry.
- **Concurrent commits**: Unlikely in single-agent model, but `.tmp` naming includes PID to prevent collision.

## Verification

- [ ] Atomicity directive present in all three sync steps (2b, 3b, 6b)
- [ ] Atomicity directive present in pattern-sync and session-sync command docs
- [ ] Edge cases documented

## Dependencies

None.
