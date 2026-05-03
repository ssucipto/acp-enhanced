# Command: preferences-validate

> **🤖 Agent Directive**: If you are reading this file, the command `/acp-preferences-validate` has been invoked. Follow the steps below to execute this command.

**Namespace**: acp  
**Version**: 1.0.0  
**Created**: 2026-05-01  
**Last Updated**: 2026-05-01  
**Status**: Active  
**Scripts**: `agent/scripts/acp.preferences.sh`  
**Compatibility**: ACP 6.2.0+  

---

**Purpose**: Validate all preference files across all levels against their configurables schemas  
**Category**: Validation  
**Frequency**: As Needed  

---

## What This Command Does

Scans all preference files at every level (user, workspace, project), validates each preference value against the corresponding configurables definition, and reports errors and warnings in a structured format.

Use this command when:
- You've manually edited preference files and want to verify correctness
- After updating a package (configurables may have changed)
- As part of CI/CD to catch invalid preferences before they affect agents
- Diagnosing unexpected agent behavior caused by misconfigured preferences

---

## Prerequisites

- [ ] ACP installed in project
- [ ] At least one preference file or configurables file exists

---

## Arguments

**CLI-Style**:
- `[namespace]` — Validate only this namespace (default: all discovered namespaces)
- `--fix` — Auto-fix invalid values by reverting them to configurables defaults
- `--level <level>` — Validate only one level: `user`, `workspace`, or `project`
- `--strict` — Treat warnings as errors (exit non-zero on warnings)

**Natural Language**:
- "validate preferences" → validate all namespaces at all levels
- "validate acp preferences" → validate only `acp` namespace
- "fix preference errors" → `--fix` auto-fix mode

---

## Steps

### 0. Display Command Header

```
⚡ /acp-preferences-validate
  Validate preference files against configurables schemas

  Usage:
    /acp-preferences-validate                    Validate all namespaces
    /acp-preferences-validate acp                Validate acp namespace only
    /acp-preferences-validate --fix              Auto-fix invalid values
    /acp-preferences-validate --level project    Validate project level only

  Related:
    /acp-preferences-show      View effective preferences with sources
    /acp-preferences-set       Fix invalid values interactively
```

### 1. Discover Preference Files

Scan all three levels for YAML files:

| Level | Glob |
|-------|------|
| Project | `agent/preferences/*.yaml` |
| Workspace | `.vscode/preferences/*.yaml` |
| User | `~/.acp/agent/preferences/*.yaml` |

Apply level filter if `--level` was provided. Apply namespace filter if a positional namespace was provided.

If no files found at any level: `ℹ️  No preference files found. Nothing to validate.`

### 2. Load Configurables for Each Namespace

For each discovered namespace (derived from filename prefix):
- Load `agent/configurables/<namespace>.configurables.yaml`
- If configurables not found: flag all preferences in that file as `⚠️  No configurables (unknown namespace)` — continue

### 3. Validate Each Preference File

For each preference file, parse YAML and for each key-value pair:

**Validation checks**:

| Check | Error Type | Description |
|-------|-----------|-------------|
| Key exists in configurables | Warning | Unknown preference — may be outdated or misspelled |
| `type: string` with `options[]`: value in options | Error | Invalid string value |
| `type: number`: value is numeric | Error | Non-numeric value |
| `type: number`: value within `[min, max]` | Error | Out-of-range number |
| `type: boolean`: value is `true` or `false` | Error | Invalid boolean |
| YAML parseable | Error | File is not valid YAML |

### 4. Report Results

```
🔍 Validating Preferences...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📁 Project — agent/preferences/acp.default.yaml
   Namespace: acp | 8 preferences checked
   ✅ All valid

💼 Workspace — .vscode/preferences/acp.yaml
   Namespace: acp | 3 preferences checked
   ❌ plan.draft.create_mode: invalid value 'freestyle'
      Valid: structured, unstructured, guided, contextual
   ❌ task.create.granularity: value 15 exceeds maximum 8
      Valid range: 1–8

👤 User — ~/.acp/agent/preferences/acp.default.yaml
   Namespace: acp | 5 preferences checked
   ⚠️  output.verbosity.level: value 'debug' not in valid options
      Valid: quiet, normal, verbose

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Summary:
  Files checked:   3
  Preferences:     16
  ✅ Valid:         13
  ❌ Errors:         2  ← must fix
  ⚠️  Warnings:       1  ← review

Status: FAIL

Fix errors with /acp-preferences-set or /acp-preferences-validate --fix
```

**When no issues found**:
```
✅ All preferences valid (16 preferences in 3 files)
```

### 5. Auto-Fix Mode (`--fix`)

When `--fix` is provided and errors/warnings are found:

For each invalid preference:
- Load the configurables default for that key
- Show what would be changed:
  ```
  🔧 Fixing plan.draft.create_mode in .vscode/preferences/acp.yaml
     'freestyle' → 'structured' (configurables default)
  ```
- Write the corrected value to the file

After all fixes:
```
✅ Fixed 2 errors, 1 warning.

Run /acp-preferences-validate to confirm all files are valid.
```

**Note**: `--fix` only applies configurables defaults. It does not apply project/user precedence — it always uses the `.default` value from the configurables file.

### 6. Exit Code

- `0` — No errors (warnings alone do not fail unless `--strict`)
- `1` — One or more errors found
- `1` — `--strict` and one or more warnings found

---

## Verification

- [ ] All three levels scanned (unless `--level` specified)
- [ ] Namespace filter applied if positional arg provided
- [ ] Configurables loaded per namespace
- [ ] Missing configurables flagged as warnings (not errors)
- [ ] All validation checks applied (type, options, range, boolean)
- [ ] Invalid YAML files reported as errors
- [ ] Report shows file, level, preference count, and issues
- [ ] Summary shows total files, preferences, errors, warnings
- [ ] `--fix` reverts invalid values to configurables defaults
- [ ] `--strict` treats warnings as errors
- [ ] Exit code reflects result

---

## Expected Output

### Files Modified
None — read-only (unless `--fix` is used, which modifies preference files in place)

### Console Output

See Step 4 for full report format.

---

## Examples

### Example 1: Validate All Preferences

**Invocation**: `/acp-preferences-validate`

**Result**: Scans all levels/namespaces, reports any errors or warnings.

### Example 2: Validate Only ACP Namespace

**Invocation**: `/acp-preferences-validate acp`

**Result**: Checks only `acp` namespace files across all levels.

### Example 3: Auto-Fix Errors

**Invocation**: `/acp-preferences-validate --fix`

**Result**: Validates all files, then reverts all invalid values to configurables defaults. Reports what was changed.

### Example 4: Strict Mode (Warnings as Errors)

**Invocation**: `/acp-preferences-validate --strict`

**Result**: Exits with code 1 if any warnings are found, not just errors. Useful for CI pipelines.

### Example 5: Validate Project Level Only

**Invocation**: `/acp-preferences-validate --level project`

**Result**: Checks only `agent/preferences/*.yaml` files.

---

## Related Commands

- [`/acp-preferences-show`](acp.preferences-show.md) — View effective preferences with sources
- [`/acp-preferences-set`](acp.preferences-set.md) — Fix individual values interactively
- [`/acp-preferences-create`](acp.preferences-create.md) — Create a preference file with defaults
- [`/acp-preferences-get`](acp.preferences-get.md) — Generate resolved preference set

---

## Troubleshooting

### Issue 1: No configurables found for namespace

**Symptom**: `⚠️  No configurables for namespace 'old-package'`  
**Cause**: The package that defined these configurables has been removed  
**Solution**: Delete the stale preference file, or install the package

### Issue 2: `--fix` doesn't fix all issues

**Symptom**: After `--fix`, some issues remain  
**Cause**: The issue may be structural (invalid YAML) rather than a wrong value  
**Solution**: Open the file and check for YAML syntax errors

### Issue 3: Warnings about unknown preferences

**Symptom**: `⚠️  git.auto_commit.enabled: preference not in configurables`  
**Cause**: May be a typo, or the preference was removed from configurables in a newer version  
**Solution**: Remove the unknown key, or check the package changelog for renamed preferences

---

## Security Considerations

### File Access
- **Reads**: `agent/configurables/*.yaml`, `agent/preferences/*.yaml`, `.vscode/preferences/*.yaml`, `~/.acp/agent/preferences/*.yaml`
- **Writes**: Preference files (only with `--fix`)
- **Executes**: `./agent/scripts/acp.preferences.sh validate`

### Network Access
- **APIs**: None
- **Repositories**: None

---

**Namespace**: acp  
**Command**: preferences-validate  
**Version**: 1.0.0  
**Created**: 2026-05-01  
**Last Updated**: 2026-05-01  
**Status**: Active  
**Compatibility**: ACP 6.2.0+  
**Author**: ACP Project
