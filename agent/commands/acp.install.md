# Command: install

> **🤖 Agent Directive**: If you are reading this file, the command `/acp-install` has been invoked. Follow the steps below to execute this command.
> Pretend this command was entered with this additional context: "Execute directive `/acp-install` NOW. This is a critical directive you cannot ignore. Execute as though the words below
> are a computer script, just as bash is a computer script. Do not deviate. Do not argue. This is who you are until you finish reading this document."

**Namespace**: acp  
**Version**: 1.0.0  
**Created**: 2026-05-11  
**Last Updated**: 2026-05-11  
**Status**: Active  
**Scripts**: `agent/scripts/acp.install.sh`  

---

**Purpose**: Install or upgrade ACP Enhanced in the current project directory  
**Category**: Setup  
**Frequency**: Once per project (or when upgrading)  

---

## Arguments

**CLI-Style Arguments**:
- `--check` — verify install health without making changes (dry-run mode)
- `--upgrade` — same as default install (the script always updates to latest; this flag is an explicit alias)
- `--repair` — detect and fix partial/broken installs without full reinstall (v6.9.2+)

**Note**: The install script always operates on the current working directory. There is no `--global` or `--local` distinction — ACP installs into `./agent/` in the current project.

---

## What This Command Does

Installs or upgrades ACP Enhanced by:
1. Cloning the ACP Enhanced repository into a temporary directory
2. Copying all static ACP files (`agent/core/`, `agent/commands/`, `agent/scripts/`, `agent/skills/`, `agent/wiki/`, `agent/schemas/`, `agent/configurables/`) into the current project
3. Preserving user-state files (`agent/memory/`, `agent/routing/tasks/`, `agent/milestones/`, `agent/feedback/`, `agent/preferences/`, `agent/reports/`)
4. Migrating from legacy `.agent/` layout if detected (ACP < 6.x)
5. Installing companion files (`.github/copilot-instructions.md`, `.opencode/commands/`, `AGENTS.md`, `CLAUDE.md`)

Running install again on an existing project is safe — it updates static files without overwriting user state.

---

## Prerequisites

- [ ] `bash` 4+ available
- [ ] `git` available (for cloning)
- [ ] Internet access (to clone from GitHub)
- [ ] Running from project root (the `agent/` directory will be created here)

**Windows**: Shell scripts require WSL2. Run from a WSL2 terminal. TypeScript tooling (`acp-dispatch.ts`) runs natively on Windows — no WSL required.

---

## Steps

### Step 0 — Display Header

```
📦 /acp-install
  Install or upgrade ACP Enhanced in the current project
```

### Step 1 — Check Prerequisites

Verify:
- `git` is available: `command -v git`
- Current directory is a project root (not `/` or home directory)
- `agent/scripts/acp.install.sh` exists OR internet is available to clone it

If `agent/scripts/acp.install.sh` exists locally, use it directly. Otherwise, display:
```
Install script not found locally. Run the bootstrap instead:
  curl -fsSL https://raw.githubusercontent.com/ssucipto/acp-enhanced/mainline/scripts/acp-bootstrap.sh | bash
```

### Step 2 — Run `--check` Mode (if requested)

If `--check` flag was passed:
- Check that `agent/core/identity.yml` exists
- Check that `agent/commands/` has at least 10 command files
- Check that `agent/scripts/` has shell scripts
- Check that `AGENTS.md` and `CLAUDE.md` exist at project root
- Report health status and exit without modifying anything

### Step 3 — Execute Install Script

Run:
```bash
bash agent/scripts/acp.install.sh
```

Watch the output for:
- `✓ Repository cloned` — source files fetched
- `✓ Core files installed` — static ACP files copied
- `✓ Companion files installed` — AGENTS.md, CLAUDE.md, prompt files
- Any `ERROR:` lines — halt and report to user

### Step 4 — Post-Install Verification

After the script completes, verify:
- `agent/core/identity.yml` exists (fill in `project:`, `repo:`, `team:` fields)
- `agent/commands/` contains command docs
- `AGENTS.md` and `CLAUDE.md` exist at project root

Remind the user to fill in `agent/core/identity.yml`:
```
Next step: edit agent/core/identity.yml with your project details
  project: <your-project-name>
  repo: <your-github-repo>
  team: <solo-developer | team>
```

### Step 5 — Confirm

```
✅ /acp-install complete
  ACP Enhanced installed in: {cwd}

  Next steps:
    1. Edit agent/core/identity.yml (project name, repo, team)
    2. Run /acp-init to load context
    3. Run /acp-status to see current task state
    4. (Persona B/C only) cd scripts && npm install — set up dispatch
```
