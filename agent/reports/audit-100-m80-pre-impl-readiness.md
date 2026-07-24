# Audit Report: M80 Pre-Implementation Readiness

**Audit**: #100
**Date**: 2026-07-24
**Subject**: Pre-implementation readiness of M80 (E2E Suite Debt Remediation), tasks 265/266/268, after task-267 removal
**Mode**: --pre-impl

## Summary

Cross-referenced all 7 F-M78-01 failures against the actual test files AND the scripts they exercise. The M80 plan is **sound and complete** — the 7 failures map cleanly to task-265 (3 test-side) + task-266 (4 behavior/fixture/mode), with no failure unaccounted for. task-267 removal is clean (F-086-02 marked fixed per developer confirmation; no dangling refs; validate exit 0). Phase 2 surfaced **one trap worth avoiding** (F-100-03: copilot-instructions.md is auto-generated) and four precision refinements. **Verdict: READY WITH REFINEMENTS** — no blockers; amend tasks 265/266 so implementation can't stumble.

## Pre-Implementation Readiness (M80)

**Mode**: --pre-impl

### Phase 1 — Plan Correctness
| Check | Result | Notes |
|-------|--------|-------|
| task-267 removal consistent | ✅ | file deleted; progress/milestone/task-268 updated; validate exit 0 |
| F-086-02 settled | ✅ | marked fixed (developer-confirmed 2026-07-24), not fabricated |
| 7 failures fully covered | ✅ | 265: e2e-workflow, validate-cross-layer, validate-ts · 266: version, package-info, project-update, post-milestone-sweep |
| Open blockers | ✅ None | all fixes are local; no external dependency |

### Phase 2 — Code Cross-Reference (key phase)
| Test | Verified root cause | Correct fix side |
|------|---------------------|------------------|
| acp.e2e-workflow | test greps copilot-instructions for `"light mode"`; doc says `"light + full modes"` | test regex (doc phrasing intentional) — **but see F-100-03** |
| acp.validate-cross-layer | `cp package.json` at lines **23, 59, 74**; no root package.json exists | test — make cp conditional / use package.yaml (all 3) |
| acp.validate-ts | placeholder-check flags temp fixtures ({COMMAND_NAME}) | test fixture/assertion |
| acp.version | `acp.version-check.sh:31` `exit 1` on missing AGENT.md; test expects `2`; **no documented convention** (command doc silent) | free choice — decide + document (F-100-02) |
| acp.package-info | "Show global package info" sub-test exit 1≠0 | diagnose (global-registry fixture) |
| acp.project-update | script DOES emit "Added tag" (`acp.project-update.sh:227`) but test got empty output → script exits early | fixture: `--add-tag` block's test-project registration |
| acp.post-milestone-sweep | `acp.post-milestone-sweep.sh` is git mode **100644 (not executable)**; test `test -x` fails | repo: `chmod +x` + `git update-index --chmod=+x` (F-100-01) |

### Phase 3 — Carryover Check
| Carryover | Status | Blocks M80? |
|-----------|--------|-------------|
| F-M78-01 (7 E2E failures) | pending → M80 target | No — this is the work |
| F-086-02 (FIFOZ) | **fixed** (developer-confirmed) | No — closed |
| (no other pending) | — | — |

### Phase 4 — Operational Completeness
| Check | Result | Notes |
|-------|--------|-------|
| Version bump planned | ✅ | task-268 → v6.28.2 incl. progress.yaml version (M79 lesson applied) |
| Assertion-level check planned | ✅ | task-268 guardrail (audit-099 lesson) |
| Route consistency | ✅ | routes 254,255,257 (256 retired with task-267) |

### Phase Summary
| Phase | Findings | Highest Severity |
|-------|----------|-----------------|
| Phase 1 | 0 | none |
| Phase 2 | 5 | medium (F-100-03) |
| Phase 3 | 0 | none |
| Phase 4 | 0 | none |
| **Total** | **5** | **medium** |

## Key Findings (all refinements — no blockers)

| ID | Sev | Finding | Amend |
|----|-----|---------|-------|
| **F-100-03** | medium | **Auto-sync trap** — `.github/copilot-instructions.md` is auto-generated from `AGENTS.md` by the pre-commit hook. Fixing the e2e-workflow "light mode" failure by editing copilot-instructions.md directly would be **reverted on commit**. The fix must be either test-side (regex) or edit the `AGENTS.md` source. | task-265: state this constraint; prefer test-regex fix |
| **F-100-01** | low | post-milestone-sweep root cause is a **missing executable bit** (git 100644 on `acp.post-milestone-sweep.sh`), not a "behavior mismatch". Fix = `chmod +x` + `git update-index --chmod=+x`. The test's `|| true # Windows` does NOT suppress the recorded FAIL. | task-266: name the precise fix |
| **F-100-02** | low | acp.version — **no documented exit-code convention** (command doc silent), so 1-vs-2 is a free choice; pick one and document it in the script header. Bonus: `acp.version-check.sh` has **duplicate ERR traps** (lines 7-8) — second overrides first; clean up. | task-266: note convention absence + trap cleanup |
| **F-100-04** | low | validate-cross-layer `cp package.json` occurs at **three** sites (23, 59, 74); all must be fixed identically. Project has no root package.json (uses package.yaml). | task-265: fix all 3 |
| **F-100-05** | low | project-update empty output = script exits before the tag logic → the `--add-tag` test block's fixture (test-project registration) is the likely cause, not the script (which has the echo). Regression risk of the version-check exit-code change is low: grep shows no test/script depends on its exit 1. | task-266: record precise cause |

## Recommendations

1. Apply F-100-01..05 as task refinements before `/acp-proceed` — none block, but F-100-03 prevents a wasted edit that the commit hook would silently revert.
2. Keep guardrail #1 (no blind greening): post-milestone-sweep chmod, project-update fixture, and version exit-code are all *real* fixes/decisions, not assertion deletions.
3. Re-affirm the audit-099 lesson at closure: compare failure counts assertion-level, not file-level.
