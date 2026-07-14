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
---

## Objective

Align docs with implementation; fix false CHANGELOG assurance.

## Steps

1. Fix `acp.version-update.md` — domain.yml path, default safe behavior, AGENTS.md
2. README: pre-v6.24.0 warning + tier table summary
3. CONTRIBUTING: safe update workflow for downstream consumers
4. CHANGELOG v6.24.0 entry notes v6.9.0 doc-only gap correction
5. Stamp route-079 `completed:` after E2E green

## Verification

- [ ] Command doc matches script flags
- [ ] No reference to `agent/core/domain.yml`

## User-Observable Acceptance

README accurately describes which files are preserved on update.
