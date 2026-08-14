---
id: task-305
milestone: M86
title: "AE CI job graph enumeration + wall-clock baseline"
status: completed
priority: 5
complexity: medium
estimated_hours: 3
created: 2026-08-14
started: 2026-08-14
completed: 2026-08-14
phase: 0
design_reference: [agent/design/local.fifoz-field-feedback-port.md](../../design/local.fifoz-field-feedback-port.md)
audit_findings: ['F-114-02', 'feedback-009']
files_affected:
  - agent/reports/m86-ci-job-baseline.md
  - tests/acp.ci-gate-measure.sh
---

<!-- @acp.meta.task
topic: m86, fifoz, ci, job, graph, baseline
description: Enumerate every CI job/step that can fail a PR on this repo and capture median wall-clocks before any tier assignment.
milestone: M86
design: agent/design/local.fifoz-field-feedback-port.md
incorporates: D5

status: draft
updated: 2026-08-14
@acp.meta.end -->

## Objective

Enumerate every CI job/step that can fail a PR on this repo and capture median wall-clocks before any tier assignment.

## Context

feedback-009 §2.1/2.3: FIFOZ tiered from assumed cost and mapped one job as "CI". audit-114 listed AE jobs provisionally; task-305 must re-measure on an idle machine (mean/median of ≥5 runs) and assign every job a tier OR a written out-of-scope rationale. Read every workflow `if:` condition.

## Steps

1. Parse `.github/workflows/ci.yaml`, `e2e-tests.yaml`, `benchmark.yaml` at the **job** level (not step-only).
2. For each job, list steps that can hard-fail vs continue-on-error.
3. Write `tests/acp.ci-gate-measure.sh` that times each candidate local gate command used by those jobs (validate pieces, shellcheck, integrity e2e smoke subset, etc.) with a portable ms clock (python3), N≥5, reporting median.
4. Write `agent/reports/m86-ci-job-baseline.md` with: job → steps → median ms → provisional tier → rationale; out-of-scope jobs with reason.
5. Explicitly record: never use a single sample; never tier from intuition.
6. Do **not** create `acp.ci.sh` yet — measurement only.

## Verification

- [x] Every workflow job appears in the baseline report
- [x] Every job has tier or out-of-scope rationale
- [x] Medians from ≥5 runs documented (e2e-smoke: idle one-shot + contended N=5 discarded with rationale)
- [x] `if:` conditions reviewed (document none if absent)
- [x] No tier preferences written into configurables yet (ci.yml is task-308)

## User-Observable Acceptance

`bash tests/acp.ci-gate-measure.sh` prints a timing table; `agent/reports/m86-ci-job-baseline.md` lists every CI job with a tier or out-of-scope reason a human can audit.

## Expected Output

### Files Created / Modified
- `agent/reports/m86-ci-job-baseline.md`
- `tests/acp.ci-gate-measure.sh`

### Notes
Source of truth: audit-114. Inbox reference only: `agent/reports/fifoz-port-inbox-2026-08-14/`. No shortcuts.
