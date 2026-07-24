---
id: task-265
milestone: M80
title: "Fix test-side E2E bugs (stale expectations, wrong file ref, fixtures)"
status: planned
priority: 5
complexity: medium
estimated_hours: 2.5
created: 2026-07-24
started: null
completed: null
route: route-254
audit_findings: [F-M78-01, F-100-03, F-100-04]
depends_on: []
design_reference: [Audit: audit-099](../../reports/audit-099-m78-implementation-gaps.md)
---

> **Amended per audit-100**: (F-100-03) `.github/copilot-instructions.md` is **auto-generated from AGENTS.md by the pre-commit hook** — editing it directly is reverted on commit. Fix e2e-workflow test-side (regex) or edit the AGENTS.md source, never copilot-instructions.md. (F-100-04) the `cp package.json` bug is at **three** sites (lines 23, 59, 74), all must be fixed.

## Objective

Fix the three F-M78-01 failures whose root cause is clearly test-side (not a product bug): stale grep expectation, a fixture copying a nonexistent file, and placeholder-fixture handling.

## Sub-items

1. **acp.e2e-workflow** — the assertion (`tests/acp.e2e-workflow.test.sh:43`) greps `.github/copilot-instructions.md` for `"light mode"`, but the canonical doc phrasing is "light + full modes" (line 3). **Prefer the test-regex fix**: broaden to match `light + full` / `light.*mode` so it passes for the right reason. **Do NOT edit copilot-instructions.md directly (F-100-03)** — it is regenerated from AGENTS.md by the pre-commit hook; if a doc-side fix is chosen, edit `AGENTS.md`. Add a one-line rationale comment on the assertion.
2. **acp.validate-cross-layer** — hard error `cp "${PROJECT_ROOT}/package.json"` at **lines 23, 59, and 74** (file absent; project uses `package.yaml`). Fix **all three** identically: make the copy conditional (`[ -f "$PROJECT_ROOT/package.json" ] && cp …`) or drop it if the cross-layer validation doesn't need it. Confirm the test then runs its real assertions.
3. **acp.validate-ts** — placeholder-check flags the temp fixtures (`{COMMAND_NAME}`, `{NAMESPACE}`). Determine whether the test intends those fixtures to be flagged (positive detection) or excluded; fix the assertion/fixture so the test passes for the right reason (assert the placeholder fixtures ARE flagged and the valid fixture is NOT).

## Steps

1. Read each failing test file and its assertions; reproduce the failure.
2. For each, decide test-fix vs code-fix (all three expected test-side); implement the minimal correct fix with a rationale comment.
3. Re-run each test file to green; keep assertions behavioral (values/exit codes).

## Verification

- [ ] `tests/acp.e2e-workflow.test.sh` green (light-mode assertion passes for the right reason)
- [ ] `e2e/acp.validate-cross-layer.test.sh` runs without the cp hard-error and passes
- [ ] `tests/acp.validate-ts.test.sh` green; placeholder fixtures asserted correctly
- [ ] No test weakened to a type-only/no-op assertion
- [ ] No product code changed for these three (test-side only) — or, if a real doc/code bug is found, note it explicitly

## User-Observable Acceptance

These three test files pass in `run-e2e-tests.sh`, and each passes because it verifies real behavior — not because an assertion was deleted.
