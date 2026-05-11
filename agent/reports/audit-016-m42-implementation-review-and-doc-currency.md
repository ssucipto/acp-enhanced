# Audit Report: M42 Implementation Review + Documentation Currency

**Audit**: #016  
**Date**: 2026-05-11  
**Subject**: M42 milestone (routes 036–042, commit `91560c4`) implementation correctness + README/QUICKSTART/AGENT.md documentation currency post-v6.8.0  

---

## Summary

M42 shipped 7 routes targeting 9 audit-015 findings (BUG-003, MEMORY-001/002, ROUTING-001/002/003, VALIDATE-001/002, STRUCT-003). All 7 routes are correctly implemented in `scripts/acp-dispatch.ts` and `scripts/acp-validate.ts`. The commit is clean and complete.

**Two categories of findings** emerged:
1. **Documentation gaps** — README.md has stale command counts (says "59 commands" in 3 places, should be 63) and is missing M41/M42 milestone entries from the "Recent Protocol Enhancements" section. The `/acp-validate` command doc does not mention the 4 new validate functions added in M42.
2. **One minor code observation** — `checkStaleness()` is called before `validateAgentsMdSize()` / `validateSessionsMemory()` in the no-args path, meaning informational staleness output appears before blocking validation results. Low priority, cosmetic.

No functional bugs found in M42 implementation.

---

## Files Analyzed

| File | Type | Relevance |
|------|------|-----------|
| `scripts/acp-dispatch.ts` | source | M42 route-036 (BUG-003), route-039 (ROUTING-002), route-040 (MEMORY-001) |
| `scripts/acp-validate.ts` | source | M42 route-037 (MEMORY-002), route-038 (VALIDATE-001/002), route-041 (ROUTING-003) |
| `agent/routing/taxonomy.yml` | config | M42 route-039 (ROUTING-001): 9 new task types, `last_updated` field |
| `agent/core/constraints.yml` | config | M42 route-038 (VALIDATE-001): `agents_md_rules` block |
| `agent/memory/lessons.md` | memory | M42 route-040 (MEMORY-001): archive schema |
| `agent/memory/audit-carryovers.md` | memory | All 22 entries now `status: fixed` |
| `agent/design/acp-ux-review.md` | doc | M42 route-042 (STRUCT-003): moved from `scripts/FINAL-REVIEW.md` |
| `agent/progress.yaml` | state | M42 complete, `current_milestone: M42-complete` |
| `agent/wiki/domain.yml` | wiki | `ux_review` entry added; `count: 63` command count |
| `README.md` | doc | Command counts stale; M41/M42 milestone history missing |
| `AGENT.md` | doc | Version 6.8.0 ✅; no milestone history section |
| `scripts/QUICKSTART.md` | doc | No version refs; functional — no required changes |
| `agent/commands/acp.validate.md` | command | Missing documentation of 4 new validate checks |
| `CHANGELOG.md` | changelog | [6.8.0] entry complete ✅ |
| `agent/core/identity.yml` | config | `version: 6.8.0` ✅ |
| `package.yaml` | config | `version: 6.8.0` ✅ |

---

## M42 Implementation Verification

### route-036 — BUG-003: Dispatch Order + SIGINT

| Check | Result | Evidence |
|-------|--------|----------|
| `appendLedger()` before `updateRoutingYml()` | ✅ | `acp-dispatch.ts:286-287` |
| SIGINT handler registered before API call | ✅ | `acp-dispatch.ts:245-251` |
| SIGINT handler deregistered after stream | ✅ | `acp-dispatch.ts:284` |
| SIGINT path calls `appendLedger()` | ✅ | `acp-dispatch.ts:248` |
| SIGINT path does NOT call `updateRoutingYml()` | ✅ | Correct omission at `acp-dispatch.ts:246-250` |

### route-037 — MEMORY-002: validateSessionsMemory()

| Check | Result | Evidence |
|-------|--------|----------|
| Function exists | ✅ | `acp-validate.ts:451` |
| Validates required keys (date, executor, tasks, done) | ✅ | Lines 451-496 |
| Warns on non-YYYY-MM-DD date format | ✅ | Regex check in function body |
| Called from no-args main path | ✅ | `acp-validate.ts:507` |
| Returns boolean (affects exit code) | ✅ | `sessionsValid` in exit condition |

### route-038 — VALIDATE-001+002: Size Guard + Parity Diff

| Check | Result | Evidence |
|-------|--------|----------|
| `validateAgentsMdSize()` function exists | ✅ | `acp-validate.ts:413` |
| Reads `agents_md_rules` from constraints.yml | ✅ | Lines 413-449 |
| `agents_md_rules` block in constraints.yml | ✅ | `agent/core/constraints.yml:37-43` |
| `runParityCheck()` uses Set-based diff | ✅ | `acp-validate.ts:152` |
| Parity outputs per-filename `❌` | ✅ | Function body at 152-250 |

### route-039 — ROUTING-001+002: Taxonomy + getSkillFile

| Check | Result | Evidence |
|-------|--------|----------|
| `last_updated: 2026-05-11` in taxonomy.yml | ✅ | Line 4 |
| 25 total `executor:` entries | ✅ | `grep -c executor: agent/routing/taxonomy.yml` = 25 |
| 9 new crosscut task types in `getSkillFile()` | ✅ | `acp-dispatch.ts:97-100` |
| `crosscutTypes` includes all 9 new types | ✅ | wiki-update, memory-write, changelog-update, progress-update, adr-write, audit-run, milestone-create, route-create, upstream-parity-check |

### route-040 — MEMORY-001: Lessons Archive

| Check | Result | Evidence |
|-------|--------|----------|
| Archive schema comment in lessons.md | ✅ | `agent/memory/lessons.md:5-9` |
| First entry archived with `status: archived` | ✅ | `agent/memory/lessons.md:12-13` |
| `getFilteredLessons()` skips archived entries | ✅ | `acp-dispatch.ts:53` |

### route-041 — ROUTING-003: Staleness Check

| Check | Result | Evidence |
|-------|--------|----------|
| `checkStaleness()` exists | ✅ | `acp-validate.ts:330` |
| Reads `last_updated` from taxonomy.yml | ✅ | Lines 340-360 |
| Reads `last_verified` from config.yml models | ✅ | Lines 362-396 |
| 90-day taxonomy threshold | ✅ | Line ~348 |
| 180-day model threshold | ✅ | Line ~381 |
| Non-blocking (informational) | ✅ | `acp-validate.ts:505`: comment confirms; excluded from exit code |
| Called before size/sessions checks | ⚠️ | `acp-validate.ts:505` — staleness output appears before blocking checks (cosmetic) |

### route-042 — STRUCT-003 + Wrap-up

| Check | Result | Evidence |
|-------|--------|----------|
| `agent/design/acp-ux-review.md` exists | ✅ | `ls agent/design/acp-ux-review.md` |
| `scripts/FINAL-REVIEW.md` deleted | ✅ | `git show 91560c4 --stat` shows rename |
| Header note in acp-ux-review.md | ✅ | Line 1 of file |
| `domain.yml` `ux_review` entry | ✅ | `agent/wiki/domain.yml:472` |
| Version 6.8.0 in identity.yml | ✅ | `agent/core/identity.yml:31` |
| Version 6.8.0 in package.yaml | ✅ | `package.yaml:5` |
| Version 6.8.0 in AGENT.md | ✅ | `AGENT.md:4` |
| CHANGELOG.md [6.8.0] entry | ✅ | `CHANGELOG.md` — Fixed/Added/Changed/Moved sections |
| M42 `status: completed` in progress.yaml | ✅ | `agent/progress.yaml` |
| All 7 routes stamped `completed: 2026-05-11` | ✅ | route-036 through route-042 |
| All 9 audit-015 carryovers `status: fixed` | ✅ | 22 fixed entries, 0 pending (1 comment line) |
| Session entry in sessions.md | ✅ | Last entry with M42 tasks |

---

## Key Findings

| ID | Finding | Location | Severity | Type |
|----|---------|----------|----------|------|
| DOC-001 | README command count says "59 commands" in 3 places; actual count is 63 | `README.md:102,113,229,230` | Medium | Stale docs |
| DOC-002 | README "Recent Protocol Enhancements" section covers only v6.4–v6.6 (M38/M39/M40); M41 (v6.7.0) and M42 (v6.8.0) are not documented | `README.md:244` | Medium | Missing docs |
| DOC-003 | `/acp-validate` command doc does not mention the 4 new checks added in M42: `validateSessionsMemory`, `validateAgentsMdSize`, `checkStaleness`, improved `runParityCheck` | `agent/commands/acp.validate.md` | Low | Missing docs |
| DOC-004 | `domain.yml` `count: 63` comment says "61 acp.* + 2 git.*"; actual acp.* count is 61 ✅ but the README says 59 in multiple places — inconsistency between files | `README.md` vs `agent/wiki/domain.yml:6` | Low | Inconsistency |
| OBS-001 | `checkStaleness()` in no-args path runs before `validateAgentsMdSize()` / `validateSessionsMemory()`; informational output appears before blocking results | `acp-validate.ts:503-509` | Low | Code style |

---

## Code Pointers

| Location | Description |
|----------|-------------|
| `scripts/acp-dispatch.ts:245-251` | SIGINT handler registration before API stream |
| `scripts/acp-dispatch.ts:284-287` | SIGINT deregistration, then `appendLedger()`, then `updateRoutingYml()` |
| `scripts/acp-dispatch.ts:46-88` | `getFilteredLessons()` — archive-aware filter |
| `scripts/acp-dispatch.ts:91-110` | `getSkillFile()` — full crosscutTypes list including 9 M42 additions |
| `scripts/acp-validate.ts:152-250` | `runParityCheck()` — Set-based diff implementation |
| `scripts/acp-validate.ts:330-411` | `checkStaleness()` — taxonomy + config.yml model checks |
| `scripts/acp-validate.ts:413-449` | `validateAgentsMdSize()` — byte-size guard |
| `scripts/acp-validate.ts:451-496` | `validateSessionsMemory()` — sessions.md YAML structure |
| `scripts/acp-validate.ts:500-511` | no-args main block — execution order |
| `agent/core/constraints.yml:37-43` | `agents_md_rules` block |
| `agent/memory/lessons.md:5-13` | Archive schema comment + first archived entry |
| `agent/routing/taxonomy.yml:1-5` | Header with `version`, `last_updated`, `count` fields |
| `agent/design/acp-ux-review.md:1` | Origin note (moved from `scripts/FINAL-REVIEW.md`) |
| `README.md:96,102,113,229,230` | Command count references (stale 59/63 mix) |
| `README.md:244-290` | "Recent Protocol Enhancements" section (missing M41/M42) |

---

## Git History

| Date | Commit | Summary |
|------|--------|---------|
| 2026-05-11 | `91560c4` | feat(M42): complete Dispatch Integrity + Validation Hardening — v6.7.0 → v6.8.0 |
| 2026-05-11 | `1f517a4` | plan(M42): dispatch integrity + validation hardening — 7 routes for 9 audit-015 findings |
| 2026-05-11 | `1e32cf6` | audit(015): M41 verification + external final audit assessment |
| 2026-05-11 | `c660c65` | chore(M41b): write session entry for M41b completion |
| 2026-05-11 | `263b3b2` | feat(OBS-004): Persona A defaults in routing.yml + M41 wrap-up [6.7.0] |

---

## Recommendations

1. **Fix README.md command counts** (DOC-001) — change "59 commands" → "63 commands" at lines 102, 113, 229, 230. Update section header from "v6.4–v6.6" → "v6.4–v6.8".
2. **Add M41/M42 milestone entries to README.md** (DOC-002) — append M41 (v6.7.0: command docs + bootstrap hook + Windows docs + config.yml last_verified) and M42 (v6.8.0: dispatch integrity + validation hardening) under "Recent Protocol Enhancements".
3. **Update acp.validate.md** (DOC-003) — add a new "Run TypeScript Validator" step or supplement the existing validate description to mention the 4 new checks in `acp-validate.ts`.
4. **Optional**: Reorder no-args path so `checkStaleness()` runs last (after the blocking checks) to keep informational output at the end (OBS-001).
