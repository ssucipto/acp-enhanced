---
id: task-248
milestone: M73
title: "Carryover integrity restore + verified_in_audit guard"
status: completed
priority: 5
complexity: medium
estimated_hours: 2
created: 2026-07-15
started: null
completed: null
route: route-237
audit_findings: [F-094-01]
depends_on: []
design_reference: [Design: M73 Closure Honesty](../design/m73-m72-closure-honesty-remediation.md)
---

## Objective

Restore 19 historical `verified_in_audit` values corrupted by bulk `replace_all` during task-247, and add a guard preventing false audit-093 stamps on pre-M72 fixes.

## Context

Commit `07ab4d5` (task-247 release) replaced all `verified_in_audit: null` with `audit-093`, overwriting audit-015/016/041 stamps on entries from May–June 2026. This breaks carryover audit trail integrity (F-094-01 critical).

## Steps

1. Extract pre-corruption baseline: `git show 07ab4d5^:agent/memory/audit-carryovers.md` → save temp diff reference
2. For each corrupted entry (lines ~208–354 per audit-094): restore original `verified_in_audit` from baseline; preserve M72-era `fixed` status where runtime fixes are real
3. Entries fixed during M72 (F-091-*, F-092-*): set `verified_in_audit: null` pending task-252 audit-095 — do NOT stamp audit-093
4. Implement D9 guard: vitest or validate helper that fails if any carryover has `fix_applied_date` before `2026-07-15` AND `verified_in_audit: audit-093`
5. Add lesson to `lessons.md`: never bulk-replace carryover audit stamps

## Verification

- [ ] `rg 'verified_in_audit: audit-093' agent/memory/audit-carryovers.md` — only M72 closure entries (if any remain), zero pre-July historical IDs
- [ ] Manual spot-check: audit-015 BUG-003, MEMORY-002 restored to original audit IDs
- [ ] Guard test passes on restored file; fails on corrupted fixture
- [ ] `git diff agent/memory/audit-carryovers.md` reviewed entry-by-entry (no bulk replace)

## User-Observable Acceptance

Carryover audit trail accurately reflects which audit verified each fix; historical May–June fixes no longer falsely cite audit-093.
