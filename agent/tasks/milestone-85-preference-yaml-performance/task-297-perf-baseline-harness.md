---
id: task-297
milestone: M85
title: "Performance baseline harness — capture the numbers before changing anything"
status: completed
priority: 5
complexity: low
estimated_hours: 2
created: 2026-07-28
started: 2026-07-30
completed: 2026-07-30
phase: 1
depends_on: []
audit_findings: [A-110-05, F-112-01]
files_affected:
  - tests/acp.yaml-parser-perf.sh
  - tests/fixtures/yaml-perf/pref-shape.yaml
---

## Objective

Create a reproducible benchmark that records the current cost of `yaml_parse`, `yaml_get`, and `get_preference`, so the milestone's improvements are measured rather than asserted.

## Context

audit-110 measured these ad hoc: `yaml_parse` 1.37s on 106 lines, one `get_preference` ~2.2s, `coderabbit_active()` 21.5s. Those numbers came from `/usr/bin/time -p` at a shell prompt and are not repeatable by anyone else.

The baseline must exist **before** the optimisation, otherwise the perf gate in task-303 gets tuned to whatever number the optimisation happens to produce — which is how a gate ends up asserting nothing.

## Steps

1. Create `tests/fixtures/yaml-perf/` with a committed fixture that mirrors the real shape of `agent/preferences/acp.default.yaml` (~106 lines, nested maps, arrays, quoted scalars). Do **not** point the benchmark at a live repo file that will drift.
   - **(audit-112)** Include at least one value containing a literal `|`. It is currently truncated (F-112-01), so the baseline records the broken behaviour and task-299's fix shows up as a visible diff rather than an unverifiable claim.
2. Write `tests/acp.yaml-parser-perf.sh` measuring, over N repetitions and reporting the median:
   - `yaml_parse` on the fixture
   - `yaml_get` for a deep key (cache cold)
   - `yaml_get` for a second key (cache warm, same shell)
   - a full `get_preference` walk
3. Use a portable millisecond clock — `date +%s%3N` is unavailable on BSD; reuse the `python3 -c 'import time...'` idiom already used elsewhere in this repo.
4. Print a table and record the observed values in the task's Verification section as the committed baseline.
5. Make the script exit 0 always at this stage — it is a measurement tool now; task-303 turns it into a gate.

## Recorded Baseline (2026-07-30, bash 3.2.57, idle Mac)

Medians of 5 runs against `tests/fixtures/yaml-perf/pref-shape.yaml` (95 lines):

| Measurement | Baseline |
|---|---|
| `yaml_parse` (full AST build) | **3384 ms** |
| `yaml_get` deep key (cache cold) | 3490 ms |
| `yaml_get` ×4 same shell (cache warm) | 3562 ms |
| `get_preference` (4 layers) | **1488 ms** |
| `get_preference_or` (wraps the above) | 1464 ms |

Two observations worth carrying into task-298/299:

1. **This fixture is slower than the 106-line `acp.default.yaml` (3384ms vs ~1369ms) despite being 95 lines.** It is more deeply nested, so it has more AST *nodes* — which is the fork-per-node cost showing up directly. Node count, not line count, is the driver.
2. **The in-shell cache works.** Four `yaml_get` calls in one shell (3562ms) cost barely more than one cold call (3490ms), i.e. one parse plus four cheap queries. The waste is re-parsing across `$( )` subshells (A-110-05), not within a shell.
3. `get_preference` and `get_preference_or` are within noise of each other (1488 vs 1464 ms), confirming audit-113 F2-03 — the wrapper cannot be faster than what it wraps.

**Correctness baseline (F-112-01):** `acp.pipe_value` is `"a|b|c"` in the fixture and `yaml_get` returns `"a` — truncated at the first pipe. task-299's fix will flip this line of the harness output to `→ FIXED`.

## Verification

- [x] Fixture committed under `tests/fixtures/yaml-perf/` and not gitignored (`git check-ignore` reports untracked-but-addable)
- [x] Benchmark runs on macOS bash 3.2.57 with no GNU-only flags (`date +%N` avoided; python3 ms clock reused from repo idiom)
- [x] Median of N runs reported (default `PERF_REPS=5`, overridable)
- [x] Baseline numbers recorded above
- [x] Script exits 0 and is **excluded** from the parallel suite — renamed off the `tests/*.test.sh` glob because it takes ~72s pre-optimisation, which would risk the 180s limit on slower runners and re-break the windows-latest E2E that audit-110 fixed
- [x] Fixture contains a `|` value so F-112-01 is captured in the baseline (audit-112/113)

## User-Observable Acceptance

`bash tests/acp.yaml-parser-perf.sh` prints a table of current parse and lookup timings that a reader can compare against the same command after the milestone.
