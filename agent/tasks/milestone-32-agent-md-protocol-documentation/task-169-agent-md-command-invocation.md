---
id: task-169
milestone: M32
title: Add Command Invocation section to AGENT.md
status: completed
priority: 3
complexity: low
estimated_hours: 1.5
created: 2026-05-05
started: 2026-05-05T00:00:00Z
completed: 2026-05-05
---

<!-- @acp.meta.task
topic: add, command, invocation, section, to, agentmd
description: Add Command Invocation section to AGENT.md
milestone: M32
status: completed
updated: 2026-05-05
@acp.meta.end -->


## Objective

Add a "Command Invocation" section to `AGENT.md` with the complete naming table (6 rows), the invocation chain diagram, and porting rules for upstream content.

## Context

The critical naming duality (`/acp-` vs `@acp.`) and the triple-file architecture are documented only in ADR-4 and ADR-6 — two files agents don't load by default. Lessons.md has a high-priority entry about the `@acp-foo` confusion (dash instead of dot after `@`). A section in AGENT.md makes this discoverable to agents and contributors at session start.

This is the most important undocumented convention in the codebase.

## Implementation

Add a "Command Invocation" section to AGENT.md:

```markdown
## Command Invocation

Every ACP command has **three files** (all must exist for each command):

| Surface | File location | Format | Example |
|---|---|---|---|
| Command directive | `agent/commands/acp.NAME.md` | `acp.NAME.md` (dot) | `acp.plan.md` |
| VS Code slash cmd | `.github/prompts/acp-NAME.prompt.md` | `acp-NAME.prompt.md` (hyphen) | `acp-plan.prompt.md` |
| opencode cmd | `.opencode/commands/acp-NAME.md` | `acp-NAME.md` (hyphen) | `acp-plan.md` |
| User invocation | `/acp-NAME` in chat | slash + hyphen | `/acp-plan` |
| Body references | `/acp-NAME` in command docs | slash + hyphen | `/acp-plan` |

**Invocation chain**:
```
user types /acp-plan
  → IDE reads .github/prompts/acp-plan.prompt.md (or .opencode/commands/acp-plan.md)
    → prompt says "Read and execute agent/commands/acp.plan.md"
      → agent executes acp.plan.md steps
```

**Critical rules**:
- ✅ `/acp-plan` — correct user invocation  
- ✅ `@acp.plan` — **ONLY** valid when meaning "dot-notation filename `acp.plan.md`"  
- ❌ `@acp-plan` — NEVER valid (dash after @ is wrong)  
- ❌ `@acp plan` — NEVER valid (space is wrong)  

**Porting rule**: Upstream uses `@acp.<name>` as invocation. When porting: replace `@acp.<name>` → `/acp-<name>` everywhere.

See ADR-4 (naming convention) and ADR-6 (triple-file architecture).
```

## Expected Output

### Files Updated
- `AGENT.md`

## Verification
- [ ] AGENT.md has a "Command Invocation" section
- [ ] Section has the 5-column naming table
- [ ] Invocation chain is shown
- [ ] The 4 critical rules (2 correct, 2 wrong) are listed
- [ ] Porting rule for `@acp.<name>` → `/acp-<name>` is present
- [ ] Section is ≤35 lines

## User-Observable Acceptance
A developer or agent reading AGENT.md can answer: (a) what files comprise a command, (b) how to invoke it correctly, (c) what NOT to write, (d) how to port upstream content. No need to read ADRs for this core knowledge.
