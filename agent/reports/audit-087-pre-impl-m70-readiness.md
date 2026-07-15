# Audit Report: M70 Pre-Implementation Readiness

**Audit**: #087  
**Date**: 2026-07-15  
**Subject**: M70 Tech Debt & Gate Hardening — `--pre-impl` readiness check  
**Mode**: `--pre-impl`  
**Verdict**: **BLOCKED** — 4 blocking gaps, 6 amendments required before `/acp-proceed`

---

## Summary

Pre-implementation audit cross-referenced M70 milestone, design, 12 tasks, 11 routes, and open carryovers against live code @ v6.25.3 (`9a82ff2`). Planning artifacts are structurally complete (all task/route files exist, progress.yaml synced). However, **4 findings block implementation start** due to wrong rule IDs, overstated scope on already-shipped work, and route file hygiene gaps. **6 medium/low amendments** recommended before Phase 1.

---

## Pre-Implementation Readiness (M70)

**Mode**: `--pre-impl`

### Phase 1 — Plan Correctness

| Check | Result | Notes |
|-------|--------|-------|
| Milestone doc complete | ⚠️ | Header says "11 tasks" but map has **12**; `progress.yaml` has `tasks_total: 12` |
| Design doc complete | ✅ | `agent/design/m70-tech-debt-gate-hardening.md` |
| Task files exist (219–230) | ✅ | 12/12 present |
| Route files exist (208–219) | ⚠️ | **route-209 missing** (gap: 208, 210–219) |
| Acceptance criteria unambiguous | ⚠️ | task-225 uses non-existent rule IDs |
| Open blockers documented | ✅ | 5 pending + 3 in-progress carryovers mapped |

### Phase 2 — Code Cross-Reference

| File | Field/Value Checked | Result | Notes |
|------|---------------------|--------|-------|
| `agent/schemas/*.schema.yaml` | session, lessons, decisions, carryovers | ✅ exist | **task-221 overstated** — schemas already shipped |
| `scripts/acp-validate.ts:693-698` | SCHEMA_DATA_MAP | ✅ wired | `runSchemaEnforcement()` at line 1362 |
| `e2e/acp.commit-sync.test.sh` | GAP-041-07 deliverable | ✅ exists | **Not in command-e2e-coverage.yaml** |
| `e2e/acp.repair-tools.test.sh` | GAP-041-07 deliverable | ✅ exists | **Not in command-e2e-coverage.yaml** |
| `agent/commands/acp.review.md` | API-01, CQ-01 rule IDs | ❌ | **Do not exist** — use AP-01, SC-01 or NC-01 |
| `agent/commands/acp.review.md` | EH-01, TS-02 | ✅ | Valid rule IDs |
| `agent/wiki/integrity-rules.md` | IG-35 definition | ⚠️ | IG-35 = files outside `files_affected`, **not** git-provenance |
| `agent/routing/tasks/route-162.md` | branch protection | ⚠️ | M59 route exists; `completed:` empty; overlaps task-219 |
| `agent/routing/tasks/route-208.md` | `files_affected` | ❌ | Empty `[]` — all 11 M70 routes same |
| `docs/USAGE.md:468` | branch protection docs | ✅ | Partial — needs completion checklist |

### Phase 3 — Carryover Check

| Carryover | Severity | Status | Blocks M70? |
|-----------|----------|--------|-------------|
| CRIT-065-002 | critical | pending | Yes — Phase 1 |
| MED-066-007 | medium | pending | **Partial** — schemas exist; enforcement gaps remain |
| GAP-041-04 | low | in-progress | Yes — patterns.md has no schema |
| GAP-041-07 | medium | in-progress | **Partial** — E2E exists, not in coverage registry |
| GAP-041-08 | medium | in-progress | Yes — atomic helper not extracted |
| F-086-02 | medium | pending | No — Phase 5 ops |
| F-086-03 | medium | pending | Yes — Phase 3 |
| F-086-04 | low | pending | Yes — Phase 2 |

### Phase 4 — Operational Completeness

| Check | Result | Notes |
|-------|--------|-------|
| Route files exist | ✅ | 11 routes (208–219, skip 209) |
| Route `files_affected` populated | ❌ | All empty — must fill before implementation |
| Version bump planned | ✅ | v6.26.0 in task-230 |
| Wiki update planned | ✅ | review gate, IG-35 in task-229 |
| E2E coverage registry update | ❌ | commit-sync/repair-tools not registered |
| route-162 reconciliation | ⚠️ | Stamp complete or merge into task-219 |

### Phase Summary

| Phase | Findings | Highest Severity |
|-------|----------|-----------------|
| Phase 1 — Plan Correctness | 3 | medium |
| Phase 2 — Code Cross-Reference | 6 | **high** |
| Phase 3 — Carryover Check | 0 new | — |
| Phase 4 — Operational Completeness | 3 | medium |
| **Total** | **12** | **high** |

### Readiness Verdict

**BLOCKED** — Amend task-225 rule IDs, rescope tasks 221/226/229, populate route `files_affected`, and reconcile route-162 before starting `/acp-proceed task-219`.

---

## Key Findings

| ID | Severity | Finding | Location | Fix |
|----|----------|---------|----------|-----|
| F-087-01 | **HIGH** | task-225 references **API-01** and **CQ-01** — neither exists in `acp.review.md` | task-225:4,23 | Use **AP-01** (not API-01); replace CQ-01 with **SC-01** or **NC-01** |
| F-087-02 | **HIGH** | task-221 scope duplicates shipped work — 4 memory schemas exist + `runSchemaEnforcement()` active | task-221, MED-066-007 | Rescope to: patterns.schema.yaml, vitest fixtures, stricter enforcement |
| F-087-03 | **MEDIUM** | task-226 E2E suites **already exist** but not in `command-e2e-coverage.yaml` | e2e/*.test.sh | Rescope to: registry + CI wire + `--memory` flag test |
| F-087-04 | **MEDIUM** | task-229 IG-35 scope wrong — wiki defines route `files_affected` drift, not git author | integrity-rules.md:91 | Implement IG-35 in validate/route-stamp check, not git-provenance |
| F-087-05 | **MEDIUM** | All M70 routes have empty `files_affected: []` | route-208..219 | Populate before implementation |
| F-087-06 | **MEDIUM** | route-162 (M59) duplicates task-219; `completed:` never stamped | route-162.md | Merge: complete route-162 when task-219 done |
| F-087-07 | **LOW** | Milestone header "11 tasks" vs 12 in map/progress | milestone-70.md:5 | Fix to 12 |
| F-087-08 | **LOW** | route-209 missing in sequence | routing/tasks/ | Document skip or reserve for amend |
| F-087-09 | **LOW** | `patterns.md` has no schema — GAP-041-04 incomplete | agent/schemas/ | Add patterns.schema.yaml in task-221 |
| F-087-10 | **MEDIUM** | task-230 `depends_on` omits tasks 220, 222, 225, 228, 229 | task-230.md | Expand dependency list |
| F-087-11 | **LOW** | F-086-01 partially fixed (git-provenance header descoped @ v6.25.3) | audit-086 | task-229: wiki-only IG-35 enforcement |
| F-087-12 | **INFO** | `acp.recurring-complete.sh` not wired into `acp.update.md` | — | Optional task-231 or note in task-223 |

---

## Recommended Plan Amendments (before `/acp-proceed`)

### Amendment A — task-225 rule IDs (BLOCKING)

```diff
- TS-02, API-01, EH-01, CQ-01
+ TS-02, AP-01, EH-01, SC-01
```

### Amendment B — task-221 rescope (BLOCKING)

Change title to: **"Harden memory schema enforcement (MED-066-007)"**

Deliverables:
- Add `patterns.schema.yaml`
- Vitest fixtures for schema validation failures
- Ensure `runSchemaEnforcement()` errors fail CI (not warn-only)

### Amendment C — task-226 rescope

Change to: **"Register commit-sync E2E in coverage registry (GAP-041-07)"**

- Add `e2e/acp.commit-sync.test.sh` and `e2e/acp.repair-tools.test.sh` to `command-e2e-coverage.yaml`
- Add `--memory` validate path test

### Amendment D — task-229 rescope

Change to: **"IG-35 route files_affected drift check (F-086-01)"**

- Compare `git diff --name-only` vs route `files_affected` in `acp-validate.ts` or new script
- Update wiki/skill if descoping

### Amendment E — Populate route `files_affected`

Example route-208:
```yaml
files_affected:
  - docs/USAGE.md
  - agent/routing/tasks/route-162.md
```

### Amendment F — Reconcile route-162

When task-219 completes: stamp `route-162.md completed: 2026-07-15` and reference in carryover.

---

## Revised Build Order (recommended)

| Order | Task | Notes |
|-------|------|-------|
| 0 | **Amend plan** | Fix F-087-01..06 in docs (30 min) |
| 1 | task-219 + route-162 | Branch protection |
| 2 | task-221 (rescoped) | patterns schema + vitest |
| 3 | task-222, task-223 | Field lint + carryover freshness |
| 4 | task-224, task-225 (fixed IDs) | Review gate |
| 5 | task-226 (rescoped) | Coverage registry |
| 6 | task-227 | Atomicity |
| 7 | task-228, task-229 (rescoped) | FIFOZ + IG-35 |
| 8 | task-230 | Release v6.26.0 via PR |

---

## Git History

| Date | Commit | Summary |
|------|--------|---------|
| 2026-07-15 | 9a82ff2 | plan(M70): tech debt and gate hardening milestone |
| 2026-07-15 | 3021aab | v6.25.3 audit-086 carryover hygiene |

---

## Recommendations

1. Run `/acp-plan` amendment pass to fix F-087-01..07 before any implementation
2. Start with **task-219** only after amendments merged
3. Do **not** expand review scanner until rule IDs validated against `acp.review.md`
4. Close MED-066-007 with rescoped task-221, not greenfield schema creation
