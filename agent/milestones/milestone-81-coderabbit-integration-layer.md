# Milestone 81: CodeRabbit Integration Layer (CodeRabbit-only)

<!-- @acp.meta.milestone
topic: coderabbit, integration, findings-import, ADR-22, optionality, multi-tenant
description: CodeRabbit-only integration surface — policy map, findings-import, review wiring; Aikido deferred; ADR-22 carve-out from ADR-19
status: in_progress
updated: 2026-07-24
@acp.meta.end -->

**Planned version**: 6.29.0  
**Status**: in_progress (1/6) — task-269 ✅; **BLOCKED** 270–274 on findings fixture  

**Estimated effort**: ~20h (6 tasks)  
**Source**: Maintainer request 2026-07-24 — one CodeRabbit consumer; Aikido cost unjustified; ADR-19 gate too broad for user base  
**Depends on**: M78 (optionality, v6.28.0), M80 (E2E 68/68, v6.28.2), **audit-101** (F-101-01..08)  
**Pre-impl**: [audit-101-m81-pre-impl-readiness.md](../reports/audit-101-m81-pre-impl-readiness.md) — verdict READY WITH AMENDMENTS (applied this session)

## Governance (F-101-01 — binding)

**ADR-22 (task-269) is a carve-out of ADR-19, not a supersede/reopen.**

- ADR-19 remains in force for **Aikido**, **M76 golden-path**, and **M77 supply-chain moat**.
- ADR-22 unlocks **CodeRabbit-only M81** when: CodeRabbit on ≥1 consumer repo + 2 weeks real findings (fixture).
- Wording in ADR-22 / docs MUST follow ADR-21 precedent (“carved out”), never “supersedes ADR-19”.

## Goal

Wire ACP Enhanced to **use** CodeRabbit where installed — importing findings into the carryover ledger and augmenting `/acp-review` — while every path stays **optional** for repos without CodeRabbit.

## Implementation readiness (post–audit-101)

| Task | Gated? | May start when |
|------|--------|----------------|
| **269** | **No** (F-101-04) | Now — ADR-22 + policy map + wiki/config/research sync |
| **270–274** | **Yes** | After ADR-22 accepted **and** gate artifact `tests/fixtures/coderabbit-findings-sample.json` exists (sanitized real export) |

**Explicitly NOT required:** Aikido.

## Scope boundary

| In scope (M81) | Out of scope (deferred) |
|----------------|-------------------------|
| ADR-22 carve-out + policy map lite (~15 rules) | Full 64-rule owner map |
| `acp.findings-import.sh` — **`--input` file only** (v1) | `--pr` / live API / unverified CLI (F-101-05) |
| `.coderabbit.yaml` starter template | patterns/lessons auto-generator + `generate_on_commit` |
| `/acp-review` augmentation when `coderabbit_active` | Replacing `/acp-review` |
| Thin wrapper **or** review-doc path for weekly recurring | Inventing a step array on `weekly-code-review` (F-101-02) |
| E2E cases A–D + M78 regression | Aikido / M76 / M77 |

## Anti-shortcut guardrails (binding)

1. Every CodeRabbit path: `if coderabbit_active; then … else … fi` — tested absent branch.
2. `/acp-review` + carryover loop stay standalone-complete.
3. No Aikido in this milestone.
4. findings-import idempotent (dedup by `finding_id`).
5. E2E asserts values/exit codes — not `typeof`-only.
6. Import format from **committed fixture** — no speculative vendor schema (F-101-05 / F-098-04).
7. **Phase 1 deterministic rules never deferred** to CodeRabbit (F-101-07) — SC-01, EH-01/02, TS-01/02, AP-01, NC-01, SH-01 always run.
8. Match **live** carryover ledger shape — no invented fields (F-101-03).
9. Script-first surface: `bash agent/scripts/acp.findings-import.sh` — no fake `/acp-findings-import` command (F-101-06).
10. Assertion-level regression check at closure (audit-099).

## Build order

| Phase | Route | Task | Title | Est. | Notes |
|-------|-------|------|-------|------|-------|
| **0** | route-258 | task-269 | ADR-22 + policy map lite + doc sync | 3h | **Ungated** (F-101-04) |
| **1** | route-259 | task-270 | `acp.findings-import.sh` (fixture `--input`) | 6h | Gate: fixture |
| **1** | route-260 | task-271 | `.coderabbit.yaml` starter + wiki bootstrap | 2h | After 269 |
| **2** | route-261 | task-272 | Wire `/acp-review` + weekly wrapper | 4h | F-101-02/06/07 |
| **2** | route-262 | task-273 | E2E integration + optionality | 3h | Cases A–D |
| **3** | route-263 | task-274 | Closure — ship v6.29.0 | 2h | Full version file list |

**Routes**: create at `/acp-dispatch` time (F-098-06 pattern) — not pre-created.

**Dependencies:** 269 → 270,271. 270,271 → 272. 272 → 273. All → 274.

## audit-101 amendment map

| Finding | Folded into |
|---------|-------------|
| F-101-01 | This milestone governance + task-269 ADR wording |
| F-101-02 | task-272 (wrapper / review-doc — no step array) |
| F-101-03 | task-270 (live carryover shape) |
| F-101-04 | task-269 ungated; gate on 270+ |
| F-101-05 | task-270 (fixture-first; no `--pr` in v1) |
| F-101-06 | task-272 (script path only) |
| F-101-07 | task-269 policy map + task-272 Phase 1 rule |
| F-101-08 | task-269 wiki/configurables/research sync |

## Verification gates (M81 closure)

- [ ] ADR-22 in `decisions.md` as **carve-out** (not supersede); F-097-01 `gated_remainder` → ADR-22/M81
- [ ] `bash agent/scripts/acp.findings-import.sh --dry-run` no-ops when inactive
- [ ] `--input tests/fixtures/coderabbit-findings-sample.json` produces valid live-shape carryovers when active
- [ ] `/acp-review` Phase 1 never deferred; Phase 2 annotations only when `coderabbit_active`
- [ ] `weekly-code-review` inactive path identical to pre-M81; active path uses documented wrapper/review behavior
- [ ] `e2e/coderabbit-integration.test.sh` + `e2e/coderabbit-optionality.test.sh` green; full suite assertion-level green
- [ ] `npx vitest run` + `npx tsx scripts/acp-validate.ts` exit 0
- [ ] v6.29.0 tagged; CHANGELOG; integrity-manifest; full version file set (F-098-07)

## Optionality test matrix (must pass at closure)

| # | `enabled` | `.coderabbit.yaml` | findings-import | /acp-review | weekly-code-review |
|---|-----------|-------------------|-----------------|-------------|-------------------|
| A | false | absent | silent no-op, exit 0 | ACP-only | ACP-only (`command:` unchanged behavior) |
| B | true | absent | no-op + hint once | ACP-only + hint | ACP-only + hint |
| C | true | present | `--input` imports | ACP + Phase 2 annotations | wrapper/review CR path |
| D | false | present | no-op (opt-in wins) | ACP-only | ACP-only |
