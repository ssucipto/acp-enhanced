---
id: task-243
milestone: M72
title: "Docs alignment — validate.md corrections, lessons, notes, pipefail rationale, /acp-verify pointer"
status: planned
priority: 4
complexity: low
estimated_hours: 2
created: 2026-07-15
started: null
completed_date: null
route: route-232
audit_findings: [F-091-05, F-091-07, F-091-11, F-091-12]
depends_on: [task-241]
design_reference: [Design: M72 Validation Truth](../design/m72-validation-truth-drift-hardening.md)
---

## Objective

Bring every doc that audit-091 caught lying (or lagging) back in line with enforced reality.

## Context (inlined from audit-091)

- `acp.validate.md` Step 11.6 documents invocation `(cd scripts && npx ts-node acp-validate.ts)` — the vacuous-green trap — and claims sessions entries require `tasks_completed`; `session.schema.yaml` actually requires only `date`, `executor`, `done` (F-091-07).
- lessons.md high-priority companion-file lesson names only prompts + opencode; progress.yaml notes line says "prompts + opencode + cursor parity" — both predate the `.claude/commands/` surface (F-091-05 doc half).
- 4 sourced libraries intentionally lack `set -euo pipefail` (`acp.common.sh`, `acp.yaml-parser.sh`, `acp.driver-yaml.sh`, `acp.integrity-output.sh`) but the exemption is undocumented (F-091-11).
- User reached for `/acp-verify`, which doesn't exist; standards enforcement is `/acp-review`, consistency is `/acp-validate` (F-091-12).

## Steps

1. `acp.validate.md`: Step 11.6 invocation → `npx tsx scripts/acp-validate.ts` (repo root); session required-keys text → match session.schema.yaml; Step 11.7 → describe 5-surface parity
2. lessons.md: update the high-priority companion-file lesson to name all 4 wrapper directories + "run sync scripts"
3. progress.yaml notes line → "wrappers across 4 surfaces (prompts, opencode, cursor, claude)"
4. `agent/skills/scripts.md`: add sourced-library strict-mode exemption rationale (set -e propagation into the sourcing shell); name the 4 files
5. `/acp-verify` discoverability: add an `agent/index/` inline note (kind: note) mapping "verify" intent → `/acp-review` (standards) and `/acp-validate` (consistency)
6. Guardrail #4: after editing `acp.validate.md`, regenerate all 4 wrapper surfaces and re-run parity

## Verification

- [ ] `grep -c "cd scripts && npx ts-node" agent/commands/acp.validate.md` → 0
- [ ] Step 11.6 session keys match session.schema.yaml required_fields exactly
- [ ] lessons.md lesson names .github/prompts, .opencode/commands, .cursor/commands, .claude/commands
- [ ] Wrappers regenerated; parity 5 surfaces clean
- [ ] Carryovers F-091-05/07 stamped `fixed`

## User-Observable Acceptance

Following acp.validate.md Step 11.6 verbatim produces a real validation run (non-vacuous), and searching the index for "verify" points to the right commands.
