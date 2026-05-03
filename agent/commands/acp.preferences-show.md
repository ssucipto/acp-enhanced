# Command: preferences-show

> **🤖 Agent Directive**: If you are reading this file, the command `/acp-preferences-show` has been invoked. Follow the steps below to execute this command.

**Namespace**: acp  
**Version**: 1.0.0  
**Created**: 2026-05-01  
**Last Updated**: 2026-05-01  
**Status**: Active  
**Scripts**: acp.preferences.sh  
**Compatibility**: ACP 6.2.0+  

---

**Purpose**: Display the effective preference set for a namespace with source attribution for each value  
**Category**: Utility  
**Frequency**: As Needed  

---

## What This Command Does

Shows current effective preferences — the result of applying the full 4-level precedence chain — with a clear indicator of where each value came from (project, workspace, user, or configurables default).

This is the primary debugging tool for the preferences system. Use it to:
- Verify which preferences are active
- Understand where each value originates
- Identify overrides at different levels
- Check for stale or unexpected values

---

## Prerequisites

- [ ] ACP installed in project
- [ ] At least one of: `agent/configurables/<ns>.configurables.yaml`, or any preference file

---

## Arguments

**CLI-Style**:
- `[namespace]` — Positional: namespace to show (default: `acp`)
- `--all` — Show all discovered namespaces
- `--presets` — List available presets instead of preference values
- `--format <format>` — Output format: `table` (default), `yaml`, `json`

**Natural Language**:
- "show preferences" → shows `acp` namespace in table format
- "show preferences for mcp-auth" → shows `mcp-auth-server-base` namespace
- "show all preferences" → shows all discovered namespaces
- "list presets" → shows available presets for `acp` namespace

---

## Steps

### 0. Display Command Header

```
⚡ /acp-preferences-show
  Display effective preferences with source attribution

  Usage:
    /acp-preferences-show                     Show acp namespace
    /acp-preferences-show mcp-auth            Show specific namespace
    /acp-preferences-show --all               Show all namespaces
    /acp-preferences-show --presets           List available presets for acp
    /acp-preferences-show acp --presets       List available presets for specific namespace
    /acp-preferences-show --format yaml       Output as YAML

  Related:
    /acp-preferences-get       Generate resolved preference set (raw)
    /acp-preferences-set       Modify a preference value
    /acp-preferences-create    Create a preference file
    /acp-preferences-validate  Check preferences for errors
```

### 1. Determine Namespace

If a positional namespace was provided, use it. If `--all` was provided, discover all namespaces. Otherwise default to `acp`.

**Namespace discovery for `--all`**: scan `agent/configurables/*.configurables.yaml`, extract each file's namespace prefix.

### 1a. (If --presets) List Presets and Exit

If `--presets` was provided, display available presets and exit without showing preference values:

- For each namespace to check, invoke `./agent/scripts/acp.preferences.sh list-presets <namespace>`
- Display output, then stop.

**Example output**:
```
📦 Available Presets — acp

  📁 project: batch-planning
  📁 project: interactive-planning
  📁 project: rapid-prototyping

  Use with: /acp-plan --preset acp.<preset-name>
  File path: agent/preferences/acp.<preset-name>.yaml
```

If no presets are found:
```
📦 Available Presets — acp

  (no presets found)

  To create a preset:
    1. Create agent/preferences/acp.<preset-name>.yaml
    2. Set any acp namespace preferences in that file
    3. Use with: /acp-plan --preset acp.<preset-name>
```

### 2. Generate Preferences

For each namespace:
- Invoke `./agent/scripts/acp.preferences.sh generate <namespace> yaml`
  - This produces the full resolved preference set using the 4-level precedence chain
- If the script is unavailable, fall back to reading files directly

### 3. Get Sources

For each preference key in the resolved set:
- Invoke `./agent/scripts/acp.preferences.sh source <namespace> <pref.path>`
  - Returns: `project` | `workspace` | `user` | `default` | `none`

### 4. Display Preferences

**Table format** (default):

```
📊 Effective Preferences — acp

  plan.draft.create_mode    'structured'     📁 Project
  plan.batch.auto_confirm   false            ⚙️  Default
  task.create.granularity   3                ⚙️  Default
  task.create.auto_number   true             ⚙️  Default
  validation.auto_fix.enabled  true          ⚙️  Default
  validation.strict_mode.enabled  false      ⚙️  Default
  output.verbosity.level    'normal'         ⚙️  Default
  git.auto_commit.enabled   false            ⚙️  Default

  ─────────────────────────────────────────────────────
  8 preferences • 1 override (project)

  Source legend:
    📁 Project    agent/preferences/acp.default.yaml
    💼 Workspace  .vscode/preferences/acp.yaml
    👤 User       ~/.acp/agent/preferences/acp.default.yaml
    ⚙️  Default    agent/configurables/acp.configurables.yaml
```

**YAML format** (`--format yaml`):

```yaml
# Effective preferences — acp
# Generated: 2026-05-01
acp:
  plan.draft.create_mode: structured      # project
  plan.batch.auto_confirm: false          # default
  task.create.granularity: 3              # default
  ...
```

**JSON format** (`--format json`):

```json
{
  "acp": {
    "plan.draft.create_mode": "structured",
    "plan.batch.auto_confirm": false,
    ...
  }
}
```

### 5. Handle Missing Data

- **No configurables found**: warn and show what files were found at each level
- **No preference files found at any level**: show defaults from configurables only, note that no overrides are set
- **No data at all**: guide user to run `/acp-preferences-create`

---

## Verification

- [ ] Namespace determined (prompt, argument, or default)
- [ ] `--presets` flag: lists presets via `list_presets` and exits
- [ ] Preferences generated via `acp.preferences.sh generate`
- [ ] Source determined for each preference via `acp.preferences.sh source`
- [ ] Table/YAML/JSON output displayed per `--format`
- [ ] Source legend shown
- [ ] Override summary line shown (count by level)
- [ ] Missing data handled gracefully

---

## Expected Output

### Files Modified
None — read-only command

### Console Output

See Step 4 for the full output format.

---

## Examples

### Example 1: Show ACP Preferences (Default)

**Invocation**: `/acp-preferences-show`

**Result**: Table of all 8 ACP preferences with source attribution.

### Example 2: Show Specific Package Preferences

**Invocation**: `/acp-preferences-show mcp-auth-server-base`

**Result**: Table of all preferences defined in `agent/configurables/mcp-auth-server-base.configurables.yaml`.

### Example 3: Show All Namespaces as YAML

**Invocation**: `/acp-preferences-show --all --format yaml`

**Result**: All discovered namespaces output in YAML format with inline source comments.

---

## Related Commands

- [`/acp-preferences-get`](acp.preferences-get.md) — Generate resolved preference set (raw output)
- [`/acp-preferences-create`](acp.preferences-create.md) — Create a preference file with defaults
- [`/acp-preferences-set`](acp.preferences-set.md) — Modify individual preference values
- [`/acp-preferences-validate`](acp.preferences-validate.md) — Validate preference files

---

## Troubleshooting

### Issue 1: All values show as "Default"

**Symptom**: Every preference shows ⚙️ Default  
**Cause**: No preference files exist at project/workspace/user level  
**Solution**: Run `/acp-preferences-create --level project` to create a project-level file with your overrides.

### Issue 2: Unexpected value source

**Symptom**: A value is coming from a level you didn't expect  
**Cause**: A preference file at a higher-precedence level is overriding your setting  
**Solution**: Check the legend paths. Edit or remove the file at the overriding level.

### Issue 3: Namespace not found

**Symptom**: `No configurables found for namespace '<ns>'`  
**Cause**: The package hasn't been installed or its configurables file is missing  
**Solution**: Install the package first or verify `agent/configurables/<ns>.configurables.yaml` exists.

---

## Security Considerations

### File Access
- **Reads**: `agent/configurables/<ns>.configurables.yaml`, `agent/preferences/*.yaml`, `.vscode/preferences/*.yaml`, `~/.acp/agent/preferences/*.yaml`
- **Writes**: None
- **Executes**: `./agent/scripts/acp.preferences.sh generate` and `source`

### Network Access
- **APIs**: None
- **Repositories**: None

---

**Namespace**: acp  
**Command**: preferences-show  
**Version**: 1.0.0  
**Created**: 2026-05-01  
**Last Updated**: 2026-05-01  
**Status**: Active  
**Compatibility**: ACP 6.2.0+  
**Author**: ACP Project
