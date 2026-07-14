---
id: task-238
milestone: M71
title: "M71 closure audit + v6.26.0 ship"
status: completed
priority: 5
complexity: medium
estimated_hours: 3
created: 2026-07-15
started: 2026-07-15
completed_date: 2026-07-15
route: route-227
audit_findings: [F-089-13]
depends_on: [task-232, task-233, task-234, task-235, task-236, task-237]
design_reference: [Design: M71 Remediation](../design/m71-m70-remediation-release-gate.md)
---

## Objective

Run audit-090 closure, amend audit-088 verdict, complete task-230, ship via PR.

## Steps

1. Run `/acp-audit M71 closure`
2. Amend `audit-088-m70-closure.md` verdict → PASS WITH GAPS RESOLVED
3. Stamp task-219..230 frontmatter; mark task-230 completed
4. Stamp all F-089 carryovers fixed (or documented deferrals)
5. PR develop → mainline

## Verification

- [ ] audit-090 PASS verdict
- [ ] M71 verification gates all checked
- [ ] task-230 completed in progress.yaml

## User-Observable Acceptance

v6.26.0 on mainline via PR; ≤2 pending carryovers (FIFOZ ops only).
