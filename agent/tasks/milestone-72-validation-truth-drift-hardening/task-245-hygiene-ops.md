---
id: task-245
milestone: M72
title: "Hygiene ops — commit Claude-integration tree, sessions compaction, dependency audit"
status: planned
priority: 3
complexity: low
estimated_hours: 2
created: 2026-07-15
started: null
completed_date: null
route: route-234
audit_findings: [F-091-08, F-091-09, F-091-13]
depends_on: []
design_reference: [Design: M72 Validation Truth](../design/m72-validation-truth-drift-hardening.md)
---

## Objective

Clear the three routine-hygiene findings. Runs FIRST in implementation order (guardrail #9): the uncommitted Claude-integration work must land as its own commit before validator tasks edit adjacent files.

## Context (inlined from audit-091)

- F-091-13: working tree holds uncommitted post-release work — `.claude/commands/` (72 wrappers), `agent/scripts/acp.claude-commands-sync.sh`, `e2e/acp.claude-commands-sync.test.sh`, `agent/wiki/claude-integration.md`, ADR-18 in decisions.md, session entry in sessions.md, hooks in install/version-update/bootstrap scripts.
- F-091-08: sessions.md at 17 entries; protocol threshold >15 → compact oldest 10 into a weekly summary block (CLAUDE.md Session Commit Protocol step 5).
- F-091-09: recurring task `monthly-dependency-audit` (`/acp-integrity --rules dependencies`) overdue since 2026-07-08.

## Steps

1. Commit the Claude-integration work as one logical commit (`feat(claude): native .claude/commands slash-command surface (ADR-18)`) — review staged set for strays first
2. Run sessions.md compaction: oldest 10 entries → one `type: weekly-summary` block; extract any key_facts that belong in patterns.md/decisions.md; re-run `/acp-validate --memory` equivalent (schema enforcement) after
3. Run `/acp-integrity --rules dependencies`; record findings; update `recurring_tasks`: `last_run: <today>`, `next_due: <today>+1month`, `last_findings_count`, `status: current`
4. Write session entry for this phase (guardrail #7)

## Verification

- [ ] `git status` clean for all Claude-integration paths
- [ ] sessions.md ≤ 8 entries incl. summary block; schema enforcement passes
- [ ] `monthly-dependency-audit` status `current`, dates updated
- [ ] Carryovers F-091-08/09/13 stamped `fixed`

## User-Observable Acceptance

`git log --oneline -1` shows the Claude-integration commit; `/acp-status` shows no overdue recurring tasks.
