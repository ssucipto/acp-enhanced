---
id: task-158
milestone: M29
title: Sync agent/wiki/domain.yml to current codebase state
status: completed
priority: 3
complexity: low
estimated_hours: 1
created: 2026-05-05
started: 2026-05-05T00:00:00Z
completed: 2026-05-05
---

<!-- @acp.meta.task
topic: sync, agentwikidomainyml, to, current, codebase, state
description: Sync agent/wiki/domain.yml to current codebase state
milestone: M29
status: completed
updated: 2026-05-05
@acp.meta.end -->


## Objective

Update `agent/wiki/domain.yml` so its `commands:`, `scripts:`, `schemas:`, and `test_suites:` sections accurately reflect the current state of the codebase (58 commands, current script count, current schema count).

## Context

`agent/wiki/domain.yml` is the machine-readable knowledge base for ACP Enhanced. It's used by `/acp-init` to populate context and by `/acp-index` for the key-file index. If it's stale, agents in fresh sessions load incorrect counts and may reference non-existent commands.

The last wiki sync was performed around audit-005 (2026-05-04/05). Since then, new commands, scripts, and schemas have been added (M26, M27, M28 work). The current codebase has:
- 58 command files in `agent/commands/`
- ~27+ scripts in `agent/scripts/`
- Schemas in `agent/schemas/`
- 22 E2E test files in `e2e/`

## Implementation

1. Run `ls agent/commands/ | wc -l` — confirm current count
2. Run `ls agent/scripts/ | wc -l` — confirm current count
3. Run `ls agent/schemas/ | wc -l` — confirm current count
4. Run `ls e2e/*.test.sh | wc -l` — confirm current count
5. Open `agent/wiki/domain.yml`
6. Compare each section's entries to actual filesystem state
7. Add any missing commands, scripts, schemas, or test suites
8. Remove any entries for files that no longer exist
9. Update counts and descriptions where needed

## Expected Output

### Files Updated
- `agent/wiki/domain.yml`

## Verification
- [ ] `grep -c "name:" agent/wiki/domain.yml` matches expected section entry count
- [ ] Commands section count in domain.yml equals `ls agent/commands/*.md | wc -l`
- [ ] Scripts section count in domain.yml equals `ls agent/scripts/*.sh | wc -l`
- [ ] All M26–M28 commands present in domain.yml commands section

## User-Observable Acceptance
After running `/acp-init`, the agent reports accurate command/script counts. No "command not found in domain" warnings from `/acp-validate`.
