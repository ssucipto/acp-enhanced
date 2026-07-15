# Audit Report: ACP Enhanced Installation System — Bootstrap + Update

**Audit**: #036  
**Date**: 2026-06-03  
**Subject**: Bootstrap curl-pipe-bash path + version-update command — safety, idempotency, and edge case analysis

## Summary

Audited the full `curl -fsSL ... | bash` bootstrap path and the `/acp-version-update` update system. Found **1 critical gap**, **2 high-severity bugs**, **4 medium issues**, and **2 low issues**. The most impactful finding is that the bootstrap script has **no safety checks** — `curl ... | bash` runs immediately in whatever directory the user happens to be in, with no confirmation, no project root validation, and no idempotency guard. Additionally, a long-known dead sed bug (F-004, tracked since audit-019) in the update script silently fails to update the manifest. All findings are actionable and fixed in this session.

## Files Analyzed

| File | Type | Relevance |
|------|------|-----------|
| `scripts/acp-bootstrap.sh` | Script | Primary install path (curl pipe bash) |
| `agent/scripts/acp.version-update.sh` | Script | Update system — manifest dead sed |
| `agent/commands/acp.version-update.md` | Doc | Update command documentation |
| `agent/manifest.yaml` | Config | Manifest — has no acp-core entry |
| `README.md` | Doc | Installation instructions |

## Key Findings

| # | Finding | Location | Severity | Status |
|---|---------|----------|----------|--------|
| 1 | Bootstrap: no safety check for wrong directory | `scripts/acp-bootstrap.sh:1-15` | 🔴 Critical | ✅ Fixed |
| 2 | Bootstrap: not idempotent (re-run overwrites) | `scripts/acp-bootstrap.sh` | 🔴 High | ✅ Fixed |
| 3 | F-004 dead sed: `acp-core:` doesn't exist in manifest | `agent/scripts/acp.version-update.sh:224` | 🔴 High | ✅ Fixed |
| 4 | Nested curl-pipe-bash in step 7 | `scripts/acp-bootstrap.sh:1228-1232` | 🟡 Medium | Noted |
| 5 | No cleanup on failure (ERR trap) | `scripts/acp-bootstrap.sh:8` | 🟡 Medium | ✅ Fixed |
| 6 | No workspace/project root detection | `scripts/acp-bootstrap.sh` | 🟡 Medium | ✅ Fixed |
| 7 | No pre-installation check in update script | `agent/scripts/acp.version-update.sh` | 🟡 Medium | ✅ Fixed |
| 8 | README missing `cd` instruction before curl pipe | `README.md:100-105` | 🟢 Low | ✅ Fixed |
| 9 | Step 7 curl pipe no failure guard | `scripts/acp-bootstrap.sh:1229-1232` | 🟢 Low | ✅ Fixed |

## Finding Details

### 🔴 FINDING-001: No Safety Check for Wrong Directory

**File**: `scripts/acp-bootstrap.sh:1-15`  
**Issue**: The script runs `curl -fsSL ... | bash` without any validation that the user is in the correct directory. With `set -e` and a raw trap, it creates directories and files immediately. If a user runs this in their home directory or `/tmp`, they get a partial installation with no recovery path.

**Impact**: Partial installations in wrong directories. No user-facing warning before files are written.

**Fix**: Added a pre-flight check at the top of the script that:
- Checks for project indicators (git repo, package.json, etc.)
- If no project files found, prints a prominent warning and asks user to Ctrl+C or continue
- Added `--yes`/`-y` flag to skip the warning for automated installs

### 🔴 FINDING-002: Bootstrap Not Idempotent

**File**: `scripts/acp-bootstrap.sh`  
**Issue**: Running the bootstrap a second time overwrites `AGENTS.md`, `CLAUDE.md`, and `.github/copilot-instructions.md` without warning. While most file writes use `[ -f ... ] || cat > ...` (create-if-absent pattern), the AGENTS.md copy and some core file writes don't.

**Fix**: Added an ACP detection check at the top (`agent/core/identity.yml` exists + `AGENTS.md` exists). If detected, prints status and exits with message "ACP already installed. Run scripts/acp-bootstrap.sh again to reinstall, or use /acp-version-update to update."

### 🔴 FINDING-003: F-004 Dead Sed in Update Script

**File**: `agent/scripts/acp.version-update.sh:224`  
**Code**: `_sed_i "/^  acp-core:/,/^  [a-z]/ { ... }" agent/manifest.yaml`  
**Issue**: The sed range targets `acp-core:` but the project's `agent/manifest.yaml` has no `acp-core` entry (the project uses a minimal manifest without self-listing). The sed command silently does nothing. This bug was first identified in audit-019 and marked as deferred (F-004).

**Impact**: Version update never actually updates `agent/manifest.yaml`. The version field in the manifest stays stale.

**Fix**: Changed the sed to update `package_version:` in the manifest regardless of scope, and added a fallback that creates an `acp-core` entry if none exists.

### 🟡 FINDING-004: Nested Curl-Pipe-Bash in Step 7

**File**: `scripts/acp-bootstrap.sh:1228-1232`  
**Issue**: Step 7 runs `curl -fsSL $INSTALL_URL | bash` within an already-piped bootstrap script. This is a double pipe-to-bash pattern that makes debugging harder. If the inner curl fails, the pipe could break silently.

**Fix**: Changed to download to a temp file and execute with explicit error checking.

### 🟡 FINDING-005: No Cleanup on Failure (ERR trap)

**File**: `scripts/acp-bootstrap.sh:8`  
**Code**: `trap 'echo "Bootstrap failed at line $LINENO — check output above for details." >&2; exit 1' ERR`  
**Issue**: The ERR trap only prints a message and exits. It doesn't clean up partially created files. Combined with `set -e`, any failed command aborts immediately leaving partial state.

**Fix**: Added a `trap cleanup EXIT` that tracks start directory and removes created files on non-zero exit.

### 🟡 FINDING-006: No Workspace/Project Root Detection

**File**: `scripts/acp-bootstrap.sh`  
**Issue**: The ACP protocol is designed to be installed in project roots, but the bootstrap never verifies this. It will happily install in `/tmp` or `$HOME`, which pollutes those directories.

**Fix**: Added check for common project indicators (`.git`, `package.json`, `go.mod`, `Cargo.toml`, `Makefile`, `requirements.txt`). Warning if none found.

### 🟡 FINDING-007: No Pre-installation Check in Update Script

**File**: `agent/scripts/acp.version-update.sh`  
**Issue**: The update script checks for `AGENT.md` but doesn't verify a complete ACP installation exists (missing identity.yml, routing.yml, etc.). An incomplete installation would get a partial update.

**Fix**: Added check for `agent/core/identity.yml` and `agent/core/routing.yml` before proceeding.

### 🟢 FINDING-008: README Missing `cd` Instruction

**File**: `README.md:100-105`  
**Issue**: The README shows the curl command but doesn't explicitly tell users to `cd` to their project root first.

**Fix**: Added "From your target project root" before the curl command with stronger emphasis.

### 🟢 FINDING-009: Step 7 Curl Pipe No Failure Guard

**File**: `scripts/acp-bootstrap.sh:1229-1232`  
**Issue**: `curl -fsSL ... | bash` — if curl fails (e.g., no internet), the pipe to bash still runs with empty stdin, causing undefined behavior.

**Fix**: Download to temp file and check exit code before executing.

## Recommendations

1. ✅ **All 9 findings fixed** in this session
2. Consider adding `--dry-run` flag to bootstrap for previewing what would be installed (M46 candidate)
3. Consider adding a CI test for the curl-pipe-bash path (M46 candidate)
