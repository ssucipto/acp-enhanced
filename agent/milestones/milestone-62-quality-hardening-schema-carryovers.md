# Milestone 62: Quality Hardening, Schema Coverage & Carryover Resolution

**Target version**: 6.17.0  
**Status**: planned  
**Estimated effort**: ~14h (5 routes)  
**Source**: audit-065 (H4, H7, M2), audit-066 (M11), audit-067 (L1-L4), audit-062 carryovers (F-062-01..05)

## Goal

Bring the script layer to full convention conformance, validate the memory layer with schemas, clean up low-severity debt, and resolve the 5 long-standing audit-062 carryovers (recurring-task/hooks hardening).

## Build Order

| Route | Title | Addresses | Est. | Status |
|-------|-------|-----------|------|--------|
| route-173 | Upgrade 17 scripts from bare `set -e` to `set -euo pipefail` (+ fix surfaced unbound vars) | H4 (HIGH-065-004) | 3h | created |
| route-174 | Add `## Steps` to integrity/review; `## Verification` to 5 commands | H7, M2 | 3h | created |
| route-175 | Add memory-layer entity schemas + enforce all schemas in `acp-validate.ts` | M11 (MED-066-007) | 4h | created |
| route-176 | Resolve 5 audit-062 carryovers (hooks format, checklist verification, auto next_due, git-hook ref, findings feedback loop) | F-062-01..05 | 2h | created |
| route-177 | Low-severity cleanups: whitelist reviewed_by, routing.yml dynamic-state, dispatch YAML-split, git-provenance grep→parser | L1-L4 | 2h | created |

## audit-062 Carryover Detail (route-176)

| Finding | Fix target |
|---------|-----------|
| F-062-01 | Restore 2 dropped hooks (pre_commit_integrity_phase1, ci_npm_ignore_scripts) to hooks block |
| F-062-02 | Verify 3 milestone checklist items (disabled exclusion, frequency/trigger XOR, executor cross-validation) |
| F-062-03 | Automated `next_due` calculation for recurring tasks (no manual date drift) |
| F-062-04 | Reference git-hook implementation for pre-commit-rule-audit trigger |
| F-062-05 | findings-to-task feedback loop: add `last_findings_count` to recurring_tasks |

## Industry-Standard Verification (double-verify gate)

- All scripts pass `shellcheck --severity=error` after pipefail upgrade
- Schema enforcement proven by a deliberately malformed memory entry failing validation
- audit-062 carryovers marked `fixed` with `verified_in_audit`
- No unbound-variable regressions (run full E2E after route-173)

## Success Criteria

- All 36 scripts use `set -euo pipefail` (0 bare `set -e`)
- All command docs structurally conformant (Steps + Verification present)
- Memory-layer YAML validated in CI
- 5 audit-062 carryovers resolved
- `CHANGELOG.md` entry for v6.17.0

## References

- `agent/skills/scripts.md` (set -euo pipefail rule)
- `agent/memory/audit-carryovers.md` (F-062 entries)
- `agent/reports/audit-067-complete-consolidated-audit.md` (Part B Medium/Low)
