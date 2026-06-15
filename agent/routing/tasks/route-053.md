---
id: route-053
title: R6 Phase 1 — Add skills_catalog to taxonomy.yml
task_type: yaml-schema
milestone: M44
complexity: low
executor: deepseek-v4-flash
context_required: [agent/routing/taxonomy.yml]
design_reference: [Skills → @-Mention Pattern](../design/local.skills-at-mention-pattern.md)
files_affected: [agent/routing/taxonomy.yml]
tokens_est: 1500
created: 2026-06-03
completed: 2026-06-03
depends_on: []
---

# R6 Phase 1: Add skills_catalog to taxonomy.yml

Add `skills_catalog` section and `mention` field to each task_type in taxonomy.yml.

## Acceptance Criteria

- [ ] `skills_catalog` section added with all 7 skills
- [ ] Each skill has: name, mention (`@{name}`), file path, description, triggers list
- [ ] Each task_type has `mention` field referencing its skill
- [ ] Existing `skill` field preserved (backward compat)
