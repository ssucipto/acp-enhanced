---
id: route-187
title: M58 plan correction — fix circular go/no-go gate, reconcile route-155 scope, fixture confidence policy, canonical script name
task_type: adr-write
milestone: M65
complexity: medium
executor: copilot
context_required:
  - reports/audit-069-m57-m58-post-sync-reaudit.md
  - artifacts/research-m58-taint-flow-calibration.md
files_affected:
  - agent/milestones/milestone-58-acp-integrity-v2-semantic-analysis.md
  - agent/memory/decisions.md
  - agent/benchmarks/fixtures/taint-flow/manifest.yaml
  - agent/routing/tasks/route-157.md
  - agent/routing/tasks/route-158.md
tokens_est: 8000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-15
started: 2026-06-15
completed: 2026-06-15
override_reason:
---

## Objective

Repair the M58 v2.0 plan so it is internally consistent and executable: break the circular go/no-go gate, formally reconcile route-155's delivered-vs-stated scope, encode the confidence policy into the taint fixtures, and settle on one taint-script name.

## Context

audit-069: F-069-04 (HIGH) the §10 go/no-go gate is circular — it gates routes 156–158 on empirical taint TPR, but the TPR is "measured in route-158", which is itself gated. F-069-03 (HIGH) route-155 was counted complete but did not deliver the milestone §7 empirical scope (10 CVEs, TS sample, ESLint-security comparison, empirical TPR, memory-poisoning UX doc). F-068-04/F-069-07 (MED) the taint fixture manifest encodes `severity` but not the research-mandated `max_confidence`/`ci_blocking`, so route-158 E2E cannot assert the confidence ceilings the plan requires (≤MEDIUM, advisory-only). F-069-10 (LOW) script-name mismatch (`acp.taint-heuristic.sh` vs `acp.taint-scan.sh`/`acp.memory-scan.sh`).

## Steps

1. **ADR for the gate** (F-069-04): write an ADR in `agent/memory/decisions.md` choosing ONE: (a) move empirical TPR measurement into route-155/156 (before the gate), or (b) accept the literature-derived confidence ceilings explicitly and remove the empirical precondition. Update `milestone-58 §10` to the chosen, non-circular sequence.
2. **ADR for route-155 scope** (F-069-03): write an ADR either committing to finish the missing empirical scope (and add routes for it) OR formally descoping milestone-58 §7/§10 to the literature-calibration approach actually taken. Update milestone-58 §7/§10 accordingly so "done" matches scope.
3. **Fixture confidence policy** (F-068-04/F-069-07): add `max_confidence` and `ci_blocking` columns to `agent/benchmarks/fixtures/taint-flow/manifest.yaml` per the §4 confidence table (taint ≤ MEDIUM, advisory; never CRITICAL auto-fail in `--ci`). Update route-157/158 acceptance criteria to assert no CRITICAL auto-fail on taint fixtures and that confidence ≤ MEDIUM.
4. **Canonical script name** (F-069-10): pick ONE name (recommend `acp.taint-heuristic.sh` per the research) and update route-157, milestone-58, and any references to it consistently.

## Expected Output

### Files Modified
- `agent/memory/decisions.md` — 2 ADRs (gate, route-155 scope)
- `milestone-58-*.md` — non-circular §10 gate, scope §7/§10 reconciled
- `agent/benchmarks/fixtures/taint-flow/manifest.yaml` — max_confidence + ci_blocking
- `route-157.md`, `route-158.md` — canonical name + confidence-aware acceptance

## Verification (double-verify)

- [ ] **Manual**: re-read milestone-58 §10 — the proceed decision no longer depends on a measurement produced by a gated route (no cycle)
- [ ] **Manual**: every taint fixture row has `severity`, `max_confidence`, `ci_blocking`; none allows CRITICAL in `--ci`
- [ ] **Manual**: one taint-script name appears across route-157/milestone-58/research (no aliases)
- [ ] ADRs present in decisions.md with status Accepted

## User-Observable Acceptance

- M58 v2.0 can be executed as written — no circular precondition, scope matches "done", and the test ground truth supports the confidence assertions the plan requires.

## Addresses

audit-069 F-069-03 (HIGH), F-069-04 (HIGH), F-069-07 (MED), F-069-10 (LOW); audit-068 F-068-04 (MED)
