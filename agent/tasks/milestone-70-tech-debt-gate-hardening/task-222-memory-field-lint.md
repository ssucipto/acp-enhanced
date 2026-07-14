---
id: task-222
milestone: M70
title: "Memory registry field-level lint (GAP-041-04)"
status: completed
priority: 4
complexity: medium
estimated_hours: 6
created: 2026-07-15
started: 2026-07-15
completed_date: 2026-07-15
route: route-211
audit_findings: [GAP-041-04]
depends_on: [task-221]
---

## Objective

Enforce required fields (`date:`, `name:`) and warn on unquoted colons in sessions.md and patterns.md.

## Steps

1. Add `validateMemoryFieldLint()` using schemas from task-221
2. Integrate into `/acp-validate --memory`
3. Fix any existing violations

## Verification

- [ ] Missing `date:` in session entry fails validate
- [ ] GAP-041-04 carryover fixed
