---
id: task-225
milestone: M70
title: "Expand acp.review-scan.sh — TS-02, AP-01, EH-01, NC-01"
status: completed
priority: 4
complexity: high
estimated_hours: 8
created: 2026-07-15
started: 2026-07-15
completed_date: 2026-07-15
route: route-214
audit_findings: [F-086-03]
depends_on: [task-224]
---

## Objective

Expand Phase 1 scanner from 4 to 8 rules with E2E fixtures.

## Steps

1. Add rule checks to `acp.review-scan.sh` for TS-02, AP-01, EH-01, NC-01
2. Add fixtures under `agent/benchmarks/fixtures/review/`
3. Extend `e2e/acp.review.test.sh` behavioral assertions
4. Update command doc rule table with Phase 1 column

## Verification

- [ ] Scanner covers 8 rules with passing + failing fixtures
- [ ] E2E review suite green
