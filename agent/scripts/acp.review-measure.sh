#!/usr/bin/env bash
# acp.review-measure.sh — Measure review-scan corpus recall and precision,
# plus a wall-clock perf gate (M85 task-303).
# Usage: bash agent/scripts/acp.review-measure.sh [--ci] [--min-recall 90] [--min-precision 90] [--perf-budget-ms 450]

set -euo pipefail
trap 'echo "[acp.review-measure] Error on line $LINENO" >&2; exit 1' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
SCAN_SCRIPT="${SCRIPT_DIR}/acp.review-scan.sh"
CORPUS_DIR="${PROJECT_ROOT}/tests/fixtures/review-corpus"
EXPECTED_FILE="${CORPUS_DIR}/expected.yaml"
CI_MODE=false
MIN_RECALL=90
MIN_PRECISION=90
# audit-110: a single-file scan measured 103ms post-Phase-1 (199ms before that,
# ~2950ms before audit-110's original fix). 450ms gives ~4.4x headroom over the
# measured figure — enough to absorb CI load / slower runners without going
# slack enough to hide a real regression. Not tuned to sit just above 103ms.
PERF_BUDGET_MS=450
PERF_BUDGET_REPS=5

usage() {
  cat <<'EOF'
Usage: bash agent/scripts/acp.review-measure.sh [--ci] [--min-recall 90] [--min-precision 90] [--perf-budget-ms 450]

Runs acp.review-scan.sh in --json mode against the labelled review corpus and
prints per-rule recall / precision plus aggregate totals. Also times a
single-file scan (median of 5 runs) and, under --ci, fails the build if it
exceeds --perf-budget-ms (audit-110: correctness gates can't see performance
regressions — this closes that blind spot).
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --ci)
      CI_MODE=true
      shift
      ;;
    --min-recall)
      MIN_RECALL="$2"
      shift 2
      ;;
    --min-precision)
      MIN_PRECISION="$2"
      shift 2
      ;;
    --perf-budget-ms)
      PERF_BUDGET_MS="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 is required for acp.review-measure.sh" >&2
  exit 2
fi

SCAN_SCRIPT="${SCAN_SCRIPT}" \
CORPUS_DIR="${CORPUS_DIR}" \
EXPECTED_FILE="${EXPECTED_FILE}" \
CI_MODE="${CI_MODE}" \
MIN_RECALL="${MIN_RECALL}" \
MIN_PRECISION="${MIN_PRECISION}" \
PERF_BUDGET_MS="${PERF_BUDGET_MS}" \
PERF_BUDGET_REPS="${PERF_BUDGET_REPS}" \
python3 - <<'PY'
import json
import os
import shutil
import statistics
import subprocess
import sys
import time
from collections import defaultdict
from pathlib import Path


def pct(tp: int, denom_extra: int) -> float:
    denom = tp + denom_extra
    return 100.0 if denom == 0 else (tp * 100.0) / denom


scan_script = Path(os.environ["SCAN_SCRIPT"])
corpus_dir = Path(os.environ["CORPUS_DIR"])
expected_file = Path(os.environ["EXPECTED_FILE"])
ci_mode = os.environ["CI_MODE"] == "true"
min_recall = float(os.environ["MIN_RECALL"])
min_precision = float(os.environ["MIN_PRECISION"])
perf_budget_ms = float(os.environ["PERF_BUDGET_MS"])
perf_budget_reps = int(os.environ["PERF_BUDGET_REPS"])
shellcheck_available = shutil.which("shellcheck") is not None

with expected_file.open(encoding="utf-8") as fh:
    cases = json.load(fh)["cases"]

stats = defaultdict(lambda: {"tp": 0, "fp": 0, "fn": 0})
rule_order = []
skipped = []
perf_target = None  # first non-skipped corpus file — reused for the wall-clock gate below

for case in cases:
    optional_tool = case.get("optional_tool")
    if optional_tool == "shellcheck" and not shellcheck_available:
        skipped.append(case["file"])
        continue

    file_rel = case["file"]
    target_rel = case.get("target", file_rel)
    target = corpus_dir / target_rel
    if perf_target is None:
        perf_target = target
    proc = subprocess.run(
        ["bash", str(scan_script), "--json", "--include-tests", str(target)],
        capture_output=True,
        text=True,
        check=False,
    )
    if proc.returncode != 0:
        print(proc.stderr.strip(), file=sys.stderr)
        raise SystemExit(proc.returncode)

    stdout = proc.stdout.strip()
    payload = json.loads(stdout or '{"findings":[],"summary":{"active_total":0}}')
    if isinstance(payload, dict):
        actual_findings = payload.get("findings", [])
    else:
        actual_findings = payload
    expected_findings = case.get("findings", [])

    expected_set = {
        (finding.get("file", file_rel), finding["rule"], int(finding["line"]))
        for finding in expected_findings
    }
    actual_set = set()
    for finding in actual_findings:
        actual_rel = os.path.relpath(Path(finding["file"]), corpus_dir)
        key = (actual_rel, finding["rule"], int(finding["line"]))
        actual_set.add(key)
        if finding["rule"] not in rule_order:
            rule_order.append(finding["rule"])
    for finding in expected_findings:
        if finding["rule"] not in rule_order:
            rule_order.append(finding["rule"])

    for _, rule, _ in expected_set & actual_set:
        stats[rule]["tp"] += 1
    for _, rule, _ in actual_set - expected_set:
        stats[rule]["fp"] += 1
    for _, rule, _ in expected_set - actual_set:
        stats[rule]["fn"] += 1

if not rule_order:
    raise SystemExit("No measurement cases were executed")

header = f"{'Rule':<8} {'TP':>3} {'FP':>3} {'FN':>3} {'Recall':>8} {'Precision':>10}"
print(header)
print("-" * len(header))

total_tp = total_fp = total_fn = 0
for rule in rule_order:
    tp = stats[rule]["tp"]
    fp = stats[rule]["fp"]
    fn = stats[rule]["fn"]
    total_tp += tp
    total_fp += fp
    total_fn += fn
    recall = pct(tp, fn)
    precision = pct(tp, fp)
    print(f"{rule:<8} {tp:>3} {fp:>3} {fn:>3} {recall:>7.1f}% {precision:>9.1f}%")

agg_recall = pct(total_tp, total_fn)
agg_precision = pct(total_tp, total_fp)
print("-" * len(header))
print(
    f"{'ALL':<8} {total_tp:>3} {total_fp:>3} {total_fn:>3} "
    f"{agg_recall:>7.1f}% {agg_precision:>9.1f}%"
)

executed_cases = len(cases) - len(skipped)
print(f"\nExecuted cases: {executed_cases}")
if skipped:
    print(f"Skipped optional corpus: {', '.join(skipped)}")

# ── Wall-clock perf gate (M85 task-303 / audit-110) ─────────────────────────
# audit-110's lesson: correctness gates (recall/precision above) cannot see
# performance regressions — the corpus scored 100%/100% throughout an 18x
# slowdown. Timed here, always, so drift is visible before it breaks;
# gated only under --ci so a local run never fails on a noisy machine.
print()
if perf_target is None:
    print("Perf gate: skipped — no corpus case available to time")
else:
    samples_ms = []
    for _ in range(perf_budget_reps):
        start = time.perf_counter()
        subprocess.run(
            ["bash", str(scan_script), "--json", "--include-tests", str(perf_target)],
            capture_output=True,
            text=True,
            check=False,
        )
        samples_ms.append((time.perf_counter() - start) * 1000.0)
    median_ms = statistics.median(samples_ms)
    print(
        f"Perf: single-file scan ({perf_target.relative_to(corpus_dir)}) "
        f"median {median_ms:.0f}ms over {perf_budget_reps} runs "
        f"(budget {perf_budget_ms:.0f}ms, audit-110)"
    )
    if ci_mode and median_ms > perf_budget_ms:
        print(
            f"CI gate failed: single-file scan median {median_ms:.0f}ms exceeds "
            f"the {perf_budget_ms:.0f}ms budget (audit-110 — a scanner regression "
            "correctness gates cannot see; see agent/commands/acp.review.md)",
            file=sys.stderr,
        )
        raise SystemExit(1)

if ci_mode and (agg_recall < min_recall or agg_precision < min_precision):
    print(
        f"CI gate failed: recall {agg_recall:.1f}% / precision {agg_precision:.1f}% "
        f"(min {min_recall:.1f}% / {min_precision:.1f}%)",
        file=sys.stderr,
    )
    raise SystemExit(1)
PY
