---
id: task-267
milestone: M80
title: "F-086-02 FIFOZ downstream /acp-version-update verification (ops)"
status: planned
priority: 3
complexity: low
estimated_hours: 1
created: 2026-07-24
started: null
completed: null
route: route-256
audit_findings: [F-086-02]
depends_on: []
design_reference: [Carryover: F-086-02](../../memory/audit-carryovers.md)
---

## Objective

Close carryover F-086-02 — verify `/acp-version-update` works correctly on a downstream FIFOZ consumer repo (the tier-aware copy logic that preserves customized `identity.yml`/wiki/taxonomy).

## Context

F-086-02 has been pending since audit-086: the consumer-side upgrade path was never verified end-to-end on a real downstream project. This is an **ops task gated on external access** — it needs a checkout of the FIFOZ consumer repository, which the autonomous agent may not have.

## Precondition (blocking)

- [ ] FIFOZ consumer repo is accessible locally (clone path known)

If the precondition is NOT met: do NOT mark this task complete and do NOT mark F-086-02 fixed. Record the blocker precisely (what access is needed) and leave the carryover `pending`. This is guardrail #4 of M80 — honest closure over forced closure.

## Steps (when precondition met)

1. In the FIFOZ consumer repo (on a branch), run `/acp-version-update` (or `agent/scripts/acp.version-update.sh --diff` first).
2. Verify tier behavior: Tier C framework files refresh; Tier B customized config (`identity.yml`, wiki, taxonomy) preserved; Tier A data untouched.
3. Confirm no destructive overwrite of consumer customizations; capture the diff.
4. Record the result; if clean, mark F-086-02 `fixed` with `verified_in_audit` set by the next audit.

## Verification

- [ ] EITHER: downstream `/acp-version-update` verified clean (tiers respected) → F-086-02 fixed
- [ ] OR: precondition unmet → task stays open, F-086-02 stays pending with exact access precondition recorded
- [ ] No false "completed" without real downstream verification

## User-Observable Acceptance

The consumer upgrade path is either proven safe on a real downstream repo, or the exact blocker is documented so it can be run the moment access exists — never silently claimed done.
