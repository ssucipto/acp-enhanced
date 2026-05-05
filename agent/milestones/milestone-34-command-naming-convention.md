# Milestone 34: Command Naming Convention Formalization

<!-- @acp.meta.milestone
topic: naming, convention, documentation, patterns, lessons
description: Create the definitive command naming convention pattern document and update skills/lessons to reference it.
tasks: task-176..task-177
status: draft
updated: 2026-05-05
@acp.meta.end -->

**Goal**: Create `agent/patterns/local.command-naming-convention.md` as the single authoritative reference for ACP Enhanced's `/acp-` vs `@acp.` duality, the triple-file architecture, and porting rules — so contributors and agents never introduce naming inconsistencies again.  
**Duration**: 0.5 day  

---

## Overview

ACP Enhanced has a well-established command naming convention documented in ADR-4 and partially in `agent/skills/commands.md`. However:
- `lessons.md` has a high-priority entry about `@acp-foo` vs `@acp.foo` confusion caused by a commands skill file using a dash instead of a dot
- The full naming table (file, VS Code slash, opencode slash, agent invocation) exists only in ADR-4 prose, not as a scannable reference
- The triple-file architecture (command doc + `.github/prompts/` + `.opencode/commands/`) and porting rules are in ADR-6 but not indexed anywhere agents naturally scan

This milestone creates a canonical pattern document and wires it into both lessons.md and commands.md.

---

## Deliverables

### 1. Naming Convention Pattern Document
- `agent/patterns/local.command-naming-convention.md` — complete naming table, invocation chain, triple-file architecture diagram, porting rules for upstream content

### 2. Skills and Lessons Update
- `agent/skills/commands.md` — add link to naming convention pattern at top of file
- `agent/memory/lessons.md` — update the existing high-priority `@acp-foo` vs `@acp.foo` entry to reference the pattern doc

---

## Success Criteria

- [ ] Pattern doc exists at `agent/patterns/local.command-naming-convention.md`
- [ ] Pattern doc includes the full naming table (6 rows: file, .github/prompts/, .opencode/commands/, user invocation VS Code, user invocation opencode, agent invocation in text)
- [ ] Pattern doc includes the invocation chain (user → IDE reads prompt → prompt delegates to command doc)
- [ ] Pattern doc includes porting rules (`@acp.foo` → `/acp-foo`, `@acp-foo` never valid)
- [ ] `agent/skills/commands.md` references the pattern doc
- [ ] lessons.md entry updated to reference the pattern doc

---

## Key Files to Create/Update

```
agent/
├── patterns/
│   └── local.command-naming-convention.md   (new)
├── skills/
│   └── commands.md                           (update — add reference)
└── memory/
    └── lessons.md                            (update — existing entry)
```

---

## Tasks

1. [task-176-naming-convention-pattern.md](../tasks/milestone-34-command-naming-convention/task-176-naming-convention-pattern.md) — Create local.command-naming-convention.md pattern document
2. [task-177-update-skills-and-lessons.md](../tasks/milestone-34-command-naming-convention/task-177-update-skills-and-lessons.md) — Update commands.md skill and lessons.md to reference the pattern

---

**Next Milestone**: [milestone-35-acp-validate-ts-enhancement.md](milestone-35-acp-validate-ts-enhancement.md)  
**Blockers**: None — pure documentation  
**Notes**: Can run concurrently with M29–M32. Small but high-leverage: prevents recurrence of the high-priority lesson in lessons.md.
