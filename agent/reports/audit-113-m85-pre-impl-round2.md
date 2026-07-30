# Audit Report: M85 Pre-Implementation — Round 2 (auditing the amendments)

**Audit**: #113
**Date**: 2026-07-30
**Subject**: Second pre-implementation pass on M85, targeting the audit-112 amendments themselves
**Mode**: `--pre-impl`

## Summary

Round 1 (audit-112) verified the plan's numbers and found a real bug (F-112-01). Round 2 audits **the amendments audit-112 produced** — per this repo's v1→v2 discipline, where the second pass historically catches what the first could not see because the first pass wrote it.

It found five findings, three of them HIGH, and **all five are defects in my own round-1 work**:

1. The amendment introduced a **circular dependency** — the precise failure it claimed to prevent.
2. The new resolver task specifies a **layer model that does not exist**.
3. Several recorded measurements were **single samples taken under load** and are wrong by up to 15×, now propagated into the milestone doc, a carryover, and two audit reports as facts.

The core defect M85 exists to fix is unaffected: `yaml_parse` re-measured at **1369ms mean over 7 runs** against 1370ms recorded, and the ~900-fork count is a count, not a timing, so load cannot skew it.

## Pre-Implementation Readiness (M85, round 2)

**Mode**: `--pre-impl`

### Phase 1 — Plan Correctness

| Check | Result | Notes |
|-------|--------|-------|
| Task files complete | ✅ | 9 tasks |
| `files_affected` accurate | ✅ | unchanged from round 1 |
| Dependency chain resolvable | ❌ | **F2-01 — declared DAG is acyclic, but task-305's steps require task-299, which depends on task-305** |
| Open blockers | ❌ | F2-01 must be resolved before implementation |

### Phase 2 — Code Cross-Reference

| File | Checked | Result |
|------|---------|--------|
| `acp.preferences.sh` | `_pref_project_file` / `_pref_workspace_file` / `_pref_user_file` exist | ✅ |
| `acp.preferences.sh` | `_pref_default_file` (named in task-301) | ❌ **does not exist — F2-02** |
| `acp.preferences.sh:125+` | 4th layer is `_pref_configurables_file`, read as `${ns}.${path}.default` | ❌ **different key shape — F2-02** |
| `acp.preferences.sh:153` | `get_preference_or` is a thin wrapper calling `get_preference` | ❌ **cannot be faster — F2-03** |
| `acp.coderabbit.sh:62` | `coderabbit_active` short-circuits when disabled → 1 preference call | ❌ **not 2 — F2-03** |
| `acp.review-measure.sh:26+` | `--ci` / `--min-recall` `case` block extensible for a budget flag | ✅ |
| `acp.yaml-parser.sh` | `yaml_parse` 1.37s | ✅ re-confirmed, 1369ms mean / 7 runs |

### Phase 3 — Carryover Check

| Carryover | Severity | Status | Blocks? |
|-----------|----------|--------|---------|
| A-110-04 | high → **medium** | pending | No — but **severity and baseline are wrong (F2-04)** |
| A-110-05 | medium | pending | No — M85 is this carryover |
| A-110-07 | medium | pending | No — task-304 closes it |

### Phase 4 — Operational Completeness

| Check | Result |
|-------|--------|
| Milestone doc, progress.yaml entry, `file:` pointer | ✅ |
| Version bump, perf gate, carryover closure planned | ✅ |
| Success criteria measurable | ❌ **two criteria carry false baselines (F2-04)** |

### Phase Summary

| Phase | Findings | Highest Severity |
|-------|----------|-----------------|
| Phase 1 — Plan Correctness | 1 | **high** |
| Phase 2 — Code Cross-Reference | 2 | **high** |
| Phase 3 — Carryover Check | 1 | medium |
| Phase 4 — Operational Completeness | 1 | low |
| **Total** | **5** | **high** |

### Readiness Verdict

**BLOCKED** on F2-01 and F2-02. Both are amendable in place; neither changes the milestone's purpose.

## Findings

### F2-01 — The amendment introduced a circular dependency (HIGH)

`task-299` declares `depends_on: [task-298, task-305]`. But `task-305` step 3 reads:

> "Make the reader honour the encoding. `cut` cannot; this is **unblocked by task-299's parameter-expansion splitter**, so coordinate the two."

So 305 needs 299's splitter, and 299 waits for 305. An implementer following the DAG starts 305, reaches step 3, and finds the capability does not exist yet. The only ways out are to write a throwaway escape-aware reader that 299 immediately replaces — **writing the reader twice, which is exactly what audit-112 claimed the sequencing prevented** — or to deadlock.

Root cause: splitting an atomic change across two tasks. The encoding and the splitter both live in `get_field()` and the AST record format; they are one edit.

### F2-02 — task-301 specifies a preference layer model that does not exist (HIGH)

task-301 instructs the implementer to pass "the layer file paths in precedence order" and audit-110/112 both describe a uniform 4-layer walk. Reality:

- `_pref_default_file` — **does not exist**. There is no such helper.
- The 4th layer is `_pref_configurables_file`, and it is read with a **different key shape**:

```bash
value="$(yaml_get "$configurables_file" "${namespace}.${pref_path}.default" ...)"
```

Note the `.default` suffix. A resolver that treats all four files uniformly returns empty where the bash implementation returns a value — a silent behaviour change in the exact subsystem task-302 then wires into every preference read.

### F2-03 — Noise-derived measurements recorded as facts (HIGH)

Several figures were single samples taken while full E2E sweeps were running. Re-measured with repetition:

| Claim (as recorded) | Re-measured | Verdict |
|---|---|---|
| `get_preference` strict **13.8s** | 1521ms (mean/5) | **wrong** |
| `get_preference_or` **5.5s** | 1545ms (mean/5) | **wrong** |
| `coderabbit_active` **21.5s** = 13.8 + 5.5 | **1439ms** (mean/5) | **wrong by ~15×** |
| one `get_preference` ~2.2s | ~1.5s | overstated |
| scan speedup **18×** | 2950→199ms ≈ **15×** | overstated |
| `yaml_parse` **1.37s** | **1369ms** (mean/7) | ✅ accurate |
| ~900 forks per parse | count, not timing | ✅ unaffected by load |

The `get_preference_or` figure was structurally impossible: it is a five-line wrapper that *calls* `get_preference`, so it cannot be faster. That should have been caught by reading the function before recording the number.

The `21.5s` decomposition was invented by the noise — `coderabbit_active` short-circuits on `[[ "$(_coderabbit_enabled)" == "true" ]] &&` and, with CodeRabbit disabled by default, makes **one** preference call, never reaching `coderabbit_available`.

These figures are currently stated as fact in `milestone-85-*.md`, the A-110-05 carryover, `audit-110-*.md`, and `audit-112-*.md`.

### F2-04 — A-110-04's severity and success criterion rest on the false baseline (MEDIUM)

A-110-04 is filed HIGH on the basis of "coderabbit_active() costs 21.5s". At 1.44s it is not a distinct finding at all — it is **one instance of A-110-05** (any single preference read costs ~1.5s). The M85 success criterion "coderabbit_active(): < 200ms (from 21.5s)" cites a baseline that never existed.

### F2-05 — Minor overstatements (LOW)

"one `get_preference` ~2.2s" (actual ~1.5s) and "18×" (actual ~15×). Small, but they are in the same documents as the correct figures, and a reader cannot tell which numbers were verified.

## Required Amendments

1. **Merge task-305 into task-299** as one atomic task covering writer encoding + escape-aware fork-free reader. Removes the circular dependency and restores a linear chain `297 → 298 → 299 → 300 → …`.
2. **Rewrite task-301's layer model** to the real four layers, including `_pref_configurables_file` and its `${ns}.${path}.default` key shape, with an explicit instruction to read `get_preference` rather than infer.
3. **Correct every propagated figure** in the milestone doc and the A-110-05 carryover; annotate audit-110 and audit-112 with a correction note rather than silently editing history.
4. **Downgrade A-110-04** to medium, restate it as an instance of A-110-05, and fix the success criterion baseline.

## Recommendations

1. **Any performance figure entering a planning document must be a mean over ≥5 runs on an otherwise idle machine.** Every wrong number here came from a single sample taken during a test sweep.
2. **Read the function before recording its cost.** `get_preference_or` being slower-than-its-callee was disprovable from five lines of source.
3. Keep the ~900-fork count as the milestone's primary justification. It is load-independent and was the one figure that survived scrutiny unchanged.

---

**Findings**: 5 (3 HIGH, 1 MEDIUM, 1 LOW) — all in round-1's own output
**Verdict**: **BLOCKED** pending 4 amendments; M85's purpose and core justification stand.
