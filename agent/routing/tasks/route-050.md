---
id: route-050
title: R6 — Convert Skills to @-Mention Pattern
task_type: architecture-design
milestone: M44
complexity: medium
executor: deepseek-v4-pro
context_required: [agent/skills/*.md, agent/routing/taxonomy.yml, copilot-instructions.md]
design_reference: [Skills → @-Mention Pattern](../design/local.skills-at-mention-pattern.md)
files_affected: [agent/routing/taxonomy.yml, .github/copilot-instructions.md, CLAUDE.md, AGENT.md, agent/skills/*.md]
tokens_est: 6000
created: 2026-06-03
completed:
delegated_to: [route-053, route-054, route-055]
---

# R6: Skills → @-Mention Pattern

**Source**: audit-022, ChoreHive feedback R6 (P2)

## Problem

7 skill files exist (commands, scripts, schemas, testing, typescript, crosscut, upstream-sync). 0 loads across 14 sessions. Domain knowledge lives in copilot-instructions.md, not skills. Skills are never read because they're auto-loaded by a protocol that agents skip.

## Solution

Convert skills from auto-load to explicit @-mention invocation:
- `@backend` → load `agent/skills/backend.md`
- `@testing` → load `agent/skills/testing.md`
- taxonomy.yml becomes a catalog (discoverable reference), not a routing table
- Skills are NOT auto-loaded; invoked explicitly when user needs specialized context

## Acceptance Criteria

- [ ] Each skill file has an @-mention trigger defined
- [ ] Agent reads skill file when user types `@{skill-name}`
- [ ] taxonomy.yml converted from routing table to catalog
- [ ] Auto-load removed from context protocol (full mode)
- [ ] Backward compatible: existing skill files preserved
