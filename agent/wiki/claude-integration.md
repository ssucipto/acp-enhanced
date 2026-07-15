# ACP Enhanced — Claude Code Integration

How to invoke ACP commands in Claude Code, and how slash commands stay in sync with `agent/commands/`.

---

## Invocation

| Method | Example | Status |
|--------|---------|--------|
| Slash command | `/acp-init` | ✅ Preferred (auto-generated during install) |
| @-mention alias | `@acp-init` | ✅ Works (legacy fallback) |
| File reference | `@agent/commands/acp.init.md` | ✅ Works (direct source) |

---

## How Slash Commands Are Generated

`agent/scripts/acp.claude-commands-sync.sh` reads every `agent/commands/acp.*.md`
and `git.*.md` and writes matching `.claude/commands/<slash-name>.md` wrappers —
Claude Code's native project-level custom slash command format.

| Source (canonical) | Claude Code slash command |
|--------------------|----------------------------|
| `agent/commands/acp.init.md` | `/acp-init` |
| `agent/commands/acp.plan.md` | `/acp-plan` |
| `agent/commands/git.commit.md` | `/git-commit` |

**Naming rule**: dots in source filenames become hyphens in slash names (`acp.design-spec` → `/acp-design-spec`).

---

## How to use in Claude Code

1. Open a Claude Code session in this project.
2. Type `/` — Claude Code lists project commands from `.claude/commands/`.
3. Select e.g. `/acp-init` or type `/acp-init` directly.
4. Add arguments in the same message: `/acp-plan milestone 1 auth migration`.

### Invocation aliases (all equivalent)

The agent treats these the same way:

- `/acp-init` — **preferred** (native Claude Code slash command)
- `@acp-init` — legacy / workaround when the slash picker is unavailable
- `@agent/commands/acp.init.md` — direct source reference

All three must **execute** the command, not only read it.

---

## Agent behavior (`CLAUDE.md`)

`CLAUDE.md` is auto-loaded by Claude Code at session start and defines the Context
Loading Protocol (core → skill → memory). It intentionally does not enumerate
individual `/acp-*` commands — those are discovered natively via `.claude/commands/`,
the same way Cursor commands are discovered via `.cursor/commands/` (see
`.cursor/rules/acp-slash-commands.mdc` for the Cursor-side equivalent of this note).

---

## When to re-sync

Re-run the sync script after:

- `acp.install.sh`, `acp.version-update.sh`, or `scripts/acp-bootstrap.sh` (install/update scripts run sync automatically)
- Adding a new command under `agent/commands/`
- Changing a command **Purpose** line (updates the slash-command description in Claude Code's picker)

```bash
./agent/scripts/acp.claude-commands-sync.sh
```

---

## Troubleshooting

- **`/` menu stale**: Restart the Claude Code session
- **Commands missing after update**: Re-run sync script manually
- **Wrapper content outdated**: Sync script regenerates from canonical sources

---

## Related

- `agent/wiki/cursor-integration.md` — same pattern for Cursor
- `agent/memory/decisions.md` — ADR-6 (cross-tool parity) and its Claude Code extension
