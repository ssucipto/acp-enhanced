---
id: route-035
title: M41b — Set routing.yml Persona A defaults + M41 milestone wrap-up (OBS-004)
task_type: yaml-schema
milestone: M41
complexity: low
executor: deepseek-v4-flash
context_required:
  - agent/core/routing.yml
  - agent/wiki/domain.yml
  - agent/wiki/architecture.md
  - agent/reports/audit-014-external-feedback-quality-and-improvement-plan.md
files_affected:
  - agent/core/routing.yml
  - agent/wiki/domain.yml
  - agent/wiki/architecture.md
  - agent/milestones/milestone-41-stabilisation-sprint.md
  - agent/progress.yaml
  - CHANGELOG.md
  - AGENT.md
  - agent/core/identity.yml
  - package.yaml
tokens_est: 5000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-05-11
completed: 2026-05-11
override_reason:
---

## Task Description

Final wrap-up route for M41. Set Persona A defaults in `routing.yml`, update `domain.yml` with the 4 new commands (acp.feedback, acp.task, acp.install, acp.dispatch), bump version to 6.7.0, write CHANGELOG entry, and stamp all M41 routes as completed. Closes OBS-004 from audit-014 and completes the milestone.

## Acceptance Criteria

### routing.yml defaults (OBS-004)
- [ ] `agent/core/routing.yml`: `executor: copilot`, `model: github-copilot` (replaces `unset`)
- [ ] Comment preserved: "updated by acp-dispatch.ts at runtime"
- [ ] `persona: A` remains (already set)

### domain.yml updates
- [ ] 4 new command entries added: `acp.feedback`, `acp.task`, `acp.install`, `acp.dispatch`
- [ ] `commands.count` updated to 63 (59 existing + 4 new)
- [ ] Each new command includes: name, purpose, category (workflow/core), scripts referenced

### architecture.md updates
- [ ] Section added: "AGENTS.md Sync Pre-Commit Hook" — documents hook installed by bootstrap
- [ ] Short description of how the hook works

### Version bump 6.6.0 → 6.7.0
- [ ] `agent/core/identity.yml`: version field updated
- [ ] `package.yaml`: version updated
- [ ] `AGENT.md`: version badge/field updated

### CHANGELOG.md
- [ ] New `[6.7.0] - 2026-05-11` entry added at top with M41 summary:
  - Added: acp.feedback.md, acp.task.md, acp.install.md, acp.dispatch.md + companions
  - Fixed: sessions.md malformed entry, HTTP-Referer placeholder, domain.yml count
  - Changed: routing.yml Persona A defaults, config.yml last_verified dates, README QUICKSTART link + Branch Safety section + Windows docs
  - Removed: scripts/scripts-package.json (duplicate)
  - Added: AGENTS.md pre-commit sync hook in bootstrap

### progress.yaml
- [ ] M41 status → completed, progress → 100, tasks_completed → 14/14
- [ ] `current_milestone: M41-complete`
- [ ] `next_steps` updated: M41 done entry added; M42 FUTURE entry added
- [ ] description updated: version 6.6.0 → 6.7.0, command count updated

### Audit carryover closure
- [ ] All 13 carryover entries in `agent/memory/audit-carryovers.md` set `status: fixed`, `fix_applied_date: 2026-05-11`
- [ ] `verified_in_audit: 14` (audit-014 was the source)

### Route stamping
- [ ] All route files 022–035 get `completed: 2026-05-11`

## Implementation Notes

Run wrap-up steps in order: routing.yml → domain.yml → architecture.md → version bump → CHANGELOG → progress.yaml → carryover closure → route stamps. Use `git add -f` for gitignored files (milestones/, routing/tasks/, progress.yaml, memory/).
