---
id: task-214
milestone: M63
title: "Case-insensitive Agent Directive check in tier E2E (F-083-06)"
status: completed
priority: 3
complexity: low
estimated_hours: 0.5
created: 2026-07-15
started: 2026-07-15
completed: 2026-07-15
route: route-207
audit_findings: [F-083-06, SC-M63-05]
depends_on: [task-212]
---

## Objective

Fix false failure on `acp.proceed` which uses "CRITICAL AGENT DIRECTIVE" not literal "Agent Directive".

## Steps

1. Replace `assert_contains ... "Agent Directive"` with `grep -qi "agent directive"` in tier3 suite
2. Apply same fix to tier2 suite for consistency
3. Re-run both suites — 100% pass

## Verification

- [x] `acp.proceed` passes Agent Directive check
- [x] tier2 + tier3 green
