---
id: route-039
title: M42 — Add 9 missing taxonomy entries + getSkillFile() mapping (ROUTING-001 + ROUTING-002)
task_type: yaml-schema
milestone: M42
complexity: medium
executor: copilot
context_required:
  - agent/routing/taxonomy.yml
  - scripts/acp-dispatch.ts
  - agent/memory/sessions.md
  - agent/reports/audit-015-m41-verification-and-final-audit-assessment.md
files_affected:
  - agent/routing/taxonomy.yml
  - scripts/acp-dispatch.ts
tokens_est: 7000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-05-11
completed: 2026-05-11
override_reason:
---

## Task Description

Two closely related routing improvements bundled into one route:

**ROUTING-001**: Add 9 common task types to `agent/routing/taxonomy.yml`. These types occur regularly in sessions history (M29–M41) but are absent from the taxonomy — Persona B/C dispatch silently falls back to the wrong executor and context set.

**ROUTING-002**: Update `getSkillFile()` in `scripts/acp-dispatch.ts` to include explicit mapping for these task types so the crosscut fallthrough is intentional and documented, not accidental.

## Context

From audit-015:
- **ROUTING-001**: `9 common task types missing (wiki-update, memory-write, changelog-update, progress-update, adr-write, audit-run, milestone-create, route-create, upstream-parity-check)`
- **ROUTING-002**: `getSkillFile() has no explicit mapping for 7 of 9 new task types — silent crosscut fallthrough`

## Acceptance Criteria

### ROUTING-001 — 9 new taxonomy entries

- [ ] Read current `agent/routing/taxonomy.yml` to understand exact entry format before adding
- [ ] Add the following 9 entries, following the exact YAML field order used in existing entries:

  ```yaml
  - task_type: wiki-update
    description: Updates to agent/wiki/ files (domain.yml, architecture.md, glossary)
    executor: deepseek-v4-flash
    model: deepseek-v4-flash
    context_required:
      - agent/wiki/domain.yml
      - agent/wiki/architecture.md
    skill: crosscut
    tokens_est: 4000
    complexity: low

  - task_type: memory-write
    description: Writing or updating memory layer files (sessions.md, lessons.md, patterns.md)
    executor: copilot
    model: github-copilot
    context_required:
      - agent/memory/sessions.md
      - agent/memory/lessons.md
    skill: crosscut
    tokens_est: 2000
    complexity: low

  - task_type: changelog-update
    description: Writing version entries to CHANGELOG.md
    executor: deepseek-v4-flash
    model: deepseek-v4-flash
    context_required:
      - CHANGELOG.md
    skill: crosscut
    tokens_est: 2000
    complexity: low

  - task_type: progress-update
    description: Updating agent/progress.yaml milestone and task status
    executor: deepseek-v4-flash
    model: deepseek-v4-flash
    context_required:
      - agent/progress.yaml
    skill: crosscut
    tokens_est: 3000
    complexity: low

  - task_type: adr-write
    description: Writing architectural decision records to agent/memory/decisions.md
    executor: copilot
    model: github-copilot
    context_required:
      - agent/memory/decisions.md
    skill: crosscut
    tokens_est: 3000
    complexity: low

  - task_type: audit-run
    description: Running /acp-audit against a milestone or codebase
    executor: copilot
    model: github-copilot
    context_required:
      - agent/commands/acp.audit.md
      - agent/memory/audit-carryovers.md
    skill: crosscut
    tokens_est: 8000
    complexity: high

  - task_type: milestone-create
    description: Creating milestone planning documents in agent/milestones/
    executor: copilot
    model: github-copilot
    context_required:
      - agent/milestones/milestone-1-{title}.template.md
      - agent/progress.yaml
    skill: crosscut
    tokens_est: 5000
    complexity: medium

  - task_type: route-create
    description: Creating routing task files in agent/routing/tasks/
    executor: copilot
    model: github-copilot
    context_required:
      - agent/routing/taxonomy.yml
      - agent/routing/rules.md
    skill: crosscut
    tokens_est: 3000
    complexity: low

  - task_type: upstream-parity-check
    description: Checking fork divergence against upstream prmichaelsen/agent-context-protocol
    executor: deepseek-v4-flash
    model: deepseek-v4-flash
    context_required:
      - agent/wiki/architecture.md
      - agent/patterns/local.upstream-integration-runbook.md
    skill: crosscut
    tokens_est: 6000
    complexity: medium
  ```

- [ ] Total taxonomy entries after this route: 25 (16 existing + 9 new)
- [ ] Also add `last_updated: 2026-05-11` to taxonomy.yml header block (needed for route-041 staleness check)

### ROUTING-002 — getSkillFile() explicit mapping

- [ ] Locate `getSkillFile()` function in `scripts/acp-dispatch.ts`
- [ ] Read its current implementation before modifying
- [ ] Add explicit `crosscutTypes` array that includes all task types that map to `crosscut.md`:
  ```typescript
  const crosscutTypes = [
    'wiki-update',
    'memory-write',
    'changelog-update',
    'progress-update',
    'adr-write',
    'audit-run',
    'milestone-create',
    'route-create',
    'upstream-parity-check',
    'documentation-sync',
    'crosscut',
  ];
  if (crosscutTypes.includes(taskType)) return 'agent/skills/crosscut.md';
  ```
- [ ] Add this check AFTER the explicit mappings for typescript-feature, bash-scripting, yaml-schema, etc. (preserve existing behaviour)
- [ ] Verify: all existing task_types still resolve to their correct skill files
- [ ] Verify: the 9 new task types now resolve to `crosscut.md` explicitly (not via unknown-type fallback)

## Implementation Notes

Read `taxonomy.yml` carefully before writing entries — match existing indentation, field order, and quoting style exactly. The `last_updated:` header field is needed by route-041; add it in this route to avoid the need to revisit the file. After adding entries, verify total count is 25 with a quick grep count.
