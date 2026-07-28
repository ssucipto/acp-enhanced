# Audit Report: M83 Pre-Implementation Readiness

**Audit**: #104
**Date**: 2026-07-27
**Subject**: M83 — Deterministic Local Review Engine (17 tasks, 6 phases)
**Mode**: `--pre-impl`
**Executor**: claude-opus-5

---

## Summary

M83's plan structure is sound — 17 task files exist, the milestone doc and `progress.yaml` agree, cross-layer validation is clean, and all 18 owned carryovers map to a task. Phase 2 cross-referencing against the live codebase found **7 gaps**, one of them a silent-failure class.

The important one: three tasks add preference keys, but **none updates the `_index:` array** in `acp.configurables.yaml`. That array is what `generate_preferences` iterates (`acp.preferences.sh:223-256`), so keys omitted from it are silently absent from generated preference files — and **no validator catches this**. dupehound and gitleaks would appear to be wired up while their opt-in preferences never materialise.

The plan's core technical assumptions all held up. String-enum preferences via `options:` are genuinely implemented and validated (`acp.preferences.sh:352-365`), so task-292's three-valued `auto|true|false` design works as designed. `tests/fixtures/` is confirmed addable (not caught by any gitignore rule, unlike the `agent/reports/` incident of 2026-07-15).

One finding is pre-existing rather than a plan defect and worth calling out: `agent/wiki/domain.yml:390` already claims `acp.review.test.sh` covers *"acp.review-scan.sh behavioral fixtures"*. F-102-08 proved that suite asserts documentation strings only. The wiki has been asserting test coverage that never existed.

**Verdict: READY WITH AMENDMENTS.** Nothing blocks task-280. Six task files need small edits before their phase begins.

---

## Phase 1 — Plan Correctness

| Check | Result | Notes |
|-------|--------|-------|
| Milestone doc exists | ✅ | `milestone-83-deterministic-review-engine.md`, status `planned` |
| All 17 task files exist | ✅ | `task-280` … `task-296` |
| progress.yaml entries | ✅ | M83 block + 17 task entries, `tasks_total: 17` |
| Cross-layer status agreement | ✅ | `validateStatusConsistency` passes |
| File pointers resolve | ✅ | `validateFilePointers` passes |
| Schema validity | ✅ | `progress.schema.yaml` valid; `--memory` clean, exit 0 |
| Acceptance criteria unambiguous | ✅ | every task has Verification + User-Observable Acceptance |
| Dependency graph coherent | ✅ | 282/283/284 correctly declare `blocks:`; 296 depends on all 16 |
| Open blockers | ✅ None | M83 depends on nothing gated |

---

## Phase 2 — Code Cross-Reference

| # | File | Verified | Result |
|---|------|----------|--------|
| 1 | `agent/configurables/acp.configurables.yaml` | `_index:` array enumerates all preference keys | ❌ **tasks 290/292/293 omit it** |
| 2 | `agent/scripts/acp.preferences.sh:352-365` | `options:`/string-enum support real | ✅ implemented + validated |
| 3 | `agent/configurables/acp.configurables.yaml:182` | `integrations:` block accepts new children | ✅ slots in beside `coderabbit:` |
| 4 | `agent/schemas/command-e2e-coverage.yaml` | registry key shape | ❌ keys on **commands**, not scripts |
| 5 | `scripts/PRD-MAIN.md`, `IP_REGISTER.md` | exist; soft version requirements | ❌ **absent from task-296 `files_affected`** |
| 6 | `agent/scripts/acp.integrity-output.sh:18-28` | `ig_parse_common_args` arg order | ⚠️ breaks at first non-flag |
| 7 | `tests/fixtures/` | exists / addable | ⚠️ **does not exist**; addability verified OK |
| 8 | `agent/wiki/domain.yml:390` | claimed coverage vs reality | ❌ claims fixtures that don't exist |
| 9 | `package.yaml:183,583` | `acp.review-scan.sh` registered | ✅ precedent confirmed for new scripts |
| 10 | `scripts/package-lock.json` | tracked in git | ⚠️ task-286 rationale wrong (see F-104-05) |
| 11 | `agent/scripts/acp.coderabbit.sh` | 3-gate reference shape for task-292 | ✅ matches planned helper |
| 12 | `agent/scripts/acp.package-install.sh:527` | consent-prompt idiom for task-293 | ✅ `read -p "… (y/N)"` exists |

### Findings

**F-104-01 · HIGH · silent failure**
`agent/configurables/acp.configurables.yaml` carries an `_index:` array (line ~31) that `generate_preferences` iterates at `acp.preferences.sh:223-256` to enumerate preference paths. Tasks 290, 292, and 293 add `integrations.dupehound.enabled`, `integrations.dupehound.min_tokens`, `integrations.dupehound.install_prompt_version`, and gitleaks keys — **none of them mentions `_index:`**. Keys absent from the array are omitted from generated preference files with no error. No validator checks `_index` completeness, so this fails silently and would look like a broken opt-in gate.
→ Add `_index:` updates to the Steps of tasks 290, 292, 293. Consider a validator for `_index` ↔ definition parity as a follow-up.

**F-104-02 · MEDIUM**
`acp.validate.md` step 2c lists `scripts/PRD-MAIN.md` (`**Version:** X.Y`) and `IP_REGISTER.md` (`**Current Version** | X.Y.Z`) as soft version requirements. Both files exist. Task-296's `files_affected` omits both, so the v6.29.0 bump would leave them stale and emit soft warnings.
→ Add both to task-296 `files_affected` and Step 6.

**F-104-03 · MEDIUM**
Task-281 says "register the suite in the command E2E coverage registry." `agent/schemas/command-e2e-coverage.yaml` keys on **commands** (`acp.review:`), not scripts. Creating an `acp.review-scan:` key would not match any command doc and could fail `validateCommandE2eCoverage`.
→ Amend task-281: append `e2e/acp.review-scan.test.sh` to the existing `acp.review.suites[]` array.

**F-104-04 · LOW**
`tests/fixtures/` does not exist. Tasks 281, 284, 290, 292 assume it. Addability probed clean (no gitignore rule catches it — unlike the `agent/reports/` bare-dir incident). Note also that M81's task-270 claims to create the same directory; if M81 unblocks later, both must tolerate its pre-existence.
→ Make task-281 explicitly create it with `mkdir -p`.

**F-104-05 · LOW**
Task-286's verification says *"SC-15 does not fire on this repo (lockfiles are development-only here)"*. `scripts/package-lock.json` is **tracked in git**, so SC-15 passes because the lockfile is committed — not because of the framework/protocol qualifier. The expectation is right; the stated reason is wrong and would mislead whoever implements it.
→ Correct the rationale in task-286.

**F-104-06 · MEDIUM**
`ig_parse_common_args` (`acp.integrity-output.sh:18-28`) `break`s at the first non-flag argument, leaving everything after it in `IG_REMAINING_ARGS`. Task-280 replaces the scalar `TARGET` with an array that appends positionals — so `acp.review-scan.sh scripts/ --ci` would append `--ci` **as a scan path**. The current scalar code has the same latent bug, but the array design makes silent mis-scanning likelier.
→ Task-280 must reject or re-handle flags encountered after positionals, and task-281 must assert the flags-after-path case.

**F-104-07 · LOW · pre-existing**
`agent/wiki/domain.yml:390` describes `acp.review.test.sh` as covering *"acp.review-scan.sh behavioral fixtures"*, `test_count: 54`. F-102-08 established that suite executes nothing — it asserts documentation strings. The wiki has advertised scanner test coverage that never existed, which plausibly contributed to nobody noticing the multi-path bug.
→ Correct the domain.yml entry in task-281 when the real behavioural suite lands.

---

## Phase 3 — Carryover Check

**22 pending** (the `rg -c 'status: pending'` count of 23 includes the file's header comment).

| Carryover | Severity | Owner | Blocks M83? |
|-----------|----------|-------|-------------|
| F-101-02, 03, 05, 06 | high/medium | M81 | **No** — CodeRabbit fixture gate (ADR-22), out of scope |
| F-102-01, 02, 03 | high/high/medium | task-280 | No |
| F-102-04, 06 | medium/low | task-296 | No |
| F-102-05 | medium | task-285 | No |
| F-102-07 | medium | task-292 | No |
| F-102-08 | medium | task-281 | No |
| F-103-01, 02 | high | task-282 | No |
| F-103-03, 10 | high/medium | task-290 | No |
| F-103-04, 05, 06, 07 | high/medium | task-283 | No |
| F-103-08 | medium | task-294 | No |
| F-103-09 | medium | task-295 | No |

All 18 M83-owned carryovers map to exactly one task. No orphans, no duplicates, none stale (`validateCarryoverFreshness` and audit-stamp checks pass). The 4 M81 entries are correctly parked and independent.

---

## Phase 4 — Operational Completeness

| Check | Result | Notes |
|-------|--------|-------|
| Route files exist | ⚠️ N/A | M83 has none — but **M82 (most recent, completed) also had none**; M81 used them. Precedent supports either; consistent with latest |
| Version bump planned | ⚠️ Incomplete | task-296 covers the set **minus** PRD-MAIN.md + IP_REGISTER.md (F-104-02) |
| CHANGELOG entry planned | ✅ | task-296 Step 6 |
| Instruction-file hash sync | ✅ | AGENTS/CLAUDE/copilot all listed in task-296 |
| ADR planned | ✅ | ADR-23 in task-291, gates 292/293 |
| Pattern doc amendment | ✅ | task-291 amends `local.optional-external-tool.md` |
| Wiki updates planned | ✅ | domain.yml (281, 296), `dupehound-integration.md` (293) |
| New scripts registered | ✅ | `package.yaml` listed in 284, 290, 292 `files_affected` |
| E2E coverage registration | ⚠️ | mechanism imprecise (F-104-03) |

---

## Phase Summary

| Phase | Findings | Highest Severity |
|-------|----------|-----------------|
| Phase 1 — Plan Correctness | 0 | none |
| Phase 2 — Code Cross-Reference | 7 | **high** |
| Phase 3 — Carryover Check | 0 | none |
| Phase 4 — Operational Completeness | 3 (overlap with Phase 2) | medium |
| **Total** | **7 distinct** | **high** |

---

## Readiness Verdict

**READY WITH AMENDMENTS** — no finding blocks task-280, but six task files need edits before their phase starts; F-104-01 would otherwise fail silently.

### Amendments before starting each phase

| Before | Amend | Finding |
|--------|-------|---------|
| Phase 1 (now) | task-280 — flags after positionals; task-281 — `mkdir -p tests/fixtures`, `acp.review.suites[]` append, domain.yml:390 correction | F-104-06, 04, 03, 07 |
| Phase 3 | task-286 — fix SC-15 rationale | F-104-05 |
| Phase 3b/4 | tasks 290, 292, 293 — add `_index:` updates to Steps | **F-104-01** |
| Phase 6 | task-296 — add PRD-MAIN.md + IP_REGISTER.md | F-104-02 |

### Recommended follow-up

Add an `_index` ↔ definition parity check to `scripts/acp-validate.ts`. F-104-01 is a silent-failure class that no existing validator covers, and it will recur for every future preference key. Worth folding into task-295 or tracking as a separate carryover.

---

**Files cross-referenced**: 12 · **Findings**: 7 · **Carryovers**: 22 reviewed, 7 written
