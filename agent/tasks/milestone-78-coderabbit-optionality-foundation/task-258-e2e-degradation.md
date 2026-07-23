---
id: task-258
milestone: M78
title: "E2E test — all three CodeRabbit degradation branches"
status: planned
priority: 5
complexity: medium
estimated_hours: 3
created: 2026-07-23
started: null
completed: null
route: route-247
audit_findings: [F-097-01]
depends_on: [task-255, task-256]
design_reference: [ADR-21](../../memory/decisions.md)
---

## Objective

Add `e2e/coderabbit-optionality.test.sh` proving the optionality contract holds across all three states, with assertions on **output values** (constraints.yml `test_quality_gate` — no `typeof`-only tests).

## Context

audit-097 anti-shortcut: every CodeRabbit path needs a *tested* absent branch. This is the regression guard that keeps future (gated) integration work from breaking non-CodeRabbit users.

## Steps

1. Create `e2e/coderabbit-optionality.test.sh`, sourcing `tests/common.sh` (test_rules: every test uses common.sh; e2e in `e2e/`).
2. Set up an isolated temp project fixture with ACP files + the new helpers.
3. Cases (each asserts a specific string/exit, not just a type):
   - **default (off)**: no `.coderabbit.yaml`, `enabled=false` → `coderabbit_active` exits 1; command output contains no CodeRabbit references (silent).
   - **enabled + absent**: `enabled=true`, no config file → `coderabbit_available` exits 1; `coderabbit_active` exits 1; optional hint string present exactly once.
   - **enabled + present**: `enabled=true`, `.coderabbit.yaml` seeded → `coderabbit_available` exits 0; `coderabbit_active` exits 0.
4. Assert `coderabbit_active` false when `enabled=false` even with config file present (opt-in precedence).
5. Register the test in CI if the e2e workflow enumerates files explicitly (`.github/workflows/e2e-tests.yaml`).

## Verification

- [ ] Three state cases + opt-in-precedence case all present
- [ ] Every assertion checks a concrete value/exit code (no `typeof`-only)
- [ ] `bash e2e/coderabbit-optionality.test.sh` passes on macOS and Linux
- [ ] Test appears in CI run (or workflow globs `e2e/*.test.sh`)
- [ ] Fixture cleaned up on exit (trap)

## User-Observable Acceptance

CI fails if anyone later makes an ACP command depend on CodeRabbit or drop the absent-tool branch.
