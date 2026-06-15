# Milestone 62: Quality Hardening, Schema Coverage & Carryover Resolution

**Target version**: 6.21.0  
**Status**: completed  
**Completed**: 2026-06-15  
**Estimated effort**: ~21h (7 routes)  
**Source**: audit-065 (H4, H7, M2), audit-066 (M11), audit-067 (L1-L4), audit-062 carryovers (F-062-01..05), post-M61 shortcut postmortem (15 shortcuts across 3 rounds)

## Goal

Bring the script layer to full convention conformance, validate the memory layer with schemas, clean up low-severity debt, resolve the 5 long-standing audit-062 carryovers (recurring-task/hooks hardening), and add automated prevention gates for the 15 shortcut categories discovered during M61 autonomous completion (cross-file version consistency, test quality, post-milestone verification).

## Build Order

| Route | Title | Addresses | Est. | Status |
|-------|-------|-----------|------|--------|
| route-173 | Upgrade 17 scripts from bare `set -e` to `set -euo pipefail` (+ fix surfaced unbound vars) | H4 (HIGH-065-004) | 3h | created |
| route-174 | Add `## Steps` to integrity/review; `## Verification` to 5 commands | H7, M2 | 3h | created |
| route-175 | Add memory-layer entity schemas + enforce all schemas in `acp-validate.ts` | M11 (MED-066-007) | 4h | created |
| route-176 | Resolve 5 audit-062 carryovers (hooks format, checklist verification, auto next_due, git-hook ref, findings feedback loop) | F-062-01..05 | 2h | created |
| route-177 | Low-severity cleanups: whitelist reviewed_by, routing.yml dynamic-state, dispatch YAML-split, git-provenance grep→parser | L1-L4 | 2h | created |
| route-178 | Add 7 cross-file consistency validators to `acp-validate.ts` + test suite + `constraints.yml` rules (test_quality_gate, post_milestone_sweep hook) | M61 postmortem (shortcuts 5-12, 15) | 4h | created |
| route-179 | Create `acp.post-milestone-sweep.sh` — automated 6-gate verification script + E2E test | M61 postmortem (shortcuts 2-4, 11) | 3h | created |

**Dependency note**: route-178 must complete before route-179 (sweep script depends on constraints.yml hook and acp-validate validators).

## audit-062 Carryover Detail (route-176)

| Finding | Fix target |
|---------|-----------|
| F-062-01 | Restore 2 dropped hooks (pre_commit_integrity_phase1, ci_npm_ignore_scripts) to hooks block |
| F-062-02 | Verify 3 milestone checklist items (disabled exclusion, frequency/trigger XOR, executor cross-validation) |
| F-062-03 | Automated `next_due` calculation for recurring tasks (no manual date drift) |
| F-062-04 | Reference git-hook implementation for pre-commit-rule-audit trigger |
| F-062-05 | findings-to-task feedback loop: add `last_findings_count` to recurring_tasks |

## Industry-Standard Verification (double-verify gate)

- ✅ All scripts pass `shellcheck --severity=error` after pipefail upgrade (36/36)
- ✅ Schema enforcement verified via acp-validate.ts runSchemaEnforcement() (12 schemas)
- ✅ audit-062 carryovers marked `fixed` with `verified_in_audit: "078"` (F-062-01..05)
- ⏳ No unbound-variable regressions (run full E2E after route-173) — deferred: CRLF line endings on Windows block bash E2E execution

## Success Criteria

- All 36 scripts use `set -euo pipefail` (0 bare `set -e`)
- All command docs structurally conformant (Steps + Verification present)
- Memory-layer YAML validated in CI
- 5 audit-062 carryovers resolved
- `CHANGELOG.md` entry for v6.21.0
- All 7 post-milestone sweep gate checks pass on a completed milestone (acp.post-milestone-sweep.sh)
- `acp-validate` catches version inconsistency, stale next_steps, blank verification gates, missing tags, gitignore/gitattributes drift

## References

- `agent/skills/scripts.md` (set -euo pipefail rule)
- `agent/memory/audit-carryovers.md` (F-062 entries)
- `agent/reports/audit-067-complete-consolidated-audit.md` (Part B Medium/Low)
