# Audit Report: M57 & M58 Implementation and Plan

**Audit**: #068
**Date**: 2026-06-15
**Subject**: M57 (Recurring Tasks Scheduler + Pre-Commit Hook Framework, v6.12.1, completed) and M58 (/acp-integrity v2.0 Semantic Analysis, v6.13.0, in_progress 25%) — implementation completeness, internal consistency, and alignment to industry standards/best practices
**Mode**: standard (read-only)

## Summary

This audit verifies the two most recent feature milestones. **M57** shipped (commit `2f13486`, v6.12.1) as a recurring-task scheduler with a pre-commit hook framework. **M58** is in progress at 25% — only the research/calibration route (route-155) is done; the documentation, scripts, and E2E routes are unbuilt.

Two systemic gaps dominate. First, **milestone traceability is broken**: the `file:` pointers for M54–M57 in `progress.yaml` all point at `agent/milestones/milestone-*.md` files that do not exist on disk, so a reviewer cannot reconstruct what M57 actually delivered or planned. Second, **M57 shipped with all five of its own audit-062 findings still `pending`** (one HIGH: no automated `next_due` calculation), and **M58 is marked `in_progress` while three of its four routes were never expanded into route files** and no detection script exists yet — meaning the milestone's stated capability (`/acp-integrity --rules taint-flow`) is not runnable. Calibration artifacts (research + 12 fixtures) are high quality, but the fixture manifest encodes `severity` without the **confidence-ceiling** the research mandates, risking a future E2E that contradicts the v2.0 "never CRITICAL in `--ci`" self-protection policy.

Net: M57 is functionally complete but under-documented and carries unresolved correctness debt; M58's foundation is sound but the milestone status overstates readiness. Neither blocks the M59 critical track, but both need cleanup before M58 can ship and before external adoption.

## Files Analyzed

| File | Type | Relevance |
|------|------|-----------|
| `agent/progress.yaml` (M54–M58, recurring_tasks) | config | Milestone status, dangling file pointers, scheduler state |
| `agent/milestones/milestone-58-acp-integrity-v2-semantic-analysis.md` | doc | M58 build order, confidence model |
| `agent/artifacts/research-m58-taint-flow-calibration.md` | doc | route-155 calibration, confidence ceilings |
| `agent/benchmarks/fixtures/taint-flow/manifest.yaml` + 12 `.js` fixtures | test | Ground truth for route-158 |
| `agent/routing/tasks/route-155.md` | doc | Only M58 route that exists as a file |
| `agent/memory/audit-carryovers.md` (F-062-01..05) | memory | M57 deep-dive findings, all pending |
| `agent/core/constraints.yml` (hooks block) | config | M57 hook framework; F-062-01 divergence |
| `agent/wiki/integrity-rules.md` | doc | Rule catalogue still v1.0/deferred |
| `agent/commands/acp.integrity.md` | doc | Command still Version 1.0.0 |
| `agent/scripts/acp.meta-scan.sh` | source | Only memory/meta script present |
| git log (`2f13486`, `72d03d8`) | history | M56/M57 commit provenance |

## Key Findings

| ID | Sev | Finding | Location | Notes |
|----|-----|---------|----------|-------|
| F-068-01 | HIGH | M54–M57 milestone artifact files are missing; `progress.yaml` `file:` pointers dangle | `agent/progress.yaml:259,287` → `milestone-56/57-*.md` (absent) | Verified via `git ls-files` + `Get-ChildItem`: only milestone-50/51/52/53/58/59 exist. M57's `file: milestone-57-recurring-tasks-scheduler.md` resolves to nothing. Breaks reviewability/audit reproducibility. |
| F-068-02 | HIGH | M58 marked `in_progress` (25%) but routes 156/157/158 were never expanded into route files | `milestone-58…md:16-18`; `agent/routing/tasks/` (only route-155 present) | Milestone build order cites 4 routes; 3 don't exist. No `acp.taint-heuristic.sh`. The capability the milestone claims is not runnable. Status overstates readiness. |
| F-068-03 | HIGH | All 5 audit-062 (M57 deep-dive) carryovers still `status: pending`, incl. F-062-03 (no automated `next_due` → date drift) | `agent/memory/audit-carryovers.md:28-85` | M57 shipped the scheduler but never applied its own audit's fixes. Mapped to route-176 (M62) — but M62 is late in the queue while a HIGH correctness gap lives in a shipped feature. |
| F-068-04 | MED | Fixture manifest encodes `severity` but not the research-mandated `max_confidence`/CI policy | `agent/benchmarks/fixtures/taint-flow/manifest.yaml:12,24,34` (`severity: CRITICAL`) | Research mandates MEDIUM ceiling + "never CRITICAL in `--ci`" (`research…md:21-23,129`). Severity (impact) ≠ confidence (certainty). route-158 E2E built only on severity could assert CRITICAL output, contradicting the self-protection protocol. Add `max_confidence`/`ci_blocking` per fixture. |
| F-068-05 | MED | F-062-01: `constraints.yml` hooks block diverged from M57 plan (only 1 of 3 planned hooks); no ADR | `agent/core/constraints.yml:31-34` | Only `pre_commit → pre-commit-rule-audit` present; `ci_npm_ignore_scripts` and the 3-boolean form are absent. Architectural drift undocumented. |
| F-068-06 | MED | F-062-04: reference git hook `agent/examples/pre-commit-hook.sh` (and `agent/examples/`) does not exist | filesystem (absent) | The on-commit trigger (`pre-commit-rule-audit`) has no working reference wiring; users can't connect the scheduler to git. |
| F-068-07 | MED | Neither integrity-rules.md nor acp.integrity.md reflect any v2.0 surface; both still "v1.0 / DEFERRED to v2.0 (M58)" | `wiki/integrity-rules.md:4,111`; `commands/acp.integrity.md:7,160` | Consistent with route-156 (`not_started`) but means despite M58 `in_progress` + fixtures shipped, the doc surface is unchanged. The wiki "55 v1.0 + 15 deferred" line is becoming stale. |
| F-068-08 | MED | F-062-05: recurring_tasks entries lack `last_findings_count` (no findings→task feedback loop) | `agent/progress.yaml:6470-6514` | Weekly scan could re-find the same issue indefinitely with no automated tracking. |
| F-068-09 | LOW | Calibration fixtures are JS-only and single-file; no multi-file/interprocedural or TS/Python cases | `fixtures/taint-flow/*.js`; `research…md:136-138` | Documented as a known limit, but industry SAST calibration expects interprocedural + multi-language. Acceptable for v2.0 MVP if explicitly scoped. |
| F-068-10 | LOW | `quarterly-deep-scan` recurring task invokes unbuilt M58 capability `--rules taint-flow,memory` | `agent/progress.yaml:6507-6514` | `next_due: 2026-09-08` (future) and `last_run: null` — tolerable, but a scheduled command points at a feature that doesn't exist yet. |
| F-068-11 | LOW | route-155 `files_affected` uses a glob (`…/taint-flow/*`); body lists files explicitly | `agent/routing/tasks/route-155.md:15` | Frontmatter/body inconsistency; convention prefers explicit file lists for deterministic verification. |
| F-068-12 | LOW | `acp.meta-scan.sh` uses `set -eu` + ERR trap but not `-o pipefail` | `agent/scripts/acp.meta-scan.sh:32` | Partial case of audit-065 H4 (route-173). meta-scan isn't in route-173's 17-file list — confirm it's covered or add it. |

## Positive Confirmations

- route-155 calibration is genuinely high quality: research artifact cites sources w/ access dates, defines per-rule TPR/TNR + confidence ceilings, and ships 12 fixtures (6 vulnerable / 6 safe) with a manifest — exactly what a research-first milestone should produce.
- M57 did ship an E2E (route-154, "16 assertions PASS" per progress.yaml notes) and a `## Step 4.5` scheduler protocol across AGENTS.md/CLAUDE.md/copilot-instructions.md, plus `acp.validate.md` Step 2d validation — the runtime feature is real, only its docs/carryovers lag.
- M58 fixture severities (IG-45/46/47 = CRITICAL, IG-48/49/50 = HIGH) are internally consistent with the rule catalogue (`integrity-rules.md:117-122`).

## Industry-Standard Alignment

| Area | Standard / best practice | M57/M58 status |
|------|--------------------------|----------------|
| Milestone traceability | Each milestone has a durable artifact reachable from the index | 🔴 M54–M57 files missing (F-068-01) |
| SAST calibration | Document TPR/TNR, confidence, ground-truth fixtures before shipping detectors | 🟢 research+fixtures present; 🟡 confidence not in manifest (F-068-04) |
| Confidence ceilings on LLM security | Advisory, non-blocking for low-confidence semantic findings (avoid CI false-fail) | 🟡 policy documented, not yet encoded in test ground truth |
| Scheduler correctness | Automated due-date computation; no manual date entry | 🔴 F-062-03 pending (F-068-03) |
| Reference implementations | Ship runnable example wiring for hooks | 🔴 example hook missing (F-068-06) |
| Test coverage of new logic | Core logic covered by automated tests | 🟡 M57 has E2E; 🔴 M58 detection has fixtures but no runner/E2E (route-158) |

## Code Pointers

| Location | Description |
|----------|-------------|
| `agent/progress.yaml:287` | M57 `file:` → milestone-57-recurring-tasks-scheduler.md (does not exist) |
| `agent/progress.yaml:300-306` | M58 in_progress, progress 25, tasks_completed 1/4 |
| `agent/benchmarks/fixtures/taint-flow/manifest.yaml:12-13` | `severity: CRITICAL` with no `max_confidence` field |
| `agent/artifacts/research-m58-taint-flow-calibration.md:80,129` | CI policy: only unambiguous script hits may exit 1; never CRITICAL |
| `agent/core/constraints.yml:31-34` | Hooks block — single hook, divergent from M57 plan |
| `agent/memory/audit-carryovers.md:55-61` | F-062-03 HIGH — no automated next_due (still pending) |
| `agent/progress.yaml:6507-6514` | quarterly-deep-scan → unbuilt `--rules taint-flow,memory` |

## Git History

| Date | Commit | Summary |
|------|--------|---------|
| 2026-06-15 | `09209e2` | plan(M60-M63): expand milestones into 14 route files |
| 2026-06-15 | `447a001` | plan(M59-M63): roadmap from audit-065/066/067 |
| 2026-06-08 | `2f13486` | docs(M57): complete recurring tasks scheduler + maintenance sync |
| 2026-06-07 | `72d03d8` | feat: M56 /acp-integrity v1.0 (v6.12.0) |

## Recommendations

1. **Reconstruct the missing milestone files (F-068-01)** — create `milestone-54..57-*.md` (at minimum M57) from progress.yaml notes + git history, or change the convention and remove dangling `file:` pointers. Highest priority: it blocks any meaningful review of M57. *(~1h; new route, suggest M59 or a docs-debt route.)*
2. **Correct M58 status or expand its routes (F-068-02)** — either expand route-156/157/158 into files now (consistent with the M60-M63 expansion just done) or downgrade M58 to `planned`/`progress: 10` so status reflects reality. Recommend expanding the 3 route files. *(~1h planning.)*
3. **Pull F-062-03 (auto `next_due`) forward (F-068-03)** — it's a HIGH correctness gap in a shipped feature; consider promoting it out of route-176/M62 into the M59 critical track. The other four F-062 items can stay in route-176.
4. **Add `max_confidence`/`ci_blocking` to the fixture manifest (F-068-04)** before route-158 is written, so the E2E ground truth encodes the confidence-ceiling policy, not just severity. Update route-157/158 acceptance to assert "no CRITICAL auto-fail on taint fixtures in `--ci`".
5. **Ship the reference hook + document the hooks divergence (F-068-05, F-068-06)** — create `agent/examples/pre-commit-hook.sh` and an ADR for the hooks-block format change (folds into route-176).
6. **Add `last_findings_count` to recurring_tasks (F-068-08)** and align quarterly-deep-scan scheduling with M58 delivery (F-068-10).
7. **Low-sev cleanups (F-068-09/11/12)** — fold into existing route-173 (add meta-scan to pipefail scope) and route-177 (route-155 glob); keep the JS-only fixture limit as an explicit documented scope note in M58.

### Verdict

**M57: SHIPPED-WITH-DEBT** — feature works; documentation artifact missing and 5 self-audit findings unresolved.
**M58: FOUNDATION-ONLY** — excellent calibration, but status overstates progress; not shippable until routes 156-158 are built and the confidence-ceiling policy is encoded in the test ground truth.
