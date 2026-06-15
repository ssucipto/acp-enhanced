# Milestone 17: Artifact Commands System

**Goal**: Introduce three artifact commands for long-lived reference material — research, glossary, and reference — so agents can create, update, and link structured knowledge artifacts that persist across sessions.  
**Duration**: ~1 week (estimated 5–8 agent-hours across 5 tasks)  
**Dependencies**: M16 (Package System) — completed ✅  
**Status**: Completed ✅  
**Completed**: 2026-03-17  
**Tasks**: task-115 through task-119 (5 tasks)

---

## Overview

Prior to M17, all project documentation was either stored in `agent/progress.yaml` (structured tracking) or ad-hoc markdown files with no standardized schema or lifecycle. Long-running research, domain glossaries, and reference material accumulated in task notes and session memory with no durable home.

M17 introduced three first-class artifact commands — `@acp.artifact-research`, `@acp.artifact-glossary`, and `@acp.artifact-reference` — each backed by a template and a lifecycle protocol (create, update, link, retire). Artifacts integrate with `@acp.sync` (to verify artifact freshness) and `@acp.validate` (to catch orphaned or stale artifacts).

---

## Tasks

| Task | Name | Status |
|------|------|--------|
| task-115 | Design Artifact Schema and Templates | ✅ Completed |
| task-116 | Implement @acp.artifact-research Command | ✅ Completed |
| task-117 | Implement @acp.artifact-glossary Command | ✅ Completed |
| task-118 | Implement @acp.artifact-reference Command | ✅ Completed |
| task-119 | Integrate Artifacts with @acp.sync and @acp.validate | ✅ Completed |

---

## Deliverables

### Command Files
- [`agent/commands/acp.artifact-research.md`](../commands/acp.artifact-research.md) — create and update research artifacts
- [`agent/commands/acp.artifact-glossary.md`](../commands/acp.artifact-glossary.md) — create and update domain glossaries
- [`agent/commands/acp.artifact-reference.md`](../commands/acp.artifact-reference.md) — create and update reference documents

### Templates
- [`agent/artifacts/research.template.md`](../artifacts/research.template.md) — research artifact template
- [`agent/artifacts/glossary.template.md`](../artifacts/glossary.template.md) — glossary artifact template
- [`agent/artifacts/reference.template.md`](../artifacts/reference.template.md) — reference artifact template

### Integration
- `@acp.sync` — checks artifact freshness (warns on artifacts not updated in >30 days)
- `@acp.validate` — detects orphaned artifacts (not linked from any task or milestone)

---

## Design

**Design Document**: [`agent/design/local.artifact-commands-system.md`](../design/local.artifact-commands-system.md)

### Core Concepts

**Artifact vs. Task Note**: An artifact is a long-lived, structured knowledge document that outlives the task that created it. A task note is ephemeral — captured in `progress.yaml` and recycled at the end of the task. Artifacts are stored in `agent/artifacts/` with their own template schema.

**Three Artifact Types**:
- **Research** — captures exploratory findings, external references, and analysis results. Use when investigating a new library, protocol, or technique.
- **Glossary** — defines domain-specific terms shared across the team and agents. Reduces ambiguity in task descriptions and design docs.
- **Reference** — tabular or list-format quick-reference for recurring lookups (e.g., API endpoints, config keys, command flags).

**Lifecycle**:
1. `@acp.artifact-research` / `@acp.artifact-glossary` / `@acp.artifact-reference` — creates artifact from template
2. Agent updates artifact as work progresses (same command, update mode)
3. `@acp.sync` warns if artifact is stale
4. `@acp.validate` detects orphaned artifacts
5. Artifact is retired (archived) when it becomes obsolete

### Key Design Decisions

- **Flat storage** in `agent/artifacts/` (not nested by type) — consistent with ACP flat-directory conventions
- **Template-based creation** — all three types use a YAML frontmatter + markdown body schema
- **Linkable** — artifacts are referenced from task docs and milestone docs by relative path
- **No auto-expiry** — artifacts do not auto-delete; `@acp.sync` warns, human decides

---

## Success Criteria

- [x] Three artifact command files exist and are loadable via `@acp.*` invocation
- [x] Three artifact templates exist in `agent/artifacts/`
- [x] `@acp.sync` checks for stale artifacts (not updated in >30 days)
- [x] `@acp.validate` detects orphaned artifacts (not linked from task/milestone)
- [x] At least one artifact created during M17 as a smoke test
- [x] Artifact commands documented in AGENT.md Core Commands section

---

## Notes

- M17 was completed 2026-03-17. This milestone document was created retroactively during M24
  (AGENT.md Completeness) when the milestone-17 file was found to be missing.
- The design document at `agent/design/local.artifact-commands-system.md` contains the original
  specification and was used as the source of truth for this retroactive doc.
