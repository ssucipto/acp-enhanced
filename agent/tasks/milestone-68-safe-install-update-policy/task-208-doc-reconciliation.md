---
id: task-208
milestone: M68
title: Doc reconciliation + route-079 re-close (route-203)
status: planned
priority: 4
complexity: low
estimated_hours: 2
created: 2026-07-15
started:
completed:
route: route-203
depends_on: route-202
audit_findings: [F-080-08, F-080-12, P-081-04, P-081-06]
---

## Objective

Align docs with implementation; fix false CHANGELOG assurance; single authoritative tier table.

## Steps

1. Rewrite `acp.version-update.md` — remove L38-47 contradiction; single tier table (P-081-06, SC-080-05)
2. Fix `domain.yml` path to `agent/wiki/domain.yml` (F-080-12)
3. README: pre-v6.24.0 warning + tier table summary
4. CONTRIBUTING: safe update workflow for downstream consumers
5. CHANGELOG v6.24.0 entry notes v6.9.0 doc-only gap (SC-080-02, F-080-08)
6. Stamp route-079 `completed:` **only after route-202 E2E green** (P-081-04, SC-080-01)

## Verification

- [ ] Command doc matches script flags exactly
- [ ] No reference to `agent/core/domain.yml`
- [ ] No contradictory overwrite/preserve lists

## User-Observable Acceptance

README accurately describes which files are preserved on update.

## Anti-shortcuts

- SC-080-01: route-079 `completed:` requires route-202 E2E pass, not route-199 alone
- SC-080-05: one tier table, not conflicting sections
