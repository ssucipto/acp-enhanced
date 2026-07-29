---
id: task-301
milestone: M85
title: "Single-pass preference resolver (acp.pref-resolve.py)"
status: not_started
priority: 5
complexity: medium
estimated_hours: 3
created: 2026-07-28
started: null
completed: null
phase: 2
depends_on: [task-300]
audit_findings: [A-110-05]
files_affected:
  - agent/scripts/acp.pref-resolve.py
---

## Objective

Resolve all four preference layers in one `python3` process instead of four bash YAML walks.

## Context

`get_preference()` (`agent/scripts/acp.preferences.sh:83`) walks project → workspace → user → default, calling `yaml_get` inside `$( )` for each. Two costs compound:

1. Each layer re-parses, because the AST cache lives in shell variables and `$( )` runs in a subshell that discards them. Measured: 4 lookups cost **8.93s in-shell vs 15.59s via subshells**.
2. Even cached, each lookup has a ~2.2s floor.

Phase 1 lowers the floor; this task removes the repetition. One process reads all four files once and returns the resolved value.

## Steps

1. Write `agent/scripts/acp.pref-resolve.py` taking: namespace, dotted pref path, and the layer file paths in precedence order.
2. Implement precedence exactly as `acp.preferences.sh` does today — first non-empty wins, including the `_flat_dot_get` fallback for flat `a.b.c:` keys. Read the bash implementation; do not infer the rules.
3. Emit the resolved value on stdout and nothing else. Exit non-zero only on genuine error, so the caller can distinguish "not found" from "failed".
4. Use only the standard library. **PyYAML is not installed in this environment** (3 `integrity-v2` tests already skip for that reason), so either vendor a minimal reader for the subset used by preference files or parse without it — and state which, in the file header.
5. No network, no writes, no `os.system`. This runs on every preference read.

## Verification

- [ ] Returns identical values to the current bash `get_preference` for every key in `agent/preferences/*.yaml`
- [ ] Precedence verified with a fixture where the same key is set at all four layers
- [ ] Flat dotted-key fallback behaves identically
- [ ] Missing file, missing key, and empty value each behave as the bash version does
- [ ] Runs without PyYAML installed
- [ ] Median runtime under 100ms

## User-Observable Acceptance

`python3 agent/scripts/acp.pref-resolve.py acp integrations.gitleaks.enabled <layer files>` prints the same value the bash path prints, in well under a second.
