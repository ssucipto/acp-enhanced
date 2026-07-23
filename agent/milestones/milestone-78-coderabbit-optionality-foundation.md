# Milestone 78: CodeRabbit Optionality Foundation

<!-- @acp.meta.milestone
topic: coderabbit, optionality, preferences, feature-detection, ADR-21
description: Non-gated foundation for optional CodeRabbit integration — preference toggle, feature detection, graceful degradation, docs
status: planned
updated: 2026-07-23
@acp.meta.end -->

**Planned version**: 6.28.0
**Status**: in_progress (1/6)
**Estimated effort**: ~13h (6 tasks)
**Source**: audit-097 (optional CodeRabbit integration) + ADR-21 (carve-out from ADR-19 gate)
**Pre-impl review**: audit-098 — 7 findings folded in (F-098-01..07). Helpers live in a dedicated `acp.coderabbit.sh` (not common.sh — circular source); docs in `agent/wiki/`; detection config-file-only; `generate_on_commit` deferred to M75.
**Depends on**: preferences system (M6/M19), `acp.common.sh` detection idiom, `acp.branch-protection-setup.sh:27` exemplar
**Governance**: [ADR-21](../memory/decisions.md) — this milestone is the **non-gated** foundation; the integration surface (PR-check, findings-import, `.coderabbit.yaml` generator) stays **GATED under [ADR-19](../memory/decisions.md)**.

## Goal

Make CodeRabbit integration **optional-by-construction** before any integration surface is built. ACP is a distributed framework; a fresh install with no CodeRabbit must behave exactly as today. This milestone ships the three-gate optionality contract from audit-097 — **preference opt-in → feature detection → silent graceful degradation** — plus the pattern, tests, and user documentation that let future (gated) PR-check work land safely for users who don't have CodeRabbit.

## Context

audit-097 found that prior research (research-acp-vs-coderabbit-aikido-2026.md) and ADR-19 framed CodeRabbit as Rygan's *own* tooling and specified **no absent-tool path**. ADR-21 carves the optionality foundation out of ADR-19's gate: the foundation never parses CodeRabbit output, so it is not the speculative-interface work ADR-19 defers. Everything requiring live findings stays gated.

## Scope Boundary (binding — see ADR-21)

| In scope (M78, non-gated) | Out of scope (GATED under ADR-19 → M74/M75) |
|---|---|
| `integrations.coderabbit.{enabled,config_path}` keys | `.coderabbit.yaml` generator + `generate_on_commit` key (M75) |
| `coderabbit_available()` / `coderabbit_active()` (config-file detection) | `acp.findings-import.sh` (findings → carryovers) |
| — CLI detection deferred to adoption (F-098-04) | CLI-based / findings-based detection |
| optional-external-tool pattern | Recurring-task rewire (weekly-code-review → CodeRabbit) |
| E2E for all degradation branches | Policy 64-rule → owner map |
| "Working with CodeRabbit" how-to doc | **PR-check integration** (the core gated deliverable) |

## Build Order

| Phase | Route | Task | Title | Est. | Priority |
|-------|-------|------|-------|------|----------|
| **1** | route-244 | task-255 | Reserve `integrations.coderabbit.*` preference keys | 2h | P0 |
| **1** | route-245 | task-256 | Feature-detection helpers in `acp.common.sh` | 2h | P0 |
| **2** | route-246 | task-257 | `local.optional-external-tool.md` pattern (3-gate contract) | 1.5h | P1 |
| **2** | route-247 | task-258 | E2E: all three degradation branches | 3h | P0 |
| **3** | route-248 | task-259 | "Working with CodeRabbit" how-to documentation | 2.5h | P1 |
| **3** | route-249 | task-260 | M78 closure — validate, version 6.28.0, close carryover F-097-01 | 2h | P0 |

Dependency notes: task-256 depends on task-255 (helpers read the preference). task-257 generalizes 255+256 into a reusable pattern. task-258 depends on 255+256 (tests exercise the real helpers). task-259 documents the shipped behavior (depends on 255+256). task-260 depends on all.

## Task Map

| Task | Route | Deliverable | Gate |
|------|-------|-------------|------|
| [task-255](../tasks/milestone-78-coderabbit-optionality-foundation/task-255-preference-keys.md) | route-244 | **2 keys** (enabled, config_path) in configurables + defaults, off/inert, `_index` updated, validate | keys resolve at all 4 precedence levels |
| [task-256](../tasks/milestone-78-coderabbit-optionality-foundation/task-256-feature-detection.md) | route-245 | `coderabbit_available()` + `coderabbit_active()` in **`agent/scripts/acp.coderabbit.sh`** (registered) | config-file detection only; `== "true"`; no circular source |
| [task-257](../tasks/milestone-78-coderabbit-optionality-foundation/task-257-optional-tool-pattern.md) | route-246 | `agent/patterns/local.optional-external-tool.md` | 3-gate contract reusable for Aikido |
| [task-258](../tasks/milestone-78-coderabbit-optionality-foundation/task-258-e2e-degradation.md) | route-247 | `e2e/coderabbit-optionality.test.sh` (auto-discovered) | 3 branches assert on output values |
| [task-259](../tasks/milestone-78-coderabbit-optionality-foundation/task-259-working-with-coderabbit-docs.md) | route-248 | **`agent/wiki/coderabbit-integration.md`** + README/AGENT pointer | covers optional nature + gated PR-check roadmap |
| [task-260](../tasks/milestone-78-coderabbit-optionality-foundation/task-260-m78-closure.md) | route-249 | validate green, v6.28.0, F-097-01 closed | M78 complete |

## Anti-Shortcut Guardrails (binding)

1. **`/acp-review` + carryover loop stay standalone-complete** — CodeRabbit augments, never gates them. No code path becomes incorrect when CodeRabbit is absent.
2. **Every CodeRabbit path has a tested absent branch** — absence is normal, exits 0 silently (unlike `gh` in branch-protection, which is *required*).
3. **No gated work built here** — no `.coderabbit.yaml` generator, no findings-import, no recurring-task rewire (ADR-19 / ADR-21).
4. **E2E asserts on output values**, not `typeof` (constraints.yml `test_quality_gate`).
5. **No M74–M77 progress.yaml entries created** — ADR-19 unchanged.
6. **Defaults are inert** — `enabled: false`; a fresh install behaves exactly as today.
7. **No speculative vendor interfaces** (audit-098 F-098-04) — detection is config-file presence only; no unverified CLI name; no `generate_on_commit` key until the M75 generator exists.
8. **Layering** (audit-098 F-098-01) — an optional-tool script sources `acp.preferences.sh`; `acp.common.sh` never depends on preferences.

**Routes**: route-244..249 are created at `/acp-dispatch` time (F-098-06) — not pre-created; task files carry the planned route IDs.

## Verification Gates (M78 closure)

- [ ] `bash agent/scripts/acp.preferences.sh get acp integrations.coderabbit.enabled` resolves `false` on a clean project (task-255)
- [ ] `coderabbit_active()` returns false when key off OR `.coderabbit.yaml` absent; true only when both hold (task-256)
- [ ] `e2e/coderabbit-optionality.test.sh` covers off/silent, on+absent/skip-hint, on+present/detected — each asserting a specific output string (task-258)
- [ ] `agent/scripts/acp.coderabbit.sh` created + registered in package.yaml (D4 green); helpers do NOT live in common.sh (task-256, F-098-01)
- [ ] `agent/patterns/local.optional-external-tool.md` referenced by acp.coderabbit.sh helper comments (task-257)
- [ ] `agent/wiki/coderabbit-integration.md` states integration is optional and PR-check is gated per ADR-19 (task-259)
- [ ] `npx tsx scripts/acp-validate.ts` exit 0; `npx vitest run` + E2E green (task-260)
- [ ] audit-carryovers F-097-01 → `status: fixed`, `verified_in_audit` set (task-260)
- [ ] v6.28.0 tagged; CHANGELOG entry (task-260)
