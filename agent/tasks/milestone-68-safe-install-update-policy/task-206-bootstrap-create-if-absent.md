---
id: task-206
milestone: M68
title: bootstrap create-if-absent Tier B (route-201)
status: planned
priority: 4
complexity: low
estimated_hours: 2
created: 2026-07-15
started:
completed:
route: route-201
audit_findings: [F-080-05]
---

## Objective

Bootstrap re-run must not destroy customized Tier B files (F-080-05).

## Steps

1. Wrap constraints.yml, routing.yml in `[ -f ] || cat >`
2. Wrap wiki domain.yml, architecture.md, integrations.md
3. Wrap routing taxonomy.yml, rules.md, config.yml
4. Verify fresh install still creates stubs when missing

## Verification

- [ ] Second bootstrap run on customized project leaves domain.yml unchanged
- [ ] Fresh temp dir still gets all stubs

## User-Observable Acceptance

Re-running `acp-bootstrap.sh --yes` on an configured project does not reset wiki or routing files.
