# Milestone 44: Feedback-Driven Improvements (v6.9.0)

**Milestone**: M44
**Version Target**: 6.9.0
**Priority**: 5
**Status**: completed
**Started**: 2026-06-03
**Estimated Weeks**: 2–3

## Overview

Implement the remaining 7 recommendations from the ChoreHive production feedback cross-reference (audit-022) and the second/third-round gap audits (audit-023, audit-024). P0 items (R1 light-mode, R2 auto-lessons, 13 implementation gaps) were completed in v6.8.2. M44 covers P1, P2, and P3 items.

## Context

- **Source**: 4 weeks of daily ACP Enhanced use on ChoreHive (34 milestones, 54 audits, 14 sessions)
- **Root Insight**: Only ~10% of system surface area sees active use — commands work but users don't know they exist
- **Completed in v6.8.2**: R1 (light-mode protocol), R2 (auto-populate lessons), 8 mode-switching gaps (audit-023), 5 discoverability gaps (audit-024)
- **Remaining**: 7 recommendations across 3 priority levels

## Tasks

### Phase 1 — P1 (v6.8.3)

| Task | Recommendation | Files Affected | Complexity |
|------|---------------|----------------|:---:|
| **task-046** | R3: `--team-size` scaffold flag | `scripts/acp-bootstrap.sh`, `docs/USAGE.md` | Medium |
| **task-047** | R5: Resolve three-copy AGENTS/CLAUDE architecture | `CLAUDE.md`, `.github/copilot-instructions.md`, `scripts/acp-bootstrap.sh` | Low |
| **task-048** | R8: Observability dashboard in progress.yaml | `agent/progress.yaml` (schema), `acp-validate.ts` | Medium |

### Phase 2 — P2 (v6.9.0)

| Task | Recommendation | Files Affected | Complexity |
|------|---------------|----------------|:---:|
| **task-049** | R4: Make prompt wrappers optional | `scripts/acp-bootstrap.sh`, `agent/manifest.yaml` | Low |
| **task-050** | R6: Convert skills to @-mention pattern | `agent/skills/*.md`, `copilot-instructions.md`, `CLAUDE.md` | Medium |
| **task-051** | R9: Parallelization support | `agent/routing/taxonomy.yml`, new task schema | High |

### Phase 3 — P3 (v6.9.0)

| Task | Recommendation | Files Affected | Complexity |
|------|---------------|----------------|:---:|
| **task-052** | R7: Document manifest vs progress split | `AGENT.md`, `agent/manifest.yaml` | Trivial |

## Completed (v6.8.2 — Not in M44)

| Item | What | Audits |
|------|------|--------|
| R1 | Light-mode context protocol (routing.yml, copilot-instructions.md, CLAUDE.md) | 022, 023 |
| R2 | Auto-populate lessons from key_facts (commit protocol, scope + dedup) | 022, 023 |
| GAP-001–008 | Mode switching: reverse switch, tracking, auto-triggers, output formats, dedup threshold, scope inference | 023 |
| GAP-009–013 | Command discoverability: 24 command suggestions, post-command protocol, underused detection, getting-started check | 024 |
| git-commit/git-init | Command doc updates: v2.0.0, /prefix, dates | 021 |

## Acceptance Criteria

- [ ] `acp-bootstrap.sh --team-size solo` generates ~30 files (not ~310)
- [ ] CLAUDE.md + copilot-instructions.md are redirects to AGENT.md
- [ ] `agent/progress.yaml` has auto-populated `observability:` section on commit
- [ ] Prompt wrappers are opt-in via manifest flag
- [ ] Skills are invocable via @-mention, not auto-loaded
- [ ] `task_type: parallel` supports concurrent sub-tasks
- [ ] Manifest-vs-progress documentation table in AGENT.md
