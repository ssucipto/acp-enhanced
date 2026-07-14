---
id: task-227
milestone: M70
title: "Commit sync atomicity enforcement (GAP-041-08)"
status: completed
priority: 4
complexity: medium
estimated_hours: 4
created: 2026-07-15
started: 2026-07-15
completed_date: 2026-07-15
route: route-216
audit_findings: [GAP-041-08]
depends_on: [task-226]
---

## Objective

Extract shared `acp.atomic-write.sh` helper; enforce temp-file + rename in commit sync paths.

## Steps

1. Create `agent/scripts/acp.atomic-write.sh` — write tmp, mv atomic
2. Refactor session/pattern sync references in command docs to use helper
3. E2E failure injection test (simulate mid-write abort)

## Verification

- [ ] No partial session docs on simulated failure
- [ ] GAP-041-08 carryover fixed
