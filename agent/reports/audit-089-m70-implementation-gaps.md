# Audit Report: M70 Implementation Post-Completion

**Audit**: #089  
**Date**: 2026-07-15  
**Subject**: M70 implementation — gaps, carryovers, shortcuts  
**Verdict**: **BLOCKED** — milestone marked complete with 6 high-severity gaps; 2 carryovers still open; work uncommitted

---

## Summary

Post-implementation audit of M70 (`/acp-proceed --complete --yes M70`) cross-referenced 12 tasks, 11 routes, carryover registry, milestone shortcuts, and live code. **Substantial in-repo work landed** (8-rule review scanner, patterns schema, validate guards, IG-35 in git-provenance, E2E registry updates). However, **completion was overstated**: task files still `planned`, GAP-041-08 marked `fixed` without integration, branch protection not enabled, and **all changes remain uncommitted** with no `v6.26.0` tag.

**2 carryovers remain `pending`**: CRIT-065-002, F-086-02 (accepted ops deferrals). **3 carryovers were prematurely stamped `fixed`**: GAP-041-08 (atomic-write not wired), MED-066-007 (lessons/decisions schemas not enforced at runtime), task-219 scope (GitHub protection absent).

---

## Carryover Status

| ID | Severity | Status | M70 Claim | Audit Result |
|----|----------|--------|-----------|--------------|
| CRIT-065-002 | critical | **pending** | task-219 ✅ | ❌ `gh api` 404 — protection not enabled |
| F-086-02 | medium | **pending** | task-228 ✅ (deferred) | ⏳ Acceptable ops deferral; feedback-007 §6 unchecked |
| MED-066-007 | medium | fixed | task-221 ✅ | ⚠️ Only patterns+session log "valid"; lessons/decisions/carryovers skipped |
| GAP-041-04 | low | fixed | task-222 ✅ | ✅ `validateMemoryFieldLint()` works |
| GAP-041-07 | medium | fixed | task-226 ✅ | ✅ E2E exists + registry updated |
| GAP-041-08 | medium | fixed | task-227 ✅ | ❌ Helper created; **not wired** into sync paths |
| F-086-03 | medium | fixed | task-224/225 ✅ | ⚠️ Policy OK; `domain.yml` still says 4 rules |
| F-086-04 | low | fixed | task-223 ✅ | ⚠️ Heuristic only; no vitest fixture |

---

## Shortcut Assessment (Milestone Doc)

| Shortcut | Required Resolution | Actual | Verdict |
|----------|---------------------|--------|---------|
| Direct merge to mainline | Branch protection + PR | Script + docs only; GitHub unprotected | ❌ Open |
| `/acp-review` as CI gate | Two-phase policy | `acp.review.md` updated; `domain.yml` stale | ⚠️ Partial |
| Carryover registry drift | `validateCarryoverFreshness` | Implemented (warn-only) | ✅ |
| Memory layer unvalidated | Schemas + field lint | patterns new; array schemas not enforced | ⚠️ Partial |
| Commit sync partial writes | Atomic helper + E2E | `acp.atomic-write.sh` orphan | ❌ Open |
| FIFOZ handoff untested | Consumer verification | Documented deferral | ⏳ Accepted |
| IG-35 phantom rule | Implement or descope | `git-provenance.sh` + validate warn | ✅ |

---

## Key Findings

| ID | Severity | Finding | Location | Fix |
|----|----------|---------|----------|-----|
| F-089-01 | **HIGH** | All 12 task files still `status: planned` — progress.yaml says `completed` | `task-219..230.md:5` | Stamp `status: completed`, `completed: 2026-07-15` on each task |
| F-089-02 | **HIGH** | GAP-041-08 stamped fixed but `acp.atomic-write.sh` unused — sync docs use inline `.tmp` only | `acp.pattern-sync.md:81`, `acp.session-sync.md:80` | Wire helper or revert carryover to pending |
| F-089-03 | **CRITICAL** | CRIT-065-002 open; task-219/route-162 marked complete without GitHub protection | `gh api …/protection` → 404 | Run `acp.branch-protection-setup.sh` with admin |
| F-089-04 | **HIGH** | M70 uncommitted; no `v6.26.0` tag; validate reports missing tag | `git status`, `identity.yml` | `/git-commit` + `git tag v6.26.0` |
| F-089-05 | **MEDIUM** | `lessons.schema` / `decisions.schema` / `audit-carryovers.schema` in map but never log validation — array entries not checked | `acp-validate.ts:1021-1056` | Extend `runSchemaEnforcement` for list documents |
| F-089-06 | **MEDIUM** | `domain.yml` documents 4 review-scan rules, not 8 | `domain.yml:290-291` | Update to EH-01, EH-02, SC-01, TS-01, TS-02, AP-01, NC-01, SH-01 |
| F-089-07 | **MEDIUM** | All 11 M70 routes still `files_affected: []` | `route-208..219.md` | Populate per F-087-05 |
| F-089-08 | **MEDIUM** | No persistent review fixtures dir (task-225 step 2) | `agent/benchmarks/fixtures/review/` | Add fixtures or update task acceptance |
| F-089-09 | **MEDIUM** | `acp.validate.md` missing M70 validator docs | `acp.validate.md` | Document `validateCarryoverFreshness`, branch protection warn |
| F-089-10 | **MEDIUM** | New scripts not in `package.yaml` | `package.yaml` | Add `acp.atomic-write.sh`, `acp.branch-protection-setup.sh` |
| F-089-11 | **LOW** | task-225 title still cites API-01, CQ-01 (invalid IDs) | `task-225.md:4,23` | Update to AP-01, NC-01 |
| F-089-12 | **LOW** | No Phase 1 column in review rule table (task-225 step 4) | `acp.review.md` | Add `Phase 1` column to rules table |
| F-089-13 | **LOW** | audit-088 closure PASS premature | `audit-088-m70-closure.md` | Amend verdict to PASS WITH GAPS |
| F-089-14 | **INFO** | `validateBranchProtectionDocs` warn-only — validate exits 0 | `acp-validate.ts:760` | Consider `--strict` escalation for CRIT carryover |

---

## Code Pointers

| Location | Description |
|----------|-------------|
| `scripts/acp-validate.ts:693-970` | M70 validators: branch protection, field lint, carryover freshness, IG-35 drift |
| `agent/scripts/acp.review-scan.sh:1-5` | 8-rule Phase 1 scanner header |
| `agent/scripts/acp.atomic-write.sh` | Orphan helper — zero references in codebase |
| `agent/scripts/acp.git-provenance.sh:88-118` | IG-35 route files_affected drift |
| `agent/schemas/patterns.schema.yaml` | Only new schema file in M70 |
| `agent/schemas/command-e2e-coverage.yaml:52-57` | commit-sync + repair-tools registered |

---

## Tests Run

| Suite | Result |
|-------|--------|
| vitest | 48/48 pass |
| `e2e/acp.review.test.sh` | 60/60 pass |
| `e2e/acp.commit-sync.test.sh` | 6/6 pass |
| `e2e/acp.repair-tools.test.sh` | 6/6 pass |
| `npx ts-node scripts/acp-validate.ts` | 0 blocking errors; ⚠️ mainline unprotected; ❌ missing v6.26.0 tag |

---

## Git History

| State | Detail |
|-------|--------|
| Branch | `develop` |
| Uncommitted | 17 modified + 3 new files (M70 work) |
| Last commit | Pre-M70 (`9a82ff2` plan only) |

---

## Recommendations

### Before claiming M70 shipped

1. **Commit + tag** — `/git-commit` then `git tag v6.26.0`
2. **Revert premature stamps** — GAP-041-08 → `pending` until atomic-write wired; or wire helper now
3. **Task file sync** — update all 12 task frontmatter to `completed`
4. **Branch protection** — run setup script with GitHub admin (CRIT-065-002)
5. **Wiki parity** — fix `domain.yml` review-scan rule count

### Acceptable deferrals (document only)

- **F-086-02** — FIFOZ consumer `/acp-version-update` (external repo access)

### Readiness Verdict

**BLOCKED** for release — do not merge to `mainline` or tag until F-089-03, F-089-04 resolved and GAP-041-08 honestly closed or reverted.
