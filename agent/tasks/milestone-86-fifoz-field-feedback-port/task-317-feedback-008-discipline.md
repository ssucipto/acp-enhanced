---
id: task-317
milestone: M86
title: "feedback-008 rule-verification discipline pattern"
status: planned
priority: 5
complexity: medium
estimated_hours: 3
created: 2026-08-14
started: null
completed:
phase: 3
depends_on: [task-316]
design_reference: [agent/design/local.fifoz-field-feedback-port.md](../../design/local.fifoz-field-feedback-port.md)
audit_findings: ['feedback-008', 'F-114-07']
files_affected:
  - agent/patterns/local.rule-verification-discipline.md
  - agent/memory/lessons.md
---

<!-- @acp.meta.task
topic: m86, fifoz, feedback, 008, discipline
description: Capture the proxy-vs-invariant failure class as a durable pattern so scanners and agents stop certifying correlated proxies.
milestone: M86
design: agent/design/local.fifoz-field-feedback-port.md
incorporates: FG-5
depends_on: task-316
status: planned
updated: 2026-08-14
@acp.meta.end -->

## Objective

Capture the proxy-vs-invariant failure class as a durable pattern so scanners and agents stop certifying correlated proxies.

## Context

feedback-008 critical finding: guards verified directory existence / status-string agreement / wrong schema key instead of the invariant. Must become an ACP pattern + lesson, not only a scanner patch.

## Steps

1. Write pattern with the three proxy failures and the rule: assert the invariant, not a correlate.
2. Add lesson entry (high) pointing to the pattern.
3. Add a short checklist for adding new review-scan rules (true-positive fixture required).
4. Link from acp.review.md if a "rule authoring" section fits without bloating.

## Verification

- [ ] Pattern exists with ≥3 examples
- [ ] Lesson logged
- [ ] Checklist requires a true-positive fixture for new rules

## User-Observable Acceptance

`agent/patterns/local.rule-verification-discipline.md` explains why `scripts/node_modules/` existing must not certify YAML parse capability.

## Expected Output

### Files Created / Modified
- `agent/patterns/local.rule-verification-discipline.md`
- `agent/memory/lessons.md`

### Notes
Source of truth: audit-114. Inbox reference only: `agent/reports/fifoz-port-inbox-2026-08-14/`. No shortcuts.
