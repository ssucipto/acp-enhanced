---
id: task-301
milestone: M85
title: "Single-pass preference resolver (acp.pref-resolve.py)"
status: completed
priority: 5
complexity: medium
estimated_hours: 4
created: 2026-07-28
started: 2026-08-01
completed: 2026-08-01
phase: 2
depends_on: [task-300]
audit_findings: [A-110-05, F2-02]
files_affected:
  - agent/scripts/acp.pref-resolve.py
---

## Objective

Resolve all four preference layers in one `python3` process instead of four bash YAML walks.

## Context

`get_preference()` (`agent/scripts/acp.preferences.sh:83`) walks project → workspace → user → default, calling `yaml_get` inside `$( )` for each. Two costs compound:

1. Each layer re-parses, because the AST cache lives in shell variables and `$( )` runs in a subshell that discards them.
2. Each parse has a floor set by the parser architecture.

> **Baselines corrected 2026-07-31, post-Phase 1.** The figures this task was written
> against are stale — Phase 1 made the parser 3.8× faster. Current, means of 5:
>
> | | Now | Target |
> |---|---|---|
> | `get_preference` | **854 ms** | <100 ms |
> | `get_preference_or` | **759 ms** | <100 ms |
> | one `yaml_parse` of the real 106-line pref file | **360 ms** | — |
>
> Only **2 of 4 layers exist** here — `_pref_project_file` (`agent/preferences/acp.default.yaml`)
> and `_pref_configurables_file` (`agent/configurables/acp.configurables.yaml`); workspace and
> user are absent. So 854 ms is roughly two bash parses, and the remaining 320 forks per parse
> are architectural (see the milestone's "measured floor"). **This is why the resolver is still
> required:** the only way under 100 ms is to stop parsing YAML in bash on this path.

Phase 1 lowers the floor; this task removes the repetition. One process reads all four files once and returns the resolved value.

## Steps

1. Write `agent/scripts/acp.pref-resolve.py` taking: namespace, dotted pref path, and the layer file paths in precedence order.
2. Implement precedence exactly as `acp.preferences.sh` does today. **Read `get_preference()` line by line; do not infer the rules.**

   > **Corrected by audit-113 (F2-02).** The earlier wording implied a uniform four-file lookup and named a `_pref_default_file` helper that **does not exist**. The real model is:
   >
   > | Order | Helper | Key looked up |
   > |---|---|---|
   > | 1 | `_pref_project_file` | `${ns}.${pref_path}` |
   > | 2 | `_pref_workspace_file` | `${ns}.${pref_path}` |
   > | 3 | `_pref_user_file` | `${ns}.${pref_path}` |
   > | 4 | `_pref_configurables_file` | **`${ns}.${pref_path}.default`** |
   >
   > The configurables layer uses a **different key shape** — note the `.default` suffix. A resolver that treats all four files uniformly returns empty where the bash implementation returns a value, which would be a silent behaviour change in the subsystem task-302 wires into every preference read.
   >
   > Layers 1–3 also each fall back to `_flat_dot_get` for flat `a.b.c:` keys when the nested lookup misses. Reproduce that too.
3. Emit the resolved value on stdout and nothing else. Exit non-zero only on genuine error, so the caller can distinguish "not found" from "failed".
4. Use only the standard library. **PyYAML is not installed in this environment** (3 `integrity-v2` tests already skip for that reason), so either vendor a minimal reader for the subset used by preference files or parse without it — and state which, in the file header.
5. No network, no writes, no `os.system`. This runs on every preference read.

## Verification

- [ ] Returns identical values to the current bash `get_preference` for every key in `agent/preferences/*.yaml`
- [ ] Precedence verified with a fixture where the same key is set at all four layers
- [ ] Configurables layer resolved via `${ns}.${pref_path}.default`, not `${ns}.${pref_path}` (F2-02)
- [ ] `_flat_dot_get` fallback reproduced for layers 1-3
- [ ] Flat dotted-key fallback behaves identically
- [ ] Missing file, missing key, and empty value each behave as the bash version does
- [ ] Runs without PyYAML installed
- [ ] Median runtime under 100ms (from 854ms — measure with the same 5-run median the milestone uses)

## User-Observable Acceptance

`python3 agent/scripts/acp.pref-resolve.py acp integrations.gitleaks.enabled <layer files>` prints the same value the bash path prints, in well under a second.

## Resolution (2026-08-01)

Implemented `agent/scripts/acp.pref-resolve.py` — a line-for-line
reimplementation of `yaml_parse`/`yaml_query` (acp.yaml-parser.sh) and
`get_preference` (acp.preferences.sh) precedence, stdlib only. No structural
divergence from the bash algorithm was introduced: same space-only indent
counting, same naive first-`:`/first-`#` splitting, same `.default` suffix
quirk on the configurables layer only, same `_flat_dot_get` regex/tr
pipeline (including its "strip all whitespace, not just leading/trailing"
behaviour).

`tests/acp.pref-resolve.test.sh` (28 assertions) verifies: every real key
under `agent/preferences/acp.default.yaml` / `agent/configurables/acp.configurables.yaml`
agrees with bash `get_preference` exactly (value AND exit code); a
synthetic 4-layer fixture proves precedence project > workspace > user >
configurables; the configurables `.default` suffix is verified against a
sibling `description` field to catch exactly the F2-02 regression this task
was scoped around; flat-dot fallback; no `yaml` import (AST-checked, not
just `pip list`); median runtime 41-46ms across repeated local runs (from
854ms baseline, target was <100ms).

One test-harness pitfall worth recording: `acp.preferences.sh` reassigns
the *global* `SCRIPT_DIR` variable unconditionally when sourced — a test
script that computes its own paths from a same-named `SCRIPT_DIR` before
sourcing it will have those paths silently overwritten. Worked around by
using `ROOT_DIR` in the new test file; not a bug in acp.preferences.sh
itself (it's a leaf script, not meant to be sourced alongside others that
also use `SCRIPT_DIR`), so left as-is rather than "fixed."
