# Design: M71 M70 Remediation & Release Gate

**Milestone**: M71  
**Planned version**: 6.26.0 (release tag — code mostly landed in uncommitted M70)  
**Source**: audit-089, audit-087, audit-088 gaps  
**Status**: planned  
**Created**: 2026-07-15  
**Amends**: M70 (implementation landed; release gate blocked)

---

## Problem Statement

`/acp-proceed --complete M70` landed substantial code but audit-089 found **6 high-severity gaps**: uncommitted work, premature carryover stamps, orphan `acp.atomic-write.sh`, incomplete schema enforcement, stale wiki docs, and GitHub branch protection still absent. M70 cannot ship until M71 closes these honestly.

## Proposed Solution

Eight-task **remediation milestone** (no new features) grouped in three phases:

```
Phase 1 (P0) ──► Release artifacts + task tracking sync
Phase 2 (P1) ──► Code truth: atomic-write, array schemas, docs parity
Phase 3 (P0) ──► Ops gates: branch protection + closure audit
```

## Finding → Task Map

| Audit ID | Carryover | Task | Route |
|----------|-----------|------|-------|
| F-089-04, F-089-01 | — | task-231 | route-220 |
| F-089-02 | GAP-041-08 | task-232 | route-221 |
| F-089-05 | MED-066-007 | task-233 | route-222 |
| F-089-06,09,10,11,12 | — | task-234 | route-223 |
| F-089-07, F-089-08 | F-087-05 | task-235 | route-224 |
| F-086-04 (strengthen) | — | task-236 | route-225 |
| F-089-03 | CRIT-065-002 | task-237 | route-226 |
| F-089-13 | — | task-238 | route-227 |
| F-086-02 | F-086-02 | task-239 (ops) | route-228 |

## Key Technical Decisions

| Decision | Rationale |
|----------|-----------|
| M71 not M70 re-open | Separates "code landed" from "release gate passed" — avoids rewriting 12 completed progress entries |
| M70 → `in_progress` 11/12 | task-230 incomplete until M71 task-238 |
| Atomic-write via command docs | Sync is agent-executed; wire helper in `acp.pattern-sync.md` / `acp.session-sync.md` steps |
| Array schema validation | Extend `validateYamlListEntries()` in `runSchemaEnforcement` — same pattern as `validateMemoryFieldLint` |
| Branch protection = ops task | Cannot fix from repo alone; task-237 documents admin run + carryover stamp |
| FIFOZ deferred to task-239 P3 | External repo; not blocking v6.26.0 tag |

## Anti-Shortcut Rules (M71)

1. No carryover `fixed` without audit-090 verification pointer
2. No M71 `completed` until `git tag v6.26.0` exists
3. GAP-041-08 stays `in-progress` until atomic-write referenced in sync command steps
4. M70 milestone doc stays `completed` for implementation; M71 owns release gate

## Success Criteria

- `git tag v6.26.0` on develop
- validate 0 errors; vitest 50+ tests
- 0 `in-progress` carryovers except documented ops (F-086-02 if FIFOZ blocked)
- CRIT-065-002 `fixed` OR explicitly deferred with admin blocker in carryover
- audit-090 PASS verdict
