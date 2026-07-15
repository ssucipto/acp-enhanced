# Audit Report: ACP Enhanced Updating System Clarity

**Audit**: #019  
**Date**: 2026-06-03  
**Subject**: `/acp-version-update` vs `/acp-package-update` — review for confusion between updating ACP Enhanced (ssucipto/acp-enhanced) vs the original fork (prmichaelsen/agent-context-protocol)

## Summary

Investigated the entire updating system across three update-related commands (`/acp-version-update`, `/acp-package-update`, `/acp-version-check-for-updates`) and their scripts, command docs, and README documentation. The **scripts themselves are correct** — all three version scripts hardcode `ssucipto/acp-enhanced` as the upstream. The `/acp-version-update` vs `/acp-package-update` distinction is documented clearly in their respective command docs. However, **README.md contains stale references to `prmichaelsen/agent-context-protocol`** in its install and update instructions that would cause users to install or update from the original fork instead of ACP Enhanced.

## Files Analyzed

| File | Type | Relevance |
|------|------|-----------|
| `agent/commands/acp.version-update.md` | command doc | Primary update command — updates ACP Enhanced framework |
| `agent/commands/acp.package-update.md` | command doc | Package update command — updates third-party packages |
| `agent/commands/acp.version-check-for-updates.md` | command doc | Pre-update check command |
| `agent/commands/acp.version-check.md` | command doc | Current version display |
| `agent/commands/acp.audit.md` | command doc | Audit command definition (this audit's executor) |
| `agent/scripts/acp.version-update.sh` | script | Updater script — clones from ssucipto/acp-enhanced |
| `agent/scripts/acp.version-check-for-updates.sh` | script | Checks AGENT.md against ssucipto/acp-enhanced |
| `agent/scripts/acp.version-check.sh` | script | Reads local AGENT.md version |
| `agent/scripts/acp.package-update.sh` | script | Updates packages from their own source repos |
| `agent/scripts/acp.install.sh` | script | Install script — clones from ssucipto/acp-enhanced |
| `agent/manifest.yaml` | config | Empty packages map, no acp-core entry |
| `package.yaml` | config | Correct: homepage/repo = ssucipto/acp-enhanced, fork_of = prmichaelsen/agent-context-protocol |
| `README.md` | docs | **HAS ISSUES** — install/update curl commands point to prmichaelsen |
| `scripts/acp-bootstrap.sh` | script | Bootstrap — correctly uses ssucipto/acp-enhanced |
| `agent/core/identity.yml` | config | Correct: fork_of = prmichaelsen/agent-context-protocol |
| `agent/memory/decisions.md` | memory | ADR-7 confirms no shared ancestry, merge impossible |

## Key Findings

| ID | Finding | Location | Severity | Notes |
|----|---------|----------|----------|-------|
| F-001 | README install command points to upstream fork | README.md:562 | **HIGH** | `curl ... prmichaelsen/agent-context-protocol .../acp.install.sh` — should be `ssucipto/acp-enhanced`. Users running this would install the original ACP, not ACP Enhanced. |
| F-002 | README update command points to upstream fork | README.md:570 | **HIGH** | `curl ... prmichaelsen/agent-context-protocol .../acp.version-update.sh` — should be `ssucipto/acp-enhanced`. Users running this would pull the upstream script which itself clones `ssucipto/acp-enhanced` (the script is self-correcting), but the bootstrap path is confusing. |
| F-003 | README install command lacks section header | README.md:560–564 | LOW | The `curl ... acp.install.sh` command floats between the macOS note and "Update an Existing Project" without a clear section header. Contextually it's a "manual install" alternative to bootstrap. |
| F-004 | manifest.yaml acp-core update in version-update.sh is dead code | agent/scripts/acp.version-update.sh:235–248 | LOW | The sed block targets `/^  acp-core:/` in manifest.yaml, but the current manifest has `packages: {}` — no acp-core entry. The rule silently no-ops. Not harmful, but misleading. |

## Script Verification

All three version scripts correctly use `ssucipto/acp-enhanced`:

| Script | URL | Correct? |
|--------|-----|----------|
| `acp.version-update.sh` | `REPO_URL="https://github.com/ssucipto/acp-enhanced.git"` (line 27) | ✅ |
| `acp.version-check-for-updates.sh` | `REPO_URL="https://raw.githubusercontent.com/ssucipto/acp-enhanced/mainline"` (line 25) | ✅ |
| `acp.version-check.sh` | No network — reads local AGENT.md only | ✅ |
| `acp.install.sh` | `REPO_URL="https://github.com/ssucipto/acp-enhanced.git"` (line 27) | ✅ |
| `acp-bootstrap.sh` | Correctly uses ssucipto/acp-enhanced | ✅ |

## Command Doc Clarity

| Command | Purpose | Upstream | Clear? |
|---------|---------|----------|--------|
| `/acp-version-update` | Update ACP Enhanced framework files | ssucipto/acp-enhanced | ✅ |
| `/acp-version-check-for-updates` | Check if newer ACP Enhanced available | ssucipto/acp-enhanced | ✅ |
| `/acp-package-update` | Update third-party packages | Per-package source repos | ✅ |

Each command doc clearly states its purpose and relation to the others. No confusion between `/acp-version-update` and `/acp-package-update` in the implementation.

## Recommendations

1. **Fix README.md:562** — Change `prmichaelsen/agent-context-protocol` → `ssucipto/acp-enhanced` in the install curl command
2. **Fix README.md:570** — Change `prmichaelsen/agent-context-protocol` → `ssucipto/acp-enhanced` in the update curl command
3. **Add section header** — Label the install curl command as "### Manual Install (Alternative to Bootstrap)" or similar
4. **Consider removing F-004 dead code** — The manifest acp-core update in `version-update.sh` is dead code with the current manifest structure; either wire it up or remove it
