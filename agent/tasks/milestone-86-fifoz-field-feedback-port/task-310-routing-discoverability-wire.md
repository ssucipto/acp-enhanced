---
id: task-310
milestone: M86
title: "Wire routing.yml ci-check + discoverability surfaces"
status: completed
priority: 5
complexity: medium
estimated_hours: 3
created: 2026-08-14
started: 2026-08-14
completed: 2026-08-14
phase: 1
depends_on: [task-309]
design_reference: [agent/design/local.fifoz-field-feedback-port.md](../../design/local.fifoz-field-feedback-port.md)
audit_findings: ['F-114-08']
files_affected:
  - agent/core/routing.yml
  - agent/scripts/acp.common.sh
  - agent/commands/acp.proceed.md
  - agent/commands/acp.commit.md
---

<!-- @acp.meta.task
topic: m86, fifoz, routing, discoverability, wire
description: Replace dangling `ci-check` stubs with real `/acp-ci` suggestions and add discoverability without silent upgrade landmines undocumented.
milestone: M86
design: agent/design/local.fifoz-field-feedback-port.md
incorporates: D1
depends_on: task-309
status: completed
updated: 2026-08-14
@acp.meta.end -->

## Objective

Replace dangling `ci-check` stubs with real `/acp-ci` suggestions and add discoverability without silent upgrade landmines undocumented.

## Context

FIFOZ patched routing, common.sh help, proceed, commit. AE must wire the same **intents** carefully. Document each touch in a draft upstream-delta entry for task-314.

## Steps

1. Update `routing.yml` command_suggestions: `git-push` / `git-pr` / new `ci-check` / `acp-ci` / `acp-pr` relationships (real command names).
2. **REQUIRED**: add `/acp-ci` and `/acp-pr` lines to `display_available_commands()` in `acp.common.sh` (function at ~line 1472).
3. **REQUIRED**: add proceed Step guidance: when task touched product/framework code, run `/acp-ci --static` before marking complete. Do **not** require `--full` / matrix E2E in proceed by default.
4. **REQUIRED**: add a Related/Usage note in `acp.commit.md` that `/acp-ci --static` should be green before pushing (no new CLI flag required in M86 — documentation only).
5. **REQUIRED**: write sentinel draft list (path + greppable string) for every upstream-owned file touched — consumed by task-314 Phase B.
6. Wrappers remain task-313 (must not be skipped there).

## Verification

- [x] `rg ci-check agent/core/routing.yml` shows bindings to acp-ci (not dangling)
- [x] Help/discoverability mentions `/acp-ci`
- [x] Sentinel draft list committed in task notes or report snippet (`agent/reports/m86-drafts/task-310-sentinels.md`)

## User-Observable Acceptance

An agent reading `routing.yml` after `git-pr` is pointed at `/acp-ci` and `/acp-pr`, not a nameless `ci-check`.

## Expected Output

### Files Created / Modified
- `agent/core/routing.yml`
- `agent/scripts/acp.common.sh`
- `agent/commands/acp.proceed.md`
- `agent/commands/acp.commit.md`

### Notes
Source of truth: audit-114. Inbox reference only: `agent/reports/fifoz-port-inbox-2026-08-14/`. No shortcuts.
