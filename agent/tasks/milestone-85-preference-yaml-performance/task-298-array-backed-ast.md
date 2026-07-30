---
id: task-298
milestone: M85
title: "Array-backed AST — stop re-reading the AST file per node"
status: not_started
priority: 5
complexity: medium
estimated_hours: 4
created: 2026-07-28
started: null
completed: null
phase: 1
depends_on: [task-297]
audit_findings: [A-110-05]
files_affected:
  - agent/scripts/acp.yaml-parser.sh
---

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

- [ ] All 89 assertions in `tests/acp.yaml-parser.test.sh` pass unchanged
- [ ] All 11 assertions in `tests/yaml-array-operations.test.sh` pass unchanged
- [ ] `yaml_set` followed by `yaml_get` returns the written value (array invalidation works)
- [ ] `yaml_delete` followed by `yaml_get` returns empty
- [ ] No EXIT trap added; `AST_FILE` still removed only by the existing `cleanup_ast` path
- [ ] Benchmark from task-297 shows a measurable drop in `yaml_parse`

## User-Observable Acceptance

`bash tests/acp.yaml-parser-perf.sh` shows a lower `yaml_parse` median than the task-297 baseline, and every existing parser test still passes.
