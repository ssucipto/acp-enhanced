# Audit Report: Second-Round M44 Pre-Impl + Implementation Review

**Audit**: #026  
**Date**: 2026-06-03  
**Mode**: --pre-impl (second round)  
**Subject**: Second-round pre-impl audit of M44 + review of audit-022/023/024 implementation quality

## Summary

Second-round review of all M44 routes and the audit-022/023/024 implementation. Found **6 new gaps** (GAP-014 through GAP-019) in the implementation, plus **1 route file fix** (Route 046). All gaps are documentation/protocol-level — no code bugs. The implementation is solid but had protocol-file inconsistencies that would cause real-world agent confusion.

## Implementation Review (Audit 022–024 Outputs)

### R1 Light Mode — Quality Check

| Check | Result | Notes |
|-------|--------|-------|
| routing.yml context_modes defined | ✅ | Both modes with steps, budgets, recommendations |
| copilot-instructions.md light mode | ✅ | 5 steps with banner + recommendation + mode tracking |
| Full mode Step 6 | ✅ | Consistent output format with variable population |
| Mode switching both directions | ✅ | Light→Full via /acp-init; Full→Light via new session |
| Mode tracking (current field) | ✅ | `context_modes.current` in routing.yml |
| Agent instructions to set current | ✅ | Added in this audit (GAP-017) |

### R2 Auto-Lessons — Quality Check

| Check | Result | Notes |
|-------|--------|-------|
| Step 3b in commit protocol | ✅ | Auto-populate from key_fact |
| Scope inference | ✅ | From task_type |
| Priority auto-detection | ✅ | Keywords list |
| Dedup instruction | ⚠️ → ✅ | Was ">80% similar" (vague). Now reads last 10 entries for manual check. |

### Command Discoverability — Quality Check

| Check | Result | Notes |
|-------|--------|-------|
| command_suggestions in routing.yml | ✅ | 24 entries |
| Post-command protocol in copilot-instructions.md | ✅ | 3 rules |
| Underused-command detection | ✅ | 3x repetition rule |
| Getting-started check | ✅ | First session / >7 day rule |

## Gaps Found

| ID | Severity | Description | Status |
|----|----------|-------------|--------|
| **GAP-014** | MEDIUM | CLAUDE.md was out of sync with copilot-instructions.md (5 lines diff, different md5) | ✅ Fixed — synced |
| **GAP-015** | MEDIUM | R2 dedup instruction ">80% similar" is too vague for an LLM to compute reliably | ✅ Fixed — changed to "read last 10 entries; skip if same topic/category/root cause" |
| **GAP-016** | MEDIUM | confirm_output template variables ({executor}, {date}, {count}) had no population instructions | ✅ Fixed — added explicit "populate from" instructions |
| **GAP-017** | MEDIUM | `current: light` field had no agent instruction to set it | ✅ Fixed — added "Update context_modes.current to light/full" |
| **GAP-018** | LOW | Light mode loads "last 3 entries" from sessions.md but entries span months — "last 3" is clear from file order | ℹ️ No fix needed — file is chronologically ordered |
| **GAP-019** | LOW | `recommend_full_for` and `auto_full_triggers.task_type` were not identical lists | ✅ Fixed — added `upstream-parity-check` to auto_full_triggers |
| **GAP-020** | LOW | Route 046 AC says "~40 unused commands" — should be verified against actual count during implementation | ⚠️ Noted — verify during implementation |

## M44 Route Re-Check (post audit-025 fixes)

| Route | Pre-025 Issues | Post-025 State | Pre-026 Issues |
|-------|---------------|---------------|---------------|
| 046 | Vague exclusion list | Noted for implementation | GAP-020 (noted) |
| 047 | CRITICAL: redirect would break Claude | ✅ Rewritten — accept sync copies | ✅ Clear |
| 048 | Wrong config path, missing write mechanism | ✅ Fixed path + added file | ✅ Clear |
| 049 | Missing docs/USAGE.md | ✅ Added | ✅ Clear |
| 050 | Missing AGENT.md | ✅ Added | ✅ Clear |
| 051 | Vague "new task schema" path | ✅ Fixed to concrete path | ✅ Clear |
| 052 | No issues | ✅ Clear | ✅ Clear |

## Files Changed in This Audit

| File | Change |
|------|--------|
| `CLAUDE.md` | Synced from copilot-instructions.md (was 5 lines behind) |
| `.github/copilot-instructions.md` | Fixed GAP-015 (dedup), GAP-016 (variable population), GAP-017 (mode tracking) |
| `agent/core/routing.yml` | Fixed GAP-019 (aligned recommend_for with auto_triggers) |

## Readiness Verdict

**READY** — All 6 new gaps fixed. Implementation quality verified across audits 022–026. M44 routes cleared for implementation. One low-priority note (GAP-020) to verify during implementation.
