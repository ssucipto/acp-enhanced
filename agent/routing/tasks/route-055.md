---
id: route-055
title: R6 Phase 4+5 — Skill Headers + AGENT.md Docs
task_type: docs-update
milestone: M44
complexity: low
executor: deepseek-v4-flash
context_required: [agent/skills/*.md, AGENT.md]
design_reference: [Skills → @-Mention Pattern](../design/local.skills-at-mention-pattern.md)
files_affected: [agent/skills/commands.md, agent/skills/scripts.md, agent/skills/schemas.md, agent/skills/testing.md, agent/skills/typescript.md, agent/skills/crosscut.md, agent/skills/upstream-sync.md, AGENT.md]
tokens_est: 2000
created: 2026-06-03
completed: 2026-06-03
depends_on: [route-053]
---

# R6 Phases 4+5: Skill Headers + Documentation

Add `@{mention}` trigger to each skill file header. Update AGENT.md.

## Acceptance Criteria

- [ ] All 7 skill files have `@{mention}` in header: `**Mention**: @{commands}`
- [ ] AGENT.md updated: "Skills" section documents @-mention invocation
- [ ] AGENT.md updated: list of 7 @-mentions with descriptions
- [ ] CHANGELOG entry for @-mention pattern
