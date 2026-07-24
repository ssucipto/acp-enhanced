# Milestone 81: CodeRabbit Integration Layer (CodeRabbit-only)

<!-- @acp.meta.milestone
topic: coderabbit, integration, findings-import, ADR-22, optionality, multi-tenant
description: CodeRabbit-only integration surface — policy map, findings-import, review wiring; Aikido deferred; narrowed adoption gate
status: planned
updated: 2026-07-24
@acp.meta.end -->

**Planned version**: 6.29.0
**Status**: planned (0/6) — **implementation blocked until ADR-22 adoption gate clears**
**Estimated effort**: ~20h (6 tasks)
**Source**: Maintainer request 2026-07-24 — one consumer has CodeRabbit; user base cannot justify Aikido cost; M74–M77 ADR-19 gate too broad
**Depends on**: M78 (optionality foundation, v6.28.0), M80 (E2E green, v6.28.2)
**Supersedes (partially)**: ADR-19 gate for CodeRabbit integration work only — see task-269 (ADR-22). Aikido integration remains deferred indefinitely until a customer needs it.

## Goal

Wire ACP Enhanced to **use** CodeRabbit where it is installed — importing PR findings into the carryover ledger and augmenting `/acp-review` — while keeping every path **optional** for repos without CodeRabbit. This is the gated integration surface that M78 deliberately deferred; scoped **CodeRabbit-only** (no Aikido, no golden-path scaffold, no supply-chain moat).

## Adoption gate (ADR-22 — to be written in task-269)

Implementation (`/acp-proceed M81`) starts only when **both** are true:

| # | Condition | Rationale |
|---|-----------|-----------|
| 1 | CodeRabbit installed and reviewing PRs on **≥1 active consumer repository** | Real integration target exists |
| 2 | **≥2 weeks** of real CodeRabbit PR findings collected (export or API samples archived) | `findings-import` format designed against live output, not vendor docs |

**Explicitly NOT required:** Aikido (deferred — cost/complexity not justified for current user base).

**Planning is not blocked** — this milestone may be planned and reviewed before the gate clears.

## Scope boundary

| In scope (M81) | Out of scope (deferred) |
|----------------|-------------------------|
| ADR-22 — narrowed CodeRabbit-only gate | Full M74 64-rule owner map (ship **lite** map: ~15 high-overlap rules) |
| `acp.findings-import.sh` — CodeRabbit → carryovers | Aikido SCA/CVE import |
| `.coderabbit.yaml` **starter template** + wiki docs | Full patterns/lessons → `.coderabbit.yaml` generator (M75 original) |
| `/acp-review` augmentation when `coderabbit_active` | Replacing `/acp-review` with CodeRabbit |
| `weekly-code-review` conditional branch | `monthly-dependency-audit` → Aikido rewire |
| E2E: import + review branches + optionality regression | M76 golden-path scaffold |
| Multi-tenant: per-repo `enabled` preference (M78) | M77 AI supply-chain moat |

## Anti-shortcut guardrails (binding — extends M78 / ADR-21)

1. **Every new CodeRabbit code path** uses `if coderabbit_active; then … else … fi` — tested absent branch required.
2. **`/acp-review` + carryover loop stay standalone-complete** — CodeRabbit augments only.
3. **No Aikido code, config, or docs** in this milestone.
4. **findings-import is idempotent** — re-import does not duplicate carryover entries.
5. **E2E asserts output values / exit codes**, not `typeof`-only.
6. **Design import format from archived real findings** (task-270 prerequisite artifact) — no speculative vendor schema.

## Build order

| Phase | Route | Task | Title | Est. | Priority |
|-------|-------|------|-------|------|----------|
| **0** | route-258 | task-269 | ADR-22 + CodeRabbit policy map lite | 3h | P0 |
| **1** | route-259 | task-270 | `acp.findings-import.sh` (CodeRabbit → carryovers) | 6h | P0 |
| **1** | route-260 | task-271 | `.coderabbit.yaml` starter template + docs | 2h | P1 |
| **2** | route-261 | task-272 | Wire `/acp-review` + `weekly-code-review` branches | 4h | P0 |
| **2** | route-262 | task-273 | E2E integration + optionality regression | 3h | P0 |
| **3** | route-263 | task-274 | M81 closure — ship v6.29.0 | 2h | P0 |

**Dependencies:** 269 → 270,271 (policy map informs import + review deferrals). 270,271 → 272. 272 → 273. All → 274.

## Verification gates (M81 closure)

- [ ] ADR-22 in `decisions.md`; research report annotated CodeRabbit-only path
- [ ] `bash agent/scripts/acp.findings-import.sh --dry-run` no-ops when `coderabbit_active` false
- [ ] Import fixture produces valid `audit-carryovers.md` entries when active
- [ ] `/acp-review` report notes CodeRabbit-deferred rules only when `coderabbit_active`
- [ ] `weekly-code-review` unchanged when inactive; adds CodeRabbit step when active
- [ ] `e2e/coderabbit-integration.test.sh` green; full suite 68/68+ (no regression)
- [ ] `npx vitest run` + `npx tsx scripts/acp-validate.ts` exit 0
- [ ] v6.29.0 tagged; CHANGELOG entry

## Optionality test matrix (must pass at closure)

| # | `enabled` | `.coderabbit.yaml` | findings-import | /acp-review | weekly-code-review |
|---|-----------|-------------------|-----------------|-------------|-------------------|
| A | false | absent | silent no-op, exit 0 | ACP-only (today) | ACP-only (today) |
| B | true | absent | no-op + hint once | ACP-only + hint | ACP-only + hint |
| C | true | present | imports when invoked | ACP + deferral notes | ACP + CR thread check |
| D | false | present | no-op (opt-in wins) | ACP-only | ACP-only |

Cases A–D must be covered in `e2e/coderabbit-integration.test.sh` (task-273) plus existing `e2e/coderabbit-optionality.test.sh` (M78 regression).
