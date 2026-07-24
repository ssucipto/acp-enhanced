# Audit Report: M78 Implementation — Gaps, Inconsistencies & Carryover Integrity

**Audit**: #99
**Date**: 2026-07-23
**Subject**: Post-implementation audit of M78 (CodeRabbit Optionality Foundation, v6.28.0) — gaps, inconsistencies, carryover hygiene, and shortcuts taken

## Summary

M78's feature deliverables are sound (detection helpers, pattern, E2E 11/11, docs, off-by-default prefs). But this audit found a **real regression I introduced and then mis-reported as "zero regression"**, plus carryover-ledger debt and doc drift. The most important finding: my v6.28.0 version bump **missed `agent/progress.yaml`'s own `version:` field**, which two cross-file E2E checks catch but `acp-validate.ts` does not — and my earlier "8 pre-existing failures, zero M78 regression" conclusion was a **file-level** comparison that masked **new assertion-level failures** inside already-failing files. Honest verdict: M78 shipped with a version-consistency regression and an incomplete carryover ledger. Both are fixable in a focused v6.28.1 remediation (candidate M79).

## Key Findings

| ID | Sev | Finding | Fix |
|----|-----|---------|-----|
| **F-099-01** | high | **Version bump regression** — `agent/progress.yaml:6 version:` (and desc line 11) still `6.27.2` while identity=6.28.0. Caught by `tests/acp.e2e-workflow.test.sh:57` + `tests/acp.security.test.sh:97` cross-file checks; **missed by acp-validate.ts**. My "zero regression" claim (audit-098 closure) was file-level and masked these new assertion failures. | Bump progress.yaml `version:`→6.28.0 + desc; ship v6.28.1 |
| **F-099-02** | medium | **Validator gap** — `acp-validate.ts` version-consistency checks identity/AGENTS/CLAUDE/CHANGELOG/package but **NOT `progress.yaml` version**, so the F-099-01 regression passed validate while E2E caught it. | Add progress.yaml `version:` to `validateVersionConsistency()` |
| **F-099-03** | medium | **Carryover ledger not closed** — F-098-01..07 and F-097-01 were all implemented in M78 but remain `status: pending` in audit-carryovers.md. This is the exact carryover-integrity failure audit-094 flagged. | Mark F-098-01..07 + F-097-01 `fixed`, `verified_in_audit: audit-099` |
| **F-099-04** | low | **Stale doc** — milestone-78 Build Order table (line 43) still says task-256 helpers live in `acp.common.sh`; contradicts the Task Map (correctly `acp.coderabbit.sh`) and what shipped. `Depends on` line 16 also cites the common.sh idiom. | Correct to `acp.coderabbit.sh` |
| **F-099-05** | low | **CWD-relative detection** — `coderabbit_available` does `[[ -f "$config_path" ]]` against CWD; from a subdirectory it mis-reports a CodeRabbit-configured repo as unavailable (verified: subdir → "unavailable"). | Resolve config_path against git repo root |
| **F-099-06** | low | **Task/impl mismatch** — task-259 verification says "AGENTS.md pointer added" but the pointer shipped in README.md only. | Reconcile task-259 acceptance to README (AGENTS.md byte budget favors the lean choice) |

## Carryover Re-Assessment (all checked)

| Carryover | Was | Now (verified) |
|-----------|-----|----------------|
| F-097-01 (optionality contract) | pending | **implemented** → mark fixed/verified (F-099-03) |
| F-098-01 circular source | pending | **fixed** — acp.coderabbit.sh sources preferences.sh |
| F-098-02 agent/docs | pending | **fixed** — doc at agent/wiki/ |
| F-098-03 boolean ==true | pending | **fixed** — coderabbit_active exact match |
| F-098-04 config-only/drop generate_on_commit | pending | **fixed** — config-file detection, key dropped |
| F-098-05 CI auto-discovery | pending | **fixed** — no CI-reg step |
| F-098-06 route files | pending | **addressed** — documented "created at dispatch" |
| F-098-07 version bump enumeration | pending | **partial** — 8/9 files bumped; **progress.yaml version field MISSED** (→ F-099-01) |
| F-086-02 FIFOZ | pending | unchanged — needs downstream repo access |
| F-M78-01 (8 E2E failures) | pending | **root-caused** — see below; mostly genuine pre-existing debt |

## F-M78-01 Root-Cause Triage (the 8 failing test files)

| Test | Location | Root cause | Category |
|------|----------|-----------|----------|
| acp.e2e-workflow | tests/ | (a) progress.yaml version mismatch **[my regression, F-099-01]**; (b) copilot-instructions light-mode assertion | mixed |
| acp.security | tests/ | AGENT.md vs progress.yaml version mismatch **[my regression, F-099-01]** | **my regression** |
| acp.validate-cross-layer | e2e/ | hard error: `cp package.json` — file doesn't exist (project uses package.yaml) | pre-existing test bug |
| acp.version | e2e/ | version-check.sh exits 1 not 2 on missing AGENT.md; test expects 2 | pre-existing |
| acp.project-update | e2e/ | "confirm tag added" / "detect duplicate" git-tag assertions in fixture | pre-existing |
| acp.package-info | e2e/ | one sub-test exit 1≠0 | pre-existing |
| acp.post-milestone-sweep | e2e/ | 4/5 — one sub-test fails | pre-existing |
| acp.validate-ts | tests/ | placeholder-check flags temp fixtures ({COMMAND_NAME}/{NAMESPACE}) | pre-existing |

**Correction to audit-098 closure**: 2 of the 8 (e2e-workflow, security) carry **new** version-mismatch assertions from F-099-01 — not purely pre-existing. Fixing F-099-01 should clear security fully and reduce e2e-workflow to its pre-existing copilot-light-mode assertion. The remaining ~6 are genuine pre-existing debt for separate triage.

## Code Pointers

| Location | Description |
|----------|-------------|
| agent/progress.yaml:6 | `version: 6.27.2` — the missed field (F-099-01) |
| scripts/acp-validate.ts:893 | `validateVersionConsistency` — omits progress.yaml (F-099-02) |
| tests/acp.e2e-workflow.test.sh:57 | cross-file progress↔identity version check that caught it |
| agent/scripts/acp.coderabbit.sh (coderabbit_available) | CWD-relative `-f` test (F-099-05) |
| agent/milestones/milestone-78-…md:43 | stale `acp.common.sh` in Build Order (F-099-04) |

## Recommendations

1. **v6.28.1 closure-integrity remediation (M79)**: fix F-099-01 (version), F-099-02 (validator gap — prevents recurrence), F-099-03 (close carryovers honestly), F-099-04/06 (doc/task reconcile), F-099-05 (detection hardening).
2. **Keep the genuinely pre-existing E2E debt (~6 files) deferred** — root-caused here; triage in a later milestone. Not a shortcut I took, so out of the v6.28.1 scope.
3. **Lesson**: baseline regression comparison must be **assertion-level**, not file-level — a file already failing can silently absorb a new regression. Log to lessons.md.
