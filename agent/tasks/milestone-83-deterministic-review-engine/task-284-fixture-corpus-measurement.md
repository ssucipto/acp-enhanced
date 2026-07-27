---
id: task-284
milestone: M83
title: "Fixture corpus + published precision/recall measurement"
status: planned
priority: 5
complexity: medium
estimated_hours: 4
created: 2026-07-27
started: null
completed: null
phase: 1c
depends_on: [task-283]
audit_findings: []
blocks: [task-286, task-287, task-288, task-289, task-290]
files_affected:
  - tests/fixtures/review-corpus/
  - agent/scripts/acp.review-measure.sh
  - agent/commands/acp.review.md
  - package.yaml
---

## Objective

Build a labelled fixture corpus and a measurement script that reports recall and precision per rule, and publish the numbers in the command doc.

## Context

audit-103 Shortcut #6: the "8 deterministic rules" claim was published without any precision or recall measurement. The measured reality was ≈8% recall and 0% precision. **A rule count is not a capability claim.**

This task makes quality measurable and regression-visible, and it gates Phase 3 — no new rule ships without a corpus entry.

## Steps

1. Create `tests/fixtures/review-corpus/` with, per rule: a `positive/` file (defect present, expected finding line recorded) and a `negative/` file (lookalike text in comments/strings/valid code).
2. Record expectations in `tests/fixtures/review-corpus/expected.yaml` — `{rule, file, line}` tuples.
3. Implement `agent/scripts/acp.review-measure.sh`:
   - run the scanner over the corpus in `--json` mode
   - compare against `expected.yaml`
   - emit per-rule and aggregate **recall**, **precision**, plus TP/FP/FN counts
   - `--ci` fails when aggregate recall or precision falls below a configured floor
4. Register the script in `package.yaml`.
5. Publish the measured table in `acp.review.md`, replacing the bare rule-count claim.
6. Wire the measurement into CI so drift fails the build.

## Verification

- [ ] Corpus covers all 8 shipped rules with positive and negative cases
- [ ] Measurement reproduces audit-103's numbers when run against the **pre-fix** scanner
- [ ] Post-fix run shows recall ≥ 90% and precision ≥ 90%
- [ ] `acp.review.md` shows measured figures with the corpus size and date
- [ ] `--ci` mode fails on a deliberately regressed rule

## User-Observable Acceptance

`bash agent/scripts/acp.review-measure.sh` prints a per-rule precision/recall table, and the published numbers in the command doc are reproducible.
