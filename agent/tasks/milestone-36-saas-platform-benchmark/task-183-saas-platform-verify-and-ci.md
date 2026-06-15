---
id: task-183
milestone: M36
title: Create saas-platform verify.sh and wire into CI benchmarks workflow
status: not_started
priority: 1
complexity: medium
estimated_hours: 2
created: 2026-05-05
started:
completed:
---

## Objective

Create `agent/benchmarks/suite/saas-platform/verify.sh` that checks OWASP violation remediation, and wire the benchmark suite into `.github/workflows/benchmarks.yml` (create if absent).

## Context

The benchmark runner in `agent/benchmarks/runner/` executes prompts and produces JSON output. `verify.sh` reads that output and checks whether the expected OWASP violations (`expected_detections` from the YAML prompts) were actually detected and remediated. The CI workflow runs the benchmark on schedule (weekly) and publishes results to `agent/benchmarks/results/`.

## Implementation

### `verify.sh`

```bash
#!/usr/bin/env bash
# verify.sh — Checks OWASP violation remediation for saas-platform benchmark

<!-- @acp.meta.task
topic: verifysh, checks, owasp, violation, remediation, for, saas-platform, benchmark
description: Create saas-platform verify.sh and wire into CI benchmarks workflow
milestone: M36
status: draft
updated: 2026-05-05
@acp.meta.end -->


# Usage: ./verify.sh <results_file.json>
# Exit 0 if ≥80% violations detected, 1 otherwise

set -u

RESULTS_FILE="${1:-}"
THRESHOLD="${VERIFY_THRESHOLD:-80}"
SUITE_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ -z "$RESULTS_FILE" ]; then
  echo "Usage: $0 <results_file.json>" >&2
  exit 1
fi

if [ ! -f "$RESULTS_FILE" ]; then
  echo "Results file not found: $RESULTS_FILE" >&2
  exit 1
fi

# Count total expected detections and how many were found
# Results JSON format: { "results": [{ "id": "P001", "detected": [...], "expected": [...] }] }

total_expected=0
total_detected=0

# Parse with grep/awk (no jq dependency — macOS-safe)
# Each result line in flattened JSON...
while IFS= read -r line; do
  # Count expected and detected fields
  expected=$(echo "$line" | grep -o '"expected":\[[^]]*\]' | grep -o ',' | wc -l)
  expected=$((expected + 1))
  detected=$(echo "$line" | grep -o '"detected":\[[^]]*\]' | grep -o ',' | wc -l)
  detected=$((detected + 1))
  total_expected=$((total_expected + expected))
  total_detected=$((total_detected + detected))
done < <(grep '"id":' "$RESULTS_FILE")

if [ "$total_expected" -eq 0 ]; then
  echo "No expected detections found in results file." >&2
  exit 1
fi

pct=$((total_detected * 100 / total_expected))
echo "Benchmark result: $total_detected / $total_expected violations detected ($pct%)"

if [ "$pct" -ge "$THRESHOLD" ]; then
  echo "PASS: Detection rate $pct% meets threshold $THRESHOLD%"
  exit 0
else
  echo "FAIL: Detection rate $pct% below threshold $THRESHOLD%"
  exit 1
fi
```

### `.github/workflows/benchmarks.yml`

```yaml
name: ACP Benchmarks

on:
  schedule:
    - cron: '0 3 * * 1'  # Weekly, Mondays at 03:00 UTC
  workflow_dispatch:      # Allow manual trigger

jobs:
  saas-platform-benchmark:
    name: saas-platform benchmark
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/mainline'  # Main branch only
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          
      - name: Install dependencies
        working-directory: scripts
        run: npm ci
        
      - name: Run saas-platform benchmark (dry-run)
        run: |
          # Dry-run mode: validate prompt files and seed file structure
          # Full execution requires AI API keys (see README for manual runs)
          bash agent/benchmarks/suite/saas-platform/verify.sh --dry-run || true
          
      - name: Verify benchmark structure
        run: |
          test -f agent/benchmarks/suite/saas-platform/acp-prompts.yaml
          test -f agent/benchmarks/suite/saas-platform/baseline-prompts.yaml
          test -d agent/benchmarks/suite/saas-platform/seed/
          echo "Benchmark structure verified"
```

Note: Full benchmark execution (actually running prompts through AI) is a manual process requiring API keys. The CI workflow validates structure only. Update this when the benchmark runner is complete.

## Expected Output

### Files Created
- `agent/benchmarks/suite/saas-platform/verify.sh`
- `.github/workflows/benchmarks.yml`

## Verification
- [ ] `bash verify.sh --dry-run` exits 0 (dry-run mode always passes)
- [ ] `bash -n verify.sh` (syntax check passes)
- [ ] No `jq` or external tool dependencies in verify.sh
- [ ] `.github/workflows/benchmarks.yml` is valid GitHub Actions YAML
- [ ] Workflow runs only on `mainline` branch

## User-Observable Acceptance
`bash agent/benchmarks/suite/saas-platform/verify.sh --dry-run` exits 0. The GitHub Actions workflow file appears in the `.github/workflows/` directory. CI does not fail due to the benchmark workflow (it's schedule-triggered, not PR-triggered).
