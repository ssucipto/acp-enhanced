---
id: task-224
milestone: M70
title: "Two-phase review gate policy (F-086-03)"
status: completed
priority: 5
complexity: medium
estimated_hours: 4
created: 2026-07-15
started: 2026-07-15
completed_date: 2026-07-15
route: route-213
audit_findings: [F-086-03]
depends_on: []
---

## Objective

Publish explicit gate policy: Phase 1 `acp.review-scan.sh` + Phase 2 agent review required for release.

## Steps

1. Add "Gate Policy" section to `acp.review.md` and `code-review.md` skill
2. Document which rules are Phase 1 vs Phase 2
3. Update README/domain.yml — no "standalone CI gate" claim
4. E2E asserts policy section exists

## Verification

- [ ] Policy states 4/64 automated, 60 agent-required
- [ ] F-086-03 partially closed (policy); scanner expansion in task-225
