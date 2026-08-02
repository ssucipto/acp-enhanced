# Milestone 85: Preference & YAML Parser Performance

<!-- @acp.meta.milestone
topic: yaml-parser, preferences, performance, forks, ast, macos-flake, perf-gate
description: Remove the ~900-fork-per-parse cost in acp.yaml-parser.sh and the multi-second preference lookup that sits on top of it, then gate the improvement so it cannot silently regress
status: in_progress
updated: 2026-07-28
@acp.meta.end -->

**Planned version**: v6.30.1
**Status**: completed
**Progress**: 8/8 tasks — COMPLETE (2026-08-02)
**Estimated effort**: ~27h (8 tasks, 3 phases)
**Source**: audit-110 (root cause), audit-111 (readiness + retraction), audit-112 (pre-impl r1, 3 amendments), audit-113 (pre-impl r2, 4 amendments), maintainer directive 2026-07-28
**Depends on**: nothing — independent of M81's ADR-22 CodeRabbit fixture gate
**Closes**: A-110-04, A-110-05, A-110-07, F-112-01, F-112-02, F2-01, F2-02

---

## Why this milestone exists

audit-110 chased a `windows-latest` E2E timeout and found it was neither a Windows problem nor a hang. Every scanner invocation spent ~3 seconds resolving two preferences before checking whether the tools those preferences described were even installed. Reordering the guards gave an **~15× speedup** and turned Windows green for the first time.

That fix *sidestepped* the cost rather than removing it. The cost is still there for every other consumer:

| Measurement | Value |
|---|---|
| `yaml_parse` on a 106-line preference file | **1.37s** (~13ms/line) |
| Subprocess spawns for that one parse | **~1,428 traced; ~900 real forks** (`tr` 270, `cut` 264, `sed` 233) |
| One `get_preference` (walks up to 4 layers) | **~1.5s** (mean/5) |
| `get_preference` vs `get_preference_or` | 1521ms vs 1545ms — *identical; the latter wraps the former* |
| `coderabbit_active()` | **~1.44s** (one preference read; short-circuits when disabled) |
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
| **1 — Bash-native parser** | 297, 298, 299, 300 | `\|` encoding fixed, AST held in memory, fields split with parameter expansion, equivalence proven against the existing 100 assertions |
| **2 — Preference fast path** | 301, 302 | All layers resolved in one `python3` pass, with the pure-bash path retained as fallback |
| **3 — Gate and closure** | 303, 304 | Wall-clock budget in the corpus gate; A-110-04/05/07 verified closed |

Phase 2 must not start until Phase 1's equivalence task (300) passes. The parser is sourced by 19 files; a silent behaviour change there is far more expensive than the performance win.

## Amendments from audit-112 (pre-implementation)

Phase 2 code cross-reference found a correctness defect inside the very functions this milestone rewrites. Three amendments, all applied:

| # | Finding | Amendment |
|---|---------|-----------|
| 1 | **F-112-01** (HIGH) — the live AST writers (`:444`, `:484`) do not escape `\|`, so `piped: "a\|b\|c"` returns `"a`. 19 files source this parser. | Folded into **task-299**, which now changes writer encoding and reader in one atomic edit (see audit-113 F2-01 — the original separate task-305 was circular). |
| 2 | **F-112-02** (MEDIUM) — `add_node()` is the only function that escapes `\|`, and it has **zero call sites**. task-299 originally told the implementer to read it as the encoding authority. | task-299 retargeted to the live writers; dead `add_node()` resolved there too. |
| 3 | **F-112-03** (HIGH) — task-300's "byte-identical output" would have permanently enshrined F-112-01, since the correct new behaviour differs from the old truncated output. | task-300 now asserts equivalence **modulo the documented `\|` fix**, with every such divergence enumerated explicitly rather than silently tolerated. |

task-297's fixture must include a `\|`-containing value so the baseline captures the broken behaviour and the fix appears as a diff, not a claim.

> **F-112-01 is shippable independently.** It is a data-corruption bug and depends on no performance work. If M85 slips, it should not wait.

## Amendments from audit-113 (pre-implementation, round 2)

Round 2 audited round 1's own amendments. Five findings, all defects in round-1 output:

| # | Finding | Amendment |
|---|---------|-----------|
| 1 | **F2-01** (HIGH) — the new task-305 was **circular**: task-299 declared `depends_on: [task-305]` while task-305's steps required task-299's splitter. An implementer would have written the reader twice, the exact failure the split claimed to prevent. | task-305 **merged into task-299** as one atomic writer+reader change. Chain is linear again: 297 → 298 → 299 → 300 → 301 → 302 → 303 → 304. |
| 2 | **F2-02** (HIGH) — task-301 specified a uniform 4-file lookup and named `_pref_default_file`, which **does not exist**. The 4th layer is `_pref_configurables_file` and reads `${ns}.${path}` **`.default`** — a different key shape. | task-301 rewritten with the real four-layer table and an explicit instruction to read `get_preference()` rather than infer. |
| 3 | **F2-03** (HIGH) — several figures were single samples taken while E2E sweeps were running. `get_preference_or` "5.5s" was structurally impossible (it wraps `get_preference`); `coderabbit_active` "21.5s" was wrong by ~15×. | All figures in the table above re-measured as means over ≥5 runs and corrected. |
| 4 | **F2-04** (MEDIUM) — A-110-04 was filed HIGH on the false 21.5s baseline. | Downgraded to medium and restated as an instance of A-110-05; success criterion baseline corrected. |

**What survived scrutiny:** `yaml_parse` at 1369ms (mean/7 vs 1370ms recorded) and the ~900-fork count — the latter because a count cannot be skewed by machine load. These remain the milestone's justification.

> **Rule adopted:** any performance figure entering a planning document must be a mean over ≥5 runs on an otherwise idle machine, and the function must be read before its cost is recorded.

## Deliverables

- `agent/scripts/acp.yaml-parser.sh` — array-backed AST, fork-free field access
- `agent/scripts/acp.pref-resolve.py` — single-pass multi-layer preference resolver
- `agent/scripts/acp.preferences.sh` — wired to the fast path, pure-bash fallback intact
- `tests/acp.yaml-parser-perf.sh` — benchmark fixture and budget
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

- [x] `yaml_parse` on the 106-line preference file: **360ms** (from 1369ms, 3.8×) — *criterion amended, see below*
- [x] Single `get_preference`: **45ms** re-measured 2026-08-01 (target <100ms; was 854ms post-Phase-1) — Phase 2 resolver (task-301/302)
- [x] `coderabbit_active()`: **58ms** re-measured 2026-08-01 (target <200ms; was 646ms post-Phase-1)
- [x] `tests/acp.preferences-validate.test.sh`: **28s** (from 159s, limit unchanged at 180s)
- [x] All 100 existing parser assertions pass unchanged (`acp.yaml-parser.test.sh`, `yaml-array-operations.test.sh`)
- [x] Differential test: old and new parser produce identical output across every YAML file in the repo (task-300, golden-fixture design — see its Resolution note)
- [x] Corpus gate fails when a single-file scan exceeds its wall-clock budget (task-303, `--perf-budget-ms`)
- [x] macOS E2E green across **3 consecutive runs** — confirmed on all 3 platforms each time: commit `6559ae1`/run 30707045524, `def196d`/run 30707352192, `7e95a2d`/run 30707596784
- [x] A-110-04, A-110-05, A-110-07 stamped fixed with verifying audit — see `agent/memory/audit-carryovers.md`, verified_in_audit: "M85 task-304"
- [x] `piped: "a|b|c"` round-trips intact through `yaml_parse` → `yaml_get` (F-112-01) — verified by task-300's equivalence test (expected-divergence class)
- [x] Exactly one AST-writing code path, or all paths share one encoding helper (F-112-02) — closed by task-299 (duplicate `create_node` removed)

## Amendment: measured architectural floor (2026-07-31, post-Phase 1)

Phase 1 is complete and the numbers change what Phase 2 has to be. Re-measured, means of 5:

| Measurement | Baseline | Post-Phase-1 | Target |
|---|---|---|---|
| forks per parse (89-node fixture) | 1498 | **320** (79% fewer) | — |
| `yaml_parse` (89-node fixture) | 3384 ms | **966 ms** | — |
| `yaml_parse` (real 106-line pref file) | 1369 ms | **360 ms** (3.8×) | ~~<150ms~~ |
| `get_preference` | 1488 ms | **854 ms** | <100 ms |
| `get_preference_or` | 1464 ms | **759 ms** | <100 ms |
| `coderabbit_active()` | 1439 ms | **646 ms** | <200 ms |
| single-file review scan | 199 ms | **103 ms** | — |
| `preferences-validate` suite | 159 s | **28 s** | <60 s ✅ |

### Phase 2 final results (2026-08-01, task-301/302, means of 5)

| Measurement | Post-Phase-1 | Post-Phase-2 | Target |
|---|---|---|---|
| `get_preference` | 854 ms | **45 ms** (19×) | <100 ms ✅ |
| `coderabbit_active()` | 646 ms | **58 ms** (11×) | <200 ms ✅ |

Both land well inside their targets — the resolver (task-301, stdlib-only
Python, one process for all four layers) plus wiring it into `get_preference`
with a pure-bash fallback (task-302) fully closed the "stop parsing YAML in
bash on this path" gap the amendment above identified as the only route
under 100ms.

### The `< 150ms` criterion was not achievable and is amended

320 forks remain per parse: `wc -l` (89 — one per node, in `get_next_node_id`) and
`sed` (184 — mostly `-i` writes). Both need state that cannot cross the `$( )`
boundaries this parser is built on, which is the same constraint that killed the
array cache in task-298. `create_node` is invoked as `$(create_node …)` at every
call site, so any counter or cache it maintains is discarded on subshell exit.

**360ms is therefore close to the floor for this architecture, not a shortfall.**
Reaching 150ms in pure bash would require restructuring `yaml_parse` so its writers
are not called in command substitutions — a rewrite of the parse loop, well beyond a
performance milestone. Recorded here rather than left as a target that would be
quietly missed or gamed.

### Phase 2 is confirmed necessary

Before measuring, it was fair to ask whether Phase 1 had already made the resolver
unnecessary. It has not. `get_preference` is 854 ms, and 2 of the 4 layers exist
(`_pref_project_file` and `_pref_configurables_file`), so the cost is ~2 bash parses.
The only route to <100 ms is to stop parsing YAML in bash for this path — which is
exactly what task-301/302 do. **Phase 2 proceeds as planned, with corrected baselines.**

## References

- `agent/reports/audit-110-windows-timeout-root-cause.md` — root cause, measurements
- `agent/reports/audit-111-mainline-readiness.md` — A-110-06 retraction, flake evidence
- `agent/memory/audit-carryovers.md` — A-110-04, A-110-05, A-110-07
- `agent/scripts/acp.yaml-parser.sh:78,84` — the two structural causes
