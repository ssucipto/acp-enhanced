# ACP Preferences Best Practices

<!-- @acp.meta.design
topic: acp, preferences, best, practices
description: The ACP preferences system provides multi-level configuration (Project > Workspace > User > Default). This guide covers when and how to use each level
status: draft
updated: 2026-05-01
@acp.meta.end -->

**Created**: 2026-05-01  
**Related**: [`agent/configurables/acp.configurables.yaml`](../configurables/acp.configurables.yaml), [`@acp.preferences-show`](../commands/acp.preferences-show.md)

---

## Overview

The ACP preferences system provides multi-level configuration (Project > Workspace > User > Default). This guide covers when and how to use each level, how to design effective presets, and common troubleshooting patterns.

---

## When to Use Preferences

✅ **Use preferences for**:
- Repeated configuration — when you make the same choice every time, encode it
- Team standards — enforce consistency across contributors
- Workflow automation — batch operations, CI environments
- Personal defaults — your preferred style applied everywhere

❌ **Avoid preferences for**:
- One-time configurations — use a CLI override instead (`--plan.draft.create_mode guided`)
- Secrets or credentials — use environment variables
- Dynamic values that change per invocation — use command arguments

---

## Choosing the Right Level

### User-Level (`~/.acp/agent/preferences/`)

Best for personal defaults that travel with you across all projects:

```yaml
# ~/.acp/agent/preferences/acp.default.yaml
acp:
  plan.draft.create_mode: 'guided'      # I prefer guided drafts personally
  output.verbosity.level: 'verbose'     # I want verbose output everywhere
```

### Workspace-Level (`.vscode/preferences/`)

Best for team or IDE-specific settings checked into the repo:

```yaml
# .vscode/preferences/acp.yaml
acp:
  plan.draft.create_mode: 'structured'  # Team requires structured drafts
  task.create.granularity: 4            # Team prefers larger, milestone-level tasks
```

### Project-Level (`agent/preferences/`)

Best for project-specific overrides — the highest precedence level:

```yaml
# agent/preferences/acp.default.yaml
acp:
  validation.strict_mode.enabled: true  # This project requires strict validation
  git.auto_commit.enabled: false        # Disable auto-commit for this project
```

---

## Designing Effective Presets

### Good Preset Anatomy

A well-designed preset has:
1. A **descriptive name** that conveys the workflow intent
2. A **focused purpose** — one workflow, not a grab-bag of overrides
3. **Internal consistency** — preferences that complement each other

```yaml
# agent/preferences/acp.batch-planning.yaml
# Automated planning without interaction.
# Ideal for: CI environments, bulk task creation, rapid iteration.
acp:
  plan.draft.create_mode: 'contextual'
  plan.batch.auto_confirm: true
  task.create.granularity: 2
  output.verbosity.level: 'quiet'
```

### Poor Preset Example (avoid)

```yaml
# agent/preferences/acp.misc.yaml     ← name doesn't convey purpose
acp:
  plan.draft.create_mode: 'contextual'
  output.verbosity.level: 'verbose'    ← contradicts batch goal (quiet vs verbose)
  task.create.granularity: 3          ← same as default — redundant
```

### Naming Conventions

- **Use kebab-case**: `batch-planning` not `batchPlanning`
- **Be descriptive**: `rapid-prototyping` not `rp`
- **Include namespace when invoking**: `--preset acp.batch-planning`
- **File naming**: `{namespace}.{preset-name}.yaml`

---

## Precedence Reference

```
CLI Override → Preset → Project → Workspace → User → Default
  (highest)                                            (lowest)
```

Practical implications:
- `--plan.draft.create_mode guided` always wins, regardless of preset or files
- `--preset acp.batch-planning` wins over all file-based preferences for keys it sets
- Project preferences override everything in `~/.acp/` or `.vscode/`

---

## Package Preferences

### For Package Authors

1. **Define configurables**: create `agent/configurables/{package}.configurables.yaml`
2. **Provide presets**: at least one preset demonstrating your workflow
3. **Document in README**: include a "Preferences & Presets" section (auto-scaffolded by `@acp.package-create`)
4. **Keep ids as dot-paths**: `id: 'category.setting'` not `id: 'setting'`

```yaml
# agent/configurables/my-package.configurables.yaml
my-package:
  output.format:
    id: 'output.format'
    description: Output format for generated files
    default: yaml
    type: string
    options:
      - name: yaml
        value: yaml
        description: YAML output
      - name: json
        value: json
        description: JSON output
```

### For Package Users

1. **Explore first**: `@acp.preferences-show my-package`
2. **Try presets**: `@acp.plan --preset my-package.default` before creating custom prefs
3. **Set project-level**: use `@acp.preferences-set` rather than editing files directly

---

## Common Patterns

### Pattern 1: Environment-Based Workflow Switching

```bash
# Interactive development session
@acp.plan --preset acp.interactive-planning

# CI/automated pipeline
@acp.plan --preset acp.batch-planning
```

### Pattern 2: Temporary Override (no persistent change)

```bash
# Always use structured, but need guided just this once
@acp.plan --plan.draft.create_mode guided
```

### Pattern 3: Team Standard + Personal Override

```yaml
# .vscode/preferences/acp.yaml (checked in, team-wide)
acp:
  plan.draft.create_mode: 'structured'

# ~/.acp/agent/preferences/acp.default.yaml (personal, not checked in)
# This is overridden by workspace — only applies where no workspace pref exists
acp:
  plan.draft.create_mode: 'guided'
```

---

## Troubleshooting

### Preference Not Applied

1. **Check effective value**: `@acp.preferences-show acp`
2. **Check source**: the column shows which level is winning
3. **Check precedence**: a higher-priority file might be setting the same key
4. **Validate**: `@acp.preferences-validate` for syntax/schema errors

### Preset Not Found

```
Error: Preset not found: acp.my-preset
```

1. Check the file exists at `agent/preferences/acp.my-preset.yaml` (project) or `~/.acp/agent/preferences/acp.my-preset.yaml` (user)
2. Verify the filename matches `{namespace}.{preset-name}.yaml` exactly
3. List available presets: `@acp.preferences-show acp --presets`

### Invalid Preference Value

```
Error: Value 'invalid' is not a valid option for 'plan.draft.create_mode'
```

1. Check the configurables file for valid options
2. Run `@acp.preferences-validate` to identify all issues
3. Use `@acp.preferences-set` to set a valid value interactively

### Preferences Not Loading in Commands

If a command doesn't seem to respect preferences:
1. Check the command version — preferences require ACP 6.2.0+
2. Confirm `agent/scripts/acp.preferences.sh` exists and is executable
3. Run `@acp.preferences-show` to confirm preferences are resolvable
4. Check if the command documents its preference support (look for a "Preferences" section)
