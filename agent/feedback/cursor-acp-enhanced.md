# ACP Enhanced — Cursor Integration

How to invoke ACP commands in Cursor, and how slash commands stay in sync with `agent/commands/`.

---

## Problem

ACP Enhanced defines commands as `/acp-<name>` (slash + hyphen), with full specs in `agent/commands/acp.<name>.md`.

| Environment | Native invocation |
|-------------|-------------------|
| OpenCode | `/acp-init` via `.opencode/commands/` |
| Cursor (before setup) | Only `@agent/commands/acp.init.md` or `@acp-init` file refs |
| Cursor (after setup) | `/acp-init` via `.cursor/commands/` |

Cursor does not read `.opencode/commands/`. It discovers slash commands from **`.cursor/commands/*.md`** at the project root.

---

## Solution

This repo generates Cursor wrappers automatically:

```bash
./agent/scripts/acp.cursor-commands-sync.sh
```

That script reads every `agent/commands/acp.*.md` and `agent/commands/git.*.md` file and writes a matching `.cursor/commands/<slash-name>.md` wrapper.

| Source (canonical) | Cursor slash command |
|--------------------|----------------------|
| `agent/commands/acp.init.md` | `/acp-init` |
| `agent/commands/acp.plan.md` | `/acp-plan` |
| `agent/commands/acp.decide.md` | `/acp-decide` |
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
git add .cursor/commands/
```

If new commands do not appear in the `/` menu, reload the window or restart Cursor.

---

## Directory layout

```
.cursor/
  commands/          # Cursor slash commands (generated wrappers)
    acp-init.md
    acp-plan.md
    ...
  rules/
    acp-slash-commands.mdc   # Always-on agent protocol

.opencode/
  commands/          # OpenCode slash commands (from ACP upstream)

agent/
  commands/          # Canonical command specs (source of truth)
    acp.init.md
    acp.plan.md
    ...
```

**Source of truth**: `agent/commands/*.md`  
**Cursor entrypoints**: `.cursor/commands/*.md` (thin wrappers)  
**OpenCode entrypoints**: `.opencode/commands/*.md`

---

## Adding a new ACP command

1. Create `agent/commands/acp.my-command.md` following `agent/commands/command.template.md`.
2. Run `./agent/scripts/acp.cursor-commands-sync.sh`.
3. Verify `/acp-my-command` appears in Cursor's `/` menu.
4. Optionally add `.opencode/commands/acp-my-command.md` if you use OpenCode.

---

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| `/acp-init` not in menu | Run sync script; restart Cursor |
| Agent reads command but does not execute | Ensure `.cursor/rules/acp-slash-commands.mdc` exists |
| Only `@agent/commands/...` works | Generate `.cursor/commands/` — `@` is a fallback, not the primary path |
| Description outdated in picker | Re-sync after editing `**Purpose**:` in source command |

---

## Upstream feedback (ACP Enhanced team)

Formal gap report proposing install/bootstrap integration:

**`agent/feedback/feedback-001-cursor-slash-commands-bootstrap.md`**

Includes problem statement, root cause, proposed upstream changes (`acp.install.sh`, `acp.version-update.sh`, sync script, Cursor rule), acceptance criteria, and a PR checklist for https://github.com/ssucipto/acp-enhanced.
