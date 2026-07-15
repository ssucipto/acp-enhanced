# Milestone 72: Validation Truth & Drift Hardening

<!-- @acp.meta.milestone
topic: validation, drift, parity, ci, audit-091
description: Close all audit-091 findings and pending carryovers with enforcement, not just fixes
status: planned
updated: 2026-07-15
@acp.meta.end -->

**Planned version**: 6.27.0
**Status**: in_progress (3/8 — task-241 complete)
**Estimated effort**: ~20h (8 tasks)
**Source**: audit-091 (whole-system gaps & standards)
**Amended**: 2026-07-15 per audit-092 pre-impl readiness — F-092-01 (manifest regen), F-092-02 (closure renumbered → audit-093), F-092-03 (gitignore scope/D9 policy), F-092-04 (shellcheck prereq, field shapes)
**Design**: [m72-validation-truth-drift-hardening.md](../design/m72-validation-truth-drift-hardening.md)

## Goal

Close **all audit-091 findings (F-091-01..14)** and **all addressable pending carryovers** (CRIT-065-002; F-086-02 stays on task-239/M71 ops; F-092-01..04 folded in by this amendment). Core principle from the design doc: *a drift fix only counts when it lands together with the enforcement check that would have caught it.* No feature work — hardening only.

## Build Order

| Phase | Route | Task | Title | Findings | Est. | Priority |
|-------|-------|------|-------|----------|------|----------|
| **1** | route-229 | task-240 | Drift closures (versions, sync, registrations, evidence-dir gitignore per D9) | F-091-01, 02, 14; F-092-03, 04 (fix half) | 2h | P0 |
| **1** | route-230 | task-241 | Validator hardening (root, zero-fail, hash, pkg, 5-surface, addability) | F-091-01..05, 14 (enforce half) | 5h | P0 |
| **2** | route-231 | task-242 | Wrapper strays + bootstrap dead-glob cleanup + manifest regen | F-091-04, 06; F-092-01 (partial) | 2h | P1 |
| **2** | route-232 | task-243 | Docs alignment (validate.md, lessons, notes, pipefail rationale, /acp-verify pointer) | F-091-05(doc), 07, 11, 12 | 2h | P1 |
| **2** | route-233 | task-244 | ShellCheck CI gate (install prereq per F-092-04) | F-091-10; F-092-04 | 3h | P1 |
| **3** | route-234 | task-245 | Hygiene ops (commit tree, sessions compaction, dependency audit) | F-091-08, 09, 13 | 2h | P2 |
| **3** | route-235 | task-246 | Branch protection ops + PR to mainline | CRIT-065-002 | 1h | P0 |
| **4** | route-236 | task-247 | M72 closure audit (audit-093) + manifest-clean gate + ship v6.27.0 | all F-091 + F-092 re-verify | 3h | P0 |

Dependency notes: task-241 depends on task-240 (fixed state must exist before checks assert it); task-242/243 depend on task-241 (parity re-run validates cleanup); task-247 depends on all.

## Task Map

| Task | Route | Deliverable | Gate |
|------|-------|-------------|------|
| [task-240](../tasks/milestone-72-validation-truth-drift-hardening/task-240-drift-closures.md) | route-229 | package.yaml 6.26.0; copilot-instructions resync; hook installed; 3 scripts registered | F-091-01/02 fix-half done |
| [task-241](../tasks/milestone-72-validation-truth-drift-hardening/task-241-validator-hardening.md) | route-230 | ROOT-anchored validator; zero-found=fail; hash sync check; pkg version check; 5-surface parity | F-091-01..05 enforced + vitests |
| [task-242](../tasks/milestone-72-validation-truth-drift-hardening/task-242-wrapper-bootstrap-cleanup.md) | route-231 | 6 dot-strays deleted; bootstrap globs fixed; wrappers regenerated | F-091-04/06 fixed |
| [task-243](../tasks/milestone-72-validation-truth-drift-hardening/task-243-docs-alignment.md) | route-232 | validate.md Step 11.6 + session keys corrected; lessons/notes updated; pipefail rationale | F-091-07/11/12 fixed |
| [task-244](../tasks/milestone-72-validation-truth-drift-hardening/task-244-shellcheck-ci.md) | route-233 | shellcheck job in ci.yaml (SHA-pinned, error-severity) | F-091-10 fixed |
| [task-245](../tasks/milestone-72-validation-truth-drift-hardening/task-245-hygiene-ops.md) | route-234 | Claude-integration commit; sessions.md compacted; dependency audit run | F-091-08/09/13 fixed |
| [task-246](../tasks/milestone-72-validation-truth-drift-hardening/task-246-branch-protection-pr.md) | route-235 | mainline protected; PR develop→mainline opened | CRIT-065-002 fixed |
| [task-247](../tasks/milestone-72-validation-truth-drift-hardening/task-247-m72-closure-ship.md) | route-236 | audit-093 PASS; v6.27.0 tagged; carryovers honestly stamped | M72 complete |

## Anti-Shortcut Guardrails

Binding for every task (full text in design doc §Anti-Shortcut Guardrails):

1. No doc-only fixes — fix + enforcement land together or the carryover stays `pending`.
2. No vacuous greens — zero-population checks must fail.
3. No carryover stamped `fixed` without audit-093 re-verification.
4. No command-doc edit without regenerating all 4 wrapper surfaces + parity re-run.
5. No validator change without a vitest (positive + negative fixture).
6. No release without CHANGELOG + tag + package.yaml + instruction headers.
7. Memory writes at moment of discovery (per-phase session entries).
8. Repo-root discipline — documented invocations from root only.
9. No mixed commits — Claude-integration tree commits separately (task-245) before validator edits touch adjacent files.
10. No manifest drift — tasks touching manifest-covered files regenerate integrity-manifest in the same task; closure requires clean `/acp-integrity --diff` (D10).
11. No silent policy changes — D9 evidence-dir decision is recorded; future gitignore policy shifts need an ADR.

## Verification Gates

- [ ] `npx tsx scripts/acp-validate.ts` from repo root: 0 errors; from `scripts/` cwd: loud failure (not vacuous pass)
- [ ] Parity reports 5 surfaces, 0 strays; deliberately breaking one wrapper file makes it fail (negative test)
- [ ] `package.yaml` version check present and passing at 6.27.0
- [ ] AGENTS.md / CLAUDE.md / copilot-instructions.md content-hash identical
- [ ] ShellCheck job green in CI
- [ ] vitest suite ≥ 34 passing (28 + ≥6 new)
- [ ] `gh api repos/.../branches/mainline/protection` returns 200
- [ ] `agent/integrity-manifest.yaml` regenerated; `/acp-integrity --diff` clean (F-092-01)
- [ ] `git ls-files agent/reports agent/feedback` covers all on-disk files; clarifications/drafts/preferences still ignored (D9)
- [ ] audit-093 PASS verdict; all F-091 + F-092 carryovers `fixed` with audit-093 pointer
- [ ] `git tag v6.27.0` exists; CHANGELOG entry present

## Accepted Deferrals

| Item | Condition |
|------|-----------|
| F-086-02 FIFOZ consumer verification | Stays task-239 (M71, P3 ops) — requires downstream repo access; not duplicated in M72 |
| ShellCheck warning-level ratchet | Follow-up after error-level gate lands green |
| M58 Phase-2 semantic rules | Still gated on ADR-10 exit criteria — untouched by M72 |
