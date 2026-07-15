---
id: task-219
milestone: M70
title: "Enable GitHub branch protection on mainline (CRIT-065-002)"
status: completed
priority: 5
complexity: low
estimated_hours: 2
created: 2026-07-15
started: 2026-07-15
completed_date: 2026-07-15
route: route-208
audit_findings: [CRIT-065-002]
depends_on: []
---

## Objective

Enable branch protection on `mainline` (and optionally `develop`) per `docs/USAGE.md` route-162 spec.

## Steps

1. GitHub Settings → Branches → add rule for `mainline`
2. Require PR, 1 review, required status checks (CI validate + e2e)
3. Disable force-push and direct pushes
4. Document completion in `docs/USAGE.md` with checklist

## Verification

- [ ] Branch protection rule active on GitHub
- [ ] Direct push to mainline blocked (test with dummy commit attempt)
- [ ] CRIT-065-002 carryover stamped fixed

## User-Observable Acceptance

Future releases to `mainline` require PR + green CI.
