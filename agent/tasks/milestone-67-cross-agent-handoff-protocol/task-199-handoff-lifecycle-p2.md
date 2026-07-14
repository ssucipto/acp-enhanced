---
id: task-199
milestone: M67
title: Handoff lifecycle P2 — LATEST, superseded, ancestry (route-194)
status: completed
priority: 3
complexity: low
estimated_hours: 2
created: 2026-07-15
started:
completed: 2026-07-15
route: route-194
---

## Objective

P2 polish: `HANDOFF-LATEST.md` copy on save, `status: superseded` on prior handoff, optional git ancestry validate.

## Context

Addresses **H10, H6** and shortcut **S4** (return path documentation in template; this route adds lifecycle).

## Steps

1. Handoff command writes copy to `agent/reports/HANDOFF-LATEST.md`
2. On new handoff with `supersedes:` → mark old frontmatter `status: superseded`
3. validate `--strict`: pinned SHA is ancestor of HEAD (`git merge-base --is-ancestor`)
4. Return handoff filename convention in wiki

## Verification

- [ ] LATEST file updated on executor save
- [ ] Superseded marking documented
- [ ] Ancestry check optional (warn not fail by default)

## Depends on

task-198
