---
id: task-307
milestone: M86
title: "Pre-implementation audit --pre-impl for M86"
status: completed
priority: 5
complexity: medium
estimated_hours: 4
created: 2026-08-14
started: 2026-08-14
completed: 2026-08-14
phase: 0
depends_on: [task-305, task-306]
design_reference: [agent/design/local.fifoz-field-feedback-port.md](../../design/local.fifoz-field-feedback-port.md)
audit_findings: ['F-114-01']
files_affected:
  - agent/reports/audit-115-m86-pre-impl-readiness.md
---

<!-- @acp.meta.task
topic: m86, fifoz, pre, impl, audit
description: Run `/acp-audit --pre-impl` against M86 tasks 308–321 and produce a readiness verdict before any coding task starts.
milestone: M86
design: agent/design/local.fifoz-field-feedback-port.md
incorporates: D4
depends_on: task-305, task-306
status: completed
updated: 2026-08-14
@acp.meta.end -->

## Drift Remediation / Audit Result

**Report**: `agent/reports/audit-115-m86-pre-impl-readiness.md`  
**Verdict**: READY (after plan amendments). Initial BLOCKED on F3-01…F3-08.

## Objective

Run `/acp-audit --pre-impl` against M86 tasks 308–321 and produce a readiness verdict before any coding task starts.

## Context

M85 taught that pre-impl audits catch circular deps and wrong field names. User directive: no shortcuts. Coding tasks 308+ are BLOCKED until this audit reports READY (or documents amendments applied to task files).

## Steps

1. Invoke `/acp-audit --pre-impl` with subject M86 / tasks 308-321.
2. Phase 1–4 from acp.audit.md: plan correctness, code cross-ref against inbox + live AE files, carryover check, operational completeness.
3. Verify ADR-26 list (identical commands) is **not** scheduled as work.
4. Verify task-312 depends on task-311; task-309 does not paste FIFOZ Expo bodies.
5. Apply amendments to task files if findings require them (update tasks in place; do not skip).
6. Publish `agent/reports/audit-115-m86-pre-impl-readiness.md` with READY/BLOCKED verdict.
7. If BLOCKED: stop the milestone; do not start 308.

## Verification

- [ ] audit-115 exists with Phase 1–4 tables
- [ ] Verdict READY or documented amendments + re-audit
- [ ] No coding commits for 308+ before READY
- [ ] Carryovers from audit-114 still pending (expected) listed

## User-Observable Acceptance

`agent/reports/audit-115-m86-pre-impl-readiness.md` shows READY before any `/acp-ci` implementation commit.

## Expected Output

### Files Created / Modified
- `agent/reports/audit-115-m86-pre-impl-readiness.md`

### Notes
Source of truth: audit-114. Inbox reference only: `agent/reports/fifoz-port-inbox-2026-08-14/`. No shortcuts.


## Completion Evidence (2026-08-14)

- [x] audit-115 published with Phase 1–4 tables
- [x] F3 findings amended into tasks/milestone/design/progress/carryovers
- [x] Coding gate: start at task-305; 308+ still after 305–306
