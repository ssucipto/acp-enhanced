---
id: task-300
milestone: M85
title: "Parser equivalence — prove output is byte-identical before Phase 2"
status: completed
priority: 5
complexity: medium
estimated_hours: 3
created: 2026-07-28
started: 2026-08-01
completed: 2026-08-01
phase: 1
depends_on: [task-299]
audit_findings: [A-110-05, F-112-03, F2-01]
files_affected:
  - tests/acp.yaml-parser-equivalence.test.sh
---

## Objective

Prove the optimised parser produces identical output to the pre-milestone parser across every YAML file in the repository — **except for values containing `|`, which task-299 deliberately fixes** — before any other subsystem is touched.

> **Amended by audit-112 (F-112-03).** As originally written, "byte-identical output" would have permanently enshrined the F-112-01 truncation bug: the pre-milestone parser returns `"a` for `"a|b|c"`, so an unqualified equivalence gate would have marked the *correct* new behaviour as a regression. Equivalence is therefore asserted **modulo the documented `|` fix**, which gets its own positive assertions instead.

## Context

19 files source `acp.yaml-parser.sh`, including `acp.install.sh`, `acp.package-install.sh`, and `acp.package-publish.sh`. A silent behaviour change there is far more expensive than the performance win — a mis-parsed manifest during install is the kind of failure that surfaces in someone else's repo, weeks later.

The 100 existing assertions are a good net but they test the parser's *intended* behaviour, not its *actual current* behaviour on real-world files. Equivalence testing catches the difference.

## Steps

1. Extract the pre-milestone parser from git (`git show <pre-M85-sha>:agent/scripts/acp.yaml-parser.sh`) into a temp path as the reference implementation.
2. Enumerate every `.yaml`/`.yml` file tracked in the repo, plus `agent/preferences/*.yaml` and `tests/fixtures/**`.
3. For each file, run both implementations over an identical query set (all leaf keys, several nested paths, array indices) and diff the output.
4. Diff `yaml_parse` AST files byte-for-byte where the format is expected to be unchanged.
5. Report any divergence as a hard failure with the file, key, and both outputs — **except** where the value contains `|`, which must be asserted against the *corrected* expectation from task-299, never against the old truncated output.
6. Enumerate every divergence attributable to the `|` fix explicitly in the test output, so "expected difference" is never a silent category.
7. Keep this as a committed regression test, not a one-off script — the next parser change deserves the same net.

## Verification

- [ ] Every tracked YAML file parsed by both implementations with zero divergence, except values containing `|`
- [ ] Every `|`-attributable divergence listed explicitly and matched against the corrected expectation
- [ ] Query set covers leaf scalars, nested maps, arrays, quoted strings with `:` and `#`, empty values, and comments
- [ ] Divergences (if any) are reported with file + key + both outputs, not just a count
- [ ] Test is committed and runs in CI
- [ ] **Phase 2 does not start until this passes**

## User-Observable Acceptance

`bash tests/acp.yaml-parser-equivalence.test.sh` reports zero divergences across every YAML file in the repo.

## Resolution (2026-08-01)

Implemented as a **golden-fixture** regression test rather than re-deriving the
pre-M85 parser from git history on every run: `add_child` rewrites the whole
growing AST_FILE with `sed -i` on every child append, in both parsers,
unaffected by M85's field-access optimisation — that alone makes parsing
`agent/progress.yaml` (9,480 lines) take ~100s, and dumping the AST of every
tracked file with the pre-M85 parser did not finish in 5 minutes. Re-running
the pre-M85 parser every CI invocation was not viable inside the 180s budget.

Instead, `tests/fixtures/yaml-parser-equivalence/pre-m85-ast.golden.tsv` captures
the pre-M85 parser's AST output for all 74 tracked YAML files, generated once.
`tests/acp.yaml-parser-equivalence.test.sh` sources only the current parser and
diffs its live output against that fixture — 73 files, ~79s, zero unexpected
divergences. `agent/progress.yaml` (the one file >= 2000 lines) is covered by
the companion `tests/acp.yaml-parser-equivalence-large.sh` (not `*.test.sh`,
same convention as `acp.yaml-parser-perf.sh`) — ~97s, zero unexpected
divergences.

Every divergence found (56 total across both scripts) was individually
verified attributable to the F-112-01 `|` fix, including an edge case not
anticipated in the task's original design: several `agent/index/*.yaml`
files use `description: |` (YAML block-scalar syntax), which this parser
doesn't specially support — it just stores the literal value `|`. The old
`cut -d'|' -f4` implementation misaligned onto the adjacent parent-id field
for those; the new parser correctly returns `|`. Same fix, wider blast
radius than the original truncation-of-a-string-value case.
