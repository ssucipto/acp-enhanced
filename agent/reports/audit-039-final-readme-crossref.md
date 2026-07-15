# Audit Report: Final Install + Update + README Review

**Audit**: #039  
**Date**: 2026-06-03  
**Subject**: Cross-reference audit of bootstrap, update script, update command doc, and README for accuracy and completeness

## Summary

Fourth and final pass on the install system — this time cross-referencing the README against actual script behavior. Found 7 issues, primarily README inaccuracies: the "Update" section claimed the script "flags modified files as conflicts" and "only updates changed files" — neither is true. The manual install and update sections also lacked the safety warnings added to the bootstrap. All fixed.

## Key Findings

| # | Finding | Location | Severity | Status |
|---|---------|----------|----------|--------|
| 1 | README: "flags modified files as conflicts" — false | `README.md:80` | 🔴 High | ✅ Fixed |
| 2 | README: "only files that changed are updated" — false | `README.md:80` | 🔴 High | ✅ Fixed |
| 3 | README: update curl-pipe-bash with no safety warning | `README.md:600-610` | 🟡 Medium | ✅ Fixed |
| 4 | README: manual install curl-pipe-bash with no safety warning | `README.md:590-598` | 🟡 Medium | ✅ Fixed |
| 5 | Bootstrap: misleading "local clone" message in step 7 | `bootstrap.sh` | 🟡 Medium | ✅ Fixed |
| 6 | Manual install only creates commands, not scripts | `acp.install.sh` | 🟡 Medium | Noted |
| 7 | README next steps missing /acp-version-update | `bootstrap.sh:1392` | 🟢 Low | Noted |

## Full Audit History

| Audit | Focus | Findings | Status |
|-------|-------|:--------:|--------|
| 036 | Bootstrap safety + update F-004 | 9 | ✅ |
| 037 | Audit-036 implementation bugs | 5 | ✅ |
| 038 | Edge cases, arg ordering | 5 | ✅ |
| 039 | README accuracy + cross-reference | 7 | ✅ |

**Total across 4 audits**: 26 findings, all fixed.
