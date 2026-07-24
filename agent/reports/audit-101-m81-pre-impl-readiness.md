# Audit Report: M81 Pre-Implementation Readiness

**Audit**: #101  
**Date**: 2026-07-24  
**Subject**: Pre-implementation readiness of M81 (CodeRabbit Integration Layer — CodeRabbit-only), tasks 269–274  
**Mode**: `--pre-impl`  
**Head**: `6b0cdfd` (plan commit) · branch `develop` · app **6.28.2**

## Summary

M81 is the right product slice for the stated user base (one CodeRabbit consumer; Aikido deferred). The optionality foundation from M78 is sound and should be reused, not reinvented. Cross-referencing tasks against live code, ADR-19/21, carryover ledger, and prior M78 pre-impl lessons (audit-098/099) surfaced **8 actionable gaps** — none make the *plan* worthless, but **two are high**: (1) milestone language that “supersedes ADR-19” risks an illegal reopen of a DO-NOT-re-open decision; (2) task-270/`--pr` + invented carryover fields risk speculative vendor interfaces and schema drift (the exact F-098-04 / ledger-integrity class of shortcut). Recurring-task wiring as written is also unimplementable against the real `weekly-code-review` shape (single `command:` string).

**Verdict: READY WITH AMENDMENTS** — amend tasks/milestone before `/acp-proceed`. Implementation of tasks 270–274 remains blocked until the adoption gate artifact exists; task-269 (ADR-22 + docs) should be **explicitly ungated** so the carve-out is written before any import code.

---

## Files Analyzed

| File | Type | Relevance |
|------|------|-----------|
| `agent/milestones/milestone-81-coderabbit-integration-layer.md` | plan | Scope, gate, optionality matrix |
| `agent/tasks/milestone-81-.../task-269..274-*.md` | plan | Acceptance criteria |
| `agent/memory/decisions.md` (ADR-19, ADR-21) | ADR | Gate + carve-out precedent |
| `agent/scripts/acp.coderabbit.sh` | source | Detection API to source |
| `agent/patterns/local.optional-external-tool.md` | pattern | 3-gate contract |
| `agent/wiki/coderabbit-integration.md` | wiki | Stale ADR-19 roadmap |
| `agent/configurables/acp.configurables.yaml` | config | Preference keys; stale ADR-19 comment |
| `agent/commands/acp.review.md` | command | 64-rule owners; Phase 1 vs 2 |
| `agent/progress.yaml` (`weekly-code-review`, M81) | tracking | Recurring shape; next_due |
| `agent/memory/audit-carryovers.md` | ledger | Pending/deferred/verified hygiene |
| `agent/schemas/audit-carryovers.schema.yaml` + `scripts/acp-validate.ts` | schema | Import field mapping (`description`→`finding`) |
| `agent/reports/audit-097/098/099/100` | prior audits | Shortcut lessons |
| `agent/reports/research-acp-vs-coderabbit-aikido-2026.md` | research | Header vs body drift |
| `package.yaml`, `agent/templates/`, `tests/fixtures/` | ops | Registration / missing dirs |
| `e2e/coderabbit-optionality.test.sh` | test | M78 regression baseline |

## Git History (relevant)

| Date | Commit | Summary |
|------|--------|---------|
| 2026-07-24 | `6b0cdfd` | `plan(M81): CodeRabbit-only integration layer` |
| 2026-07-24 | `b834dee` | post-M80 sync |
| 2026-07-24 | `d080a25` | M80 ship v6.28.2 (68/68 E2E) |
| 2026-07-23 | (M78/M79) | optionality foundation + closure integrity |

---

## Pre-Implementation Readiness (M81)

**Mode**: `--pre-impl`

### Phase 1 — Plan Correctness

| Check | Result | Notes |
|-------|--------|-------|
| Milestone + 6 task files exist | ✅ | All paths in progress.yaml resolve |
| Acceptance criteria present | ⚠️ | Present but several are ambiguous / unimplementable as written (F-101-02, F-101-03, F-101-05) |
| `files_affected` lists | ❌ | **None of the 6 tasks list `files_affected`** — Phase 2 harder; amend |
| Open blockers | ⚠️ | Adoption gate artifact missing (expected); ADR-22 not written yet (task-269) |
| ADR-19 conflict | ❌ | Milestone line 15: “Supersedes (partially) ADR-19” — ADR-19 is **DO NOT re-open**; must be **carve-out** language like ADR-21 (F-101-01) |
| task-269 self-gating | ❌ | Frontmatter `gate:` blocks ADR writing — ADR-22 must land **before** gate clears (F-101-04) |

### Phase 2 — Code Cross-Reference

| File / Fact | Checked | Result | Notes |
|-------------|---------|--------|-------|
| `acp.coderabbit.sh` | `coderabbit_active` / `available` / `hint` | ✅ | Source these; do not reimplement |
| Preferences | `enabled` + `config_path` only | ✅ | No `generate_on_commit` (F-098-04 still correct) |
| `weekly-code-review` | `progress.yaml:7485` | ❌ | Single `command: /acp-review --report --carryover` — **no step list** to “add a conditional step” (F-101-02) |
| Carryover live shape | `finding` + lowercase `severity` | ⚠️ | Validator maps `description`→`finding`; task-270 invents `source: coderabbit` + `planned_in: M81-import` (F-101-03) |
| Schema enums | schema says CRITICAL/HIGH… | ⚠️ | Live ledger uses `medium` etc.; import must match **live** format validators accept |
| `--pr` / API path | task-270 step 3 | ❌ | Speculative vendor interface — no verified CodeRabbit CLI/API contract yet (F-098-04 class → F-101-05) |
| `tests/fixtures/` | exists? | ❌ | Directory absent — create in task-270 |
| `agent/templates/` | yaml template precedent? | ⚠️ | Only `.md` templates today; path OK if named clearly |
| `/acp-findings-import` | task-272 text | ❌ | Slash-command referenced; task-270 says script-first / no command (F-101-06) |
| Phase 1 review rules | SC-01, EH-*, TS-01/02 | ⚠️ | Must **not** be deferred to CodeRabbit when active — layered defense (F-101-07) |
| Wiki roadmap | `coderabbit-integration.md:69-78` | ❌ | Still says gated under ADR-19 → `/acp-plan M74` (F-101-08) |
| Configurables comment | `acp.configurables.yaml:178` | ⚠️ | Still “GATED under ADR-19” — update when ADR-22 lands |
| Research body | §5 roadmap table | ⚠️ | Header updated; body still M74–M77 as next action |
| Routes 258–263 | on disk? | ⚠️ | Absent — same as F-098-06; create at `/acp-dispatch` or note |
| task-274 version files | listed | ⚠️ | Omits `AGENT.md`, `README.md` badge, `CLAUDE.md`/copilot sync — F-098-07 lesson |
| Integrity / package.yaml | new script | ✅ | task-270/274 mention register + manifest |

### Phase 3 — Carryover Check

| Carryover | Severity | Status | Blocks M81? |
|-----------|----------|--------|-------------|
| *(none pending)* | — | — | — |
| **CRIT-065-002** branch protection | critical | **deferred** | No — ops (GitHub Free); unrelated to CodeRabbit |
| **F-097-01** optionality | low | **fixed** | No — foundation done; `gated_remainder: ADR-19` should retarget to **ADR-22/M81** when ADR written |
| F-M78-01, F-100-01..05 | — | **fixed** | No — M80 closed |
| F-099-01..05, F-098-* | — | fixed, many `verified_in_audit: null` | No — ledger hygiene (18 fixed-unverified overall); stamp at next closure audit, not a M81 blocker |

**Ops note (not a M81 carryover):** `weekly-code-review` and `weekly-integrity-scan` have `next_due: 2026-07-22` while today is **2026-07-24** — overdue recurring reviews. Run or defer with reason before claiming M81 “healthy ops.”

### Phase 4 — Operational Completeness

| Check | Result | Notes |
|-------|--------|-------|
| Route files exist | ⚠️ | Referenced, not on disk (dispatch-time OK if documented) |
| Version bump planned | ⚠️ | v6.29.0 yes; expand file list (F-098-07) |
| Wiki update planned | ✅ | tasks 269 + 271 |
| CHANGELOG planned | ✅ | task-274 |
| Integrity-manifest | ✅ | task-274 |
| domain.yml E2E map | ✅ | task-270 |
| Gate artifact defined | ❌ | No committed path/format for “2 weeks findings” sample yet — add acceptance artifact to task-269/270 (F-101-05) |
| Optionality E2E matrix | ✅ | Cases A–D in milestone + task-273 |
| No Aikido in scope | ✅ | Consistent across tasks |

### Phase Summary

| Phase | Findings | Highest Severity |
|-------|----------|------------------|
| Phase 1 — Plan Correctness | 3 | **high** (F-101-01) |
| Phase 2 — Code Cross-Reference | 5 | **high** (F-101-02, F-101-05) |
| Phase 3 — Carryover Check | 0 blockers | — |
| Phase 4 — Operational Completeness | 2 | medium |
| **Total unique** | **8** | **high** |

### Readiness Verdict

**READY WITH AMENDMENTS** — fold F-101-01..08 into milestone/task docs before `/acp-proceed`. Do **not** start task-270 until (a) ADR-22 carve-out is written and (b) a real sanitized findings fixture exists. Do **not** treat “supersede ADR-19” as authorized.

---

## Key Findings (actionable — fold into plan)

| ID | Sev | Finding | Amend |
|----|-----|---------|-------|
| **F-101-01** | **high** | Milestone says “Supersedes (partially) ADR-19”. ADR-19 is **DO NOT re-open**. ADR-21 precedent is a **carve-out**, not a reopen. Wrong wording invites illegal re-litigation and confuses gate status. | Rewrite as: “ADR-22 carves CodeRabbit integration (M81) out of ADR-19’s Aikido-coupled gate; ADR-19 remains in force for Aikido / M76 / M77.” Write ADR-22 with that language. |
| **F-101-02** | **high** | task-272: “Add conditional step” to `weekly-code-review` — but the recurring task is a **single command string** (`/acp-review --report --carryover`), not a step list. | Implement via `/acp-review` doc + optional helper invoked **from** review when `coderabbit_active`, **or** change `command:` to a thin wrapper script that calls review then import. Do not invent a non-existent step array. |
| **F-101-03** | medium | task-270 invents carryover fields `source: coderabbit` and `planned_in: M81-import`. Live ledger + validator expect `finding` (mapped from schema `description`), lowercase severities, `planned_in: M81` (or null), plus `file` / `fix_target`. | Match live entry shape from existing carryovers; put origin in `finding`/`description` text or `notes:` — don’t invent schema. |
| **F-101-04** | medium | task-269 frontmatter `gate:` requires consumer findings **before** ADR-22 can be written — blocks the document that unlocks the rest. | Split: **task-269 ungated** (ADR + policy map + wiki). Gate applies to **270–274** only. |
| **F-101-05** | **high** | `--pr <number>` / live API path + “design from real findings” without a committed fixture path = speculative vendor interface (repeats F-098-04). | Gate artifact: `tests/fixtures/coderabbit-findings-sample.json` (sanitized, from real export). **v1 import = `--input` file only.** Defer `--pr`/network until CLI/API verified. |
| **F-101-06** | medium | task-272 references `/acp-findings-import` slash command; task-270 says script-first, no command doc. | Pick one: script-only (`bash agent/scripts/acp.findings-import.sh`) in all docs, **or** add a real command doc + 5-surface wrappers. Prefer script-only for M81. |
| **F-101-07** | medium | Policy map “owner: coderabbit” could be misread as skipping ACP Phase 1 / critical rules (SC-01, etc.) when CodeRabbit is active — weakens layered defense. | Bind: Phase 1 deterministic rules **never** deferred. Only Phase 2 semantic overlap may be annotated “also covered by CodeRabbit — verify via import.” ACP-owned rules always run. |
| **F-101-08** | low | Docs still point consumers to ADR-19 → `/acp-plan M74` (`coderabbit-integration.md` roadmap; research §5; configurables comment). | Update in task-269 to M81 / ADR-22; keep M74–M77 as deferred Aikido/golden-path track. |

---

## Shortcuts Explicitly Called Out (do not take)

| Shortcut | Why forbidden | Lesson |
|----------|---------------|--------|
| Reopen / “supersede” ADR-19 without carve-out ADR | Violates DO NOT re-open | ADR-21 pattern only |
| Blind-green E2E by weakening optionality | Breaks multi-tenant | M78 matrix A–D |
| Speculative CodeRabbit CLI/`gh` API | F-098-04 | Fixture-first `--input` |
| Defer SC-01 / Phase 1 to CodeRabbit | False assurance | audit-070 / layered defense |
| File-level “suite still green” at closure | Masks regressions | audit-099 assertion-level |
| Invent carryover schema fields | Breaks validate / ledger | Match live entries |
| Pretend recurring tasks have steps | Unimplementable | Read `progress.yaml` shape |
| Ship without regenerating integrity-manifest | D4 ERROR | task-274 already notes |

---

## Code Pointers

| Location | Description |
|----------|-------------|
| `agent/memory/decisions.md:163-170` | ADR-19 DO NOT re-open + Aikido-coupled gate |
| `agent/memory/decisions.md:181-188` | ADR-21 carve-out precedent (use this shape for ADR-22) |
| `agent/scripts/acp.coderabbit.sh:47-73` | Detection API to source in findings-import |
| `agent/progress.yaml:7485-7493` | `weekly-code-review` single-command shape |
| `scripts/acp-validate.ts:1605-1610` | Carryover `description`↔`finding` mapping |
| `agent/wiki/coderabbit-integration.md:69-78` | Stale “gated → /acp-plan M74” roadmap |
| `agent/configurables/acp.configurables.yaml:176-179` | Stale ADR-19 gating comment |
| `agent/milestones/milestone-81-...md:15` | Illegal “Supersedes ADR-19” wording |

## Key Decisions (binding — do not re-litigate in M81)

- **Buy detection / build governance** (research) — still valid; Aikido deferred for cost, not abandoned forever.
- **ADR-21**: CodeRabbit augments, never gates ACP paths; absence is normal.
- **F-098-04**: No speculative vendor CLI/API until verified against real adoption.
- **audit-099**: Assertion-level regression comparison at closure.
- **M81 scope**: CodeRabbit-only; no Aikido, no golden-path, no full generator.

## Recommendations

1. **Amend before implement** — apply F-101-01..08 to milestone + tasks 269–274 (same session `/acp-plan` amendment preferred).
2. **Run task-269 first (ungated)** — write ADR-22 carve-out + policy map lite + wiki/configurables/research sync; retarget F-097-01 `gated_remainder` → ADR-22/M81.
3. **Collect gate artifact** — sanitized findings JSON from the CodeRabbit consumer → `tests/fixtures/coderabbit-findings-sample.json` before coding the parser.
4. **Then** `/acp-proceed` 270→271→272→273→274 with fixture-only import and review-doc wiring (no `--pr` in v1).
5. **Ops**: clear overdue weekly recurring reviews (or defer with reason); CRIT-065-002 stays deferred.

## Carryovers Written

Appended to `agent/memory/audit-carryovers.md` as **F-101-01..08** (`status: pending`, `planned_in: M81`).
