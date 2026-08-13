---
id: task-316
milestone: M86
title: "Diff-merge acp.review-scan.sh FIFOZ ↔ AE M83"
status: planned
priority: 5
complexity: high
estimated_hours: 6
created: 2026-08-14
started: null
completed:
phase: 3
depends_on: [task-307]
design_reference: [agent/design/local.fifoz-field-feedback-port.md](../../design/local.fifoz-field-feedback-port.md)
audit_findings: ['F-114-09', 'feedback-008']
files_affected:
  - agent/scripts/acp.review-scan.sh
  - agent/reports/m86-review-scan-merge-notes.md
---

<!-- @acp.meta.task
topic: m86, fifoz, review, scan, diff, merge
description: Merge FIFOZ feedback-008 precision fixes into AE M83 scanner without blind overwrite.
milestone: M86
design: agent/design/local.fifoz-field-feedback-port.md
incorporates: FG-5
depends_on: task-307
status: draft
updated: 2026-08-14
@acp.meta.end -->

## Objective

Merge FIFOZ feedback-008 precision fixes into AE M83 scanner without blind overwrite.

## Context

Diff is in `agent/reports/fifoz-port-inbox-2026-08-14/acp.review-scan.sh.fifoz-vs-ae.diff` (+75/−7). AE has M83 corpus, rule_overrides, perf work. Each hunk must be classified: take FIFOZ / keep AE / hybrid. Re-run review E2E and measure.

## Steps

1. Read the full diff and feedback-008 summary of false-positive rules.
2. For each hunk, record decision in `agent/reports/m86-review-scan-merge-notes.md`.
3. Apply merge carefully; keep AE M83 behaviors that already fixed the same class.
4. Run `e2e/acp.review-scan.test.sh` and `acp.review-measure.sh --ci`.
5. Ensure dependency probes use execution-context PATH rules (FG-7) if FIFOZ fixed that.
6. Forbid replacing entire file with FIFOZ copy.

## Verification

- [ ] Merge notes list every hunk decision
- [ ] review-scan E2E green
- [ ] measure --ci green
- [ ] File is not identical to either pre-merge AE or FIFOZ blindly

## User-Observable Acceptance

Merge notes file exists; `bash e2e/acp.review-scan.test.sh` passes after the merge.

## Expected Output

### Files Created / Modified
- `agent/scripts/acp.review-scan.sh`
- `agent/reports/m86-review-scan-merge-notes.md`

### Notes
Source of truth: audit-114. Inbox reference only: `agent/reports/fifoz-port-inbox-2026-08-14/`. No shortcuts.
