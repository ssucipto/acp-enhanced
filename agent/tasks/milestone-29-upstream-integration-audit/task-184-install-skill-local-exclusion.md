---
id: task-184
milestone: M29
title: Add local.* exclusion to install script skills copy
status: completed
priority: 3
complexity: low
estimated_hours: 1
created: 2026-05-05
started: 2026-05-05T00:00:00Z
completed: 2026-05-05
---

## Objective

Update `agent/scripts/acp.install.sh` to exclude `local.*` skill files from the wildcard copy, matching the protection pattern already applied to `agent/patterns/` (templates-only copy). This prevents a project's custom skill extensions from being silently overwritten on upgrade.

## Context

Direction B concern from 2026-05-05 session: `acp.install.sh` line ~164 copies all `agent/skills/*.md` to every target project with a plain `cp` (no `-n` flag), overwriting everything unconditionally. This means any downstream project that creates `agent/skills/local.my-custom-skill.md` loses it on every ACP Enhanced upgrade.

The patterns directory already protects project-local files: `agent/patterns/local.*` files are safe because the install script copies only `*.template.md` patterns. Skills have no equivalent protection.

ACP Enhanced now ships `upstream-sync.md` (and may ship more skills over time). Projects that extend these with a `local.*` file — for example `local.upstream-sync-extensions.md` with project-specific DEFER overrides — should not lose those extensions on upgrade.

The convention follows what already exists: `local.*` = project-local, never shipped, never overwritten.

## Implementation

In `agent/scripts/acp.install.sh`, replace the skills wildcard copy (line ~164):

```bash
# BEFORE (overwrites everything including local.* project files):

<!-- @acp.meta.task
topic: before, overwrites, everything, including, local, project, files
description: Add local.* exclusion to install script skills copy
milestone: M29
status: completed
updated: 2026-05-05
@acp.meta.end -->


if [ -d "$TEMP_DIR/agent/skills" ]; then
    cp "$TEMP_DIR/agent/skills/"*.md "$TARGET_DIR/agent/skills/" 2>/dev/null || true
fi
```

With a loop that skips `local.*` files:

```bash
# AFTER (preserves local.* project-local skill extensions):
if [ -d "$TEMP_DIR/agent/skills" ]; then
    for _skill_file in "$TEMP_DIR/agent/skills/"*.md; do
        [ -e "$_skill_file" ] || continue  # glob safety: skip if no match
        _skill_basename=$(basename "$_skill_file")
        case "$_skill_basename" in
            local.*) continue ;;  # never overwrite project-local skill extensions
        esac
        cp "$_skill_file" "$TARGET_DIR/agent/skills/"
    done
    unset _skill_file _skill_basename
fi
```

Note: `case ... esac` is bash 3.2-safe. No `[[ ]]`, no `declare -A`, no `mapfile`. The `unset` cleans loop variables to avoid polluting the script scope.

## Expected Output

### Files Modified
- `agent/scripts/acp.install.sh`

## Verification
- [ ] `local.*` skill files in target project are NOT overwritten after running the updated install script on an existing project
- [ ] Standard ACP Enhanced skill files (commands.md, scripts.md, testing.md, upstream-sync.md, etc.) ARE still copied and overwrite the target as expected
- [ ] Script is bash 3.2-compatible (no bash 4+ constructs)
- [ ] Script passes on macOS: `bash agent/scripts/acp.install.sh` in a temp project with `agent/skills/local.test.md` — file survives install
- [ ] Script passes on Linux: same test
- [ ] Glob safety guard (`[ -e "$_skill_file" ] || continue`) prevents errors in empty directory

## User-Observable Acceptance
A project with `agent/skills/local.custom-workflow.md` can safely run `bash acp.install.sh` to upgrade ACP Enhanced without losing its custom skill file. All ACP Enhanced baseline skill files are still updated to the latest version.
