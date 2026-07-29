---
id: task-299
milestone: M85
title: "Fork-free field access — replace cut/tr pipes with parameter expansion"
status: not_started
priority: 5
complexity: medium
estimated_hours: 4
created: 2026-07-28
started: null
completed: null
phase: 1
depends_on: [task-298]
audit_findings: [A-110-05]
files_affected:
  - agent/scripts/acp.yaml-parser.sh
---

## Objective

Remove the second fork per field read by splitting the pipe-delimited AST records with bash parameter expansion instead of `cut`/`tr`.

## Context

`get_field()` at `:84` is `get_node "$node_id" | cut -d'|' -f"$field_num"`. With task-298 removing the `sed`, `cut` becomes the remaining per-access fork. There are **39** `cut`/`tr` pipe sites in the file; `:95-97` show the pattern repeated inline (`id=$(echo "$node" | cut -d'|' -f1)` …).

AST records are `id|type|key|value|parent_id|`. Fields are positional and the delimiter is fixed, so `${var%%|*}` / `${var#*|}` splits them without a subprocess.

## Steps

1. Rewrite `get_field()` to split with parameter expansion. Handle the `value` field carefully — it is user data and may itself contain `|`; confirm how `add_node` (`:72`) encodes it before assuming a naive split is safe. If values are not escaped, that is a **pre-existing correctness bug** — record it as a finding and do not paper over it.
2. Replace the inline `echo … | cut` sites (`:95-97` and the rest of the 39) with a single split helper.
3. Replace `tr` uses where they are doing character deletion/translation that parameter expansion or `case` can do.
4. Leave any `awk`/`grep` doing genuine multi-line work alone — this task is about per-field forks, not a rewrite of the query engine.

## Verification

- [ ] All 89 + 11 existing parser assertions pass unchanged
- [ ] A value containing a literal `|` round-trips correctly through `yaml_set` → `yaml_get`, or the encoding gap is filed as a finding
- [ ] A value containing spaces, `:`, `#`, and UTF-8 round-trips correctly
- [ ] `grep -cE "\| *(cut|tr) " agent/scripts/acp.yaml-parser.sh` drops substantially from 39
- [ ] Benchmark shows `yaml_parse` at or below the 150ms success criterion

## User-Observable Acceptance

`bash tests/acp.yaml-parser-perf.test.sh` reports `yaml_parse` under 150ms on the committed fixture, down from ~1.37s.
