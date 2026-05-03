# Command: preferences-get

> **🤖 Agent Directive**: When this command is invoked, resolve and display the
> complete preference set for the specified namespace by running the shell script
> `./agent/scripts/acp.preferences.sh`. Apply precedence rules automatically:
> Project → Workspace → User → Configurables default.

**Namespace**: acp  
**Version**: 1.0.0  
**Purpose**: Resolve and display preferences for a given namespace  
**Category**: Utility  
**Frequency**: As Needed  
**Scripts**: acp.preferences.sh  

---

## What This Command Does

Reads all preference sources for a namespace (project, workspace, user, and
configurables defaults) and outputs the resolved values with precedence applied.
The highest-precedence value wins: Project overrides Workspace, which overrides
User, which overrides the Configurables default.

---

## Arguments

| Argument    | Type   | Required | Default | Description                                  |
|-------------|--------|----------|---------|----------------------------------------------|
| `namespace` | string | Yes      | —       | Preference namespace (e.g., `acp`, package name) |
| `format`    | string | No       | `yaml`  | Output format: `yaml` or `json`              |
| `path`      | string | No       | —       | Single preference path (dot notation) to resolve instead of all |

---

## Steps

### 1. Validate Namespace

Confirm the namespace is non-empty and that the configurables file exists:

```bash
./agent/scripts/acp.preferences.sh has <namespace> <any.key>
# or simply proceed — generate emits {} for empty namespaces
```

### 2. Resolve Preferences

Run the preference script to generate the full, resolved preference set:

```bash
# Full namespace (all preferences):
./agent/scripts/acp.preferences.sh generate <namespace> [yaml|json]

# Single preference:
./agent/scripts/acp.preferences.sh get <namespace> <preference.path>
```

### 3. Report Source (Optional)

If the user asks *where* a value came from, report the source level:

```bash
./agent/scripts/acp.preferences.sh source <namespace> <preference.path>
# Returns: project | workspace | user | default | none
```

### 4. Display Output

Show the resolved preferences to the user with clear formatting.

---

## Precedence Levels (Highest → Lowest)

| Level       | File Location                                            |
|-------------|----------------------------------------------------------|
| Project     | `./agent/preferences/<namespace>.default.yaml`           |
| Workspace   | `.vscode/preferences/<namespace>.yaml`                   |
| User        | `~/.acp/agent/preferences/<namespace>.default.yaml`      |
| Default     | `./agent/configurables/<namespace>.configurables.yaml`   |

---

## Expected Outcomes

| Scenario                                | Outcome                                         |
|-----------------------------------------|-------------------------------------------------|
| Namespace has full project preferences  | Project-level values returned for all keys      |
| Only defaults set                       | Configurables default values returned           |
| Namespace not found                     | Error message; exit 1                           |
| Single `path` arg provided              | Only that preference resolved and returned      |

---

## Examples

### Example 1: Get All ACP Preferences
```
/acp-preferences-get acp
```

Expected output:
```yaml
acp:
  plan.draft.create_mode: 'structured'
  task.create.granularity: 3
  validation.auto_fix.enabled: true
```

### Example 2: Get a Single Preference
```
/acp-preferences-get acp plan.draft.create_mode
```

Expected output:
```
structured
```

---

## Verification

- [ ] Preferences resolved without error
- [ ] Correct precedence applied (project overrides workspace overrides user overrides default)
- [ ] If `path` argument given, only that key returned
- [ ] Output format matches requested format (`yaml` or `json`)
- [ ] If namespace not found, non-zero exit with clear error message

### Example 3: Get Preferences as JSON
```
/acp-preferences-get acp json
```

### Example 4: Check Preference Source
```
/acp-preferences-get source acp plan.draft.create_mode
```

Expected output:
```
project
```

---

## Related Commands

- `/acp-preferences-show` — Display preferences annotated with their source level
- `/acp-preferences-set` — Set a preference at a specific level
- `/acp-preferences-validate` — Validate preferences against schema

---

## Notes

- The script is both sourceable and directly executable.
- All functions guard against missing files using `[[ -f ... ]]` checks — no
  errors are thrown for absent preference levels.
- `yaml_query()` from `acp.yaml-parser.sh` handles path resolution internally.
