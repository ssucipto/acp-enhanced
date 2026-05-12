---
id: route-045
title: M43 — Routing rules guidance + checkStaleness ordering (R3 + OBS-001)
task_type: yaml-schema
milestone: M43
complexity: low
executor: deepseek-v4-flash
context_required:
  - routing/rules.md
  - memory/audit-carryovers.md
files_affected:
  - agent/routing/rules.md
  - scripts/acp-validate.ts
tokens_est: 3000
tokens_actual:
cost_est_usd: 0.00
cost_actual_usd:
created: 2026-05-12
completed: 2026-05-12
override_reason:
---

## Task Description

Two small fixes bundled together as they both touch routing/validation hygiene:

**R3** — Add a routing threshold rule to `agent/routing/rules.md` to clarify when a command doc change should use `command-doc-write` vs `command-doc-update`. The gap was discovered during audit-017 when the cost report tried to classify new-section additions to existing docs and had no rule to distinguish write vs update.

**OBS-001** — Reorder `checkStaleness()` in `scripts/acp-validate.ts` no-args main block so informational staleness output appears after the two blocking checks (`validateAgentsMdSize`, `validateSessionsMemory`). Currently staleness output prints first, mixing informational lines before error lines.

**Source**: 
- R3 from audit-017 recommendation (`agent/reports/audit-017-taxonomy-improvement-suggestions.md`)
- OBS-001 from audit-016 carryover (`agent/memory/audit-carryovers.md`, audit_id: 16)

## Implementation

### R3 — `agent/routing/rules.md`

Add to the "Ambiguity Resolution" section (after the existing `command-doc-write vs bash-script-create` block):

```
When uncertain between command-doc-write and command-doc-update:
  - If ADDING a new section with > 20 lines of new protocol text → command-doc-write
  - If updating/correcting existing content (< 20 net new lines) → command-doc-update
  - If rewriting > 50% of an existing command doc → command-doc-write
```

### OBS-001 — `scripts/acp-validate.ts`

In the no-args main block (around lines 503–512), the current order is:

```typescript
checkStaleness();
validateAgentsMdSize();
validateSessionsMemory();
```

Reorder to:

```typescript
validateAgentsMdSize();
validateSessionsMemory();
checkStaleness();
```

This ensures blocking validation errors print before informational staleness warnings.

## Acceptance Criteria

- [ ] `routing/rules.md` has new threshold rule under "Ambiguity Resolution" for command-doc-write vs command-doc-update
- [ ] Rule specifies the `> 20 lines` threshold for new protocol text
- [ ] `acp-validate.ts` no-args block calls `checkStaleness()` after `validateAgentsMdSize()` and `validateSessionsMemory()`
- [ ] `npx ts-node scripts/acp-validate.ts` runs without syntax errors
- [ ] Carryover OBS-001 in `agent/memory/audit-carryovers.md` set to `status: fixed, fix_applied_date: 2026-05-12`
