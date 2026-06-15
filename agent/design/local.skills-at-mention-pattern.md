# Skills → @-Mention Pattern

<!-- @acp.meta.design
topic: skills, -mention, pattern
description: Skills → @-Mention Pattern
status: draft
updated: 2026-06-15
@acp.meta.end -->

**Design**: DR-001  
**Created**: 2026-06-03  
**Last Updated**: 2026-06-15  
**Namespace**: local  
**Source**: audit-022 R6, ChoreHive feedback  

---

## Problem

ACP Enhanced has 7 skill files (`commands.md`, `scripts.md`, `schemas.md`, `testing.md`, `typescript.md`, `crosscut.md`, `upstream-sync.md`). They are designed to be auto-loaded by task_type in the full context-loading protocol.

**In 14 sessions of production use, skill files were loaded 0 times.** Why:

1. **Agents skip the full protocol** — light mode is the default, and light mode doesn't load skills
2. **Even in full mode, the mapping is passive** — agents must read taxonomy.yml, match task_type to skill, then load it. This is overhead for no perceived benefit.
3. **Domain knowledge lives elsewhere** — in ChoreHive, `copilot-instructions.md` (160 lines) contains actively maintained domain knowledge that's auto-attached. Skills are a second, unmaintained copy.
4. **Skills are invisible** — users don't know they exist. The only way to discover them is to read taxonomy.yml.

## Solution

Convert skills from **auto-load** to **explicit @-mention invocation**. The user types `@{skill-name}` in chat, and the agent reads the corresponding skill file.

### How It Works

```
User: "@{testing} add E2E tests for the auth endpoints"
       ↓
Agent detects @{testing} mention
       ↓
Agent reads agent/skills/testing.md
       ↓
Agent applies testing conventions + executes the task
```

### @-Mention Triggers

| Mention | Skill File | When to Use |
|---------|-----------|-------------|
| `@{commands}` | `skills/commands.md` | Writing or updating command docs |
| `@{scripts}` | `skills/scripts.md` | Writing bash shell scripts |
| `@{schemas}` | `skills/schemas.md` | Designing YAML schemas |
| `@{testing}` | `skills/testing.md` | Writing E2E or unit tests |
| `@{typescript}` | `skills/typescript.md` | Working on TypeScript tooling |
| `@{crosscut}` | `skills/crosscut.md` | Cross-cutting docs, README, AGENT.md |
| `@{upstream}` | `skills/upstream-sync.md` | Checking upstream parity |

## Architecture Changes

### 1. taxonomy.yml — Convert to Catalog

Before (routing table):
```yaml
task_types:
  command-doc-write:
    executor: deepseek-v4-pro
    skill: commands
```

After (catalog + routing):
```yaml
task_types:
  command-doc-write:
    executor: deepseek-v4-pro
    skill: commands        # Keep for backward compat
    mention: "@{commands}"  # NEW: @-mention trigger

skills_catalog:
  - name: commands
    mention: "@{commands}"
    file: agent/skills/commands.md
    description: Command doc writing conventions
    triggers: [command-doc-write, command-doc-update]
```

### 2. Context Protocol — Remove Auto-Load

In full mode Step 3, replace:
```
### Step 3 — Load Skill (one file only)
Based on task_type, load EXACTLY ONE skill file:
```

With:
```
### Step 3 — Skills are Now @-Mention Invoked
Skill files are no longer auto-loaded. Instead, they are invoked explicitly:
- User types `@{skill-name}` in chat
- Agent reads `agent/skills/{skill-name}.md`
- Agent applies conventions from the skill file

> See `agent/core/routing.yml → skills_catalog` for the full list.
```

### 3. copilot-instructions.md — Add @-Mention Detection

Add to the protocol:
```markdown
### @-Mention Skill Invocation

When the user types `@{skill-name}` in a message:
1. Match against `agent/core/routing.yml → skills_catalog`
2. Read the corresponding `agent/skills/{skill-name}.md`
3. Apply conventions from the skill file to the task
4. Brief acknowledgement: `[@commands] Loaded command doc conventions.`
```

## Implementation Plan

| Phase | Task | Files |
|-------|------|-------|
| 1 | Add `skills_catalog` + `mention` fields to taxonomy.yml | `agent/routing/taxonomy.yml` |
| 2 | Remove auto-load from context protocol (full mode Step 3) | `.github/copilot-instructions.md`, `CLAUDE.md` |
| 3 | Add @-mention detection to agent protocol | `.github/copilot-instructions.md`, `CLAUDE.md` |
| 4 | Add `@{mention}` to each skill file header | `agent/skills/*.md` (7 files) |
| 5 | Update AGENT.md documentation | `AGENT.md` |

## Trade-offs

| Pro | Con |
|-----|-----|
| Skills become visible — users discover them via `@{` autocomplete | Skills no longer auto-loaded; user must remember to invoke |
| No protocol overhead — skills loaded only when needed | New users may not know @-mentions exist |
| Aligns with LangChain Interpreters pattern (May 2026) | Existing taxonomy.yml skill mappings become redundant |
| Domain knowledge stays in one place | Migration needed for projects relying on auto-load |

## Key Design Decisions

| Decision | Rationale |
|----------|-----------|
| Keep taxonomy.yml skill field as backward compat | Existing dispatch logic references it |
| Use `@{name}` not `/skill-name` | @-mentions are chat-native; slashes are command-native |
| One skill per invocation | Skills are domain-specific; mixing them creates context pollution |
| Brief acknowledgement format `[@skill]` | Minimal token overhead; user knows skill was loaded |

## Acceptance Criteria

- [ ] All 7 skill files have `@{mention}` trigger in their header
- [ ] taxonomy.yml has `skills_catalog` with mention mappings
- [ ] Context protocol Step 3 replaced with @-mention documentation
- [ ] Agent detects and responds to `@{skill-name}` in chat
- [ ] Backward compatible: taxonomy.yml skill field preserved
