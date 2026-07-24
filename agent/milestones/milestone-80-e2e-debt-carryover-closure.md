# Milestone 80: E2E Suite Debt Remediation & Open Carryover Closure

<!-- @acp.meta.milestone
topic: e2e-debt, pre-existing-failures, carryover-closure, F-M78-01, F-086-02
description: Fix the 7 root-caused pre-existing E2E failures and close the remaining open carryovers honestly
status: planned
updated: 2026-07-24
@acp.meta.end -->

**Planned version**: 6.28.2
**Status**: planned (0/3)
**Estimated effort**: ~6h (3 tasks)
**Source**: audit-099 (F-M78-01 root-cause triage)
**Depends on**: M79 (v6.28.1)

## Goal

Close the remaining open carryover honestly. F-M78-01 is the 7 genuinely pre-existing E2E test failures root-caused in audit-099 — a mix of stale test expectations, a fixture referencing a nonexistent file, and script-vs-test behavior mismatches. This milestone fixes what is fixable, decides code-vs-test per case (no blind greening), and documents anything irreducible.

> **F-086-02 (FIFOZ downstream `/acp-version-update`) is already done** — developer-confirmed 2026-07-24; its planned task-267 was removed as redundant and the carryover marked fixed.

## The 7 pre-existing failures (audit-099 root causes)

| Test | Root cause | Likely fix | Task |
|------|-----------|-----------|------|
| acp.e2e-workflow | greps copilot-instructions for "light mode"; doc says "light + full modes" | test regex (stale) OR doc phrase | 265 |
| acp.validate-cross-layer | hard error: `cp package.json` — file absent (project uses package.yaml) | test harness | 265 |
| acp.validate-ts | placeholder-check flags temp fixtures ({COMMAND_NAME}/{NAMESPACE}) | test fixture/assertion | 265 |
| acp.version | version-check.sh exits 1 not 2 on missing AGENT.md; test expects 2 | decide code vs test | 266 |
| acp.package-info | one sub-test exit 1≠0 | decide code vs test | 266 |
| acp.project-update | git-tag "confirm tag added"/"detect duplicate" fixture asserts | git fixture setup | 266 |
| acp.post-milestone-sweep | 4/5 — one sub-test fails | diagnose + fix | 266 |

## Build Order

| Route | Task | Title | Scope | Est. |
|-------|------|-------|-------|------|
| route-254 | task-265 | Fix test-side E2E bugs (stale expectations, wrong file ref, fixtures) | e2e-workflow, validate-cross-layer, validate-ts | 2.5h |
| route-255 | task-266 | Reconcile script-vs-test behavior mismatches | version, package-info, project-update, post-milestone-sweep | 2.5h |
| route-257 | task-268 | M80 closure — full suite, v6.28.2, close carryover | closure | 1h |

Dependency: task-268 depends on 265–266.

## Anti-Shortcut Guardrails (binding)

1. **No blind greening** — for each failure, decide explicitly whether the TEST or the CODE is wrong, and fix the correct side. A test asserting wrong behavior is fixed by correcting the assertion WITH a one-line rationale; a real code bug is fixed in the code.
2. **Behavioral assertions** — any test touched must still assert on values/exit codes, not types (constraints.yml `test_quality_gate`).
3. **No new regressions** — full-suite failure count must strictly decrease; re-run assertion-level, not just file-level (audit-099 lesson).
4. **Document irreducible** — if any failure reflects an intentional design choice the test wrongly encodes, record the decision rather than forcing green.

## Verification Gates (M80 closure)

- [ ] Each of the 7 failures: fixed OR documented-irreducible with rationale (task-265/266)
- [ ] Full E2E suite failure count < 7 (target 0 for F-M78-01 scope); no NEW failures (task-268)
- [ ] Any touched test still asserts on values/exit codes (task-265/266)
- [ ] `acp-validate.ts` exit 0; vitest green; v6.28.2 tagged (task-268)
- [ ] F-M78-01 → fixed (or partial with documented remainder); carryovers schema valid (task-268)
