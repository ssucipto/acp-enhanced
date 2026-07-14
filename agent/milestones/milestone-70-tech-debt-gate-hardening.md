# Milestone 70: Tech Debt & Gate Hardening

**Planned version**: 6.26.0  
**Status**: planned  
**Estimated effort**: ~52h (11 tasks, 5 phases)  
**Source**: audit-086, open carryovers (audit-041/065/066/086), v6.25.x shortcuts

## Goal

Close **all remaining open carryovers** and **all unacceptable shortcuts** identified in audit-086. Establish defensible production gates (branch protection, review policy, memory validation) so M63+ coverage gains are not undermined by registry drift or false security assurance.

## Build Order

| Phase | Route | Title | Carryovers | Est. | Priority |
|-------|-------|-------|------------|------|----------|
| **1** | route-208 | GitHub branch protection | CRIT-065-002 | 4h | P0 |
| **2** | route-210 | Memory-layer schemas | MED-066-007 | 8h | P1 |
| **2** | route-211 | Memory registry field lint | GAP-041-04 | 6h | P1 |
| **2** | route-212 | Carryover freshness validator | F-086-04 | 4h | P1 |
| **3** | route-213 | Two-phase review gate policy | F-086-03 | 4h | P1 |
| **3** | route-214 | Review scanner expansion | F-086-03 | 8h | P1 |
| **4** | route-215 | Commit sync E2E suite | GAP-041-07 | 6h | P2 |
| **4** | route-216 | Commit sync atomicity | GAP-041-08 | 4h | P2 |
| **5** | route-217 | FIFOZ consumer verification | F-086-02 | 4h | P2 |
| **5** | route-218 | IG-35 resolution | F-086-01 | 2h | P2 |
| **5** | route-219 | M70 closure + v6.26.0 | audit-086 | 4h | P0 |

## Task Map

| Task | Route | Deliverable | Gate |
|------|-------|-------------|------|
| [task-219](../tasks/milestone-70-tech-debt-gate-hardening/task-219-branch-protection.md) | route-208 | Branch protection enabled + docs | CRIT-065-002 fixed |
| [task-220](../tasks/milestone-70-tech-debt-gate-hardening/task-220-branch-protection-verify.md) | route-208 | Verify checklist in USAGE.md | manual + validate |
| [task-221](../tasks/milestone-70-tech-debt-gate-hardening/task-221-memory-schemas.md) | route-210 | session/carryovers/lessons schemas | validate enforces |
| [task-222](../tasks/milestone-70-tech-debt-gate-hardening/task-222-memory-field-lint.md) | route-211 | Field-level lint GAP-041-04 | vitest + validate |
| [task-223](../tasks/milestone-70-tech-debt-gate-hardening/task-223-carryover-freshness.md) | route-212 | validateCarryoverFreshness() | 0 stale pending |
| [task-224](../tasks/milestone-70-tech-debt-gate-hardening/task-224-review-gate-policy.md) | route-213 | Two-phase gate in acp.review.md | doc + E2E |
| [task-225](../tasks/milestone-70-tech-debt-gate-hardening/task-225-review-scanner-expand.md) | route-214 | +4 rules in review-scan | E2E fixtures |
| [task-226](../tasks/milestone-70-tech-debt-gate-hardening/task-226-commit-sync-e2e.md) | route-215 | commit/repair/--memory E2E | GAP-041-07 |
| [task-227](../tasks/milestone-70-tech-debt-gate-hardening/task-227-commit-atomicity.md) | route-216 | Atomic sync helper + tests | GAP-041-08 |
| [task-228](../tasks/milestone-70-tech-debt-gate-hardening/task-228-fifoz-consumer.md) | route-217 | FIFOZ version-update verified | F-086-02 |
| [task-229](../tasks/milestone-70-tech-debt-gate-hardening/task-229-ig35-resolution.md) | route-218 | IG-35 impl or wiki descope | F-086-01 |
| [task-230](../tasks/milestone-70-tech-debt-gate-hardening/task-230-m70-release.md) | route-219 | audit + v6.26.0 tag | 0 open carryovers |

## Shortcuts Addressed

| Shortcut | Resolution |
|----------|------------|
| Direct merge to mainline | Branch protection + PR workflow (Phase 1) |
| `/acp-review` as CI gate | Two-phase policy: scanner + agent (Phase 3) |
| Carryover registry drift | validateCarryoverFreshness (Phase 2) |
| Memory layer unvalidated | Schemas + field lint (Phase 2) |
| Commit sync partial writes | Atomic helper + E2E (Phase 4) |
| FIFOZ handoff untested | Consumer verification (Phase 5) |
| IG-35 phantom rule | Implement or descope wiki (Phase 5) |

## Accepted (Not Fixed — Documented)

| Item | Rationale |
|------|-----------|
| 60/64 review rules need agent | By design — semantic rules cannot be scripted |
| FIFOZ blocked on access | Defer with documented blocker in carryovers |

## Verification Gates

- [ ] All 8 open carryovers `status: fixed` with `verified_in_audit: audit-087` or M70
- [ ] `npx ts-node scripts/acp-validate.ts` — 0 errors
- [ ] New memory schema vitest tests pass
- [ ] E2E commit-sync suite green
- [ ] Git tag v6.26.0
- [ ] `mainline` updated via PR (not direct merge)

## Dependencies

- M63 complete (command E2E coverage) ✅
- audit-086 report ✅
- v6.25.3 shipped ✅
