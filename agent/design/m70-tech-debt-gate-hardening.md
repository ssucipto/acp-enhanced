# Design: M70 Tech Debt & Gate Hardening

**Milestone**: M70  
**Planned version**: 6.26.0  
**Source**: audit-086, audit-065/066/070 carryovers, audit-041 GAPs  
**Status**: planned  
**Created**: 2026-07-15

---

## Problem Statement

After v6.25.3, audit-086 closed 21 stale carryovers but **8 actionable debts remain**: production branch protection, memory-layer schema gaps, review gate ambiguity, M47 commit-sync gaps, FIFOZ consumer verification, and carryover registry drift risk.

Shortcuts that must not recur:
- Registry/carryover status without code re-verification
- Claiming `/acp-review` or `/acp-integrity` as CI gates without explicit phase policy
- Direct merges to `mainline` without PR + required checks
- Commit auto-sync without atomic write guarantees

## Proposed Solution

Five-phase milestone closing **every open carryover** and **documenting accepted-by-design shortcuts** with explicit gate policy.

## Architecture

```
Phase 1 (P0) ──► GitHub branch protection + verify docs
Phase 2 (P1) ──► Memory schemas + validate + carryover freshness guard
Phase 3 (P1) ──► Review two-phase gate policy + scanner expansion
Phase 4 (P2) ──► M47 E2E (commit sync, repair, --memory) + atomicity
Phase 5 (P2) ──► FIFOZ consumer + IG-35 + release v6.26.0
```

## Key Technical Decisions

| Decision | Rationale |
|----------|-----------|
| Two-phase review gate | Phase 1 scanner (deterministic) + agent pass (semantic) — no false "64/64 automated" claim |
| Carryover freshness in validate | Prevents 21-entry drift recurrence (F-086-04) |
| Memory schemas before field lint | GAP-041-04 depends on schema definitions |
| Branch protection manual + verify | CRIT-065-002 cannot be fixed from repo alone |
| FIFOZ as ops task | F-086-02 is consumer-project action, not framework code |

## Carryover Closure Map

| Carryover | Task | Route |
|-----------|------|-------|
| CRIT-065-002 | task-219 | route-208 |
| MED-066-007 | task-221 | route-210 |
| GAP-041-04 | task-222 | route-211 |
| F-086-04 | task-223 | route-212 |
| F-086-03 | task-224, task-225 | route-213, route-214 |
| GAP-041-07 | task-226 | route-215 |
| GAP-041-08 | task-227 | route-216 |
| F-086-02 | task-228 | route-217 |
| F-086-01 | task-229 | route-218 |
| GAP-041-07 (E2E) | task-226 | route-215 |
| All M70 | task-230 | route-219 |

## Anti-Shortcut Rules (M70 gates)

1. No carryover marked `fixed` without `verified_in_audit` + code pointer
2. No milestone `completed` without verification gates checked in milestone doc
3. Review scanner expansion must have E2E fixtures per new rule
4. Schema changes require validate.ts unit test
5. Branch protection documented in `docs/USAGE.md` with screenshot/checklist

## Success Criteria

- 0 `pending` carryovers except explicitly deferred ops (FIFOZ if blocked)
- `acp-validate` enforces memory schemas + carryover freshness
- Published review gate policy in `acp.review.md` + skill
- E2E for commit auto-sync paths
- v6.26.0 tagged and on `mainline` via PR
