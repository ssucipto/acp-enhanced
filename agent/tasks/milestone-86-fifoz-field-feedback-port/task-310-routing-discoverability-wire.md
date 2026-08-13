---
id: task-310
milestone: M86
title: "Wire routing.yml ci-check + discoverability surfaces"
status: planned
priority: 5
complexity: medium
estimated_hours: 3
created: 2026-08-14
started: null
completed:
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
status: draft
updated: 2026-08-14
@acp.meta.end -->

## Objective

Replace dangling `ci-check` stubs with real `/acp-ci` suggestions and add discoverability without silent upgrade landmines undocumented.

## Context

FIFOZ patched routing, common.sh help, proceed, commit. AE must wire the same **intents** carefully. Document each touch in a draft upstream-delta entry for task-314.

## Steps

1. Update `routing.yml` command_suggestions: `git-push` / `git-pr` / new `ci-check` / `acp-ci` / `acp-pr` relationships (real command names).
2. Add `/acp-ci` to `display_available_commands` in `acp.common.sh` if that function lists core commands.
3. Add proceed Step guidance: when task touched code, run `/acp-ci --static` before marking complete (wording precise; do not make proceed hang on full E2E by default).
4. Add optional `--ci` note to commit command doc if appropriate (or defer if conflicts — document decision).
5. List every touched upstream-owned file + proposed sentinel for task-314 register.
6. Do not skip wrappers — wrappers are task-313/319.

## Verification

- [ ] `rg ci-check agent/core/routing.yml` shows bindings to acp-ci (not dangling)
- [ ] Help/discoverability mentions `/acp-ci`
- [ ] Sentinel draft list committed in task notes or report snippet

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
