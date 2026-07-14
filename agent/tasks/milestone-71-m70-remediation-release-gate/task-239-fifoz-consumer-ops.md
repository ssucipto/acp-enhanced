---
id: task-239
milestone: M71
title: "FIFOZ consumer /acp-version-update (F-086-02 ops)"
status: planned
priority: 3
complexity: medium
estimated_hours: 4
created: 2026-07-15
started: null
completed_date: null
route: route-228
audit_findings: [F-086-02]
depends_on: []
design_reference: [Design: M71 Remediation](../design/m71-m70-remediation-release-gate.md)
---

## Objective

Verify FIFOZ runs `/acp-version-update` on v6.26.0+ and retires local wiki workaround.

## Steps

1. Run `/acp-version-update` against FIFOZ repo (or document access blocker)
2. Verify handoff protocol files post-update
3. Check feedback-007 §6
4. Stamp F-086-02 fixed or deferred with reason

## Verification

- [ ] feedback-007 §6 checked OR documented blocker in carryover
- [ ] F-086-02 resolved

## User-Observable Acceptance

FIFOZ `agent/` layout matches v6.26.0+ handoff protocol (or explicit deferral in carryovers).

**Note**: Optional P3 — does not block M71 completion or v6.26.0 tag.
