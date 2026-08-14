---
id: task-273
milestone: M81
title: "E2E integration + optionality regression tests"
status: completed
priority: 5
complexity: medium
estimated_hours: 3
created: 2026-07-24
started: 2026-08-14
completed: 2026-08-14
route: route-262
depends_on: [task-270, task-272]
design_reference: [task-258](../milestone-78-coderabbit-optionality-foundation/task-258-e2e-degradation.md)
audit_findings: [F-101-05]
gate: "task-270 import + task-272 wiring complete"
files_affected:
  - e2e/coderabbit-integration.test.sh
  - e2e/coderabbit-optionality.test.sh
---

## Objective

Add `e2e/coderabbit-integration.test.sh` for matrix A–D + import behavior; keep M78 `e2e/coderabbit-optionality.test.sh` green.

## Steps

1. Create `e2e/coderabbit-integration.test.sh` (auto-discovered; offline `--skip-network`):
   - **A** `enabled=false`, no config → import exit 0, no writes
   - **B** `enabled=true`, no config → hint; import no-op
   - **C** `enabled=true`, config + fixture → import writes expected `finding_id` / live fields
   - **D** `enabled=false`, config present → import no-op (opt-in wins)
2. Value/exit assertions only — no `typeof`-only
3. Temp fixtures + trap cleanup; use committed sample under `tests/fixtures/`
4. Confirm M78 optionality suite still passes

## Verification

- [ ] Cases A–D green
- [ ] M78 suite unchanged green
- [ ] macOS + Linux; no network

## User-Observable Acceptance

CI fails if import becomes mandatory or absent-tool branch is dropped.
