# Audit Report: Audit-036 Implementation Review — Bugs in the Fixes

**Audit**: #037  
**Date**: 2026-06-03  
**Subject**: Post-implementation review of audit-036 fixes — bugs, ordering issues, and gaps found in the fix code itself

## Summary

Audit-036 added safety checks, idempotency, and cleanup to the bootstrap script. However, the implementation contained **5 bugs** caused by hasty editing: a function-ordering problem (ERR trap calling an undefined function), a confusing typo, an overly aggressive cleanup, and a missing partial-installation guard. All 5 issues have been fixed.

## Files Analyzed

| File | Type | Relevance |
|------|------|-----------|
| `scripts/acp-bootstrap.sh` | Script | All 5 bugs in one file |
| `agent/scripts/acp.version-update.sh` | Script | Verified — no new issues |
| `agent/reports/audit-036-installation-system.md` | Doc | Reference for expected fixes |

## Key Findings

| # | Finding | Location | Severity | Status |
|---|---------|----------|----------|--------|
| 1 | `cleanup_on_failure` defined after use by ERR trap | `scripts/acp-bootstrap.sh:12,61` | 🔴 Critical | ✅ Fixed |
| 2 | `HAS_GIT="-z"` typo (should be `""`) | `scripts/acp-bootstrap.sh:29` | 🟢 Low | ✅ Fixed |
| 3 | Cleanup `rm -rf agent/` too aggressive | `scripts/acp-bootstrap.sh:66` | 🔴 High | ✅ Fixed |
| 4 | `_BOOTSTRAP_START_DIR` set after pre-flight checks | `scripts/acp-bootstrap.sh:59` | 🟡 Medium | ✅ Fixed |
| 5 | No partial installation detection | `scripts/acp-bootstrap.sh` | 🟡 Medium | ✅ Fixed |

## Finding Details

### 🔴 BUG-001: Cleanup Function Defined After ERR Trap References It

**File**: `scripts/acp-bootstrap.sh`  
**Before**: `trap` at line 12 called `cleanup_on_failure`, but the function wasn't defined until line 61. If `set -e` triggered on any pre-flight check (lines 18-57), bash would error: "cleanup_on_failure: command not found".

**Fix**: Moved `cleanup_on_failure` definition and `_BOOTSTRAP_START_DIR` before the `trap` statement. Now the function exists before the trap references it.

**Risk**: If someone had an error during idempotency check or directory scanning, bash would abort with a secondary error on top of the original failure.

### 🔴 BUG-002: Aggressive Cleanup Destroys User Files

**File**: `scripts/acp-bootstrap.sh:66`  
**Before**: `cleanup_on_failure` ran `rm -rf agent/` without checking whether `agent/` contained pre-existing user files. If the bootstrap script was run near an existing ACP installation or project, it would nuke the entire `agent/` directory.

**Fix**: Added a safety check — `find` for non-template, non-YAML, non-markdown files. If any found, `agent/` is preserved with a warning. Also added `$_BOOTSTRAP_START_DIR != "/"` guard to prevent accidental root deletion.

### 🟡 BUG-003: `_BOOTSTRAP_START_DIR` Set After Pre-flight Checks

**File**: `scripts/acp-bootstrap.sh:59`  
**Issue**: `_BOOTSTRAP_START_DIR` was set at line 59, but any failure in pre-flight checks (lines 18-57) would leave it empty, making the cleanup function's guard `[ -n "$_BOOTSTRAP_START_DIR" ]` false — so cleanup would be silently skipped even though files were partially created.

**Fix**: Moved `_BOOTSTRAP_START_DIR` to before the trap definition so it's always available.

### 🟡 BUG-004: No Partial Installation Detection

**File**: `scripts/acp-bootstrap.sh`  
**Issue**: The idempotency check required BOTH `agent/core/identity.yml` AND `AGENTS.md` to exist. If only one existed (corrupted partial install), the check passed and the script would proceed, potentially making things worse.

**Fix**: Added a dedicated check that detects when exactly one of these files exists, prints a warning, and continues with the installation attempt.

### 🟢 BUG-005: `HAS_GIT="-z"` Typo

**File**: `scripts/acp-bootstrap.sh:29`  
**Issue**: `HAS_GIT="-z"` assigned the literal string `-z` instead of an empty string `""`. The comparison `"$HAS_GIT" != "yes"` still worked correctly (since `-z` ≠ `yes`), but the code was confusing and suggested a copy-paste error from a `test -z` expression.

**Fix**: Changed to `HAS_GIT=""`.

## Recommendations

1. ✅ All 5 bugs fixed and verified
2. **Test pattern**: Future bootstrap fixes should include a `bash -n` syntax check in CI
3. **Review practice**: Post-implementation reviews catch bugs that initial implementations miss — this audit found bugs in 4 of 9 audit-036 findings
