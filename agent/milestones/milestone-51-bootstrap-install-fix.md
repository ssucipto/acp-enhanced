# Milestone 51 — Bootstrap Install Fix (v6.9.4)

**Status**: Completed  
**Priority**: P0  
**Started**: null  
**Target**: 2026-06-06  
**Estimated**: 0.2 day  
**Progress**: 0% (0/4 tasks)

---

## Goal

Fix 3 bugs discovered in audit-045 that cause `acp-bootstrap.sh` to silently produce broken installs on all fresh curl-pipe-bash invocations. Every new user since the step-1 directory creation was introduced gets 0 command files and 0 script files.

---

## Deliverables

| Route | Task | Priority | Effort |
|-------|------|----------|--------|
| 113 | Fix BUG-045-01: Step 7 directory check → file count check | P0 | Low |
| 114 | Fix BUG-045-02: Extract opencode generation from GENERATE_PROMPTS block | P0 | Low |
| 115 | Fix BUG-045-03: Exit non-zero on verification failure + remediation message | P0 | Low |
| 116 | Add E2E bootstrap smoke test (fresh install in temp dir) | P1 | Medium |

---

## Success Criteria

1. **Fresh install works**: `curl .../acp-bootstrap.sh | bash` on a new project produces 40+ commands and 20+ scripts
2. **OpenCode independent**: `.opencode/commands/` generated when `GENERATE_OPENCODE=true` regardless of `GENERATE_PROMPTS`
3. **Failed verify exits non-zero**: Bootstrap exits 1 when post-install verification fails
4. **E2E test covers bootstrap**: Test creates temp project, runs bootstrap, verifies file counts

---

## Dependencies

- audit-045 (findings + carryovers)
- `scripts/acp-bootstrap.sh` (single file, all fixes colocated)

---

## Notes

- All 3 bugs are in `scripts/acp-bootstrap.sh` — fixes are <20 lines total
- The pre-flight check (line 85-100) already uses correct file-count logic — step 7 fix follows same pattern
- OpenCode generation (lines 1301-1330) needs extraction from GENERATE_PROMPTS block
- Verification (lines 1420-1445) needs exit code + remediation message
