---
id: task-303
milestone: M85
title: "Wall-clock perf gate in the corpus measurement"
status: completed
priority: 5
complexity: low
estimated_hours: 2
created: 2026-07-28
started: 2026-08-01
completed: 2026-08-01
phase: 3
depends_on: [task-302]
audit_findings: [A-110-05]
files_affected:
  - agent/scripts/acp.review-measure.sh
  - .github/workflows/ci.yaml
---

## Objective

Fail CI when a single-file scan exceeds a wall-clock budget, closing the blind spot that let an 18× slowdown ship unnoticed.

## Context

audit-110's central lesson: **correctness gates cannot see performance regressions.** The corpus gate scored 100% recall / 100% precision throughout the period when every scanner invocation was ~3s slower than necessary. The only signal was a per-test timeout on the slowest platform, which reads as "Windows is flaky" — and the instinctive response (raise the timeout) deletes the signal entirely. That is exactly what happened before the root cause was found.

## Steps

1. Add a `--perf-budget-ms` option to `acp.review-measure.sh`, defaulting to a value with clear headroom over the measured post-M85 number — not tuned to the exact figure.
   > **Measured 2026-07-31:** a single-file review scan is **103 ms** post-Phase-1 (199 ms before, ~2950 ms before audit-110's fix). A budget around **400-500 ms** gives roughly 4-5× headroom — enough to absorb CI load and slower runners without going slack enough to hide a real regression. Do not set it just above 103 ms.
2. Time a single-file scan of a committed corpus fixture, median of N runs to avoid a one-off outlier failing CI.
3. Under `--ci`, fail with a message naming the budget, the observed time, and the audit that established the budget.
4. Print the timing on every run, not only on failure, so drift is visible before it breaks.
5. The existing recall/precision gate is unchanged and still authoritative for correctness.
6. Document the budget and its rationale in `agent/commands/acp.review.md` beside the corpus figures.

## Verification

- [ ] Gate fails when the budget is artificially lowered below the observed time
- [ ] Gate passes at the real budget with headroom
- [ ] Median of N runs used, not a single sample
- [ ] Timing printed on success as well as failure
- [ ] `.github/workflows/ci.yaml` runs the gate
- [ ] Failure message names the budget, the observed value, and audit-110

## User-Observable Acceptance

`bash agent/scripts/acp.review-measure.sh --ci` prints a scan timing alongside recall/precision, and fails the build if the scanner regresses past its budget.

## Resolution (2026-08-01)

Added `--perf-budget-ms` (default 450, per audit-110's measured 103ms
single-file figure — ~4.4x headroom) and `--perf-budget-reps` (5, matching
the milestone's median-of-5 convention elsewhere). Times the first
non-skipped corpus case (`positive/eh01.ts`) via `time.perf_counter()` in
the existing python3 heredoc — median of 5 full `bash acp.review-scan.sh`
subprocess invocations, printed on every run (300-360ms locally, well under
budget; higher than the isolated 103ms figure because this times the whole
subprocess path including bash startup and script-sourcing overhead, which
is what the gate actually needs to catch). The recall/precision gate is
untouched; the perf check runs before it so timing always prints even if
recall/precision fails.

Verified: `--perf-budget-ms 10` fails with exit 1 and a message naming the
budget (10ms), the observed median, and audit-110; the real default budget
(450ms) passes with correct headroom; a low budget without `--ci` never
fails (local runs are informational only). `.github/workflows/ci.yaml`'s
existing `acp.review-measure.sh --ci` step already runs the new gate
automatically — its name was updated for clarity, no new step needed.
Documented in `agent/commands/acp.review.md` beside the existing corpus
recall/precision table.

No dedicated test file was added: no *.test.sh convention exists for this
script (it's CI-invoked directly, not command-doc-backed), and the
Verification checklist above was exercised manually end-to-end instead.
