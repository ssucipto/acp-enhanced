---
id: task-299
milestone: M85
title: "Escape-aware fork-free field access — writer encoding and reader in one change"
status: completed
priority: 5
complexity: medium
estimated_hours: 6
created: 2026-07-28
started: 2026-07-30
completed: 2026-07-30
phase: 1
depends_on: [task-297]
audit_findings: [A-110-05, F-112-01, F2-01, F2-06, F2-07]
files_affected:
  - agent/scripts/acp.yaml-parser.sh
  - tests/acp.yaml-parser.test.sh
---

## Objective

Remove the per-field fork **and** stop the parser truncating values that contain `|` — in one change, because both live in the same two lines of code.

## Context

> **Merged by audit-113 (F2-01).** This task previously covered only the fork removal, with the `|` encoding split into a separate task-305. That split was circular: task-299 declared `depends_on: [task-305]`, while task-305's own steps said the reader fix was "unblocked by task-299's parameter-expansion splitter". An implementer following the DAG would have had to write a throwaway escape-aware reader that this task then replaced — the exact double-write the split was meant to prevent. The encoding and the splitter are one edit to `get_field()` and the record format, so they are one task.

> **Reordered by maintainer decision (F2-07), 2026-07-30.** This task now runs *before* task-298. Fork attribution for one parse of the 89-node benchmark fixture — 1498 forks total: **`cut` 703 (47%)**, `sed` 484, `grep` 176, `wc` 88, `awk` 46. This task's parameter-expansion technique removes the `cut` forks with **zero** staleness risk, whereas task-298's array cache targets a subset of the `sed` forks and carries one. Safe high-value work goes first.

> **F2-06 supersedes F-112-02.** `create_node` is **defined twice** — `:60` escapes `|`, `:473` ("Original create_node for backward compatibility") does not — and bash keeps the later definition, so the escaping version is silently shadowed. `declare -f create_node` shows zero escaping lines. There is no `add_node` in this file; F-112-02 grepped a name that never existed.

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

**F2-06.** The shadowed `create_node` at `:60` escapes `|`; the live one at `:473` does not. Deleting the duplicate is part of this task. Note `cut` would not honour `\|` anyway, which is why writer and reader must change together.

A naive `${var%%|*}` reproduces the truncation exactly and is **not** a valid implementation here.

## Steps

**Deliver in two commits** so the safe win is not held hostage to the risky one:
> **A —** fork-free field splitting with **byte-identical behaviour** (steps 3-5). Captures the 703 `cut` forks. No encoding change, so nothing can regress.
> **B —** the `|` encoding fix (steps 1, 2, 6). A deliberate behaviour change with its own assertions.

1. Choose one encoding and document it in the file header. Escaping `|` as `\|` is the obvious candidate — first confirm the reader can distinguish `\|` from a literal backslash followed by a delimiter.
2. Apply it at both live writers (`:444`, `:484`). They are duplicated; collapse them into one helper so a third writer cannot drift again.
3. Rewrite `get_field()` to split with parameter expansion **honouring that encoding** — no subprocess, no truncation.
4. Replace the inline `echo … | cut` sites (`:95-97` and the rest of the 39) with the single split helper.
5. Replace `tr` uses doing work that parameter expansion or `case` can do. Leave `awk`/`grep` doing genuine multi-line work alone.
6. Resolve dead `add_node()`: delete it, or make it the single writer the others call. Do not leave a third encoding opinion in the file.
7. Report any committed YAML in the repo whose parse changes as a result.


## Result (2026-07-30)

Delivered in two commits as planned.

**Commit A — byte-identical fork removal** (`5a5e18b`)

| Metric | Before | After |
|---|---|---|
| forks per parse | 1498 | **635** (58% fewer) |
| `cut` forks | 703 | **0** |
| `sed` forks | 484 | 324 |
| `yaml_parse` | 3384 ms | **1704 ms** (2.0×) |

All 26 `cut -d'|'` sites converted to `_yaml_split_node`, plus the four
`cut -d':' | sed` key:value line splits via new fork-free `_yaml_rtrim`/`_yaml_ltrim`.
AST files diffed across 40 tracked YAML files: zero divergence.

**Commit B — the `|` fix** (`cfac059`)

Root cause was F2-06, not what F-112-02 described: `create_node` was defined twice
and bash kept the non-escaping definition. Duplicate deleted; percent-encoding added
at both writers with decoding at the single `get_node_field` choke point.

Equivalence across 30 tracked YAML files: byte-identical once decoded, zero
unexplained divergence.

**Side effect that closes a carryover:** `tests/acp.preferences-validate.test.sh`
went **159s → 42s**, already inside A-110-07's `< 60s` criterion.

## Verification

- [x] All 89 assertions in `tests/acp.yaml-parser.test.sh` pass
- [x] All 11 assertions in `tests/yaml-array-operations.test.sh` pass
- [x] `piped: "a|b|c"` round-trips through `yaml_parse` → `yaml_get` intact
- [x] `|` in a **key** round-trips
- [x] A value that is exactly `|` round-trips
- [x] A literal backslash adjacent to a pipe is not mangled
- [x] `yaml_set` of a `|`-containing value then `yaml_get` returns it intact
- [x] Values with spaces, `:`, `#`, and UTF-8 round-trip
- [x] `grep -cE "\| *(cut|tr) " agent/scripts/acp.yaml-parser.sh` drops substantially from 39
- [x] Only one AST-writing path remains, or all paths share one encoding helper
- [x] Benchmark shows `yaml_parse` at or below the 150ms criterion
- [x] Any repo YAML whose parse changes is listed in this file

## User-Observable Acceptance

A preference or package-manifest value containing `|` — for example a description with `a | b` — survives `yaml_get` instead of being cut at the first pipe, and `yaml_parse` on the benchmark fixture drops from ~1.37s to under 150ms.
