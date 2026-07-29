# Audit Report: M85 Pre-Implementation Readiness

**Audit**: #112
**Date**: 2026-07-28
**Subject**: Pre-implementation readiness of M85 (Preference & YAML Parser Performance)
**Mode**: `--pre-impl`

## Summary

M85's plan is accurate — every measurement, line reference, and count in it verified against the code. Phase 2 cross-reference nonetheless found something the plan did not anticipate and which **changes the milestone's shape**: the YAML parser silently truncates any value containing a `|`, and the only function that escapes `|` is dead code.

This is not a performance issue. It is a **correctness bug in the parser that 19 files depend on**, including `acp.install.sh` and `acp.package-install.sh`. M85 was about to rewrite exactly the functions involved while asserting byte-identical output — which would have locked the bug in permanently.

**Verdict: READY, with three amendments required before task-299 starts.**

## Pre-Implementation Readiness (M85)

**Mode**: `--pre-impl`

### Phase 1 — Plan Correctness

| Check | Result | Notes |
|-------|--------|-------|
| Task files complete | ✅ | 8 tasks, all with objective/context/steps/verification/acceptance |
| `files_affected` accurate | ✅ | 12 paths: 8 exist, 4 correctly marked to-create |
| Dependency chain resolvable | ✅ | Linear DAG 297→298→299→300→301→302→303→304, one root, no cycles |
| Open blockers | ✅ None | |

### Phase 2 — Code Cross-Reference

| File | Checked | Result |
|------|---------|--------|
| `acp.yaml-parser.sh:78` | `get_node()` does `sed -n "$((node_id + 1))p"` | ✅ exact |
| `acp.yaml-parser.sh:84` | `get_field()` pipes to `cut -d'\|'` | ✅ exact |
| `acp.yaml-parser.sh` | 39 `cut`/`tr` pipe sites | ✅ exactly 39 |
| `acp.yaml-parser.sh:72` | `add_node()` escapes `\|` | ⚠️ **true but unreachable — see F-112-02** |
| `acp.yaml-parser.sh:444,484` | live AST writers | ❌ **no escaping at all — F-112-01** |
| `acp.preferences.sh:83` | `get_preference` 4-layer walk | ✅ |
| `acp.preferences.sh` | `_flat_dot_get` fallback exists | ✅ |
| `acp.review-scan.sh` | `node_scan_modules_available()` pattern to mirror | ✅ |
| `acp.gitleaks.sh` | `_ACP_GITLEAKS_PREF_CACHE` memoisation pattern | ✅ 5 refs |
| `acp.review-measure.sh` | `--ci` flag exists to extend | ✅ |
| `tests/acp.yaml-parser.test.sh` | 89 assertions | ✅ exactly 89 |
| `tests/yaml-array-operations.test.sh` | 11 assertions | ✅ exactly 11 |
| Parser consumers | 19 files | ✅ exactly 19 |
| PyYAML availability | absent (task-301 must not depend on it) | ✅ confirmed absent |
| `mapfile` availability | absent on bash 3.2 (task-298 must use `while read`) | ✅ confirmed absent |

### Phase 3 — Carryover Check

| Carryover | Severity | Status | Blocks? |
|-----------|----------|--------|---------|
| A-110-04 | high | pending | No — M85 task-302 closes it |
| A-110-05 | medium | pending | No — M85 is this carryover |
| A-110-07 | medium | pending | No — M85 task-304 closes it |

No carryovers outside M85's own scope. Nothing blocking.

### Phase 4 — Operational Completeness

| Check | Result | Notes |
|-------|--------|-------|
| Milestone doc exists | ✅ | `milestone-85-preference-yaml-performance.md` |
| progress.yaml entry + `file:` pointer | ✅ | M85, 8 tasks, pointer resolves |
| Version bump planned | ✅ | v6.30.1 declared |
| Perf gate planned | ✅ | task-303 |
| Carryover closure planned | ✅ | task-304 |
| M84 record gap | ✅ Resolved | Backfilled in `9b7b6a5` before this audit |

### Phase Summary

| Phase | Findings | Highest Severity |
|-------|----------|-----------------|
| Phase 1 — Plan Correctness | 0 | none |
| Phase 2 — Code Cross-Reference | 3 | **high** |
| Phase 3 — Carryover Check | 0 | none |
| Phase 4 — Operational Completeness | 0 | none |
| **Total** | **3** | **high** |

### Readiness Verdict

**READY — with three amendments.** The plan is sound and its numbers are real; the amendments exist because Phase 2 found a correctness defect inside the code M85 is about to rewrite.

## Findings

### F-112-01 — YAML values containing `|` are silently truncated (HIGH)

The live AST writers at `acp.yaml-parser.sh:444` and `:484` emit records as:

```bash
echo "${next_id}|${type}|${key}|${value}|${parent_id}|" >> "$AST_FILE"
```

with **no escaping of `|` inside `$value`**. `get_field()` then splits with `cut -d'|'`, so any embedded pipe shifts every subsequent field.

Reproduced:

```yaml
piped: "a|b|c"
```

| | Value |
|---|---|
| AST record | `2\|scalar\|piped\|"a\|b\|c"\|0\|` |
| `yaml_get` returns | `"a` |
| Expected | `a\|b\|c` |

19 files source this parser, including `acp.install.sh`, `acp.package-install.sh`, and `acp.package-publish.sh`. A manifest or preference value containing `|` is silently truncated — no error, no warning.

### F-112-02 — `add_node()` is dead code, and it is the only escaping path (MEDIUM)

`add_node()` (`:60-73`) does escape:

```bash
key=$(echo "$key"   | sed 's/|/\\|/g')
value=$(echo "$value" | sed 's/|/\\|/g')
```

It has **zero call sites** across `agent/scripts/`, `tests/`, and `e2e/`. The live paths are `:444` and `:484`, which do not escape.

M85's task-299 instructed the implementer to "confirm how `add_node` (`:72`) encodes it before assuming a naive split is safe". That points at the wrong function and would have produced a false sense of safety: reading `add_node` suggests escaping exists.

Note also that even if the escaping were reachable, `cut -d'|'` does not honour backslash escapes — so `\|` would still split. Fixing this requires changing the **writer and the reader together**.

### F-112-03 — "byte-identical output" conflicts with fixing F-112-01 (HIGH, plan conflict)

Task-300 requires the optimised parser to produce byte-identical output to the current one, and gates Phase 2 on it. That requirement is correct in spirit — 19 consumers — but as written it would **permanently enshrine F-112-01**, because fixing the truncation necessarily changes output for any value containing `|`.

Task-299 as written makes this worse: replacing `cut` with `${var%%|*}` reproduces the same truncation, so the bug would survive the rewrite silently and the equivalence test would confirm it as correct.

## Required Amendments

1. **New task (task-305)** — fix `|` handling in writer and reader together, before the equivalence gate. Escape on write at `:444`/`:484`, honour the escape on read, and either delete dead `add_node()` or make it the single writer.
2. **Amend task-300** — equivalence becomes "identical except for values containing `|`, which are covered by dedicated correctness assertions". Without this the gate contradicts task-305.
3. **Amend task-299** — retarget from `add_node` to the live writers `:444`/`:484`, and require the new splitter to honour escaping rather than assuming a naive split is safe.

## Recommendations

1. Sequence task-305 **before** task-299 so the encoding is settled before the splitter is rewritten. Rewriting the reader twice is wasted work.
2. Add a `|`-in-value case to the parser fixture in task-297 so the baseline captures the broken behaviour explicitly, making the fix visible as a diff rather than a claim.
3. Treat F-112-01 as shippable on its own if M85 slips — it is a data-corruption bug and does not depend on any performance work.

---

**Findings**: 3 (2 HIGH, 1 MEDIUM) · **Amendments required**: 3
**Verdict**: **READY** once the three amendments land.
