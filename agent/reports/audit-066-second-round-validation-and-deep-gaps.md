# Audit Report: ACP Enhanced — Second-Round Validation & Deep Gap Analysis

**Audit**: #066  
**Date**: 2026-06-15  
**Subject**: Second-round audit on top of audit-065 — validate/challenge round-1 findings, deep-dive areas surveyed shallowly, surface new gaps. Same purpose: gaps, inconsistencies, development directions, production-readiness for startup engineering tooling.  
**Builds on**: audit-065 (comprehensive gap analysis)

---

## Summary

This is a second-opinion audit. Round 1 (audit-065) cast a wide net across 23 files and found 22 findings. This round does two things round 1 did not: (1) **validates** round-1 findings against the actual code — confirming, correcting, or downgrading each; and (2) **deep-dives** the TypeScript tooling, CI validation wiring, and YAML parser — areas round 1 only listed but never opened.

**Headline result**: Round 1 was directionally correct but had one **misdiagnosis** (decisions.md) and **missed a data-loss bug** more severe than anything it found. The single most important new finding is that `acp-dispatch.ts` **overwrites `core/routing.yml`**, destroying the `context_modes` and `command_suggestions` configuration on every Persona B/C dispatch. Round 1 also missed that **the CI validation pipeline is partly a no-op** — structural command checks never run.

This round: **5 corrections** to audit-065 + **8 new findings** (1 High data-loss, 2 High CI-validation, 4 Medium, 1 Low).

---

## Part A — Validation of Audit-065 Findings

| audit-065 ID | Verdict | Detail |
|--------------|---------|--------|
| CRIT-065-001 (decisions.md missing) | ⚠️ **DOWNGRADE → Medium** | **Misdiagnosed.** `agent/.gitignore:34` lists `memory/decisions.md` as instance data (alongside sessions.md, lessons.md). Storage is not "missing" — the file is intentionally local-only and created on first `/acp-decide`. The real (smaller) finding: this framework-dev project never ran `/acp-decide`, so its own 57-milestone decision history is uncaptured. This is a discipline gap, not a structural defect. |
| CRIT-065-002 (no branch protection) | ✅ **CONFIRMED** | Remains Critical. Verified `git_workflow` defined in identity.yml but no enforcement layer. |
| CRIT-065-003 (46/71 untested) | ✅ **CONFIRMED, denominator corrected** | Actual: 68 acp commands (not 71) + 2 git = 70. Untested = **46 of 68 = 68%** (round 1 said 65%). Finding was *understated*. 22 commands have tests. |
| HIGH-065-004 (17 scripts bare `set -e`) | ✅ **CONFIRMED** | Count verified exactly: 17 scripts. |
| HIGH-065-005 (no Windows CI) | ✅ **CONFIRMED** | e2e-tests.yaml matrix = `[ubuntu-latest, macos-latest]` only. |
| HIGH-065-006 (no SECURITY.md) | ✅ **CONFIRMED** | Verified absent. |
| MED-065 group (CODEOWNERS, PR template, Dependabot, lockfile, team_members) | ✅ **CONFIRMED** | All verified absent / empty. |
| MED-008 (audit reports 052–064 missing) | ⚠️ **PARTIALLY MISDIAGNOSED** | `agent/reports/` is **gitignored** (`agent/.gitignore:5`). Reports are instance-local by design. The "missing" 052–064 were likely generated in sessions on a different machine/checkout and never force-committed. Reframe: this is an instance-data sync gap, not lost work. Lower priority. |

**Round-1 scorecard**: 17 of 22 findings fully confirmed. 1 misdiagnosis (CRIT-065-001), 1 partial misdiagnosis (MED-008), 1 understatement (CRIT-065-003 denominator). The `.gitignore` instance-data model was the blind spot — round 1 treated gitignored local files as structural absences.

---

## Part B — New Findings (missed by round 1)

### Category A — TypeScript Dispatch Tooling (never opened in round 1)

| ID | Finding | Location | Severity |
|----|---------|----------|---------|
| HIGH-066-001 | `updateRoutingYml()` **overwrites entire `core/routing.yml`** with a 4-line `session:` stub — destroys `context_modes` (line 24) and `command_suggestions` (line 83) | `scripts/acp-dispatch.ts:191-195`, called at `:287` | High |
| MED-066-002 | `apiKey: process.env.OPENROUTER_API_KEY!` non-null assertion — missing env var produces a cryptic OpenAI SDK error, not a clear preflight message | `scripts/acp-dispatch.ts:233` | Medium |
| MED-066-003 | No unit tests for TS tooling — `scripts/*.test.ts` = 0 files; `acp-dispatch.ts` and `acp-validate.ts` are entirely untested | `scripts/` | Medium |
| LOW-066-004 | sessions/lessons parsed via `split("\n- date:")` string-splitting, not the YAML parser — fragile to format drift | `scripts/acp-dispatch.ts:39,49` | Low |

**HIGH-066-001 detail** (the most important finding of this round):

```typescript
function updateRoutingYml(executor: string, modelId: string) {
  const content =
    `session:\n  executor: ${executor}\n  model: ${modelId}\n  persona: B\n`;
  writeFileSync(path.join(AGENT_DIR, "core/routing.yml"), content, "utf-8");
}
```

`core/routing.yml` is **framework data (git-tracked)**, not instance data. It contains `session:`, `context_modes:` (the entire light/full mode system), and `command_suggestions:` (the post-command discoverability feature). This function replaces the whole file with only the `session:` block. Every Persona B/C dispatch silently deletes the mode and suggestion config. Since the file is tracked, the destruction would be committed. The function must do a **surgical update of the `session:` block only** (e.g., via the bash `yaml_set` parser the project already ships, or a targeted regex replace), never a full overwrite.

> Note: this only triggers on Persona B/C (OpenRouter dispatch). Persona A (Copilot, the current default) never calls `dispatch()`, which is why it has gone unnoticed — but it is a latent data-loss landmine for any team that adopts multi-model dispatch.

### Category B — CI Validation Is Partly a No-Op (round 1 assumed CI validated structure)

| ID | Finding | Location | Severity |
|----|---------|----------|---------|
| HIGH-066-005 | `acp-validate.ts` is **never run in CI** — placeholder check + frontmatter-field check never execute automatically. CI runs only `ci-validate.sh` | `.github/workflows/ci.yaml:28-29` | High |
| HIGH-066-006 | `ci-validate.sh` frontmatter check is a **no-op for command files** — it gates on `head -1 \| grep '^---$'`, but command docs start with `# Command: foo` (inline `**bold**:` markers, not `---` YAML frontmatter). Every command file is skipped | `scripts/ci-validate.sh:46` | High |

**Combined impact**: There is **no automated structural conformance check** for command docs anywhere in CI. This is *why* HIGH-065-002 (missing `## Steps`) and MED-065-003 (missing `## Verification`) existed undetected — nothing checks them. The validation logic exists in `acp-validate.ts` but is orphaned from the pipeline. Round 1 reported the symptoms (missing sections) without finding the root cause (the checker isn't wired in, and the bash checker silently skips command files).

### Category C — Schema & Data-Model Coverage

| ID | Finding | Location | Severity |
|----|---------|----------|---------|
| MED-066-007 | Only 5 schemas (`progress`, `package`, `task`, `projects`, `driver`). No schema for `milestone`, `session`, `lessons`, `decisions`, `clarification`, `feedback`, or `audit-carryovers` entities — the memory layer is unvalidated | `agent/schemas/` | Medium |
| LOW-066-008 | `acp-validate.ts` validates command markdown structure but does **not** validate any YAML file against the 5 schemas that exist — schemas are documentation-only, not enforced | `scripts/acp-validate.ts` | Low |

---

## Part C — Re-Prioritized Risk Ranking (merging both rounds)

Round 1's #1 priority (create decisions.md) was over-ranked. Corrected ranking:

| Rank | Finding | Why this order | Source |
|------|---------|----------------|--------|
| 1 | HIGH-066-001 — routing.yml overwrite | Silent data loss of a tracked core file; corrupts the flagship context-mode system | Round 2 |
| 2 | CRIT-065-002 — branch protection | One force-push corrupts production history | Round 1 |
| 3 | HIGH-066-005/006 — CI validation no-op | Root cause of all structural drift; cheap to fix, high leverage | Round 2 |
| 4 | CRIT-065-003 — 68% commands untested | Core workflow regressions undetectable | Round 1 |
| 5 | HIGH-065-004 — 17 scripts bare `set -e` | Latent silent-failure bugs | Round 1 |
| 6 | HIGH-065-006 / HIGH-065-005 — SECURITY.md, Windows CI | Production-readiness table stakes | Round 1 |
| 7 | MED-066-003 — no TS unit tests | Dispatch/validate logic untested | Round 2 |
| 8 | MED-065-001 (downgraded) — run /acp-decide for this project | Capture decision history; not structural | Round 1 (corrected) |

---

## Revised Improvement Plan (delta over audit-065)

Audit-065's Phase 1–4 plan remains valid **except**:

**ADD to Phase 1 (now P0):**
- **P1-0: Fix `updateRoutingYml()` data-loss bug** (HIGH-066-001) — replace full-file overwrite with surgical `session:`-block update. Add a regression test that asserts `context_modes` survives a dispatch. Est. 2h. **Do this before any multi-model/Persona-B adoption.**

**ADD to Phase 2:**
- **P2-CI: Wire validation into CI + fix the no-op** (HIGH-066-005, HIGH-066-006)
  - Add `cd scripts && npm install && npx ts-node acp-validate.ts` as a CI step
  - Fix `ci-validate.sh` to check command-doc structure (`## Steps`, `## Verification`, `**Namespace**:` etc.) instead of gating on a `---` line command files never have
  - This single fix prevents future recurrence of HIGH-065-002 and MED-065-003. Est. 3h.

**REVISE Phase 1 P1-A (decisions.md):**
- Downgrade from "create missing storage (Critical)" to "run `/acp-decide` to capture this project's key ADRs (Medium)". The file auto-creates on first use. Reconstruct 6 key ADRs as originally planned, but it is no longer a structural blocker.

**ADD to Phase 3:**
- **P3-SCHEMA: Add schemas for memory-layer entities** (MED-066-007) — milestone, session, decisions, clarification, feedback, audit-carryovers. Wire `acp-validate.ts` to enforce them (LOW-066-008). Est. 4h.
- **P3-TS-TEST: Unit tests for dispatch + validate** (MED-066-003) — add `scripts/*.test.ts` with a test runner (vitest/jest). Cover `buildContext` budget enforcement, `getFilteredLessons` filtering, `updateRoutingYml` non-destructiveness. Est. 4h.
- **P3-ENV: Preflight env-var check in dispatch** (MED-066-002) — fail fast with a clear message if `OPENROUTER_API_KEY` is unset. Est. 30 min.

---

## Process Observation — Auditing the Audit

Round 1's blind spot was a **single systemic assumption**: it treated every absent file as a structural gap, without checking `.gitignore`. Two of its findings (decisions.md, missing reports) were instance-data artifacts. Conversely, round 1 **under-investigated tracked source it listed but never read** — it pointed at `scripts/package.json` and `acp-dispatch.ts:191` but did not open them, missing the routing.yml overwrite and the orphaned validator.

**Lesson for future audits** (candidate for `lessons.md`): when auditing a framework that distinguishes tracked framework-data from gitignored instance-data, **always cross-check `.gitignore` before reporting a file as "missing,"** and **always open the source files you cite as code pointers** — a pointer without a read is a guess.

---

## Gap Matrix — This Round

| Category | High | Medium | Low | Total |
|----------|------|--------|-----|-------|
| TS dispatch tooling | 1 | 2 | 1 | 4 |
| CI validation wiring | 2 | 0 | 0 | 2 |
| Schema/data-model | 0 | 1 | 1 | 2 |
| **New findings total** | **3** | **3** | **2** | **8** |
| Round-1 corrections | — | — | — | 5 (2 downgrades, 1 denominator, 2 confirmations-with-nuance) |

---

## Recommendations

1. **Fix HIGH-066-001 first** — it is a tracked-file data-loss bug that round 1 missed entirely and outranks every round-1 finding. 2 hours, highest leverage.
2. **Fix the CI validation no-op (HIGH-066-005/006) second** — it is the root cause of the structural-conformance findings; fixing it makes those classes of bug self-detecting forever. 3 hours.
3. **Treat the `.gitignore` instance/framework split as audit doctrine** — re-run any "missing file" finding through `git check-ignore` before classifying severity.
4. **Add TS unit tests (MED-066-003)** before expanding dispatch — the dispatch path is the only Turing-complete code in the repo and has zero tests.
5. **Keep audit-065's Phase 1–4 plan**, applying the deltas above. Net effort added by round 2: ~13.5h (P1-0 2h, P2-CI 3h, P3-SCHEMA 4h, P3-TS-TEST 4h, P3-ENV 0.5h).
6. **Capture this project's ADRs** by running `/acp-decide` — but de-prioritize relative to the code bugs above.

---

## Next Steps for Developer

| Priority | Action | Effort | Source |
|----------|--------|--------|--------|
| P0 | Fix `updateRoutingYml()` full-overwrite → surgical update | 2h | HIGH-066-001 |
| P0 | Enable branch protection (mainline + develop) | 15 min | CRIT-065-002 |
| P0 | Wire `acp-validate.ts` into CI + fix `ci-validate.sh` no-op | 3h | HIGH-066-005/006 |
| P1 | Continue M58 route-156 (`/acp-integrity v2.0`) | 4h | active milestone |
| P1 | E2E Tier 1 (8 core commands) | 12h | CRIT-065-003 |
| P2 | TS unit tests for dispatch + validate | 4h | MED-066-003 |
| P2 | `set -euo pipefail` upgrade (17 scripts) | 3h | HIGH-065-004 |
| P3 | Memory-layer schemas + env preflight | 4.5h | MED-066-007, MED-066-002 |
