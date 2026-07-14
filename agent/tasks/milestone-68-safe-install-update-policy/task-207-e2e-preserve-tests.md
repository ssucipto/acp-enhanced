---
id: task-207
milestone: M68
title: E2E preserve behavioral tests (route-202)
status: planned
priority: 5
complexity: medium
estimated_hours: 4
created: 2026-07-15
started:
completed:
route: route-202
---

## Objective

Regression-proof tier policy with behavioral E2E (not syntax-only).

## Steps

1. Create `e2e/acp.version-update-preserve.test.sh` — temp dir, stub AGENTS.md, customized identity.yml, progress.yaml
2. Use fixture upstream tree or mock TEMP_DIR pattern (document approach in test header)
3. Assert identity + progress unchanged after update; commands refreshed
4. Create `e2e/acp.install-preserve.test.sh` — manifest with 2 packages, reinstall
5. Register suites in domain.yml; run in CI matrix (ubuntu, macOS, windows)

## Verification

- [ ] Both suites 100% pass locally
- [ ] ≥12 assertions in version-update-preserve suite

## User-Observable Acceptance

CI green on preserve tests; failure if blind `cp` reintroduced.
