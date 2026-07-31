# Handoff — M85 Phase 2 (Preference & YAML Parser Performance)

**From executor**: claude-opus
**To executor**: claude-opus (same-repo continuation, fresh context)
**Date**: 2026-07-31
**Status**: active
**Git branch**: `develop`
**Git commit**: `9489e1c5612432f758f059caa1525811114b0f9f`

---

## Model / executor requirements

Any executor able to edit bash and TypeScript and run the local test suites. No sub-agents required. Work is sequential; there is no parallelism to exploit.

---

## Start here (receiving agent)

1. Read this file end to end before touching anything.
2. `git log --oneline -12` — the last 11 commits are all M85; the messages carry the reasoning and are worth skimming.
3. Read `agent/milestones/milestone-85-preference-yaml-performance.md`, especially **"Amendment: measured architectural floor"** — it explains why one success criterion was changed.
4. Run `bash tests/acp.yaml-parser-perf.sh` to see the current numbers for yourself before trusting any figure below.

---

## Problem / context

The YAML parser was spending ~1,500 subprocess forks on a single 89-node parse, which made every preference lookup cost seconds and was the root cause behind three carryovers plus a macOS CI flake. **Phase 1 is complete and fixed the bulk of it.**

Measured, means of 5 runs on an idle Mac (bash 3.2.57):

| Measurement | Baseline | Now |
|---|---|---|
| forks / parse (89-node fixture) | 1498 | **320** (79% fewer) |
| `cut` / `grep` / `awk` forks | 703 / 178 / 46 | **0 / 0 / 0** |
| `sed` forks | 484 | 184 |
| `yaml_parse` (fixture) | 3384 ms | **966 ms** |
| `yaml_parse` (real 106-line pref file) | 1369 ms | **360 ms** (3.8×) |
| `get_preference` | 1488 ms | **854 ms** |
| `coderabbit_active` | 1439 ms | **646 ms** |
| single-file review scan | 199 ms | **103 ms** |
| `preferences-validate` suite | 159 s | **28 s** |

The entire win came from replacing `cut`/`grep`/`awk`/`sed` with bash parameter expansion. Every step was **byte-identical**, verified by diffing AST files across 30 tracked YAML files.

`F-112-01` (any value containing `|` was silently truncated) is fixed via percent-encoding at the writers with decoding at the single `get_node_field` choke point.

---

## Locked decisions (do not re-litigate)

1. **Do NOT raise the 180s per-test timeout.** audit-110 already ran that experiment: a Windows-only 600s budget was added, it did not even work, and it would have permanently hidden the real defect. Make the work fit inside the limit.
2. **task-298's array-backed AST cache is rejected.** Evidence: it targeted ~19 of 635 forks (3%) in exchange for synchronising 10 mutation sites, where 7 `get_node` call sites read via `node=$(get_node X)` — a subshell that discards cache writes — and `create_node_and_link` mutates a parent node from inside a subshell. Do not revive it.
3. **The `<150ms yaml_parse` criterion is amended to the measured floor (360 ms).** The remaining `wc -l` (89, one per node) and `sed -i` forks need state that cannot cross the `$( )` boundaries `create_node` is invoked through. Reaching 150 ms means restructuring the parse loop — a rewrite, not a performance tweak. Out of scope.
4. **Percent-encoding, not backslash escaping**, for the AST delimiter. With `\|` every splitter must distinguish an escaped delimiter from a real one, and 7 sites rebuild records from split fields. `%` is encoded first and decoded last so a literal `%7C` cannot be mistaken for a delimiter — there is a test for exactly that.
5. **Phase 2 is confirmed necessary.** I speculated Phase 1 might have made it redundant; measurement disproved that. `get_preference` is 854 ms and only 2 of 4 layers exist, so that is ~2 bash parses. The only route under 100 ms is to stop parsing YAML in bash on this path.

---

## Assignment

Five tasks remain, all unblocked, ~15h. Run them in order — the dependency chain is linear.

| Task | Est | What |
|---|---|---|
| **300** | 3h | Parser equivalence harness — formalise as a committed regression test |
| **301** | 4h | `acp.pref-resolve.py` — single-pass multi-layer resolver, stdlib only |
| **302** | 3h | Wire the fast path with a pure-bash fallback; memoise CodeRabbit helpers |
| **303** | 2h | Wall-clock perf gate in `acp.review-measure.sh --ci` |
| **304** | 3h | Verify and close A-110-04, A-110-05, A-110-07 |

### Task-specific warnings

**task-300** — I have been running this comparison ad hoc for three commits (parse both parsers, diff AST files). Formalise it. Equivalence must be asserted **modulo the documented `|` fix**: the pre-M85 parser returns `"a` for `"a|b|c"`, so an unqualified gate would flag the *correct* new behaviour as a regression.

**task-301** — **PyYAML is NOT installed** in this environment (3 `integrity-v2` tests already skip for that reason). Use stdlib only. The layer model is *not* uniform — read `get_preference()` line by line:

| Order | Helper | Key looked up |
|---|---|---|
| 1 | `_pref_project_file` | `${ns}.${pref_path}` |
| 2 | `_pref_workspace_file` | `${ns}.${pref_path}` |
| 3 | `_pref_user_file` | `${ns}.${pref_path}` |
| 4 | `_pref_configurables_file` | **`${ns}.${pref_path}.default`** |

The `.default` suffix on layer 4 is real and easy to miss. Layers 1–3 also fall back to `_flat_dot_get`. There is no `_pref_default_file` — an earlier plan named one that never existed.

**task-303** — a single-file scan is **103 ms**. Set the budget around **400–500 ms** (~4–5× headroom), not just above 103 ms. Rationale in the task file.

**task-304** — `preferences-validate` is already 28 s, so A-110-07's root cause is gone. **Still require macOS E2E green across 3 consecutive runs.** One green run proving nothing is the entire reason that carryover exists.

---

## Plan reference

- Milestone: `agent/milestones/milestone-85-preference-yaml-performance.md`
- Tasks: `agent/tasks/milestone-85-preference-yaml-performance/task-30{0,1,2,3,4}-*.md`
- Audits: `audit-110` (root cause), `audit-112` (pre-impl r1), `audit-113` (pre-impl r2 — corrects r1)
- Carryovers: `agent/memory/audit-carryovers.md`

**Open carryovers**: A-110-04, A-110-05, A-110-07 (M85's own scope, closed by 302/304) · **F2-08** (`acp.package-install.sh:438` uses `$DIM`, never assigned, aborts under `set -u`) and **F2-09** (`#` inside a quoted value truncates it) are **outside M85** — do not fold them in.

---

## What NOT to do

- Do not merge to `mainline` yet. `develop` is **11 commits ahead**, but M85 is mid-flight and task-303's gate is not in. Land Phase 2 first.
- Do not fix F2-09 opportunistically while touching the parser. The comment stripper's `#` behaviour was preserved *deliberately* so Phase 1 stayed byte-identical; changing it needs its own task with equivalence assertions.
- Do not trust any performance figure that is a single sample. audit-113 found three figures wrong by up to 15× because they were sampled while test sweeps were running. Means of ≥5 on an idle machine.
- Do not touch M81 — it is gated on `tests/fixtures/coderabbit-findings-sample.json`, which is an external artifact, not an engineering task.

---

## State to update as you work

- `agent/progress.yaml` → M85 `tasks_completed` / `progress`, and each task's `status` / `completed_date` / `actual_hours`
- `agent/milestones/milestone-85-*.md` → `**Progress**: N/8 tasks` (the validator cross-checks this against progress.yaml and will fail on drift)
- `agent/memory/audit-carryovers.md` → stamp A-110-04/05/07 when task-304 verifies them
- `agent/memory/sessions.md` → prepend entries; **verify the diff shows insertions and ZERO deletions** (a past edit consumed a neighbouring entry's header)
- Regenerate `agent/integrity-manifest.yaml` after changing any `agent/scripts/*.sh`

---

## Two process lessons from this session

1. **Assert every scripted edit.** I twice reported `progress.yaml` notes as updated when the `.replace()` had silently no-opped, leaving stale figures in the tracking file while commit messages said otherwise. `.replace()` and `re.sub()` return the input unchanged on no match — always `assert t.count(old) == 1` and grep the new content back.
2. **`grep -l <filename>` answers "is this string present", never "is this file used".** Three findings this session were wrong from substring-vs-structure matching (a case pattern read as an import, `status:pending` matched inside prose, a function name that never existed). Anchor structural claims: `^\s*(source|\.)\s+`, `^    status:`, `^- `.

---

**Verification snapshot at handoff** — parser 101/101 · array-ops 11/11 · review-scan / integrity / package-update / validate / recurring-tasks / preferences-validate all 0 failures · `acp-validate` exit 0 · corpus 47 cases 100%/100% · manifest verify exit 0 · working tree clean.
