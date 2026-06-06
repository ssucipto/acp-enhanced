# ACP Enhanced — Cursor Integration

How to invoke ACP commands in Cursor, and how slash commands stay in sync with `agent/commands/`.

---

## Invocation

| Method | Example | Status |
|--------|---------|--------|
| Slash command | `/acp-init` | ✅ Preferred (auto-generated during install) |
| @-mention alias | `@acp-init` | ✅ Works (legacy fallback) |
| File reference | `@agent/commands/acp.init.md` | ✅ Works (direct source) |

---

## How Slash Commands Are Generated

`agent/scripts/acp.cursor-commands-sync.sh` reads every `agent/commands/acp.*.md`
and `git.*.md` and writes matching `.cursor/commands/<slash-name>.md` wrappers.

| Source (canonical) | Cursor slash command |
|--------------------|----------------------|
| `agent/commands/acp.init.md` | `/acp-init` |
| `agent/commands/acp.plan.md` | `/acp-plan` |
| `agent/commands/git.commit.md` | `/git-commit` |

**Naming rule**: dots in source filenames become hyphens in slash names (`acp.design-spec` → `/acp-design-spec`).

---

## How to use in Cursor

1. Open **Agent** or **Chat**.
2. Type `/` — Cursor lists project commands from `.cursor/commands/`.
3. Select e.g. `/acp-init` or type `/acp-init` directly.
4. Add arguments in the same message: `/acp-plan milestone 1 auth migration`.

### Invocation aliases (all equivalent)

The agent treats these the same way:

- `/acp-init` — **preferred** (native Cursor slash command)
- `@acp-init` — legacy / workaround when slash picker is unavailable
- `@agent/commands/acp.init.md` — direct source reference

All three must **execute** the command, not only read it.

---

## Agent behavior (`.cursor/rules/`)

Rule `acp-slash-commands.mdc` is always applied. It tells Cursor agents to:

1. Prefer `/acp-*` as the canonical form.
2. Map `@acp-*` and `@agent/commands/acp.*.md` to the same execution path.
3. Always load and run the full steps from `agent/commands/`.

---

## When to re-sync

Re-run the sync script after:

- `acp.install.sh` or `acp.version-update.sh` (install/update scripts run sync automatically)
- Adding a new command under `agent/commands/`
- Changing a command **Purpose** line (updates the slash-command description in Cursor's picker)

```bash
./agent/scripts/acp.cursor-commands-sync.sh
```

---

## Troubleshooting

- **`/` menu stale**: Reload Cursor window (`Cmd+Shift+P` → "Developer: Reload Window")
- **Commands missing after update**: Re-run sync script manually
- **Wrapper content outdated**: Sync script regenerates from canonical sources
