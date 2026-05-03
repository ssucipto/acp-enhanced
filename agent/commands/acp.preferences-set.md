# Command: preferences-set

> **🤖 Agent Directive**: If you are reading this file, the command `/acp-preferences-set` has been invoked. Follow the steps below to execute this command.

**Namespace**: acp  
**Version**: 1.0.0  
**Created**: 2026-05-01  
**Last Updated**: 2026-05-01  
**Status**: Active  
**Scripts**: acp.preferences.sh  
**Compatibility**: ACP 6.2.0+  

---

**Purpose**: Set a preference value at a specified level (user/workspace/project) with validation  
**Category**: Configuration  
**Frequency**: As Needed  

---

## What This Command Does

Modifies a single preference value in the appropriate level file after validating the value against the configurables schema. This is the primary way to change preferences without hand-editing YAML.

Use this command when:
- Changing how commands behave (e.g., switching draft mode)
- Setting up personal preferences at the user level
- Configuring project-wide defaults in `agent/preferences/`
- Applying temporary workspace overrides without modifying project files

---

## Prerequisites

- [ ] ACP installed in project
- [ ] `agent/configurables/<namespace>.configurables.yaml` exists (for validation)
- [ ] Target preference file exists, or agent creates it automatically

---

## Arguments

**Positional**:
- `[namespace]` — Namespace of the preference (default: `acp`)
- `[preference.path]` — Dot-notation path (e.g., `plan.draft.create_mode`)
- `[value]` — New value to set

**Flags**:
- `--user` / `--global` — Write to `~/.acp/agent/preferences/<namespace>.default.yaml`
- `--workspace` — Write to `.vscode/preferences/<namespace>.yaml`
- `--project` — Write to `agent/preferences/<namespace>.default.yaml` (default when no flag)
- `--dry-run` — Preview what would change without writing the file

**Natural Language**:
- "set draft mode to guided" → `acp plan.draft.create_mode guided --project`
- "use contextual mode globally" → `acp plan.draft.create_mode contextual --user`
- "set granularity to 5 for this project" → `acp task.create.granularity 5 --project`

---

## Steps

### 0. Display Command Header

```
⚡ /acp-preferences-set
  Set a preference value with validation

  Usage:
    /acp-preferences-set acp plan.draft.create_mode guided
    /acp-preferences-set acp plan.draft.create_mode guided --user
    /acp-preferences-set acp task.create.granularity 5 --project
    /acp-preferences-set                              (interactive)

  Related:
    /acp-preferences-show      View current effective preferences
    /acp-preferences-create    Create a preference file first
    /acp-preferences-validate  Validate all preference files
```

### 1. Parse Arguments

Extract from invocation:
- `namespace` — first positional or default `acp`
- `preference.path` — second positional (dot-notation)
- `value` — third positional
- `level` — from flag (`--user`/`--workspace`/`--project`; default `project`)

If any of the above are missing, prompt interactively:

```
Namespace [acp]:
Preference path (e.g., plan.draft.create_mode):
Value:
Level — project/workspace/user [project]:
```

### 2. Validate Preference and Value

Use `./agent/scripts/acp.preferences.sh validate <namespace> <preference.path> <value>`:

**Validation rules** (loaded from configurables):
- The `preference.path` MUST exist in `agent/configurables/<namespace>.configurables.yaml`
- For `type: string` with `options[]`: value MUST be one of the listed option values
- For `type: number`: value MUST be a valid number within `[min, max]` (if defined)
- For `type: boolean`: value MUST be `true` or `false`

**If validation fails**:
```
❌ Invalid value for plan.draft.create_mode: 'freestyle'

  Valid options:
    • structured   — Structured doc with template sections
    • unstructured — Empty draft file, user fills it in
    • guided       — Chat-only collection, no file created
    • contextual   — Inferred from context, no file created

Run /acp-preferences-set without arguments for interactive mode.
```

Halt without writing.

### 3. Determine Target File

Map level to file path:

| Level | File Path |
|-------|-----------|
| `project` (default) | `agent/preferences/<namespace>.default.yaml` |
| `workspace` | `.vscode/preferences/<namespace>.yaml` |
| `user` / `global` | `~/.acp/agent/preferences/<namespace>.default.yaml` |

If the target file does not exist:
- Auto-create it by running `/acp-preferences-create --level <level> --namespace <namespace>` internally
- Inform the user: `Creating preference file at <path> with defaults...`

### 4. Preview Change (Dry-Run or Confirmation)

Show what will be written before writing:

```
📝 Preference change:

  Namespace:  acp
  Key:        plan.draft.create_mode
  Current:    'structured'  (project)
  New value:  'guided'
  Level:      Project
  File:       agent/preferences/acp.default.yaml
```

If `--dry-run` was provided, show the above and exit without writing.

### 5. Write Preference

- Open the target file
- Set the value at the correct dot-path within the YAML structure
- If the key doesn't exist in the file, add it
- Write the file

Shell equivalent (for reference — agent may write YAML directly):
```bash
./agent/scripts/acp.preferences.sh set <namespace> <preference.path> <value> <level>
```

### 6. Confirm and Show Effective Value

```
✅ Preference updated!

  Namespace:  acp
  Key:        plan.draft.create_mode
  Value:      'guided'
  Level:      Project  (agent/preferences/acp.default.yaml)

Run /acp-preferences-show to see all effective preferences.
```

---

## Verification

- [ ] All arguments parsed (or prompted interactively)
- [ ] Validation run against configurables before writing
- [ ] Invalid values rejected with helpful error (valid options shown)
- [ ] Target file determined from level flag (default: project)
- [ ] Target file auto-created if missing (with defaults)
- [ ] Dry-run exits without writing
- [ ] Value written to correct dot-path in YAML
- [ ] Confirmation displayed with level and file path

---

## Expected Output

### Files Modified
- `agent/preferences/<namespace>.default.yaml` (project level), or
- `.vscode/preferences/<namespace>.yaml` (workspace level), or
- `~/.acp/agent/preferences/<namespace>.default.yaml` (user level)

### Console Output

```
✅ Preference updated!

  Namespace:  acp
  Key:        plan.draft.create_mode
  Value:      'guided'
  Level:      Project  (agent/preferences/acp.default.yaml)

Run /acp-preferences-show to see all effective preferences.
```

---

## Examples

### Example 1: Set Draft Mode to Guided (Project Level)

**Invocation**: `/acp-preferences-set acp plan.draft.create_mode guided`

**Result**: Sets `plan.draft.create_mode: guided` in `agent/preferences/acp.default.yaml`.

### Example 2: Set Personal Preference at User Level

**Invocation**: `/acp-preferences-set acp plan.draft.create_mode contextual --user`

**Result**: Sets `plan.draft.create_mode: contextual` in `~/.acp/agent/preferences/acp.default.yaml`. Applies to all projects on this machine.

### Example 3: Preview Without Writing

**Invocation**: `/acp-preferences-set acp task.create.granularity 5 --dry-run`

**Result**: Displays the change that would be made. Does not modify any file.

### Example 4: Interactive Mode

**Invocation**: `/acp-preferences-set`

**Result**: Prompts for namespace, preference path, value, and level in sequence. Validates and writes.

### Example 5: Invalid Value

**Invocation**: `/acp-preferences-set acp plan.draft.create_mode freestyle`

**Result**: Validation fails — shows valid options (`structured`, `unstructured`, `guided`, `contextual`). Nothing written.

---

## Related Commands

- [`/acp-preferences-show`](acp.preferences-show.md) — View current effective preferences with source
- [`/acp-preferences-create`](acp.preferences-create.md) — Create a new preference file
- [`/acp-preferences-get`](acp.preferences-get.md) — Generate resolved preference set
- [`/acp-preferences-validate`](acp.preferences-validate.md) — Validate all preference files

---

## Troubleshooting

### Issue 1: Validation fails for a value I expect to be valid

**Symptom**: `❌ Invalid value for <pref>: '<value>'`  
**Solution**: Run `/acp-preferences-show` to see valid options. Check the configurables file for the exact accepted values.

### Issue 2: Wrong level being written

**Symptom**: Preference shows at unexpected level in `/acp-preferences-show`  
**Solution**: Use explicit `--user`, `--workspace`, or `--project` flag to target the correct file.

### Issue 3: Preference not in effective set after setting

**Symptom**: `/acp-preferences-show` shows old value  
**Cause**: A higher-precedence level is overriding the one you wrote  
**Solution**: Check which level is overriding (the source column in `/acp-preferences-show`). Update or remove the higher-precedence override.

---

## Security Considerations

### File Access
- **Reads**: `agent/configurables/<ns>.configurables.yaml`, target preference file
- **Writes**: One preference file at the target level
- **Executes**: `./agent/scripts/acp.preferences.sh validate` and `set`

### Network Access
- **APIs**: None
- **Repositories**: None

---

**Namespace**: acp  
**Command**: preferences-set  
**Version**: 1.0.0  
**Created**: 2026-05-01  
**Last Updated**: 2026-05-01  
**Status**: Active  
**Compatibility**: ACP 6.2.0+  
**Author**: ACP Project
