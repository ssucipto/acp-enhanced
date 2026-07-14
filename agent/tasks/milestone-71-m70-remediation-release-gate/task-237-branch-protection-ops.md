---
id: task-237
milestone: M71
title: "GitHub branch protection ops (CRIT-065-002)"
status: completed
priority: 5
complexity: low
estimated_hours: 2
created: 2026-07-15
started: 2026-07-15
completed_date: 2026-07-15
route: route-226
audit_findings: [F-089-03]
depends_on: [task-231]
design_reference: [Design: M71 Remediation](../design/m71-m70-remediation-release-gate.md)
---

## Objective

Enable branch protection on `mainline` and `develop` via GitHub admin.

## Steps

1. Run `bash agent/scripts/acp.branch-protection-setup.sh` (requires repo admin)
2. Verify `gh api repos/.../branches/mainline/protection` returns rules
3. Stamp CRIT-065-002 `status: fixed`, `verified_in_audit: audit-090`
4. Update USAGE.md checklist if needed

## Verification

- [ ] Direct push to mainline rejected (or protection rules visible in GitHub UI)
- [ ] validate branch protection warn cleared

## User-Observable Acceptance

`gh api .../mainline/protection` returns 200 with required status checks.

**Note**: Ops task — requires GitHub admin. If blocked, document in carryover with `escalated_to: ops`.
