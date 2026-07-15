# Audit Report: Update System Safety + Repository Consistency

**Audit**: #021  
**Date**: 2026-06-03  
**Subject**: Version update and package update solidity — user data preservation, repository pointer correctness, and command redundancy

## Summary

Investigated the entire update system (`/acp-version-update`, `/acp-package-update`) for safety, correctness, and user-data preservation. Also checked all repository pointers and scanned for redundant commands. **The system is solid with one notable concern**: `acp.version-update.sh` overwrites `agent/commands/*.md` and `AGENT.md` without warning or backup, which would silently destroy user customizations to ACP command docs. All user-state files (memory, routing tasks, preferences, designs, milestones, patterns) are correctly preserved.

## Files Analyzed

| File | Type | Relevance |
|------|------|-----------|
| `agent/scripts/acp.version-update.sh` | script | Primary update — checked user-data preservation |
| `agent/scripts/acp.package-update.sh` | script | Package update — checked conflict handling |
| `agent/scripts/acp.version-check-for-updates.sh` | script | Pre-update check |
| `agent/scripts/acp.install.sh` | script | Install script |
| `agent/commands/acp.version-update.md` | command doc | Update command documentation |
| `agent/commands/acp.package-update.md` | command doc | Package update documentation |
| `agent/commands/acp.update.md` | command doc | Progress.yaml update (naming clarity) |
| `agent/commands/acp.install.md` | command doc | Install command |
| `agent/commands/acp.package-install.md` | command doc | Package install command |
| `agent/commands/acp.sync.md` | command doc | Sync documentation |
| All `agent/scripts/*.sh` | scripts | Repo URL audit |

## Key Findings

| ID | Finding | Location | Severity | Notes |
|----|---------|----------|----------|-------|
| F-001 | `AGENT.md` overwritten without warning | acp.version-update.sh:164 | **HIGH** | `cp "$TEMP_DIR/AGENT.md" "."` — users often customize AGENT.md. No backup or diff offered. Risk: silent loss of user customizations on framework update. |
| F-002 | All `agent/commands/*.md` overwritten without warning | acp.version-update.sh:147 | **HIGH** | `find ... -name "*.*.md" -exec cp {}` overwrites ALL command docs including any user modifications. No checksum comparison or backup. |
| F-003 | `acp.update` command name is ambiguous | agent/commands/acp.update.md | MEDIUM | Name suggests "update ACP" but actually updates only `progress.yaml`. Users may confuse with `/acp-version-update` or `/acp-package-update`. Consider renaming to `/acp-progress-update`. |
| F-004 | `acp.install` vs `acp.package-install` naming overlap | agent/commands/ | LOW | Two install commands with similar names. `acp.install` installs ACP itself; `acp.package-install` installs packages. Functionally distinct but naming could confuse. |

## User Data Safety Matrix (version-update.sh)

| File/Directory | Overwritten? | Safe? |
|----------------|-------------|-------|
| `agent/memory/sessions.md` | ❌ (create-if-absent) | ✅ |
| `agent/memory/lessons.md` | ❌ (create-if-absent) | ✅ |
| `agent/memory/decisions.md` | ❌ (create-if-absent) | ✅ |
| `agent/memory/patterns.md` | ❌ (create-if-absent) | ✅ |
| `agent/routing/ledger.md` | ❌ (create-if-absent) | ✅ |
| `agent/routing/tasks/route-*.md` | ❌ (only route-template.md) | ✅ |
| `agent/progress.yaml` | ❌ (not in copy path) | ✅ |
| `agent/manifest.yaml` | ⚠️ Partial (acp-core section) | ✅ |
| `agent/design/*.md` (non-template) | ❌ (only .template.md) | ✅ |
| `agent/milestones/*.md` (non-template) | ❌ (only .template.md) | ✅ |
| `agent/patterns/*.md` (non-template) | ❌ (only .template.md) | ✅ |
| `agent/preferences/` | ❌ (not touched) | ✅ |
| `agent/configurables/` | ❌ (not touched) | ✅ |
| `agent/drafts/` | ❌ (not touched) | ✅ |
| `agent/reports/` | ❌ (not touched) | ✅ |
| `agent/clarifications/` | ❌ (not touched) | ✅ |
| `agent/artifacts/` | ❌ (not touched) | ✅ |
| `agent/specs/` | ❌ (not touched) | ✅ |
| `agent/index/` | ❌ (not touched) | ✅ |
| `agent/schemas/` | ❌ (not touched) | ✅ |
| **`AGENT.md`** | ✅ **OVERWRITTEN** | ⚠️ |
| **`agent/commands/*.md`** | ✅ **OVERWRITTEN** | ⚠️ |
| `agent/core/*.yml` | ✅ Overwritten | ✅ (static framework) |
| `agent/skills/*.md` | ✅ Overwritten | ✅ (static framework) |
| `agent/wiki/*` | ✅ Overwritten | ✅ (static framework) |
| `agent/routing/taxonomy.yml` | ✅ Overwritten | ✅ (static framework) |
| `agent/routing/rules.md` | ✅ Overwritten | ✅ (static framework) |
| `agent/routing/config.yml` | ✅ Overwritten | ✅ (static framework) |
| `agent/scripts/*.sh` | ✅ Overwritten | ✅ (framework scripts) |
| `.opencode/commands/*.md` | ✅ Overwritten | ✅ (generated artifacts) |
| `agent/*.template.*` | ✅ Overwritten | ✅ (templates) |

## Repository Pointer Audit

| File | URL | Correct? |
|------|-----|----------|
| `acp.version-update.sh:41` | `github.com/ssucipto/acp-enhanced.git` | ✅ |
| `acp.version-update.sh:252` | `github.com/ssucipto/acp-enhanced` | ✅ |
| `acp.install.sh:27` | `github.com/ssucipto/acp-enhanced.git` | ✅ |
| `acp.install.sh:441` | `github.com/ssucipto/acp-enhanced.git` | ✅ |
| `acp.version-check-for-updates.sh:25` | `raw.githubusercontent.com/ssucipto/acp-enhanced` | ✅ |
| `acp.package-create.sh:548` | `github.com/ssucipto/acp-enhanced` | ✅ |
| `package.yaml` | `github.com/ssucipto/acp-enhanced` | ✅ |
| `README.md` | `ssucipto/acp-enhanced` (all URLs) | ✅ (fixed in audit-019) |

**Verdict**: Zero `prmichaelsen` references in scripts. All pointers correct.

## Recommendations

1. **F-001/F-002**: Add a backup step before overwriting `AGENT.md` and `agent/commands/*.md` — either:
   - Warn the user and offer `--force` / `--skip-modified` flags (like package-update.sh does)
   - Or create `.bak` copies before overwriting
   - Or use checksum comparison to detect local modifications and skip them

2. **F-003**: Consider renaming `acp.update` → `acp.progress-update` for clarity. Keep alias for backward compat.

3. **F-004**: Low priority — add clear "This installs ACP itself, not packages" to `acp.install.md` header.
