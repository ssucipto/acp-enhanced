---
id: task-213
milestone: M63
title: "Vitest unit tests for validateCommandE2eCoverage (F-083-04)"
status: completed
priority: 4
complexity: medium
estimated_hours: 1.5
created: 2026-07-15
started: 2026-07-15
completed: 2026-07-15
route: route-207
audit_findings: [F-083-04, SC-M63-04]
depends_on: [task-211]
---

## Objective

Add vitest coverage for `validateCommandE2eCoverage()` — E2E-only testing is insufficient (vitest workers block `process.chdir`).

## Steps

1. Add `CommandE2eCoverageOptions` (`repoRoot`, `commandsDir`) to `acp-validate.ts`
2. Resolve suite paths relative to `repoRoot` (absolute path support)
3. Create `scripts/fixtures/command-e2e-coverage-gap.yaml` — partial registry
4. Add 3 vitest cases: missing file, gap detection, full registry pass
5. Run `cd scripts && npm test` — 45/45 pass

## Verification

- [x] Missing registry file errors
- [x] Gap fixture reports `no E2E coverage entry for`
- [x] Full repo registry — 0 blocking errors
- [x] No `process.chdir` in tests
