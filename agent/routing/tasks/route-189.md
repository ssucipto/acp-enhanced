---
id: route-189
title: Capture this project's ADR history (/acp-decide reconstruction of key decisions)
task_type: adr-write
milestone: M65
complexity: low
executor: copilot
context_required:
  - reports/audit-065-acp-enhanced-comprehensive-gap-analysis.md
  - wiki/architecture.md
files_affected:
  - agent/memory/decisions.md
tokens_est: 5000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-15
started: 2026-06-15
completed: 2026-06-15
override_reason:
---

## Objective

Reconstruct and record the key architectural decisions this 57-milestone framework-dev project has made but never captured, so future sessions stop re-debating settled choices.

## Context

audit-065 CRIT-065-001 (downgraded to medium by audit-066: `decisions.md` is gitignored instance data, not missing storage). The project has never run `/acp-decide`; its own ADR history is uncaptured. Reconstruct from `agent/wiki/architecture.md`, `agent/memory/patterns.md`, and commit history.

## Steps

1. Identify 5–8 settled architectural decisions from wiki/patterns/commits, e.g.:
   - LLM/Script boundary rule for `/acp-integrity` (deterministic → bash, semantic → LLM).
   - Dual-store memory (YAML registries ↔ markdown docs).
   - Light/full context modes + token-budget discipline.
   - gitflow-lite (`develop` → `mainline`).
   - Confidence-ceiling policy for semantic security analysis (MEDIUM/LOW).
   - Command-doc-as-spec (no separate spec files — audit-052).
2. For each, append an ADR to `agent/memory/decisions.md` using the `/acp-decide` format (ADR-N | date | title | Status | Context | Options | Decision | Consequences | DO NOT re-open unless …).
3. Keep each ADR concise; cite the source (wiki section / audit ID / commit) in Context.

## Expected Output

### Files Modified
- `agent/memory/decisions.md` — 5–8 reconstructed ADRs

## Verification (double-verify)

- [ ] **Manual**: `decisions.md` contains ADRs for the boundary rule, dual-store memory, context modes, gitflow-lite, and confidence ceilings
- [ ] Each ADR has Status, Context (with source), Decision, Consequences, and a "DO NOT re-open" trigger
- [ ] No duplicate ADRs for the same decision

## User-Observable Acceptance

- `/acp-decide` history exists; future sessions can reference settled decisions instead of re-deriving them.

## Addresses

audit-065 CRIT-065-001 (reclassified medium)
