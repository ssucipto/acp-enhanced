---
id: task-269
milestone: M81
title: "ADR-22 + CodeRabbit policy map lite"
status: planned
priority: 5
complexity: medium
estimated_hours: 3
created: 2026-07-24
started: null
completed: null
route: route-258
depends_on: []
design_reference: [ADR-19](../../memory/decisions.md), [ADR-21](../../memory/decisions.md)
audit_findings: [F-101-01, F-101-04, F-101-07, F-101-08]
gate: null
files_affected:
  - agent/memory/decisions.md
  - agent/wiki/coderabbit-policy-map-lite.md
  - agent/wiki/coderabbit-integration.md
  - agent/configurables/acp.configurables.yaml
  - agent/reports/research-acp-vs-coderabbit-aikido-2026.md
  - agent/memory/audit-carryovers.md
  - agent/milestones/milestone-81-coderabbit-integration-layer.md
---

## Objective

Write **ADR-22** as an ADR-21-style **carve-out** (not a supersede of ADR-19), produce the policy map lite, and sync stale docs so M81 implementation has a clean governance contract.

> **Ungated (F-101-04)** — this task may run **now**. The adoption gate (CodeRabbit + 2 weeks findings) applies only to tasks 270–274.

## Context

audit-101 F-101-01: prior milestone text said “Supersedes ADR-19”, which conflicts with ADR-19 **DO NOT re-open**. Correct pattern = carve CodeRabbit-only integration out of the Aikido-coupled gate, leave Aikido/M76/M77 gated.

## Steps

1. Append **ADR-22** to `agent/memory/decisions.md`:
   - Title: CodeRabbit integration (M81) carved out of ADR-19’s Aikido-coupled gate
   - Decision: M81 may proceed when CodeRabbit is operational on ≥1 consumer repo **and** sanitized findings fixture exists; **Aikido not required**
   - ADR-19 remains in force for Aikido / M76 / M77
   - DO NOT re-open unless Aikido becomes a customer requirement or CodeRabbit optionality model changes
2. Create `agent/wiki/coderabbit-policy-map-lite.md` (~15 rule IDs):
   - Columns: `rule_id`, `owner` (`acp` | `coderabbit` | `both`), `phase` (1|2), notes
   - **Binding (F-101-07):** every Phase 1 rule (`EH-01`, `EH-02`, `SC-01`, `TS-01`, `TS-02`, `AP-01`, `NC-01`, `SH-01`) has `owner: acp` (or `both` with note “Phase 1 never deferred”)
   - Phase 2 overlap only may use `owner: coderabbit` / `both` for **annotation**, not skip
3. Sync docs (F-101-08):
   - `agent/wiki/coderabbit-integration.md` Roadmap → M81 / ADR-22; remove “run `/acp-plan M74`” as next action for CodeRabbit consumers
   - `agent/configurables/acp.configurables.yaml` comment: findings-import gated under **ADR-22/M81**, not ADR-19 alone
   - `agent/reports/research-acp-vs-coderabbit-aikido-2026.md` §5: annotate M81 CodeRabbit path; Aikido rows deferred
4. Retarget carryover F-097-01 `gated_remainder` → `ADR-22/M81` (foundation already fixed)
5. Confirm milestone governance section matches carve-out wording (already amended)

## Verification

- [ ] ADR-22 present; language is carve-out / not supersede
- [ ] Policy map ≥15 rules; Phase 1 never deferred
- [ ] Wiki + configurables + research no longer tell users to `/acp-plan M74` for CodeRabbit import
- [ ] F-097-01 `gated_remainder` updated
- [ ] `npx tsx scripts/acp-validate.ts` exit 0

## User-Observable Acceptance

Developer knows: ADR-19 still holds for Aikido; M81/ADR-22 unlocks CodeRabbit-only work; Phase 1 rules always run in `/acp-review`.
