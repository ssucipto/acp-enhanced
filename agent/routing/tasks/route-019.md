---
id: route-019
title: M40 — Add --pre-impl mode to acp.audit.md v1.1.0
task_type: command-doc-update
milestone: M40
complexity: medium
executor: deepseek-v4-flash
context_required:
  - agent/commands/acp.audit.md
  - agent/feedback/feedback-003-pre-implementation-audit-protocol.md
  - agent/reports/audit-010-feedback-002-003-implementation-plan.md
  - agent/memory/audit-carryovers.md
files_affected:
  - agent/commands/acp.audit.md
tokens_est: 6000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-05-11
completed: 2026-05-11
override_reason:
---

## Task Description

Add `--pre-impl` flag to `/acp-audit` command. When present, it activates a 4-phase
structured pre-implementation readiness protocol instead of the standard single-mode
investigation. Also add instruction to write actionable findings to `audit-carryovers.md`
at the end of any audit (standard or --pre-impl). Bump version v1.0.0 → v1.1.0.

## Acceptance Criteria

- [ ] `acp.audit.md` version: `1.0.0` → `1.1.0`
- [ ] `Last Updated:` set to `2026-05-11`
- [ ] Arguments section updated with `--pre-impl` flag and example
- [ ] Natural language examples updated: `/acp-audit --pre-impl agent/tasks/milestone-N/`
- [ ] New Step 3b added (conditional on `--pre-impl` flag): 4-phase protocol
  - Phase 1: Plan Correctness (task files in isolation)
  - Phase 2: Code Cross-Reference (task snippets vs actual codebase)
  - Phase 3: Prior Carryover Validation (reads audit-carryovers.md)
  - Phase 4: Operational Completeness (auth, RBAC, error cases, N+1)
- [ ] Each phase has specific checklist items (not vague "read files")
- [ ] --pre-impl report format adds "Phase Summary" table (finding counts per phase)
- [ ] Step 4 (Generate Report) updated: after any audit finding actionable items → write to `agent/memory/audit-carryovers.md`
- [ ] Step 4 (Generate Report) updated for ALL modes: when findings require action, append each to `agent/memory/audit-carryovers.md` under the `carryovers:` key with `status: pending`
- [ ] Steps 0–3 and Step 5 unchanged when --pre-impl is NOT passed

## Implementation Notes

Step 3b triggers when `--pre-impl` is detected in arguments. Otherwise Step 3 runs as-is.

Phase 2 (Code Cross-Reference) is the KEY phase — make the checklist explicit:
- Backend: read Pydantic model → confirm field names; read enum → confirm values; read route decorator → confirm HTTP method + path; read DI container → confirm dependency exists
- Frontend: read import source → confirm file exists; read prop interface → confirm prop names; read API client → confirm response shape

Phase 3: read the `carryovers:` list from `agent/memory/audit-carryovers.md`; for each entry with `status: pending`, verify fix applied in the codebase. If not → escalate severity by one level, record as P3-N finding.

Step 4 addition (apply to ALL audit modes):
"If this audit produced findings requiring action: append each to `agent/memory/audit-carryovers.md` with `status: pending`. If the file does not exist, create it using the schema in route-018."

## Dependency

Requires route-018 (audit-carryovers.md exists and has schema).
