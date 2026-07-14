---
id: task-242
milestone: M72
title: "Wrapper stray deletion + bootstrap dead-glob fix"
status: planned
priority: 4
complexity: low
estimated_hours: 2
created: 2026-07-15
started: null
completed_date: null
route: route-231
audit_findings: [F-091-04, F-091-06]
depends_on: [task-241]
design_reference: [Design: M72 Validation Truth](../design/m72-validation-truth-drift-hardening.md)
---

## Objective

Remove the 6 stale dot-named duplicate wrappers and fix the two dead-glob copy loops in `scripts/acp-bootstrap.sh`.

## Context (inlined from audit-091)

- Dot-named duplicates coexisting with hyphen twins: `acp.carryover-query`, `acp.pattern-sync`, `acp.session-sync` — in `.github/prompts/*.prompt.md` AND `.opencode/commands/*.md` (6 files). Invisible to old parity filter; show as picker duplicates.
- `scripts/acp-bootstrap.sh` lines ~1330 (cursor) and ~1342 (claude) loop `for _f in .opencode/commands/acp.*.md` — opencode files are hyphen-named, glob matches nothing, prints misleading "✓ 0 … generated". On fresh bootstrap the `agent/scripts/acp.*-commands-sync.sh` fallbacks don't exist yet at that point (agent/ installs at step 7).

## Steps

1. Delete the 6 dot-named files (`git rm`)
2. Fix bootstrap: replace both dead copy loops — either correct glob to `acp-*.md` or (preferred) drop the copy loops and move the two sync-script invocations to run **after** step 7 installs `agent/scripts/`
3. Ensure bootstrap output never claims success with 0 files: print a warning when count is 0
4. Regenerate all wrapper surfaces (cursor + claude sync scripts; verify prompts/opencode untouched)
5. Re-run task-241's parity check (5 surfaces, 0 strays) and `e2e/acp.cursor-commands-sync.test.sh` + `e2e/acp.claude-commands-sync.test.sh`

## Verification

- [ ] `ls .github/prompts .opencode/commands | grep -c "^acp\."` → 0
- [ ] `bash -n scripts/acp-bootstrap.sh` passes; no `acp.*.md` glob against wrapper dirs remains
- [ ] Parity: 5 surfaces matched, 0 strays
- [ ] Both wrapper e2e tests pass (10/10 each)
- [ ] Carryovers F-091-04/06 stamped `fixed`

## User-Observable Acceptance

Slash pickers (Copilot, opencode) show exactly one entry per command — no `/acp.pattern-sync` + `/acp-pattern-sync` duplicates.
