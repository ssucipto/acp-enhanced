# Command: version-update

> **🤖 Agent Directive**: If you are reading this file, the command `/acp-version-update` has been invoked. Follow the steps below to execute this command.

**Namespace**: acp  
**Version**: 1.2.0  
**Created**: 2026-02-16  
**Last Updated**: 2026-07-15  
**Status**: Active  
**Scripts**: acp.version-update.sh, acp.common.sh  

---

**Purpose**: Update ACP files (AGENT.md, templates, scripts) to the latest version  
**Category**: Maintenance  
**Frequency**: When Updates Available  

---

## Arguments

| Flag | Description |
|------|-------------|
| `--diff` | Show what files would change without applying any updates |
| `--preserve-project-core` | Skip overwriting project-specific core files (identity.yml, domain.yml, taxonomy.yml) |
| `--yes` / `-y` | Auto-confirm prompts (CI / agent runs) |

**Default behavior (v6.24.0+)**: Tier-aware safe update — customized Tier B files are **preserved**; framework Tier C files refreshed. Requires `AGENTS.md` or `AGENT.md` at project root.

---

## File tier policy (authoritative)

| Tier | Behavior | Examples |
|------|----------|----------|
| **A — Never overwrite** | Create-if-absent only | `agent/progress.yaml`, `agent/memory/*`, `agent/routing/tasks/route-*.md`, third-party `agent/commands/{ns}.*.md` (ns ≠ acp, git) |
| **B — Preserve if customized** | Skip when local ≠ upstream SHA | `agent/core/identity.yml`, `agent/wiki/domain.yml`, `agent/routing/taxonomy.yml`, `agent/skills/local.*.md` |
| **C — Always refresh** | Framework artifacts | `agent/commands/acp.*.md`, `agent/scripts/*.sh`, `AGENTS.md`, `agent/schemas/*` |
| **D — Merge only** | acp-core block in manifest | `agent/manifest.yaml` — other packages untouched |

> **Pre-v6.24.0**: Commit before updating. Older scripts blind-overwrote core files.

---

## What This Command Does

This command updates your ACP Enhanced installation using **tier-aware** copy logic in `acp.version-update.sh`. Framework files refresh; project-owned configuration is preserved by default.

Use when `/acp-version-check-for-updates` reports updates available. Git commit before updating is still recommended.

**Removed**: Contradictory overwrite lists — use the tier table above.

---

## Legacy note (v1.1.0 doc-only — fixed v6.24.0)

Project core paths: `agent/wiki/domain.yml` (not `agent/core/domain.yml`). `agent/routing/taxonomy.yml` for taxonomy.

---

## Prerequisites

- [ ] ACP installed in project
- [ ] `agent/scripts/acp.version-update.sh` exists
- [ ] Internet connection available
- [ ] Git repository initialized (recommended for easy rollback)
- [ ] Changes committed (recommended)

---

## Steps

### 0. Display Command Header

Display the following informational header, then continue immediately:

```
⚡ /acp-version-update
  Update ACP files (AGENT.md, templates, scripts) to the latest version

  Usage:
    /acp-version-update                             Standard update (warns on core file changes)
    /acp-version-update --diff                      Preview changes without applying
    /acp-version-update --preserve-project-core     Skip identity.yml, domain.yml, taxonomy.yml
    /acp-version-update --force                     Skip all confirmation prompts

  Related:
    /acp-version-check-for-updates   Check before updating
    /acp-version-check               Verify version after updating
    /acp-init                        Reload context after updating
```

### 0b. Handle --diff Flag

> **If `--diff` was passed**, run the script with `--diff` only and exit.

**Actions**:
- Run `./agent/scripts/acp.version-update.sh --diff`
- Script prints tier-aware would-change list (no writes)
- Exit without applying updates

**Expected Outcome**: User sees preview; no files modified.

### 1. Verify Prerequisites

**Actions**:
- Verify `./agent/scripts/acp.version-update.sh` exists
- Confirm `AGENTS.md` or `AGENT.md` at project root
- Recommend `git commit` before updating (rollback safety)

**Expected Outcome**: Prerequisites confirmed.

### 2. Run Update Script

Execute tier-aware update (v6.24.0+).

**Actions**:
- Run `./agent/scripts/acp.version-update.sh` with flags from user invocation
- Pass `--yes` when running non-interactively (CI / agent)
- Script behavior:
  - **Tier A** — create-if-absent only (`progress.yaml`, `memory/*`, third-party commands)
  - **Tier B** — preserve when local SHA ≠ upstream (`identity.yml`, wiki, taxonomy)
  - **Tier C** — refresh framework (`acp.*`/`git.*` commands, scripts, `AGENTS.md`)
  - **Tier D** — merge `acp-core` block in manifest only
- `--preserve-project-core` — force-skip all Tier B core/wiki/routing paths
- `--force` — overwrite Tier B even when customized (use with caution)

**Expected Outcome**: Update script completes; project-owned files preserved by default.

### 2b. Upgrade-guard HARD fail (P-UG-1)

When `agent/upstream-delta.yml` exists, `acp.version-update.sh` runs `bash agent/scripts/acp.upgrade-guard.sh` **before** printing the success banner.

- Missing sentinel → **non-zero exit** (HARD fail). Never soft-warn-only.
- Remediation: restore the sentinel string, or delete the collision entry after preferring upstream (ADR-25).
- Skipped under `--diff` (FG-6: dry-run is not verification).
- Complements overwrite-safety from audit-080/M68 — does **not** claim that work is fully solved.

**Expected Outcome**: Local fork enhancements recorded in upstream-delta remain visible after the update.

### 3. Review Changes

Show what was updated.

**Actions**:
- List files that were updated
- Show version change (old → new)
- Highlight major changes from CHANGELOG
- Note any breaking changes

**Expected Outcome**: User understands what changed  

### 4. Verify Update Success

Confirm update completed correctly.

**Actions**:
- Check `AGENTS.md` version (`> vX.Y.Z` or `**Version**:`)
- Verify template files updated
- Confirm scripts updated
- Test that ACP still works

**Expected Outcome**: Update verified successful  

### 5. Suggest Next Actions

Provide recommendations after update.

**Actions**:
- Suggest reviewing changes: `git diff`
- Recommend reading CHANGELOG for details
- Suggest running `@acp-init` to reload context
- If `bash agent/scripts/acp.dupehound.sh should-prompt` says `prompt`, offer the optional dupehound install once for the current ACP version and stamp `integrations.dupehound.install_prompt_version` on accept or decline
- Note any action items from update

**Expected Outcome**: User knows what to do next  

---

## Verification

- [ ] Update script executed successfully
- [ ] AGENTS.md updated to new version
- [ ] Tier C framework files refreshed
- [ ] Tier B customized files preserved (unless `--force`)
- [ ] Tier A data files untouched (`progress.yaml`, `memory/*`, third-party commands)
- [ ] Manifest `acp-core` block merged (other packages retained)
- [ ] No errors encountered
- [ ] When `agent/upstream-delta.yml` exists, upgrade-guard ran and **HARD-failed** on missing sentinel (P-UG-1; never soft-warn-only). Complements overwrite-safety (audit-080); does not claim it is fully solved.

---

## Expected Output

### Files Modified (Tier C — refreshed)
- `AGENTS.md`, `CLAUDE.md`, `.github/copilot-instructions.md`
- `agent/commands/acp.*.md`, `agent/commands/git.*.md`
- `agent/scripts/*.sh`, `agent/schemas/*`

### Files Preserved (Tier A/B — default)
- `agent/progress.yaml`, `agent/memory/*`, `agent/design/*`
- Customized `agent/core/*.yml`, `agent/wiki/*`, `agent/routing/taxonomy.yml`
- Third-party `agent/commands/{ns}.*.md` (ns ≠ acp, git)
- `agent/manifest.yaml` — acp-core block merged only (Tier D)

### Console Output (representative)
```
🔄 Updating ACP Enhanced to latest version...
✓ Framework commands (acp.*, git.* only)
✓ Unmodified project core/wiki/routing preserved
✓ AGENTS.md + sync copies
Review changes: git diff
```

---

## Examples

### Example 1: Applying Available Update

**Context**: `@acp-version-check-for-updates` reported version 1.1.0 available  

**Invocation**: `@acp-version-update`  

**Result**: Updates from 1.0.3 to 1.1.0, shows 15 files updated, suggests reviewing changes with git diff  

### Example 2: Already Up to Date

**Context**: Running update when already on latest version  

**Invocation**: `@acp-version-update`  

**Result**: Script reports already up to date, no files modified  

### Example 3: Update with Git Review

**Context**: Want to see exactly what changed  

**Invocation**: `@acp-version-update` then `git diff`  

**Result**: Updates applied, git diff shows line-by-line changes, can revert specific files if needed  

---

## Related Commands

- [`@acp-version-check-for-updates`](acp.version-check-for-updates.md) - Check before updating
- [`@acp-version-check`](acp.version-check.md) - Verify version after updating
- [`@acp-init`](acp.init.md) - Reload context after updating

---

## Troubleshooting

### Issue 1: Script not found

**Symptom**: Error "acp.version-update.sh not found"  

**Cause**: Older ACP installation without update scripts  

**Solution**: Manually download latest AGENT.md from repository, or install update scripts  

### Issue 2: Network error

**Symptom**: Error "Cannot fetch repository"  

**Cause**: No internet connection or GitHub unavailable  

**Solution**: Check internet connection and try again later  

### Issue 3: Permission denied

**Symptom**: Error "Permission denied" when running script  

**Cause**: Script not executable  

**Solution**: Run `chmod +x agent/scripts/acp.version-update.sh` to make it executable  

### Issue 4: Merge conflicts

**Symptom**: Git reports conflicts after update  

**Cause**: Local modifications to template files  

**Solution**: Review conflicts, keep your changes or accept updates, resolve conflicts manually  

---

## Security Considerations

### File Access
- **Reads**: Current ACP files + upstream clone for SHA compare
- **Writes**: Tier C framework files; Tier D manifest merge only
- **Executes**: `./agent/scripts/acp.version-update.sh`

### Network Access
- **APIs**: GitHub API (via update script)
- **Repositories**: Clones ACP repository to temporary directory

### Sensitive Data
- **Secrets**: Does not access any secrets or credentials
- **Credentials**: Does not access any credentials
- **Project Files**: Does not modify your project-specific files (non-templates)

---

## Notes

- **Backup recommended**: Commit changes before updating
- **Reversible**: Use `git checkout <file>` to revert specific files
- **Tier-aware (v6.24.0+)**: Project-owned Tier B files preserved by default
- **Pre-v6.24.0**: Older scripts blind-overwrote core — commit first
- **Run after update**: Consider running `@acp-init` to reload context

---

**Namespace**: acp  
**Command**: version-update  
**Version**: 1.2.0  
**Created**: 2026-02-16  
**Last Updated**: 2026-07-15  
**Status**: Active  
**Compatibility**: ACP Enhanced v6.24.0+  
**Author**: ACP Project  
