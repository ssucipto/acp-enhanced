---
id: task-298
milestone: M85
title: "Array-backed AST — stop re-reading the AST file per node"
status: completed
priority: 5
complexity: medium
estimated_hours: 4
created: 2026-07-28
started: 2026-07-30
completed: 2026-07-30
phase: 1
depends_on: [task-299]
audit_findings: [A-110-05, F2-07]
files_affected:
  - agent/scripts/acp.yaml-parser.sh
---

> **RE-SCOPED and CONDITIONAL (F2-07, maintainer decision 2026-07-30).** This task now runs *after* task-299 and is **no longer unconditional**. Fork attribution showed `cut` accounts for 703 of 1498 forks per parse (47%) and task-299 removes those safely; this task targets a subset of the 484 `sed` forks and carries a staleness hazard — all 7 `get_node` call sites read via `node=$(get_node X)`, a subshell that discards cache writes, and `create_node_and_link` mutates a *parent* node's children from inside a subshell (`:466`), which would leave a caller's cached entry stale. 10 AST mutation sites would need synchronising, on infrastructure with 19 dependents.
>
> **First action: re-measure after task-299 lands.** Then decide whether the remaining benefit justifies the risk. Abandoning this task with the measurements recorded is a valid, documented outcome — not a failure.


## Result (2026-07-30) — array cache REJECTED, fork removal delivered instead

Per the conditional scope, the first action was to re-measure after task-299. The
array cache did not justify its risk and was **not built**. That is the documented
outcome this task allowed, not a failure.

**Evidence.** The 327 sed forks remaining after task-299:

| Purpose | Forks | Targeted by the cache? |
|---|---|---|
| `sed 's/#.*$//'` comment strip (1/line) | 89 | no |
| `sed 's/,[^,]*$//'` stack pop | 46 | no |
| `sed -n Np` get_node reads | **19** | **yes** |
| `sed -i` writes | 12 | no |
| item prefix strip | 8 | no |

The cache would have removed **~19 of 635 forks (3%)** in exchange for synchronising
10 mutation sites, with 7 `get_node` call sites reading via `node=$(get_node X)` — a
subshell that discards cache writes — and `create_node_and_link` mutating a parent
node from inside a subshell. On a parser with 19 dependents that trade is bad.

**Delivered instead** — task-299's zero-risk technique on the larger targets:

| Metric | Baseline | After 299 | After 298 |
|---|---|---|---|
| forks / parse | 1498 | 635 | **320** (79% fewer) |
| `cut` | 703 | 0 | 0 |
| `grep` | 178 | 178 | **0** |
| `awk` | 46 | 46 | **0** |
| `sed` | 484 | 327 | **184** |
| `yaml_parse` | 3384 ms | 1704 ms | **966 ms** (3.5×) |

Byte-identical across 30 tracked YAML files at every step.

**Closes A-110-07 at the root:** `preferences-validate` 159s → **28s** against an
unchanged 180s limit.

Remaining forks are `wc -l` (89, one per node in `get_next_node_id`) and `sed`
(184, mostly `-i` writes). Both need state that cannot cross the `$( )` boundaries
this parser is built on — the same constraint that killed the cache.

## Objective

Hold the parsed AST in a bash array so node access costs no subprocesses, replacing the per-node `sed` read.

## Context

`get_node()` at `agent/scripts/acp.yaml-parser.sh:78` is:

```bash
sed -n "$((node_id + 1))p" "$AST_FILE"
```

One `sed` fork per node access. A tree walk is therefore O(nodes) forks. This is the larger half of the ~900 forks audit-110 counted for a single 106-line parse.

The AST file itself must stay — `yaml_set`/`yaml_delete` mutate it via `_yaml_sed_i` (`:109`), and `lessons.md` records a past incident where EXIT traps deleted `AST_FILE` from inside subshells and broke the parent's state. **Do not remove the file or add EXIT traps.** The array is a read cache over it.

## Steps

1. Add a module-level array (e.g. `_YAML_AST_NODES`) plus `_YAML_AST_LOADED` guard.
2. Populate it once at the end of `yaml_parse`, reading `$AST_FILE` with a single `while IFS= read -r` loop (bash 3.2 has no `mapfile`).
3. Rewrite `get_node()` to index the array; fall back to the `sed` read if the array is unpopulated, so any caller that builds the AST by another path still works.
4. Invalidate the array wherever `AST_FILE` is mutated — `add_node`, `yaml_set`, `yaml_delete`, and anything calling `_yaml_sed_i`. Prefer updating the array in place where the write is a single-line replacement.
5. Leave `_ast_valid()` and `YAML_CURRENT_FILE` semantics untouched.

## Verification

- [x] All 89 assertions in `tests/acp.yaml-parser.test.sh` pass unchanged
- [x] All 11 assertions in `tests/yaml-array-operations.test.sh` pass unchanged
- [x] `yaml_set` followed by `yaml_get` returns the written value (array invalidation works)
- [x] `yaml_delete` followed by `yaml_get` returns empty
- [x] No EXIT trap added; `AST_FILE` still removed only by the existing `cleanup_ast` path
- [x] Benchmark from task-297 shows a measurable drop in `yaml_parse`

## User-Observable Acceptance

`bash tests/acp.yaml-parser-perf.sh` shows a lower `yaml_parse` median than the task-297 baseline, and every existing parser test still passes.
