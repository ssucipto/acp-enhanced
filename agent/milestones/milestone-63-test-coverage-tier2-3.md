# Milestone 63: Test Coverage Sprint — Tier 2 & 3

**Planned version**: 6.25.0 → **6.25.1** (audit-083 patch)  
**Status**: completed  
**Estimated effort**: ~16h (2 routes: initial ship + audit remediation)  
**Source**: audit-065 (CRIT-065-003), audit-067 (Part D, M63), **audit-083** (post-ship gaps)

## Goal

Complete the E2E coverage effort begun in M60. Cover the remaining untested commands (package/project workflow + memory/knowledge commands) so the framework reaches a defensible coverage baseline for production dependence.

**Amendment (2026-07-15)**: After v6.25.0 ship, audit-083 found behavioral-coverage shortcuts. Phase 2 closes all findings before M63 is considered fully verified.

## Build Order

| Phase | Route | Title | Addresses | Est. | Status |
|-------|-------|-------|-----------|------|--------|
| **1** | route-206 | E2E tier 2/3 + command↔test parity CI guard | CRIT-065-003 tier 2/3 | 12h | completed |
| **2** | route-207 | audit-083 remediation + v6.25.1 | F-083-01..06, SC-M63-01..05 | 4h | completed |

> Note: route-178 in routing/tasks is M62 validators (name collision). M63 coverage shipped as route-206; audit fixes as route-207.

### Task Map (audit-083 remediation)

| Task | Finding | Deliverable | Gate |
|------|---------|-------------|------|
| [task-211](../tasks/milestone-63-test-coverage-tier2-3/task-211-route-206-coverage.md) | — | Registry + validate guard + tier2/parity E2E | v6.25.0 tag |
| [task-212](../tasks/milestone-63-test-coverage-tier2-3/task-212-tier3-dynamic-e2e-loop.md) | F-083-01, SC-M63-01 | Dynamic tier3 loop, `TIER3_COUNT=58` | tier3 100% pass |
| [task-213](../tasks/milestone-63-test-coverage-tier2-3/task-213-vitest-coverage-validator.md) | F-083-04, SC-M63-04 | Vitest + `CommandE2eCoverageOptions` | 45/45 vitest |
| [task-214](../tasks/milestone-63-test-coverage-tier2-3/task-214-agent-directive-case-fix.md) | F-083-06, SC-M63-05 | `grep -qi` in tier2/tier3 | no false ✗ on proceed |
| [task-215](../tasks/milestone-63-test-coverage-tier2-3/task-215-milestone-doc-reconciliation.md) | F-083-02, SC-M63-02 | CHANGELOG v6.25.0 + verification gates | milestone gates ✅ |
| [task-216](../tasks/milestone-63-test-coverage-tier2-3/task-216-task-tracking-alignment.md) | F-083-03, SC-M63-03 | task-211..218 + route-207 AC | dual tracking sync |
| [task-217](../tasks/milestone-63-test-coverage-tier2-3/task-217-audit-083-release-closure.md) | audit-083 | Report + carryovers + v6.25.1 | carryovers @ 083 |
| [task-218](../tasks/milestone-63-test-coverage-tier2-3/task-218-coverage-meta-assertion-pattern.md) | audit-083 R1 | Document meta-assertion rule | pattern in milestone |

### Out of scope (accepted)

| ID | Item | Rationale |
|----|------|-----------|
| F-083-05 | `git.commit` / `git.init` not in registry | M63 scoped to `acp.*` commands only |

## Tier 2 — Package/Project Workflow

`/acp-package-install`, `/acp-package-publish`, `/acp-project-create`, `/acp-projects-restore`, `/acp-version-check`, `/acp-version-update`, `/acp-version-check-for-updates`, `/acp-preferences-*` (create/get/set/show/validate)

## Tier 3 — Memory/Knowledge/Workflow

`/acp-decide`, `/acp-status`, `/acp-resume`, `/acp-feedback`, `/acp-handoff`, `/acp-report`, `/acp-update`, `/acp-memory-sync`, `/acp-pattern-sync`, `/acp-session-sync`, `/acp-carryover-query`, `/acp-cost-report`, `/acp-wiki-update`, `/acp-visualize`, `/acp-artifact-*`, `/acp-clarification-*`, `/acp-command-create`, `/acp-design-*`, `/acp-pattern-create`, `/acp-task`, `/acp-task-create`, `/acp-stakeholder-report`, `/acp-index`

## Industry-Standard Verification (double-verify gate)

- ✅ Every command in the repo has at least one E2E test file (0 untested — registry + validate)
- ✅ Coverage tracked: `validateCommandE2eCoverage()` in acp-validate.ts
- ✅ Negative assertions in tier2/tier3 suites + existing per-command E2E

## Success Criteria

- Untested-command count reaches 0
- CI enforces command↔test parity going forward (prevents future regressions)
- audit-067 Part C dimension Testing reaches 🟢
- `CHANGELOG.md` entry for v6.25.0

## Verification (post audit-083)

- [x] Registry: 70 commands in `command-e2e-coverage.yaml`
- [x] `validateCommandE2eCoverage()` — 0 untested
- [x] Tier2 E2E — all 12 tier-2 slugs
- [x] Tier3 E2E — dynamic loop, 58 tier-3 commands (not static subset)
- [x] Parity E2E — validate integration
- [x] Vitest — `validateCommandE2eCoverage` unit tests
- [x] Task doc `task-211` + audit-083 carryovers closed

## Anti-Shortcuts (from audit-083 — do not repeat)

| Rule | Enforcement |
|------|-------------|
| Registry ≠ behavioral coverage | Tier suites MUST loop all tier slugs + meta-assertion count |
| Validator needs vitest | E2E-only is insufficient for TS validators in worker threads |
| Milestone `completed` requires gates ✅ | No status drift vs route AC |
| Route complete requires task docs | Dual tracking: route + task-NNN |
| Agent Directive check is case-insensitive | Use `grep -qi` not literal string match |

## References

- `agent/reports/audit-067-complete-consolidated-audit.md` (Part C/D)
- `agent/reports/audit-083-m63-implementation-gaps.md` (post-ship remediation)
- `agent/patterns/local.e2e-testing.md`
