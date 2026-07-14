---
id: task-218
milestone: M63
title: "Coverage meta-assertion pattern — prevent registry-only shortcuts"
status: completed
priority: 3
complexity: low
estimated_hours: 0.5
created: 2026-07-15
started: 2026-07-15
completed: 2026-07-15
route: route-207
audit_findings: [audit-083-R1]
depends_on: [task-212]
---

## Objective

Document preventive rule from audit-083 recommendation: tier E2E suites must include meta-assertion that loop count matches registry tier count.

## Steps

1. Add **Anti-Shortcuts** table to milestone-63 doc
2. Document rule: `Registry ≠ behavioral coverage`
3. Require `TIER3_COUNT` (or equivalent) meta-assertion in tier suite acceptance criteria
4. Reference in route-207 AC for future coverage milestones

## Verification

- [x] Anti-Shortcuts section in milestone doc
- [x] task-212 documents meta-assertion requirement
- [x] audit-083 recommendation R1 addressed

## Pattern

```bash
# After dynamic loop
assert_equals "58" "${TIER3_COUNT}" "tier-3 command doc count"
```

Future tier suites: derive expected count from `command-e2e-coverage.yaml` tier field, not hardcoded magic numbers without cross-check.
