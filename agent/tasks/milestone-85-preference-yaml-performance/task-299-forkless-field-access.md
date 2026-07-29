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
depends_on: [task-298, task-305]
audit_findings: [A-110-05, F-112-01, F-112-02]
files_affected:
  - agent/scripts/acp.yaml-parser.sh
---

## Objective

Remove the second fork per field read by splitting the pipe-delimited AST records with bash parameter expansion instead of `cut`/`tr`.

## Context

`get_field()` at `:84` is `get_node "$node_id" | cut -d'|' -f"$field_num"`. With task-298 removing the `sed`, `cut` becomes the remaining per-access fork. There are **39** `cut`/`tr` pipe sites in the file; `:95-97` show the pattern repeated inline (`id=$(echo "$node" | cut -d'|' -f1)` …).

AST records are `id|type|key|value|parent_id|`. Fields are positional and the delimiter is fixed, so `${var%%|*}` / `${var#*|}` splits them without a subprocess.

## Steps

1. Rewrite `get_field()` to split with parameter expansion, **honouring the escaping established in task-305**. A naive `${var%%|*}` reproduces the F-112-01 truncation exactly, so it is not a valid implementation here.
   > **Amended by audit-112.** The original step said to check how `add_node` (`:72`) encodes values. That was wrong: `add_node` is dead code (F-112-02) and the live writers at `:444`/`:484` do no escaping at all (F-112-01). task-305 settles the encoding first; this task consumes it.
2. Replace the inline `echo … | cut` sites (`:95-97` and the rest of the 39) with a single split helper.
3. Replace `tr` uses where they are doing character deletion/translation that parameter expansion or `case` can do.
4. Leave any `awk`/`grep` doing genuine multi-line work alone — this task is about per-field forks, not a rewrite of the query engine.

## Verification

- [ ] All 89 + 11 existing parser assertions pass unchanged
- [ ] A value containing a literal `|` round-trips correctly (encoding from task-305 honoured, not bypassed)
- [ ] A value containing spaces, `:`, `#`, and UTF-8 round-trips correctly
- [ ] `grep -cE "\| *(cut|tr) " agent/scripts/acp.yaml-parser.sh` drops substantially from 39
- [ ] Benchmark shows `yaml_parse` at or below the 150ms success criterion

## User-Observable Acceptance

`bash tests/acp.yaml-parser-perf.test.sh` reports `yaml_parse` under 150ms on the committed fixture, down from ~1.37s.
