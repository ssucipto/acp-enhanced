---
id: task-148
title: Resolve `@acp.*` vs `/acp-*` dual-syntax confusion in AGENT.md and README
milestone: M26
task_type: command-doc-update
complexity: low
executor: Persona A (Copilot)
files_affected:
  - AGENT.md
  - README.md
created: 2026-05-04
completed: 2026-05-04
---

<!-- @acp.meta.task
topic: resolve, acp, vs, acp-, dual-syntax, confusion, in, agentmd, and, readme
description: Resolve `@acp.*` vs `/acp-*` dual-syntax confusion in AGENT.md and README
milestone: M26
status: draft
updated: 2026-05-04
@acp.meta.end -->


## Objective

Add a clear "Command Invocation Styles" section to both `AGENT.md` and `README.md` that explains the two command invocation syntaxes, when to use each, and how they relate. Currently both files mix `/acp-*` and `@acp.*` notation interchangeably with no routing guidance.

## Context

Two syntaxes exist for the same commands:

| Syntax | Surface | Mechanism |
| --- | --- | --- |
| `/acp-*` | VS Code Copilot chat | `.github/prompts/*.prompt.md` registers the slash command |
| `@acp.*` | Any agent (generic) | Agent reads `agent/commands/acp.*.md` directly |

A user on Cursor, Claude Code, Windsurf, or CLI agents (no VS Code Copilot) has no way to use `/acp-*`. They must use `@acp.*` or tell their agent to read the command file. This is never explained.

The README Quick Start says "Type: **`/acp-init`**" — which only works in VS Code Copilot. A Claude Code user following the README will type `/acp-init`, get no response, and not know what to do next.

## Steps

1. **Read AGENT.md** — find the "ACP Commands" or "How to Use" section
2. **Insert a "Command Invocation Styles" subsection** (before the commands table) with content:

   ```
   ## Command Invocation Styles

   ACP commands can be invoked in two ways depending on your agent/editor:

   | Style | When to use | Example |
   |-------|-------------|---------|
   | `/acp-*` (slash command) | VS Code with GitHub Copilot | `/acp-init` |
   | `@acp.*` (dot notation) | Any agent — Cursor, Claude Code, CLI | `@acp.init` |

   Both styles execute the same command. The slash command style requires the
   `.github/prompts/` directory (created by `acp-bootstrap.sh`).
   On any other agent, tell your agent: "Read and execute agent/commands/acp.init.md"
   ```

3. **Read README.md** — find the "Usage" or "Quick Start" section where `/acp-init` is first mentioned
4. **Add a note** below the first `/acp-*` mention:
   ```
   > **Not using VS Code Copilot?** Use `@acp.init` (dot notation) or tell your agent:
   > "Read and execute `agent/commands/acp.init.md`". Both work identically.
   ```
5. **Audit the Available Commands table** in README.md — commands currently listed only as `/acp-*`. Add a column or note showing the `@acp.*` equivalent for the first 5 workflow commands as examples.
6. **Do NOT rename** any existing command files or change command invocation in any scripts — this is a documentation-only change

## Verification

- [ ] `AGENT.md` contains a "Command Invocation Styles" section explaining both syntaxes
- [ ] The section has a comparison table (slash vs dot-notation) with examples
- [ ] `README.md` Quick Start contains a note for non-VS Code users
- [ ] No command files are renamed or modified
- [ ] No scripts are modified

## Dependencies

- None — documentation-only

## Estimated Hours

1–2 hours
