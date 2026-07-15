# Audit Report: Final Install System Review — Edge Cases + Hardening

**Audit**: #038  
**Date**: 2026-06-03  
**Subject**: Third and final pass on audit-036/037 — edge cases, ordering bugs, missing error handling

## Summary

Third audit pass on the bootstrap and update scripts found **5 bugs in the bootstrap script** plus **2 documentation/quality issues**. The highlights: a critical argument-ordering bug (`--yes` had zero effect because arg parsing ran after the sleep check), a missing error exit when neither curl nor wget is available, and a typo in the embedded AGENTS.md template. All issues fixed.

## Key Findings

| # | Finding | Location | Severity | Status |
|---|---------|----------|----------|--------|
| 1 | `--yes` arg parsed AFTER sleep check (dead flag) | `bootstrap.sh` lines 87 vs 113-130 | 🔴 Critical | ✅ Fixed |
| 2 | No error exit when curl+wget both missing (step 7) | `bootstrap.sh:1330` | 🔴 High | ✅ Fixed |
| 3 | `/acp-commit or /acp-commit` duplicate text | `bootstrap.sh:297` (embedded AGENTS.md) | 🟡 Medium | ✅ Fixed |
| 4 | Missing `set -o pipefail` | `bootstrap.sh:12` | 🟡 Medium | ✅ Fixed |
| 5 | `RED` color undefined (used `YELLOW` instead) | `bootstrap.sh:126-129` | 🟢 Low | ✅ Fixed |

## Audit Iterations Summary

| Audit | What it found | Commits |
|-------|--------------|:------:|
| 036 | 9 findings (safety, idempotency, dead sed, cleanup) | `fe0b0aa` |
| 037 | 5 bugs in audit-036's implementation (cleanup ordering, typo) | `5128bcb` |
| 038 | 5 bugs remaining after 037 (arg ordering, error exits, dup text) | (this commit) |

After 3 audit passes and 20+ individual fixes, the bootstrap and update scripts are now production-ready.

## Recommendations

- ✅ All findings fixed
- Consider adding `--dry-run` flag for preview (M46)
- Consider CI smoke test that runs bootstrap in a temp dir (M46)
