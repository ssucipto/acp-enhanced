---
id: task-254
milestone: M73
title: "M73 closure audit-096 + ship v6.27.1 patch"
status: planned
priority: 5
complexity: low
estimated_hours: 1
created: 2026-07-15
started: null
completed: null
route: route-243
audit_findings: [F-094-01, F-094-02, F-094-03, F-094-04, F-094-05, F-094-06, F-094-07, F-094-08, F-094-09, F-094-10]
depends_on: [task-248, task-249, task-250, task-251, task-252, task-253]
design_reference: [Design: M73 Closure Honesty](../design/m73-m72-closure-honesty-remediation.md)
---

## Objective

Final M73 closure audit, patch release v6.27.1, and mark M72 honestly closed.

## Context

Patch release (D8): process/metadata fixes only — no new validator features. Blocks on sweep 6/6 and audit-095 PASS.

## Steps

1. Run full quality chain: validate, vitest, e2e (if in sweep), post-milestone-sweep 6/6, manifest verify
2. Write `agent/reports/audit-096-m73-closure.md` — verify all F-094 findings addressed
3. Update CHANGELOG with v6.27.1 remediation entry
4. Bump `identity.yml`, `package.yaml`, instruction headers → 6.27.1
5. Tag `v6.27.1`; update progress.yaml M73 `completed`; amend M72 closure note to honest PASS
6. Session entry in sessions.md

## Verification

- [ ] audit-096 verdict PASS
- [ ] `git tag -l v6.27.1` exists
- [ ] `grep version agent/core/identity.yml package.yaml` → 6.27.1
- [ ] M73 milestone gates all `[x]`
- [ ] progress.yaml: M73 completed 7/7; next_steps updated
- [ ] F-094-* carryovers stamped `fixed` with `verified_in_audit: audit-096` where applicable

## User-Observable Acceptance

M72 can be cited as honestly closed; v6.27.1 documents remediation without re-shipping enforcement features.
