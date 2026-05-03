# Command: preferences-create

> **🤖 Agent Directive**: If you are reading this file, the command `/acp-preferences-create` has been invoked. Follow the steps below to execute this command.

**Namespace**: acp  
**Version**: 1.0.0  
**Created**: 2026-05-01  
**Last Updated**: 2026-05-01  
**Status**: Active  
**Scripts**: acp.preferences.sh  
**Compatibility**: ACP 6.2.0+  

---

**Purpose**: Create preference files at a specified level (user/workspace/project) with default values from configurables  
**Category**: Setup  
**Frequency**: Once per level  

---

## What This Command Does

Creates a new preference file for a given namespace at the specified level (user-global, workspace, or project). The file is populated with all default values from the corresponding configurables, so the user has a ready-to-edit starting point.

Use this command when:
- Setting up ACP preferences for the first time
- Initializing workspace or user-level overrides
- Adding preference files for a newly installed package

Unlike `/acp-preferences-set` which modifies individual values, this command creates an entire preference file in one step.

---

## Prerequisites

- [ ] ACP installed in project
- [ ] `agent/configurables/<namespace>.configurables.yaml` exists (for ACP or installed packages)

---

## Arguments

**CLI-Style**:
- `--level <level>` — Target level: `user`, `workspace`, or `project` (default: `project`)
- `--namespace <ns>` — Namespace to initialize (default: `acp`)
- `--all` — Initialize all discovered namespaces at the specified level
- `--force` — Overwrite an existing file (default: refuse to overwrite)

**Natural Language**:
- "create user preferences" → `--level user --namespace acp`
- "init workspace preferences for mcp-auth" → `--level workspace --namespace mcp-auth-server-base`
- "set up preferences" → prompts for level and namespace

---

## Steps

### 0. Display Command Header

```
⚡ /acp-preferences-create
  Create a new preference file with defaults from configurables

  Usage:
    /acp-preferences-create                          Prompt for level and namespace
    /acp-preferences-create --level user             Create user-level acp preferences
    /acp-preferences-create --level project          Create project-level acp preferences
    /acp-preferences-create --namespace mcp-auth     Create preferences for a package

  Related:
    /acp-preferences-show      View effective preferences with sources
    /acp-preferences-set       Set individual preference values
    /acp-preferences-get       Generate resolved preference set
```

### 1. Determine Target Level

If `--level` was provided, use it. Otherwise ask:

```
Which level do you want to create preferences at?

  1. User-global   (~/.acp/agent/preferences/) — applies across all projects
  2. Workspace     (.vscode/preferences/)       — applies to this workspace only
  3. Project       (agent/preferences/)          — applies to this project (checked into git)

Enter 1, 2, or 3:
```

**Level → path mapping**:

| Level | Path |
|-------|------|
| `user` / `global` | `~/.acp/agent/preferences/<namespace>.default.yaml` |
| `workspace` | `.vscode/preferences/<namespace>.yaml` |
| `project` | `agent/preferences/<namespace>.default.yaml` |

### 2. Determine Namespace

If `--namespace` was provided, use it. If `--all` was provided, discover all namespaces from `agent/configurables/*.configurables.yaml`. Otherwise ask:

```
Which namespace?

  1. acp            (core ACP preferences)
  2. <package-name> (installed package)

Enter namespace name or number:
```

### 3. Check for Existing File

- Determine the target file path from level + namespace
- If the file already exists and `--force` was NOT provided:
  ```
  ⚠️  File already exists: agent/preferences/acp.default.yaml

  Use --force to overwrite, or run /acp-preferences-show to view current values.
  ```
  Halt without writing.

- If `--force` was provided, proceed (the existing file will be replaced).

### 4. Load Configurables

Read `agent/configurables/<namespace>.configurables.yaml`:
- Extract each preference's `id` and `default` value
- If no configurables file exists:
  ```
  ⚠️  No configurables found for namespace '<namespace>'
  Cannot create preference file without a configurables definition.

  Expected: agent/configurables/<namespace>.configurables.yaml
  ```
  Halt.

### 5. Create Preference File

- Create the target directory if it does not exist
- Write the YAML file with one key per preference (dot-path → value):

```yaml
# <Namespace> Preferences
# Level: <level>
# Created: <date>
# Source: agent/configurables/<namespace>.configurables.yaml
#
# Precedence: Project > Workspace > User > Configurables default
# Edit this file to override defaults for this level.

<namespace>:
  # ── <category> ──
  <pref.path>: <default>    # <description (truncated to 60 chars)>
  ...
```

- Ensure the file is valid YAML.

### 6. Confirm Creation

Display:

```
✅ Preferences created!

File:        agent/preferences/acp.default.yaml
Level:       Project
Namespace:   acp
Preferences: 8 defaults written

Run /acp-preferences-show to view effective preferences.
Run /acp-preferences-set to override individual values.
```

---

## Verification

- [ ] Target level determined (prompted or from argument)
- [ ] Target namespace determined (prompted or from argument)
- [ ] Existing file check performed (halts without `--force`)
- [ ] Configurables loaded successfully
- [ ] Target directory created if missing
- [ ] Preference file written with all defaults
- [ ] Created file is valid YAML
- [ ] Confirmation message displayed with file path and count

---

## Expected Output

### Files Created
- `~/.acp/agent/preferences/<namespace>.default.yaml` (user level), or
- `.vscode/preferences/<namespace>.yaml` (workspace level), or
- `agent/preferences/<namespace>.default.yaml` (project level)

### Files Modified
None

### Console Output
```
✅ Preferences created!

File:        agent/preferences/acp.default.yaml
Level:       Project
Namespace:   acp
Preferences: 8 defaults written

Run /acp-preferences-show to view effective preferences.
```

---

## Examples

### Example 1: Create User-Level ACP Preferences

**Invocation**: `/acp-preferences-create --level user --namespace acp`

**Result**: Creates `~/.acp/agent/preferences/acp.default.yaml` with all 8 ACP preference defaults.

### Example 2: Create Project-Level Preferences (Prompted)

**Invocation**: `/acp-preferences-create`

**Result**: Prompts for level (user/workspace/project) and namespace, then creates the file.

### Example 3: Initialize All Namespaces at Workspace Level

**Invocation**: `/acp-preferences-create --level workspace --all`

**Result**: Creates `.vscode/preferences/<ns>.yaml` for every discovered configurables namespace.

### Example 4: Overwrite Existing File

**Invocation**: `/acp-preferences-create --level project --namespace acp --force`

**Result**: Overwrites `agent/preferences/acp.default.yaml` with fresh defaults from configurables.

---

## Related Commands

- [`/acp-preferences-show`](acp.preferences-show.md) — View effective preferences with source attribution
- [`/acp-preferences-set`](acp.preferences-set.md) — Modify individual preference values
- [`/acp-preferences-get`](acp.preferences-get.md) — Generate resolved preference set
- [`/acp-preferences-validate`](acp.preferences-validate.md) — Validate preference files against configurables

---

## Troubleshooting

### Issue 1: No configurables found

**Symptom**: `No configurables found for namespace '<namespace>'`  
**Solution**: Ensure the package defining the configurables is installed. For ACP: verify `agent/configurables/acp.configurables.yaml` exists.

### Issue 2: Permission denied creating user preferences

**Symptom**: Error creating `~/.acp/agent/preferences/`  
**Solution**: Ensure `~/.acp/` directory exists and is writable. Create it: `mkdir -p ~/.acp/agent/preferences/`

### Issue 3: File already exists

**Symptom**: `⚠️  File already exists`  
**Solution**: Use `--force` to overwrite, or `/acp-preferences-show` to review existing values first.

---

## Security Considerations

### File Access
- **Reads**: `agent/configurables/<namespace>.configurables.yaml`
- **Writes**: One preference file at the target level
- **Executes**: None

### Network Access
- **APIs**: None
- **Repositories**: None

---

**Namespace**: acp  
**Command**: preferences-create  
**Version**: 1.0.0  
**Created**: 2026-05-01  
**Last Updated**: 2026-05-01  
**Status**: Active  
**Compatibility**: ACP 6.2.0+  
**Author**: ACP Project
