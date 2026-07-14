---
id: task-226
milestone: M70
title: "E2E commit auto-sync, repair tools, --memory (GAP-041-07)"
status: planned
priority: 4
complexity: medium
estimated_hours: 6
created: 2026-07-15
started: null
completed_date: null
route: route-215
audit_findings: [GAP-041-07]
depends_on: []
---

## Objective

E2E coverage for M47 commit auto-sync, repair-tools, and `--memory` validation paths.

## Steps

1. Create `e2e/acp.commit-sync.test.sh`
2. Test session doc auto-sync idempotency
3. Test `--memory` validate path
4. Register in command-e2e-coverage.yaml if applicable

## Verification

- [ ] E2E suite passes in CI
- [ ] GAP-041-07 carryover fixed
