---
id: task-223
milestone: M70
title: "validateCarryoverFreshness guard (F-086-04)"
status: completed
priority: 4
complexity: medium
estimated_hours: 4
created: 2026-07-15
started: 2026-07-15
completed_date: 2026-07-15
route: route-212
audit_findings: [F-086-04]
depends_on: []
---

## Objective

Detect `pending` carryovers where fix_target code patterns already exist in codebase.

## Steps

1. Parse `audit-carryovers.md` pending entries
2. For each, grep fix_target file/pattern — warn if match suggests stale
3. Add vitest with fixture carryovers file
4. Document in `acp.validate.md`

## Verification

- [ ] Stale pending entry triggers warning
- [ ] F-086-04 carryover fixed after 30-day re-verify workflow documented
