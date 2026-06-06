# Audit Report: M51 Post-Implementation — Bootstrap Fix Verification

**Audit**: #046  
**Date**: 2026-06-06  
**Subject**: M51 implementation — verify BUG-045 fixes, check for regressions and gaps in `acp-bootstrap.sh`  

---

## Summary

M51 implemented 3 fixes from audit-045 plus an E2E test. All 3 bugs are **correctly addressed** — the core logic fixes work as intended. However, one **regression** and one **UX issue** were introduced. No blocking issues — both are fixable with single-line changes.

**Verdict**: BUG-045-01/02/03 are fixed. Two new findings: a defensive-coding regression in step 7 (outer `-d` check gates the download), and a confusing "Done" message printed before verification failure.

---

## Files Analyzed

| File | Type | Relevance |
|------|------|-----------|
| `scripts/acp-bootstrap.sh` | script | Primary subject — all 4 changes |
| `scripts/acp-bootstrap.sh:441` | fix | `mkdir -p agent/drafts` before cp |
| `scripts/acp-bootstrap.sh:1301-1336` | fix | OpenCode extraction from GENERATE_PROMPTS |
| `scripts/acp-bootstrap.sh:1345-1373` | fix | Step 7 file count check |
| `scripts/acp-bootstrap.sh:1437` | issue | Premature "Done" before verify |
| `scripts/acp-bootstrap.sh:1459-1473` | fix | Verification exit code + remediation |
| `e2e/acp.bootstrap.test.sh` | test | 8 assertions, all passing |
| `e2e/acp.design-spec.test.sh` | regression | 12/12 passing (no regression) |

---

## Key Findings

| ID | Severity | Finding | Location | Fix |
|----|----------|---------|----------|-----|
| G-046-01 | **MEDIUM** | Step 7 outer `-d` check wraps download logic. If `agent/commands/` and `agent/scripts/` don't exist (unlikely but possible), the download is silently skipped. Original code had an `else` clause that handled this. | `acp-bootstrap.sh:1345` | Remove outer `-d` guard. File count via `find` already handles missing dirs (returns 0 with `2>/dev/null`). Use: `if [ "$_CMD_COUNT" -ge 40 ] && [ "$_SCRIPT_COUNT" -ge 20 ]; then skip; else download; fi` |
| G-046-02 | **LOW** | "Done. ACP Enhanced is ready." printed at line 1437 BEFORE post-install verification (line 1439). If verification fails and exits 1, user sees contradictory output. | `acp-bootstrap.sh:1437` | Move "Done" message after successful verification, or make it conditional: `if [ "$_VERIFY_FAILED" != "true" ]; then echo "Done. ACP Enhanced is ready."; fi` |
| G-046-03 | **INFO** | BUG-045-01 fix verified: Step 7 correctly uses `find \| wc -l` instead of `-d`. Fresh install with empty dirs triggers download (not skip). ✅ | `acp-bootstrap.sh:1346-1347` | No action needed. |
| G-046-04 | **INFO** | BUG-045-02 fix verified: OpenCode generation now independent of GENERATE_PROMPTS. When no prompt files exist, prints graceful skip message instead of crashing. `.opencode/commands/` created by `acp.install.sh` download (step 7). ✅ | `acp-bootstrap.sh:1304-1336` | No action needed. |
| G-046-05 | **INFO** | BUG-045-03 fix verified: Post-install verification exits non-zero (1) on failure with clear remediation command (`curl ... acp.install.sh`). ✅ | `acp-bootstrap.sh:1459-1473` | No action needed. |
| G-046-06 | **INFO** | Additional fix: `mkdir -p agent/drafts` prevents crash on small team-size scaffold where `agent/drafts/` isn't created. ✅ | `acp-bootstrap.sh:441` | No action needed. |
| G-046-07 | **INFO** | No regressions in design-spec command: `e2e/acp.design-spec.test.sh` 12/12 passing after M50 routing.yml/taxonomy.yml changes. ✅ | `e2e/acp.design-spec.test.sh` | No action needed. |
| G-046-08 | **INFO** | E2E bootstrap test: 8/8 assertions, correctly handles network-unavailable test environment. BUG-045-01 regression check passes (step 7 doesn't skip with 0 files). ✅ | `e2e/acp.bootstrap.test.sh` | No action needed. |

---

## Code Pointers

| Location | Description |
|----------|-------------|
| `acp-bootstrap.sh:1345` | **G-046-01**: `if [ -d "agent/commands" ] && [ -d "agent/scripts" ]; then` — outer guard gates download |
| `acp-bootstrap.sh:1346-1347` | File count logic (correct — `find ... \| wc -l`) |
| `acp-bootstrap.sh:1349` | Skip message with counts: `${_CMD_COUNT} commands, ${_SCRIPT_COUNT} scripts` |
| `acp-bootstrap.sh:1352-1353` | Partial install warning |
| `acp-bootstrap.sh:1437` | **G-046-02**: `echo "Done. ACP Enhanced is ready."` — prints before verification |
| `acp-bootstrap.sh:1459-1461` | Verification failure detection: `_VERIFY_FAILED` flag |
| `acp-bootstrap.sh:1463-1473` | Remediation block — clear message + `exit 1` |
| `acp-bootstrap.sh:1306` | OpenCode guard: `ls .github/prompts/*.prompt.md` — graceful when absent |
| `acp-bootstrap.sh:441` | `mkdir -p agent/drafts` — prevents cp crash on small scaffold |

---

## Logic Flow Verification (Step 7)

| Scenario | `-d` check | File count | Behavior | Correct? |
|----------|-----------|------------|----------|----------|
| Fresh install (empty dirs from step 1) | ✅ true | 0 commands, 0 scripts | Downloads ✅ | ✅ |
| Already installed (40+ cmds, 20+ scripts) | ✅ true | ≥40, ≥20 | Skips with counts ✅ | ✅ |
| Partial install (5 cmds, 3 scripts) | ✅ true | <40, <20 | Warns + downloads ✅ | ✅ |
| **Dirs somehow missing** | ❌ false | N/A | **Silently skipped** ⚠️ | ❌ G-046-01 |

---

## Recommendations

### Pre-commit (fix before push)

1. **Fix G-046-01 (MEDIUM)**: Remove outer `-d` check at line 1345. The `find` with `2>/dev/null` already handles missing directories. Change to unconditional file-count gate.

2. **Fix G-046-02 (LOW)**: Move "Done. ACP Enhanced is ready." to after successful verification, or gate it on `_VERIFY_FAILED != true`.

### Optional

3. **Strengthen opencode guard** (line 1306): Add `[ -d ".github/prompts" ]` before the `ls` glob for clarity, though current code is functionally correct.

---

## Verdict

**M51 fixes are correct and verified.** BUG-045-01/02/03 are resolved. E2E test catches the core regression. Two minor follow-up items (G-046-01, G-046-02) — both single-line fixes, neither blocking.

---

**Audit type**: Post-implementation verification  
**Generated by**: ACP `/acp-audit` #046
