---
id: task-264
milestone: M79
title: "M79 closure — ship v6.28.1, confirm regression cleared"
status: planned
priority: 5
complexity: low
estimated_hours: 1
created: 2026-07-23
started: null
completed: null
route: route-253
audit_findings: [F-099-01, F-099-02]
depends_on: [task-261, task-262, task-263]
design_reference: [Audit: audit-099](../../reports/audit-099-m78-implementation-gaps.md)
---

## Objective

Close M79 honestly: confirm the version regression is gone (assertion-level), ship v6.28.1, and re-affirm the remaining genuinely-pre-existing E2E debt as deferred.

## Steps

1. Bump version 6.28.0 → 6.28.1 across the 9 stamped files (identity, package.yaml, AGENTS.md, CLAUDE.md, AGENT.md, copilot-instructions.md, README badge, CHANGELOG entry) AND `agent/progress.yaml project.version` (the field that started this). Confirm the new acp-validate progress.yaml check (task-262) passes.
2. Run full verification: `npx tsx scripts/acp-validate.ts` (exit 0), `npx vitest run`, `tests/acp.e2e-workflow.test.sh`, `tests/acp.security.test.sh`, `e2e/coderabbit-optionality.test.sh`.
3. **Assertion-level regression confirmation**: verify `acp.security` is now fully green and `acp.e2e-workflow` lost its version-mismatch assertion (only the pre-existing copilot-light-mode assertion may remain).
4. Re-run the full suite; record the new file-level pass/fail count and confirm no NEW failures vs the M79 baseline.
5. Set M79 milestone `completed`; update `current_milestone`; add recent_work; update next_steps. Regenerate integrity manifest; create git tag v6.28.1.
6. Re-affirm the remaining pre-existing E2E failures (F-M78-01) as deferred with their audit-099 root causes — do NOT mark them fixed.

## Verification

- [ ] `acp-validate.ts` exit 0 (incl. new progress.yaml version check); vitest green
- [ ] `tests/acp.security.test.sh` fully green; `tests/acp.e2e-workflow.test.sh` version assertion gone
- [ ] Full-suite failure count strictly ≤ M79 baseline, with the 2 regression assertions cleared
- [ ] v6.28.1 stamped across 9 files + progress.yaml version; git tag v6.28.1 created
- [ ] M79 milestone completed; F-M78-01 remains pending with root-cause notes

## User-Observable Acceptance

v6.28.1 ships with a consistent version across all files including progress.yaml; the security + e2e-workflow version checks pass; the remaining failing tests are exactly the documented pre-existing debt, honestly deferred.
