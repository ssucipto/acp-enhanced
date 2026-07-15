---
id: task-253
milestone: M73
title: "Branch protection ops — CRIT-065-002 honest track"
status: planned
priority: 5
complexity: low
estimated_hours: 1
created: 2026-07-15
started: null
completed: null
route: route-242
audit_findings: [F-094-03]
depends_on: [task-249]
design_reference: [Design: M73 Closure Honesty](../design/m73-m72-closure-honesty-remediation.md)
---

## Objective

Attempt CRIT-065-002 resolution (mainline branch protection + PR) or document honest deferred status — never mark complete without API proof.

## Context

`gh api repos/{owner}/{repo}/branches/mainline/protection` returns 404 (admin required). task-246 was falsely marked completed in progress.yaml (fixed in task-249).

## Steps

1. Verify task-249 reverted task-246 to `deferred` in progress.yaml
2. Retry `gh api` branch protection endpoint; if 404, document required admin permissions in carryover note
3. If admin available: enable protection per task-246 spec; open PR develop → mainline
4. On success: stamp CRIT-065-002 `fixed`, `verified_in_audit: audit-095` or `audit-096`; set task-246 `completed` with API response evidence
5. On failure: keep CRIT-065-002 `pending`; update carryover with retry date and blocker; task-246 stays `deferred`

## Verification

- [ ] `gh api .../mainline/protection` result documented in report or carryover
- [ ] task-246 status matches API outcome (deferred OR completed with proof)
- [ ] CRIT-065-002 status honest in audit-carryovers.md
- [ ] No `completed` without HTTP 200 response saved

## User-Observable Acceptance

Branch protection state is provable from API output, not assumed.
