---
id: task-299
milestone: M85
title: "Escape-aware fork-free field access — writer encoding and reader in one change"
status: not_started
priority: 5
complexity: medium
estimated_hours: 6
created: 2026-07-28
started: null
completed: null
phase: 1
depends_on: [task-298]
audit_findings: [A-110-05, F-112-01, F-112-02, F2-01]
files_affected:
  - agent/scripts/acp.yaml-parser.sh
  - tests/acp.yaml-parser.test.sh
---

## Objective

Remove the per-field fork **and** stop the parser truncating values that contain `|` — in one change, because both live in the same two lines of code.

## Context

> **Merged by audit-113 (F2-01).** This task previously covered only the fork removal, with the `|` encoding split into a separate task-305. That split was circular: task-299 declared `depends_on: [task-305]`, while task-305's own steps said the reader fix was "unblocked by task-299's parameter-expansion splitter". An implementer following the DAG would have had to write a throwaway escape-aware reader that this task then replaced — the exact double-write the split was meant to prevent. The encoding and the splitter are one edit to `get_field()` and the record format, so they are one task.

**The fork cost (A-110-05).** `get_field()` (`:84`) is `get_node "$node_id" | cut -d'|' -f"$field_num"`. With task-298 removing the per-node `sed`, `cut` is the remaining per-access fork. There are 39 `cut`/`tr` pipe sites; `:95-97` repeat the pattern inline.

**The correctness bug (F-112-01, HIGH).** The live AST writers at `:444` and `:484` emit
`${next_id}|${type}|${key}|${value}|${parent_id}|` with **no escaping**, so:

```yaml
piped: "a|b|c"
```

| | Value |
|---|---|
| AST record | `2\|scalar\|piped\|"a\|b\|c"\|0\|` |
| `yaml_get` returns | `"a` |

19 files source this parser, including `acp.install.sh`, `acp.package-install.sh`, and `acp.package-publish.sh`.

**F-112-02.** `add_node()` (`:60-73`) *does* escape `|` and has **zero call sites** — dead code, and the only escaping path in the file. Do not treat it as the encoding authority. Note `cut` would not honour `\|` anyway, which is why writer and reader must change together.

A naive `${var%%|*}` reproduces the truncation exactly and is **not** a valid implementation here.

## Steps

1. Choose one encoding and document it in the file header. Escaping `|` as `\|` is the obvious candidate — first confirm the reader can distinguish `\|` from a literal backslash followed by a delimiter.
2. Apply it at both live writers (`:444`, `:484`). They are duplicated; collapse them into one helper so a third writer cannot drift again.
3. Rewrite `get_field()` to split with parameter expansion **honouring that encoding** — no subprocess, no truncation.
4. Replace the inline `echo … | cut` sites (`:95-97` and the rest of the 39) with the single split helper.
5. Replace `tr` uses doing work that parameter expansion or `case` can do. Leave `awk`/`grep` doing genuine multi-line work alone.
6. Resolve dead `add_node()`: delete it, or make it the single writer the others call. Do not leave a third encoding opinion in the file.
7. Report any committed YAML in the repo whose parse changes as a result.

## Verification

- [ ] All 89 assertions in `tests/acp.yaml-parser.test.sh` pass
- [ ] All 11 assertions in `tests/yaml-array-operations.test.sh` pass
- [ ] `piped: "a|b|c"` round-trips through `yaml_parse` → `yaml_get` intact
- [ ] `|` in a **key** round-trips
- [ ] A value that is exactly `|` round-trips
- [ ] A literal backslash adjacent to a pipe is not mangled
- [ ] `yaml_set` of a `|`-containing value then `yaml_get` returns it intact
- [ ] Values with spaces, `:`, `#`, and UTF-8 round-trip
- [ ] `grep -cE "\| *(cut|tr) " agent/scripts/acp.yaml-parser.sh` drops substantially from 39
- [ ] Only one AST-writing path remains, or all paths share one encoding helper
- [ ] Benchmark shows `yaml_parse` at or below the 150ms criterion
- [ ] Any repo YAML whose parse changes is listed in this file

## User-Observable Acceptance

A preference or package-manifest value containing `|` — for example a description with `a | b` — survives `yaml_get` instead of being cut at the first pipe, and `yaml_parse` on the benchmark fixture drops from ~1.37s to under 150ms.
