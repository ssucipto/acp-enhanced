---
id: task-230
milestone: M70
title: "M70 closure audit + v6.26.0 release"
status: planned
priority: 5
complexity: medium
estimated_hours: 4
created: 2026-07-15
started: null
completed_date: null
route: route-219
audit_findings: [audit-086]
depends_on: [task-219, task-221, task-223, task-224, task-226, task-227]
---

## Objective

Run audit-087 closure, stamp all M70 carryovers, ship v6.26.0 via PR to mainline.

## Steps

1. Run `/acp-audit M70 closure`
2. Verify 0 pending carryovers (or documented deferrals only)
3. CHANGELOG v6.26.0, version bump, tag
4. PR develop → mainline (use branch protection from task-219)

## Verification

- [ ] audit-087 report with PASS verdict
- [ ] git tag v6.26.0
- [ ] All M70 verification gates checked in milestone doc
