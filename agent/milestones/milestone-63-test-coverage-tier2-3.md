# Milestone 63: Test Coverage Sprint — Tier 2 & 3

**Planned version**: 6.22.0  
**Status**: planned  
**Estimated effort**: ~12h (1 route, may split during planning)  
**Source**: audit-065 (CRIT-065-003), audit-067 (Part D, M63)

## Goal

Complete the E2E coverage effort begun in M60. Cover the remaining untested commands (package/project workflow + memory/knowledge commands) so the framework reaches a defensible coverage baseline for production dependence.

## Build Order

| Route | Title | Addresses | Est. | Status |
|-------|-------|-----------|------|--------|
| route-178 | E2E tests for remaining untested commands (Tier 2: package/project; Tier 3: memory/knowledge) | C2 (CRIT-065-003 tier 2/3) | 12h | created |

> Note: route-178 will be split into per-tier or per-command routes during `/acp-proceed` if the scope proves too large for a single route.

## Tier 2 — Package/Project Workflow

`/acp-package-install`, `/acp-package-publish`, `/acp-project-create`, `/acp-projects-restore`, `/acp-version-check`, `/acp-version-update`, `/acp-version-check-for-updates`, `/acp-preferences-*` (create/get/set/show/validate)

## Tier 3 — Memory/Knowledge/Workflow

`/acp-decide`, `/acp-status`, `/acp-resume`, `/acp-feedback`, `/acp-handoff`, `/acp-report`, `/acp-update`, `/acp-memory-sync`, `/acp-pattern-sync`, `/acp-session-sync`, `/acp-carryover-query`, `/acp-cost-report`, `/acp-wiki-update`, `/acp-visualize`, `/acp-artifact-*`, `/acp-clarification-*`, `/acp-command-create`, `/acp-design-*`, `/acp-pattern-create`, `/acp-task`, `/acp-task-create`, `/acp-stakeholder-report`, `/acp-index`

## Industry-Standard Verification (double-verify gate)

- ⏳ Every command in the repo has at least one E2E test file (0 untested commands at milestone exit)
- ⏳ Coverage tracked: add a CI check asserting each `agent/commands/acp.*.md` has a matching `e2e/acp.*.test.sh`
- ⏳ Negative assertions required (not happy-path only)

## Success Criteria

- Untested-command count reaches 0
- CI enforces command↔test parity going forward (prevents future regressions)
- audit-067 Part C dimension Testing reaches 🟢
- `CHANGELOG.md` entry for v6.18.0

## References

- `agent/reports/audit-067-complete-consolidated-audit.md` (Part C/D)
- `agent/patterns/local.e2e-testing.md`
