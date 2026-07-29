---
id: task-297
milestone: M85
title: "Performance baseline harness — capture the numbers before changing anything"
status: not_started
priority: 5
complexity: low
estimated_hours: 2
created: 2026-07-28
started: null
completed: null
phase: 1
depends_on: []
audit_findings: [A-110-05]
files_affected:
  - tests/acp.yaml-parser-perf.test.sh
  - tests/fixtures/yaml-perf/
---

## Objective

Create a reproducible benchmark that records the current cost of `yaml_parse`, `yaml_get`, and `get_preference`, so the milestone's improvements are measured rather than asserted.

## Context

audit-110 measured these ad hoc: `yaml_parse` 1.37s on 106 lines, one `get_preference` ~2.2s, `coderabbit_active()` 21.5s. Those numbers came from `/usr/bin/time -p` at a shell prompt and are not repeatable by anyone else.

The baseline must exist **before** the optimisation, otherwise the perf gate in task-303 gets tuned to whatever number the optimisation happens to produce — which is how a gate ends up asserting nothing.

## Steps

1. Create `tests/fixtures/yaml-perf/` with a committed fixture that mirrors the real shape of `agent/preferences/acp.default.yaml` (~106 lines, nested maps, arrays, quoted scalars). Do **not** point the benchmark at a live repo file that will drift.
2. Write `tests/acp.yaml-parser-perf.test.sh` measuring, over N repetitions and reporting the median:
   - `yaml_parse` on the fixture
   - `yaml_get` for a deep key (cache cold)
   - `yaml_get` for a second key (cache warm, same shell)
   - a full `get_preference` walk
3. Use a portable millisecond clock — `date +%s%3N` is unavailable on BSD; reuse the `python3 -c 'import time...'` idiom already used elsewhere in this repo.
4. Print a table and record the observed values in the task's Verification section as the committed baseline.
5. Make the script exit 0 always at this stage — it is a measurement tool now; task-303 turns it into a gate.

## Verification

- [ ] Fixture committed under `tests/fixtures/yaml-perf/` and not gitignored (check `git check-ignore`)
- [ ] Benchmark runs on macOS (bash 3.2) and Linux without GNU-only flags
- [ ] Median of N runs reported, not a single sample
- [ ] Baseline numbers recorded in this task file
- [ ] Script exits 0 and is excluded from the timeout-sensitive parallel suite, or completes well under 180s

## User-Observable Acceptance

`bash tests/acp.yaml-parser-perf.test.sh` prints a table of current parse and lookup timings that a reader can compare against the same command after the milestone.
