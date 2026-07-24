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
gate: "CodeRabbit on ≥1 repo + 2 weeks findings before implementation"
---

## Objective

Formalize a **CodeRabbit-only, Aikido-free** adoption gate (ADR-22) and produce a **lite policy map** — which `/acp-review` rules defer to CodeRabbit engines vs stay ACP-owned — so downstream tasks import and review wiring have a documented contract.

## Context

ADR-19 gated M74–M77 on CodeRabbit **and** Aikido. The maintainer has one CodeRabbit consumer and cannot justify Aikido cost. ADR-21 carved M78 (optionality) out of ADR-19; M81 carves the **CodeRabbit integration surface** out with a narrower gate — same precedent.

## Steps

1. Append **ADR-22** to `agent/memory/decisions.md`:
   - Gate: CodeRabbit operational + 2 weeks findings; **Aikido not required**
   - Scope: M81 deliverables only; Aikido/M76/M77 stay plan-only until explicitly re-planned
   - DO NOT re-open unless Aikido becomes a customer requirement
2. Annotate `agent/reports/research-acp-vs-coderabbit-aikido-2026.md` header: CodeRabbit-only path via M81/ADR-22; Aikido row marked "deferred for current user base"
3. Create `agent/wiki/coderabbit-policy-map-lite.md` (~15 rules):
   - Rules where CodeRabbit engines overlap (TS lint, secrets, basic SAST) → owner: `coderabbit`
   - Governance/lifecycle rules (carryover, protocol, agent-context) → owner: `acp`
   - `/acp-review` Phase 2 uses map for "defer to CodeRabbit" annotations
4. Update `agent/wiki/coderabbit-integration.md` Roadmap section: M81 replaces gated M74/M75 for CodeRabbit-only consumers

## Verification

- [ ] ADR-22 present in `decisions.md` with Status: Accepted
- [ ] Policy map lists ≥15 rule IDs with owner (`acp` | `coderabbit` | `both`)
- [ ] No Aikido references as required for M81 gate
- [ ] `npx tsx scripts/acp-validate.ts` passes after doc changes

## User-Observable Acceptance

A developer can read ADR-22 + policy map and know exactly what M81 builds, what stays gated, and when `/acp-proceed M81` is allowed.
