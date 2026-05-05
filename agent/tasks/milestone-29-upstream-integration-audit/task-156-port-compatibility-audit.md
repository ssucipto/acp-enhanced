---
id: task-156
milestone: M29
title: Port compatibility audit per identified gap
status: not_started
priority: 3
complexity: low
estimated_hours: 2
created: 2026-05-05
started:
completed:
---

## Objective

For each PORT-tagged feature in the parity matrix (task-155), document its compatibility verdict against ACP Enhanced's 4 hard constraints: macOS BSD bash, no external dependencies, 5,000-token budget discipline, `/acp-` naming convention.

## Context

ACP Enhanced has hard constraints that upstream does not share:
1. **macOS BSD bash** — scripts must work on bash 3.2 (macOS default) without GNU bash 4 features (no `mapfile`, no `declare -A` associative arrays, `sed -i` requires empty string argument)
2. **No external deps** — no `jq`, `yq`, `python`, `node` in bash scripts; pure bash only
3. **5,000-token budget discipline** — any new command doc must not require loading context that pushes total over 5,000 tokens per session
4. **`/acp-` naming** — all invocations use `/acp-command-name`; `@acp.command-name` is eliminated (ADR-4)

## Implementation

For each PORT item from task-155:
1. **macOS compat check**: Does the implementation use bash 4+ features or GNU-only coreutils? If yes, note the specific incompatibility and whether a POSIX workaround exists.
2. **Dependency check**: Does it require external tools? If yes, is there a pure-bash alternative?
3. **Token budget check**: Estimate the token cost of adding this feature to the command loading chain. Would it bust the 5,000 token cap?
4. **Naming convention check**: Does the upstream code use `@acp.` invocations that need global replacement with `/acp-`?

Add a "Compatibility" section to `agent/design/local.upstream-parity-matrix.md` with a verdict table:

| Feature | macOS | No-Deps | Token Budget | Naming | Verdict |
|---|---|---|---|---|---|
| driver.yaml system | ✅ | ✅ | ✅ | needs rename | PORT with renaming |

## Expected Output

### Files Updated
- `agent/design/local.upstream-parity-matrix.md` (add Compatibility section)

## Verification
- [ ] Every PORT-tagged feature has a Compatibility row
- [ ] Every macOS incompatibility has a POSIX workaround noted (or escalated to DEFER)
- [ ] Any feature with no viable workaround is downgraded from PORT to DEFER
- [ ] Final verdict column is one of: `PORT as-is`, `PORT with changes`, `DEFER`

## User-Observable Acceptance
`agent/design/local.upstream-parity-matrix.md` has a Compatibility section with verdict for every PORT item. No PORT item proceeds to implementation without a GREEN macOS + No-Deps verdict.
