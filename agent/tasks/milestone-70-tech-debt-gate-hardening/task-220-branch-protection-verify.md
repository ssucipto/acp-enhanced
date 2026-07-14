---
id: task-220
milestone: M70
title: "Branch protection verification checklist + validate guard"
status: completed
priority: 4
complexity: low
estimated_hours: 2
created: 2026-07-15
started: 2026-07-15
completed_date: 2026-07-15
route: route-208
audit_findings: [CRIT-065-002]
depends_on: [task-219]
---

## Objective

Add automated reminder in validate when branch protection not documented as enabled.

## Steps

1. Add `validateBranchProtectionDocs()` — checks USAGE.md has protection checklist marked complete
2. Optional: `gh api` check if `gh` available (warn-only)
3. E2E or vitest for doc presence

## Verification

- [ ] validate warns if protection checklist unchecked
- [ ] task-219 completion recorded in progress.yaml notes
