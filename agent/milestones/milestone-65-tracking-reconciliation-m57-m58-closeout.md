# Milestone 65: Tracking Reconciliation & M57/M58 Closeout

**Shipped version**: 6.20.2  
**Status**: completed
**Priority**: HIGH (single-source-of-truth integrity + unblocks M58 v2.0)
**Estimated effort**: ~12h (5 routes)
**Source**: audit-068 (residuals), audit-069 (post-sync re-audit), audit-065 straggler
**Depends on**: none (mostly tracking/docs + one validate.ts feature)
**Relates to**: M58 (this milestone repairs M58's plan so v2.0 work can proceed)

---

## 1. Goal

Restore single-source-of-truth integrity across the milestone/route/progress.yaml/git layers, and close out the open M57/M58 findings so v2.0 semantic work can resume on a sound footing.

The merge of `origin/develop` (commit `90239d9`) restored historical planning docs in their **pre-completion** state, creating status desync: `milestone-57/58.md` say "planned" while `progress.yaml` and git history say completed/in-progress; M59–M63 milestone docs + route-150..178 exist on disk but were never registered in `progress.yaml` (still `current_milestone: M58`). M58's plan also has a circular go/no-go gate and a route (155) that was counted complete while under-delivering its stated scope. This milestone makes the tracking truthful and adds a guard so it can't silently drift again.

---

## 2. Build Order

| Route | Title | Addresses | Est. | Status |
|-------|-------|-----------|------|--------|
| route-185 | Reconcile status across layers: re-stamp milestone-57/58, fill route-150..155 completed, register M59–M65 in progress.yaml, fix M54 pointer | F-069-01, F-069-02, F-069-09 | 3h | completed |
| route-186 | Add cross-layer status + dangling-pointer checks to `/acp-validate` (prevent future desync) | F-069-01 (prevention), F-069-09 (prevention) | 3h | completed |
| route-187 | M58 plan correction via ADR: fix circular go/no-go gate, reconcile route-155 scope, add fixture `max_confidence`/`ci_blocking`, canonical taint script name | F-069-03, F-069-04, F-068-04/F-069-07, F-069-10 | 3h | completed |
| route-188 | M57/M58 hygiene: promote F-062-03 to M59, gate quarterly-deep-scan until v2.0, add acp.meta-scan.sh to pipefail scope, ensure wiki v2.0 surface tracked | F-068-03/F-069-05, F-068-10, F-068-12, F-068-07 | 1.5h | completed |
| route-189 | Capture this project's ADR history (`/acp-decide` reconstruction of key ADRs) | CRIT-065-001 | 1.5h | completed |

---

## 3. Industry-Standard Alignment

| Principle | Requirement | Enforced by |
|-----------|-------------|-------------|
| Single source of truth | One authoritative status per work item | route-185 + route-186 guard |
| Traceability | No dangling references between tracking artifacts | route-186 |
| Decision provenance (ADR discipline) | Architectural decisions recorded | route-187 (ADRs), route-189 |
| Honest acceptance criteria | A task is "done" only if it met its stated scope (or was formally descoped) | route-187 |

---

## 4. Milestone-Level Exit Criteria (double-verify gate)

- `milestone-57.md` Status = completed; `milestone-58.md` Status = completed — matching `progress.yaml` and git history (M58 Phase 2 shipped v6.20.0, all 4 routes 155–158 done).
- `progress.yaml` contains registered entries for M59, M60, M61, M62, M63, M64, M65 with correct `file:` pointers; `current_milestone` reflects the active track.
- `route-150..155` have `completed:` stamps consistent with `progress.yaml` counts.
- No dangling `file:` pointers in `progress.yaml` (M54 created or removed; `tasks_total` consistent with status).
- `/acp-validate` gains (and passes) a check that FAILS when a milestone/route status disagrees with `progress.yaml` or a `file:` pointer dangles — proven by a deliberately-mismatched fixture.
- M58 go/no-go gate is non-circular (ADR recorded); route-155 either finished-to-scope or formally descoped via ADR; taint fixtures carry `max_confidence`/`ci_blocking`; one canonical taint script name.
- F-062-03 promoted to M59; quarterly-deep-scan gated/annotated until v2.0 ships; `acp.meta-scan.sh` upgraded to `set -euo pipefail`.
- `CHANGELOG.md` entry for v6.20.2.
- Carryovers F-068-03/04/07/10/12 and F-069-01..10 and CRIT-065-001 marked `fixed` with `verified_in_audit`.

---

## 5. References

- `agent/reports/audit-069-m57-m58-post-sync-reaudit.md`, `agent/reports/audit-068-m57-m58-implementation-gap-analysis.md`
- `agent/milestones/milestone-57-recurring-tasks-scheduler.md`, `milestone-58-acp-integrity-v2-semantic-analysis.md`
- `agent/routing/tasks/route-150.md`..`route-158.md`
- `agent/artifacts/research-m58-taint-flow-calibration.md`, `agent/benchmarks/fixtures/taint-flow/manifest.yaml`
- `scripts/acp-validate.ts` (cross-layer checks), `agent/commands/acp.decide.md`

*Milestone 65 | ACP Enhanced v6.20.2 | audit-068 + audit-069 | 2026-06-15*
