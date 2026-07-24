---
id: task-272
milestone: M81
title: "Wire /acp-review + weekly-code-review for coderabbit_active"
status: planned
priority: 5
complexity: medium
estimated_hours: 4
created: 2026-07-24
started: null
completed: null
route: route-261
depends_on: [task-269, task-270, task-271]
design_reference: [agent/commands/acp.review.md](../../commands/acp.review.md), [ADR-21](../../memory/decisions.md)
---

## Objective

Augment `/acp-review` and the `weekly-code-review` recurring task with **conditional** CodeRabbit-aware behavior when `coderabbit_active` — unchanged behavior when inactive.

## Context

Binding rule: CodeRabbit augments, never gates. Phase 1 (`acp.review-scan.sh`) unchanged. Phase 2 agent instructions gain deferral notes from policy map lite. Recurring task adds an optional step, not a replacement.

## Steps

1. Update `agent/commands/acp.review.md`:
   - New subsection: "CodeRabbit augmentation (when `coderabbit_active`)"
   - Phase 2: for rules owned by `coderabbit` in policy map, report as "deferred to CodeRabbit — verify via PR review or `/acp-findings-import`"
   - Explicit: Phase 2 still runs for ACP-owned rules; total review remains valid standalone
2. Update `agent/progress.yaml` → `recurring_tasks` → `weekly-code-review`:
   - Add conditional step (documented in task notes): when `coderabbit_active`, include "check open CodeRabbit PR threads / run findings-import"
   - Implementation: shell guard in recurring task doc OR small helper `acp.coderabbit-weekly.sh` sourced only when active
3. Do **not** modify `acp.review-scan.sh` to call CodeRabbit APIs

## Verification

- [ ] `/acp-review` command doc has no requirement for CodeRabbit when inactive
- [ ] Policy map rules marked `coderabbit` appear in sample review report template when active
- [ ] `weekly-code-review` command string unchanged when `coderabbit_active` false
- [ ] Manual test: run review self-check on acp-enhanced repo with `enabled=false` — identical to pre-M81

## User-Observable Acceptance

CodeRabbit user sees review reports that acknowledge CodeRabbit coverage and point to imported carryovers. Non-CodeRabbit user sees no difference.
