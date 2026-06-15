# Audit Report: M57 & M58 — Post-Sync Re-Audit

**Audit**: #069
**Date**: 2026-06-15
**Subject**: Re-audit of M57 (Recurring Tasks Scheduler, v6.12.1) and M58 (/acp-integrity v2.0, v6.13.0) milestones, plans, and tasks — performed AFTER syncing previously-gitignored instance data (milestones, tasks, routing, memory) from `origin/develop`/`origin/mainline`
**Mode**: standard (read-only re-audit; supersedes the gitignore-artifact findings of audit-068)
**Supersedes**: audit-068 findings F-068-01 and F-068-02 (both were gitignore artifacts, now resolved)

## Summary

The user un-gitignored instance data in another editor (commit `90239d9`, on both `origin/develop` and `origin/mainline`) and asked me to verify/sync locally and re-audit M57/M58. I merged `origin/develop` into local `develop` (merge commit, no conflicts) — bringing in 290 previously-ignored files (milestones 1–58, routes 001–156, `decisions.md`, etc.) while preserving my unpushed M59–M63 planning work (milestones 59–63, routes 159–178). The full M57 route set (150–154) and M58 route set (155–158) are now visible and tracked.

**This invalidates audit-068's two headline findings**: the "missing milestone files" (F-068-01) and "missing M58 routes" (F-068-02) were artifacts of the local gitignore, not real gaps. The milestone documents are, in fact, high quality — `milestone-57` and `milestone-58` carry industry-standard mappings (NIST SP 800-53, OWASP SAMM, real CVEs like CVE-2025-68143), a confidence-ceiling model, a go/no-go gate, and a risk register.

However, the sync surfaced a **new dominant problem: status desynchronization across tracking layers.** The synced planning docs are the *original, pre-completion* versions — `milestone-57.md` and `milestone-58.md` both say `Status: planned` / `Started: —`, and `route-155.md` has an empty `completed:` field — yet `progress.yaml` records M57 `completed 100%` and M58 `in_progress 25%`, git history confirms M57 shipped (commit `2f13486`), and route-155's deliverables (research artifact + 12 fixtures + manifest) physically exist. Four tracking sources disagree about the same work. Beyond the desync, the richer M58 spec reveals genuine plan-vs-implementation gaps: **route-155 (marked done) under-delivered against its milestone-defined scope**, and **M58's go/no-go gate is unsatisfiable as sequenced**.

## Sync Verification

| Check | Result |
|-------|--------|
| Merge `origin/develop` → local `develop` | ✅ Clean (ort strategy, 0 conflicts) |
| Previously-ignored files now tracked | ✅ 290 files (milestones 1–58, routes 001–156, decisions.md, manifest.yaml) |
| My M59–M63 milestones preserved | ✅ milestone-59..63 present |
| My routes 159–178 preserved | ✅ 21 of my routes tracked (155 + 159–178); 176 routes total |
| M57 routes 150–154 | ✅ all present |
| M58 routes 155–158 | ✅ all present |
| 3 on-disk collisions (manifest, milestone-58, route-155) | ✅ origin's authoritative versions taken; local copies backed up to `$TEMP/acp-collide-backup` |
| Local branch state | `develop` is 3 commits ahead of `origin/develop` (2 plan commits + merge) — **not yet pushed** |
| 40 "modified" scripts | ⚠️ line-ending churn only (no textual diff); pre-existing, unrelated to sync |

## Files Analyzed (synced versions)

| File | Type | Relevance |
|------|------|-----------|
| `agent/milestones/milestone-57-recurring-tasks-scheduler.md` (206 lines) | doc | M57 full spec — status, hooks, E2E plan |
| `agent/milestones/milestone-58-acp-integrity-v2-semantic-analysis.md` (175 lines) | doc | M58 full spec — confidence model, go/no-go gate, research phase |
| `agent/routing/tasks/route-150..154.md` | doc | M57 task breakdown |
| `agent/routing/tasks/route-155..158.md` | doc | M58 task breakdown |
| `agent/artifacts/research-m58-taint-flow-calibration.md` | doc | route-155 actual output |
| `agent/benchmarks/fixtures/taint-flow/manifest.yaml` + 12 fixtures | test | route-155 ground truth |
| `agent/progress.yaml` (M54/M57/M58, recurring_tasks) | config | Status of record vs milestone docs |
| `agent/core/constraints.yml` (hooks block) | config | M57 hooks impl vs spec |
| `agent/memory/audit-carryovers.md` (F-062-01..05) | memory | M57 deep-dive findings, still pending |

## Key Findings

| ID | Sev | Finding | Location | Notes |
|----|-----|---------|----------|-------|
| F-069-01 | HIGH | **Status desync**: milestone-57.md & milestone-58.md both say `Status: planned` / `Started: —`, contradicting progress.yaml (M57 completed 100% / M58 in_progress 25%) and git history | `milestone-57…md:6-8`; `milestone-58…md:6-8` vs `progress.yaml:280-283,300-306` | Synced docs are pre-completion versions. A reader of the milestone file would conclude the work never started. Single-source-of-truth violation introduced by the sync. |
| F-069-02 | HIGH | **route-155 completion desync**: deliverables exist (research + 12 fixtures + manifest) and progress.yaml counts M58 as 1/4 done, but synced `route-155.md` `completed:` is empty | `route-155.md:12`; deliverables on disk; `progress.yaml:305` (tasks_completed: 1) | Four layers disagree on whether route-155 is done. Auto-stamp (per /acp-commit protocol) never ran on the synced route file. |
| F-069-03 | HIGH | **route-155 scope under-delivery** vs milestone-58 §7: no 10 taint-flow CVEs, no TypeScript sample, no ESLint-security comparison, no empirical TPR (self-deferred to route-158), and **no memory-poisoning UX document** | `milestone-58…md:110-122` vs `research-m58-taint-flow-calibration.md:136-138` | Research is solid *literature* calibration with JS fixtures, but does not meet the milestone's empirical acceptance. Counted complete regardless. |
| F-069-04 | HIGH | **Go/No-Go gate unsatisfiable as sequenced**: milestone-58 §10 gates routes 156–158 on empirical taint TPR thresholds, but research measures no TPR ("measured in route-158"), and route-158 is gated by the gate | `milestone-58…md:153-163`; `research…md:137` | Circular: the gate needs route-158's measurement; route-158 is blocked by the gate. "Proceed" decision rests on literature estimates, not the mandated benchmark. |
| F-069-05 | HIGH | All 5 audit-062 (M57 deep-dive) carryovers still `pending`, incl. F-062-03 (no automated next_due → date drift) | `agent/memory/audit-carryovers.md:28-85` | M57 shipped with its own audit's fixes unresolved; mapped late to route-176/M62. Recommend promoting F-062-03 to M59. (Carries over from audit-068 F-068-03.) |
| F-069-06 | MED | **Hooks spec vs impl divergence**: milestone-57 §3.3 specifies 3 boolean hooks (`pre_commit_rule_file_audit`, `pre_commit_integrity_phase1`, `ci_npm_ignore_scripts`); constraints.yml implements a `pre_commit: [task_id]` array with only the rule-audit hook | `milestone-57…md:128-132` vs `constraints.yml:31-34` | 2 of 3 hooks absent; structure differs; no ADR. (= F-062-01, still pending.) |
| F-069-07 | MED | Fixture manifest encodes only `severity`, not `max_confidence`/`ci_blocking` — but milestone-58 §8 E2E (assertions 4–6, 9) requires asserting confidence ceilings (≤MEDIUM, no HIGH except IG-61) | `manifest.yaml` (no confidence field); `milestone-58…md:131-138` | route-158 ground truth cannot support the mandated confidence assertions as-is. (= audit-068 F-068-04.) |
| F-069-08 | MED | Doc surface still v1.0: `integrity-rules.md` ("Version 1.0.0 \| 55 v1.0 + 15 deferred") and `acp.integrity.md` unchanged despite M58 in_progress | `wiki/integrity-rules.md:4`; `commands/acp.integrity.md:7` | Expected (route-156 not started) but confirms M58 is research-only; un-defer not yet reflected anywhere consumable. |
| F-069-09 | MED | **M54 dangling milestone pointer**: progress.yaml M54 → `milestone-54-ci-cd-gitflow.md` which does not exist even after sync; M54 `status: active, progress: 30, tasks_total: 0` | `progress.yaml:M54 file:`; filesystem (absent) | Residual of audit-068 F-068-01, now scoped to M54 only. `tasks_total: 0` with `active/30%` is itself inconsistent. |
| F-069-10 | LOW | Script naming mismatch: research recommends `acp.taint-heuristic.sh`; route-157/milestone-58 call them `acp.taint-scan.sh` + `acp.memory-scan.sh` (none exist yet) | `research…md:122` vs `route-157.md:24-25` | Cosmetic now, but reconcile before route-157 to avoid a third name. |
| F-069-11 | LOW | recurring_tasks date drift + quarterly-deep-scan invokes unbuilt M58 capability (`--rules taint-flow,memory`) | `progress.yaml:6498-6514` vs `milestone-57…md:85-101` | monthly/quarterly next_due differ from milestone example; quarterly points at a feature not yet shipped. (= audit-068 F-068-10.) |
| F-069-12 | LOW | `acp.meta-scan.sh` uses `set -eu` + ERR trap but not `-o pipefail`; not in route-173's 17-file list | `agent/scripts/acp.meta-scan.sh:32` | Add to route-173 scope. (= audit-068 F-068-12.) |

## Resolved Since audit-068 (by the sync)

| audit-068 ID | Status now | Why |
|--------------|-----------|-----|
| F-068-01 (M54–M57 milestone files missing) | ✅ Resolved for M55/56/57/58 | Now tracked via sync; only M54 remains (→ F-069-09) |
| F-068-02 (M58 routes 156–158 missing) | ✅ Resolved | routes 155–158 all present and tracked |

## Positive Confirmations

- The sync was correct and complete: 290 files of milestone/route/memory history restored, merged cleanly, with my M59–M63 planning work fully preserved.
- `milestone-57` and `milestone-58` are exemplary planning docs: standards tables (NIST SP 800-53 SI-4, OWASP SAMM v2, CIS 18, ISO 27001 A.8.8; OWASP A03/LLM01:2025, CWE-134/601, MITRE ATLAS, real CVE-2025-68143/44/45), an explicit confidence-ceiling model, a self-protection protocol, a go/no-go gate, and a risk register — well above typical milestone rigor.
- route-155's research artifact is genuinely useful (literature-grounded confidence ceilings + 12 calibrated fixtures), even though it under-delivers against the milestone's empirical scope.

## Recommendations

1. **Reconcile status across tracking layers (F-069-01, F-069-02)** — re-stamp the synced planning docs to actual state: `milestone-57` → completed; `milestone-58` → in_progress; `route-150..154` + `route-155` → `completed:` filled. Add a one-time "sync reconciliation" pass and a `/acp-validate` check that flags milestone/route `status` disagreeing with `progress.yaml`.
2. **Decide route-155's fate honestly (F-069-03, F-069-04)** — either (a) finish the missing scope (empirical TPR vs ESLint-security, the memory-poisoning UX doc) so the go/no-go gate has real data, or (b) formally descope milestone-58 §7/§10 to the literature-calibration approach actually taken and record the change as an ADR. Do not leave the gate unsatisfiable.
3. **Promote F-062-03 (auto next_due) into M59** — it's a HIGH correctness gap in a shipped feature; it should not wait for M62/route-176.
4. **Add `max_confidence`/`ci_blocking` to the fixture manifest (F-069-07)** before route-158 so the E2E can assert the confidence ceilings milestone-58 §8 mandates.
5. **Resolve the M54 dangling pointer (F-069-09)** — create `milestone-54-ci-cd-gitflow.md` or remove the pointer; fix `tasks_total: 0` vs `active/30%`.
6. **Reconcile hook spec vs impl + write the ADR (F-069-06)** — folds into route-176.
7. **Complete the bidirectional sync** — push local `develop` (3 commits ahead) to `origin/develop` so the M59–M63 roadmap reaches the remote the user synced. *(Requires your approval — shared-state push.)*

### Verdict

- **Sync: VERIFIED & SUCCESSFUL** — clean merge, nothing lost, both sides integrated locally; push to origin still pending.
- **M57: SHIPPED-WITH-DEBT + STATUS-DESYNCED** — feature is real and well-specified, but its milestone doc reads "planned", and its 5 self-audit findings remain open.
- **M58: RESEARCH-ONLY, PLAN-DESYNCED** — excellent spec, but only route-155 done (and under its own scope), the go/no-go gate is unsatisfiable as written, and the milestone doc still reads "planned". Not shippable until routes 156–158 land and the gate/manifest gaps are closed.
