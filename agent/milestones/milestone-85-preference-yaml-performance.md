# Milestone 85: Preference & YAML Parser Performance

<!-- @acp.meta.milestone
topic: yaml-parser, preferences, performance, forks, ast, macos-flake, perf-gate
description: Remove the ~900-fork-per-parse cost in acp.yaml-parser.sh and the multi-second preference lookup that sits on top of it, then gate the improvement so it cannot silently regress
status: not_started
updated: 2026-07-28
@acp.meta.end -->

**Planned version**: v6.30.1
**Status**: not_started
**Progress**: 0/9 tasks
**Estimated effort**: ~28h (9 tasks, 3 phases)
**Source**: audit-110 (root cause), audit-111 (readiness + retraction), audit-112 (pre-impl, 3 amendments), maintainer directive 2026-07-28
**Depends on**: nothing — independent of M81's ADR-22 CodeRabbit fixture gate
**Closes**: A-110-04, A-110-05, A-110-07, F-112-01, F-112-02

---

## Why this milestone exists

audit-110 chased a `windows-latest` E2E timeout and found it was neither a Windows problem nor a hang. Every scanner invocation spent ~3 seconds resolving two preferences before checking whether the tools those preferences described were even installed. Reordering the guards gave an **18× speedup** and turned Windows green for the first time.

That fix *sidestepped* the cost rather than removing it. The cost is still there for every other consumer:

| Measurement | Value |
|---|---|
| `yaml_parse` on a 106-line preference file | **1.37s** (~13ms/line) |
| Subprocess spawns for that one parse | **~1,428 traced; ~900 real forks** (`tr` 270, `cut` 264, `sed` 233) |
| One `get_preference` (walks up to 4 layers) | **~2.2s** |
| `get_preference` strict vs `get_preference_or` | 13.8s vs 5.5s |
| `coderabbit_active()` | **21.5s** |
| `tests/acp.preferences-validate.test.sh` | **159s against a 180s limit** |

Two structural causes, both confirmed by reading the code:

1. **`get_node()` re-reads the AST from disk per node** — `sed -n "$((node_id + 1))p" "$AST_FILE"` (`acp.yaml-parser.sh:78`). One fork per node access.
2. **`get_field()` splits fields by piping to `cut`** — `get_node "$id" | cut -d'|' -f"$n"` (`:84`). A second fork per field. There are **39** `cut`/`tr` pipe sites in the file.

Reading one field of one node therefore costs two forks. The 19 files that source this parser all pay it.

## The macOS flake is a symptom, not a separate problem

`acp.preferences-validate.test.sh` runs 159s against a 180s per-test limit — a 12% margin. On identical code (`740db89`), the push run passed on all three platforms while the PR run failed on macOS. That is a borderline timeout tipping under runner load, and it is caused by the numbers above.

> **Binding rule for this milestone: do NOT raise the 180s timeout.**
>
> audit-110 already ran that experiment. A Windows-only 600s budget was added, it did not even work (the suite timed out at 600s too), and it would have permanently hidden the real defect. The timeout is the only signal; the fix is to make the work fit inside it.

## Goal

Make preference resolution and YAML parsing fast enough that they stop being a source of CI flakiness, without weakening any gate — and leave behind a guard that fails if the improvement ever regresses.

## Phases

| Phase | Tasks | Outcome |
|---|---|---|
| **1 — Bash-native parser** | 297, **305**, 298, 299, 300 | `\|` encoding fixed, AST held in memory, fields split with parameter expansion, equivalence proven against the existing 100 assertions |
| **2 — Preference fast path** | 301, 302 | All layers resolved in one `python3` pass, with the pure-bash path retained as fallback |
| **3 — Gate and closure** | 303, 304 | Wall-clock budget in the corpus gate; A-110-04/05/07 verified closed |

Phase 2 must not start until Phase 1's equivalence task (300) passes. The parser is sourced by 19 files; a silent behaviour change there is far more expensive than the performance win.

## Amendments from audit-112 (pre-implementation)

Phase 2 code cross-reference found a correctness defect inside the very functions this milestone rewrites. Three amendments, all applied:

| # | Finding | Amendment |
|---|---------|-----------|
| 1 | **F-112-01** (HIGH) — the live AST writers (`:444`, `:484`) do not escape `\|`, so `piped: "a\|b\|c"` returns `"a`. 19 files source this parser. | **New task-305** fixes writer and reader together, sequenced *before* task-299 so the encoding is settled before the splitter is rewritten. |
| 2 | **F-112-02** (MEDIUM) — `add_node()` is the only function that escapes `\|`, and it has **zero call sites**. task-299 originally told the implementer to read it as the encoding authority. | task-299 retargeted to the live writers; dead `add_node()` resolved in task-305. |
| 3 | **F-112-03** (HIGH) — task-300's "byte-identical output" would have permanently enshrined F-112-01, since the correct new behaviour differs from the old truncated output. | task-300 now asserts equivalence **modulo the documented `\|` fix**, with every such divergence enumerated explicitly rather than silently tolerated. |

task-297's fixture must include a `\|`-containing value so the baseline captures the broken behaviour and the fix appears as a diff, not a claim.

> **F-112-01 is shippable independently.** It is a data-corruption bug and depends on no performance work. If M85 slips, it should not wait.

## Deliverables

- `agent/scripts/acp.yaml-parser.sh` — array-backed AST, fork-free field access
- `agent/scripts/acp.pref-resolve.py` — single-pass multi-layer preference resolver
- `agent/scripts/acp.preferences.sh` — wired to the fast path, pure-bash fallback intact
- `tests/acp.yaml-parser-perf.test.sh` — benchmark fixture and budget
- `agent/scripts/acp.review-measure.sh` — wall-clock budget enforced under `--ci`
- Memoised CodeRabbit helpers (`acp.coderabbit.sh`)

## Explicit non-goals

- **Not** raising any test timeout (see binding rule).
- **Not** rewriting the YAML parser's *semantics* — this is a performance change; output must be byte-identical.
- **Not** replacing the bash parser with python3 wholesale. `identity.yml` sets `no_external_deps: pure bash preferred`; the python3 resolver is a preference-layer fast path with a bash fallback, not a replacement.
- **Not** touching M81's ADR-22 CodeRabbit gate.

## Shortcuts this milestone explicitly refuses

- Declaring victory on a wall-clock number without proving output equivalence (task 300 exists for this).
- Fixing the preference layer only, leaving the parser slow for its other 18 consumers — the user chose *both* deliberately.
- Marking A-110-07 closed because macOS happened to pass once. It already passes intermittently; closure requires repeated green runs.
- Adding the perf gate after the optimisation, tuned to whatever the new number happens to be. The baseline is captured **first** (task 297).

## Success criteria

- [ ] `yaml_parse` on the 106-line preference fixture: **< 150ms** (from 1.37s)
- [ ] Single `get_preference`: **< 100ms** (from ~2.2s)
- [ ] `coderabbit_active()`: **< 200ms** (from 21.5s)
- [ ] `tests/acp.preferences-validate.test.sh`: **< 60s** (from 159s, against an unchanged 180s limit)
- [ ] All 100 existing parser assertions pass unchanged
- [ ] Differential test: old and new parser produce identical output across every YAML file in the repo
- [ ] Corpus gate fails when a single-file scan exceeds its wall-clock budget
- [ ] macOS E2E green across **3 consecutive runs**
- [ ] A-110-04, A-110-05, A-110-07 stamped fixed with verifying audit
- [ ] `piped: "a|b|c"` round-trips intact through `yaml_parse` → `yaml_get` (F-112-01)
- [ ] Exactly one AST-writing code path, or all paths share one encoding helper (F-112-02)

## References

- `agent/reports/audit-110-windows-timeout-root-cause.md` — root cause, measurements
- `agent/reports/audit-111-mainline-readiness.md` — A-110-06 retraction, flake evidence
- `agent/memory/audit-carryovers.md` — A-110-04, A-110-05, A-110-07
- `agent/scripts/acp.yaml-parser.sh:78,84` — the two structural causes
