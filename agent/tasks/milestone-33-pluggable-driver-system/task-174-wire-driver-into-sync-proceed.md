---
id: task-174
milestone: M33
title: Wire driver hooks into acp.sync.md and acp.proceed.md
status: completed
priority: 2
complexity: low
estimated_hours: 2
created: 2026-05-05
started: 2026-05-06T00:00:00Z
completed: 2026-05-06
---

<!-- @acp.meta.task
topic: wire, driver, hooks, into, acpsyncmd, and, acpproceedmd
description: Wire driver hooks into acp.sync.md and acp.proceed.md
milestone: M33
status: completed
updated: 2026-05-05
@acp.meta.end -->


## Objective

Add conditional driver hooks to `agent/commands/acp.sync.md` Step 1.3 and `agent/commands/acp.proceed.md` Step 1, so commands can dispatch to configured backends while remaining no-op when `agent/driver.yaml` is absent.

## Context

`acp.driver-yaml.sh` (task-172) provides `driver_is_native <tool>`. Commands need a standard way to check this before invoking tools like `git`, shell, or lint utilities. The hook must be transparent when `driver.yaml` doesn't exist — it's an opt-in system.

## Implementation

### Change 1: acp.sync.md

Find Step 1.3 in `acp.sync.md` (the meta-scan invocation step). Add before the `./agent/scripts/acp.meta-scan.sh` call:

```
**1.3.0** Driver check (skip if `agent/driver.yaml` absent):
- Source `agent/scripts/acp.driver-yaml.sh` if it exists
- If `driver_is_native shell` returns false, use configured shell driver for scan execution
```

### Change 2: acp.proceed.md

Find Step 1 in `acp.proceed.md` (the task execution step). Add near the tool invocation section:

```
**Driver delegation** (when `agent/driver.yaml` present):
- Before invoking `git` operations, check `driver_is_native git`
- If not native, delegate to MCP via `driver_query git server` / `driver_query git method`
- Log delegation decision to session log if `--verbose` flag is set
```

### Constraint

Both changes must be clearly marked as **optional/conditional** hooks. They must not change behaviour when `agent/driver.yaml` is absent. Add a note:
```
> This step is a no-op if `agent/driver.yaml` does not exist.
```

## Expected Output

### Files Updated
- `agent/commands/acp.sync.md`
- `agent/commands/acp.proceed.md`

## Verification
- [ ] acp.sync.md Step 1.3 has driver check with "no-op if absent" note
- [ ] acp.proceed.md Step 1 has driver delegation section
- [ ] Both changes are conditional (no behaviour change without driver.yaml)
- [ ] Existing step numbering is preserved (new sub-steps like 1.3.0 don't break 1.4, 1.5, etc.)

## User-Observable Acceptance
Running `/acp-sync` or `/acp-proceed` without `agent/driver.yaml` behaves exactly as before. With a `driver.yaml` present that configures `git: type: mcp`, the command routes git calls to the configured MCP server.
