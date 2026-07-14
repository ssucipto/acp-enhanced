# Milestone 71: M70 Remediation & Release Gate

**Planned version**: 6.26.0  
**Status**: completed (8/9 — task-239 ops deferred)  
**Estimated effort**: ~20h (8 tasks + 1 ops optional)  
**Source**: audit-089, audit-087/088 amendment  
**Amends**: M70 implementation (code landed, release blocked)

## Goal

Close **all audit-089 gaps** and **honestly stamp carryovers** so v6.26.0 can ship via PR to `mainline`. No new features — remediation only.

## Build Order

| Phase | Route | Title | Findings | Est. | Priority |
|-------|-------|-------|----------|------|----------|
| **1** | route-220 | Release artifacts + task sync | F-089-01, F-089-04 | 2h | P0 |
| **2** | route-221 | Atomic-write integration | GAP-041-08, F-089-02 | 3h | P1 |
| **2** | route-222 | Memory array schema enforcement | MED-066-007, F-089-05 | 4h | P1 |
| **2** | route-223 | Docs/wiki parity | F-089-06,09,10,11,12 | 3h | P1 |
| **2** | route-224 | Route hygiene + review fixtures | F-089-07, F-089-08 | 3h | P2 |
| **2** | route-225 | Carryover freshness vitest | F-086-04 | 2h | P2 |
| **3** | route-226 | Branch protection ops | CRIT-065-002, F-089-03 | 2h | P0 |
| **3** | route-227 | M71 closure audit + ship | F-089-13 | 3h | P0 |
| **ops** | route-228 | FIFOZ consumer (optional) | F-086-02 | 4h | P3 |

## Task Map

| Task | Route | Deliverable | Gate |
|------|-------|-------------|------|
| [task-231](../tasks/milestone-71-m70-remediation-release-gate/task-231-release-artifacts.md) | route-220 | Commit M70 + tag v6.26.0 + task frontmatter | F-089-01/04 fixed |
| [task-232](../tasks/milestone-71-m70-remediation-release-gate/task-232-atomic-write-wire.md) | route-221 | Sync commands use acp.atomic-write.sh | GAP-041-08 fixed |
| [task-233](../tasks/milestone-71-m70-remediation-release-gate/task-233-array-schema-enforcement.md) | route-222 | lessons/decisions/carryovers validate | MED-066-007 fixed |
| [task-234](../tasks/milestone-71-m70-remediation-release-gate/task-234-docs-wiki-parity.md) | route-223 | domain.yml, package.yaml, validate.md | F-089-06/09/10 fixed |
| [task-235](../tasks/milestone-71-m70-remediation-release-gate/task-235-route-fixtures.md) | route-224 | files_affected + review fixtures | F-089-07/08 fixed |
| [task-236](../tasks/milestone-71-m70-remediation-release-gate/task-236-carryover-vitest.md) | route-225 | validateCarryoverFreshness vitest | F-086-04 hardened |
| [task-237](../tasks/milestone-71-m70-remediation-release-gate/task-237-branch-protection-ops.md) | route-226 | GitHub protection enabled | CRIT-065-002 fixed |
| [task-238](../tasks/milestone-71-m70-remediation-release-gate/task-238-m71-closure-ship.md) | route-227 | audit-090 PASS + PR mainline | M71 complete |
| [task-239](../tasks/milestone-71-m70-remediation-release-gate/task-239-fifoz-consumer-ops.md) | route-228 | FIFOZ version-update (ops) | F-086-02 fixed/deferred |

## M70 Amendment Note

M70 implementation is **code-complete** but **release-blocked** per audit-089. M71 completes task-230 scope (honest closure + v6.26.0 ship). M70 milestone remains `completed` for implementation work; M71 owns the release gate.

## Verification Gates

- [ ] `git tag v6.26.0` exists
- [ ] All task-219..230 frontmatter `status: completed`
- [ ] GAP-041-08, MED-066-007 carryovers `fixed` with audit-090 pointer
- [ ] `npx ts-node scripts/acp-validate.ts` — 0 errors
- [ ] vitest 50+ pass
- [ ] audit-090 PASS verdict
- [ ] PR develop → mainline (after branch protection)

## Accepted Deferrals

| Item | Condition |
|------|-----------|
| F-086-02 FIFOZ | task-239 optional; document blocker if no repo access |
