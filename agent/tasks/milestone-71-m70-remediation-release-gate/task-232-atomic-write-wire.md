---
id: task-232
milestone: M71
title: "Wire acp.atomic-write.sh into commit sync command paths"
status: completed
priority: 5
complexity: medium
estimated_hours: 3
created: 2026-07-15
started: 2026-07-15
completed_date: 2026-07-15
route: route-221
audit_findings: [F-089-02]
depends_on: [task-231]
design_reference: [Design: M71 Remediation](../design/m71-m70-remediation-release-gate.md)
---

## Objective

Close GAP-041-08 honestly — replace inline `.tmp` + rename prose with `acp.atomic-write.sh` in sync command steps.

## Steps

1. Update `acp.pattern-sync.md` Step that writes pattern docs — invoke `bash agent/scripts/acp.atomic-write.sh <target>`
2. Update `acp.session-sync.md` similarly
3. Add note in `acp.commit.md` auto-sync steps (2b/3b) referencing atomic-write
4. Optional E2E: verify helper used in repair-tools flow

## Verification

- [ ] `grep -r acp.atomic-write` finds references in command docs
- [ ] GAP-041-08 carryover `status: fixed`, `verified_in_audit: audit-090`

## User-Observable Acceptance

Agent following `/acp-pattern-sync` uses documented atomic-write helper, not ad-hoc `.tmp` paths.
