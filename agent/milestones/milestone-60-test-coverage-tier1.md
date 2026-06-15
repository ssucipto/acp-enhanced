# Milestone 60: Test Coverage Sprint — Tier 1 (Core Commands)

**Target version**: 6.20.2  
**Status**: completed  
**Estimated effort**: ~14h (2 routes)  
**Source**: audit-065 (CRIT-065-003), audit-067 (Part D, M60)

## Goal

Eliminate the single largest quality gap: 46 of 68 commands (68%) have no E2E test. Tier 1 covers the 8 core-workflow commands whose regressions would silently break the entire ACP loop. Goal: **no critical command without at least a smoke test.**

## Build Order

| Route | Title | Addresses | Est. | Status |
|-------|-------|-----------|------|--------|
| route-165 | E2E tests for 8 core commands: init, proceed, plan, dispatch, commit, validate, audit, route | C2 (CRIT-065-003 tier 1) | 12h | completed |
| route-166 | Fix integrity E2E `\d` ERE regex bug + add `CONTRIBUTING.md` | M13 (MED-067-003, MED-067-005) | 2h | completed |

## Tier 1 Command Coverage (route-165)

| Command | Minimum assertions |
|---------|-------------------|
| `/acp-init` | Loads core files; outputs mode banner; sets routing.yml current mode |
| `/acp-proceed` | Reads next route; respects carryovers; no-op when nothing pending |
| `/acp-plan` | Scans progress.yaml; creates milestone+route stubs; updates progress.yaml |
| `/acp-dispatch` | Builds context within budget; non-destructive routing.yml update (ties to route-159) |
| `/acp-commit` | Writes sessions.md entry; dual-store sync; >15-entry compaction trigger |
| `/acp-validate` | Detects malformed command doc; version consistency check |
| `/acp-audit` | Produces audit-N report; appends carryovers |
| `/acp-route` | Classifies task_type; creates route-NNN with frontmatter |

## Industry-Standard Verification (double-verify gate)

- Every new test must include at least one **negative** assertion (failure path), not only happy-path.
- Tests must be deterministic and parallel-safe (use `mktemp -d`, per lessons.md 2026-06-07).
- `bash -n` clean + shellcheck clean for all new test files.

## Success Criteria

- 8 core commands have passing E2E tests in `e2e/`
- Untested-command ratio drops from 68% to ≤56% (46→≤38)
- Integrity test rule-count assertion computes correctly (verified with a known-count fixture)
- `CONTRIBUTING.md` present with branch model + test requirements
- `CHANGELOG.md` entry for v6.20.2 (M60 Tier 1 E2E + integrity + CONTRIBUTING)

## References

- `agent/reports/audit-067-complete-consolidated-audit.md` (Part C scorecard: Testing = 🔴)
- `agent/patterns/local.e2e-testing.md` (test conventions)
- `e2e/acp.integrity.test.sh:32` (regex bug)
