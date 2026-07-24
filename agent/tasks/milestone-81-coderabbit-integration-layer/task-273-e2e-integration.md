---
id: task-273
milestone: M81
title: "E2E integration + optionality regression tests"
status: planned
priority: 5
complexity: medium
estimated_hours: 3
created: 2026-07-24
started: null
completed: null
route: route-262
depends_on: [task-270, task-272]
design_reference: [task-258](../milestone-78-coderabbit-optionality-foundation/task-258-e2e-degradation.md)
---

## Objective

Add `e2e/coderabbit-integration.test.sh` covering the M81 optionality matrix (cases A–D) plus findings-import behavior, while keeping `e2e/coderabbit-optionality.test.sh` (M78) green.

## Context

audit-097 + M78: every CodeRabbit path needs a tested absent branch. M81 adds import + review wiring — regression guard for multi-tenant safety.

## Steps

1. Create `e2e/coderabbit-integration.test.sh` (auto-discovered by `run-e2e-tests.sh`):
   - **Case A** (`enabled=false`, no config): `findings-import` exit 0, no carryover writes
   - **Case B** (`enabled=true`, no config): hint emitted; import no-op
   - **Case C** (`enabled=true`, config + fixture): import writes expected carryover fields
   - **Case D** (`enabled=false`, config present): import no-op (opt-in wins)
2. Assert concrete strings / exit codes — no `typeof`-only checks
3. Isolated temp fixtures; trap cleanup
4. Offline (`--skip-network`) — use fixture files only, no live CodeRabbit API in CI
5. Run full suite: `bash run-e2e-tests.sh --skip-network` — 68/68+ pass

## Verification

- [ ] Cases A–D implemented with value assertions
- [ ] M78 `e2e/coderabbit-optionality.test.sh` still passes unchanged
- [ ] Test passes macOS + Linux
- [ ] No network required

## User-Observable Acceptance

CI fails if a future change makes findings-import mandatory, breaks idempotency, or removes the absent-tool branch.
