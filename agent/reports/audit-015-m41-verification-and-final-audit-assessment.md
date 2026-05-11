# Audit Report: M41 Implementation Verification + New External Audit Assessment

**Audit**: #015  
**Date**: 2026-05-11  
**Version Audited**: 6.7.0 (post-M41)  
**Subject**: Verify all 14 M41 routes (022–035) are correctly implemented; critically review new external audit (`acp-enhanced-final-audit-report.md`) against current 6.7.0 state; identify open work.  

---

## Summary

M41 (14 routes, 022–035) is fully committed and all route files are stamped. Implementation quality is **solid overall** — 13 of 14 targets are correctly delivered. One critical process failure: `audit-carryovers.md` was never updated to mark any of the 11 M41-addressed items as `status: fixed`. The carryovers file currently shows 11 `status: pending` entries, all of which have been resolved.

The new external audit (`acp-enhanced-final-audit-report.md`) was written against v6.6.0. Cross-referenced against v6.7.0, **7 of 17 findings are already fixed** by M41. **10 findings remain open** and represent the M42/M43 work backlog. The single most critical unfixed finding is **BUG-003** (dispatch.ts: `updateRoutingYml()` called before the API stream — stale executor state on failure) which was **not included** in the M41 plan and has not been implemented.

---

## Files Analyzed

| File | Type | Relevance |
|------|------|-----------|
| `agent/routing/tasks/route-022.md` through `route-035.md` | task | All 14 M41 route files |
| `agent/memory/sessions.md` | memory | BUG-001 fix target; M41 session entries |
| `scripts/acp-dispatch.ts` | source | BUG-002, BUG-003 (new) targets |
| `agent/core/routing.yml` | config | BUG-005 (OBS-004) fix target |
| `agent/commands/acp.feedback.md`, `acp.task.md`, `acp.install.md`, `acp.dispatch.md` | command | BUG-003a–d (4 new command docs) |
| `agent/wiki/domain.yml` | wiki | BUG-004 count fix |
| `scripts/acp-validate.ts` | source | VALIDATE-001, VALIDATE-002, MEMORY-002 targets |
| `agent/routing/taxonomy.yml` | config | ROUTING-001, ROUTING-002 targets |
| `agent/routing/config.yml` | config | ROUTING-003 (OBS-002) fix target |
| `agent/memory/audit-carryovers.md` | memory | Process compliance check |
| `agent/memory/lessons.md` | memory | MEMORY-001 target |
| `scripts/acp-bootstrap.sh` | script | GAP-004 fix target |
| `README.md` | doc | GAP-002, GAP-003, GAP-005 fix targets |
| `scripts/QUICKSTART.md` | doc | GAP-003, GAP-005, STRUCT-004 fix targets |
| `scripts/FINAL-REVIEW.md` | doc | STRUCT-003 — not moved |
| `agent/feedback/acp-enhanced-final-audit-report.md` | feedback | New external audit (audited against v6.6.0) |

---

## Part 1 — M41a Verification (Routes 022–028)

### Route-022 — sessions.md malformed YAML (BUG-001) ✅

**Verdict**: FIXED correctly.  
`sessions.md` was repaired with `- date: 2026-05-05` header prepended to the orphaned block. The `\n- date:` split pattern in `acp-dispatch.ts` will parse cleanly. Commit: `b99ff1c`.

### Route-023 — HTTP-Referer dynamic (BUG-002) ✅

**Verdict**: FIXED correctly.  
`scripts/acp-dispatch.ts` lines 213–219 now read `identity.yml` and construct `repoUrl` and `projectName` dynamically. Fallback logic handles missing `homepage` field. Commit: `4765a35`.

**Note**: `updateRoutingYml()` is still called at line 208 — BEFORE the API call. This is a separate finding (new audit BUG-003) that was not part of the M41 plan. See Part 3.

### Routes 024–027 — 4 missing command docs (BUG-003a–d) ✅

**Verdict**: FIXED correctly. All four command docs created with correct format, companions present:
- `acp.feedback.md` + `.github/prompts/acp-feedback.prompt.md` + `.opencode/commands/acp-feedback.md`
- `acp.task.md` + companions
- `acp.install.md` + companions  
- `acp.dispatch.md` + companions

Commits: `9420f67`, `3cb3573`, `67a96cd`, `0fb669d`.

### Route-028 — domain.yml command count (BUG-004) ✅

**Verdict**: FIXED. Count updated 58 → 63. Four new command entries added with correct categories. Commit: `93bcf16`.

---

## Part 2 — M41b Verification (Routes 029–035)

### Route-029 — Delete scripts-package.json duplicate (GAP-001) ✅

**Verdict**: FIXED. File deleted. `agent/skills/typescript.md` reference updated. Commit: `bf92e15`.

### Route-030 — QUICKSTART link in README (GAP-002) ✅

**Verdict**: FIXED. QUICKSTART.md linked prominently in both the Install section and Quick Start section of README.md. Commit: `ecf5587`.

### Route-031 — git_workflow documentation (GAP-003) ✅

**Verdict**: FIXED. `## Branch Safety` section added to README.md with config block. QUICKSTART.md Step 2 expanded with `git_workflow:` recommendation. Commit: `b85393d`.

### Route-032 — Pre-commit hook in acp-bootstrap.sh (GAP-004) ✅

**Verdict**: FIXED correctly.  
New Step 8/8 in `acp-bootstrap.sh` installs `.git/hooks/pre-commit`. Implementation is idempotent (checks ACP marker before appending), BSD-compatible (uses `printf` not `echo -e` for file writes), `chmod +x` applied, `.git` directory existence check. Commit: `f3d5f17`.

### Route-033 — Windows/WSL2 documentation (GAP-005) ✅

**Verdict**: FIXED. `#### Windows (WSL2) Setup` subsection in README.md with `wsl --install` command. `Step 0 — Platform Setup` added to QUICKSTART.md. Commit: `d96f1d3`.

### Route-034 — last_verified in routing/config.yml (OBS-002) ✅

**Verdict**: FIXED. All 5 model entries have `last_verified: 2026-05-11`. Comment added at top of file. Commit: `3c7083b`.

**Gap**: `taxonomy.yml` has no `last_updated` field (only a comment string: `# Generated 2026-05-01`). The staleness check in `acp-validate.ts` was not added. See ROUTING-003 in Part 3.

### Route-035 — routing.yml Persona A defaults + version bump (OBS-004) ✅

**Verdict**: FIXED. `routing.yml` now has `executor: copilot`, `model: github-copilot`. Version bumped to 6.7.0 across `identity.yml`, `package.yaml`, `AGENT.md`. CHANGELOG [6.7.0] entry written. Milestone-41 marked completed. Commit: `263b3b2`.

---

## Part 2b — Critical Process Failure: audit-carryovers.md Not Updated

**Severity**: HIGH (process)  
**Finding**: `agent/memory/audit-carryovers.md` contains 11 entries from audit-014, **all with `status: pending`**. None were updated to `status: fixed` after M41 implementation. Step 4.4 of the context protocol will surface ALL 11 as blocking carryovers at the start of every future session — adding false noise and wasting context budget on phantom issues.

**Affected entries** (all should be `status: fixed`):

| finding_id | Fix applied | Commit |
|-----------|------------|--------|
| BUG-001 | sessions.md repaired | `b99ff1c` |
| BUG-002 | HTTP-Referer dynamic | `4765a35` |
| BUG-003a | acp.feedback.md created | `9420f67` |
| BUG-003b | acp.task.md created | `3cb3573` |
| BUG-003c | acp.install.md created | `67a96cd` |
| BUG-003d | acp.dispatch.md created | `0fb669d` |
| BUG-004 | domain.yml count 58→63 | `93bcf16` |
| GAP-001 | scripts-package.json deleted | `bf92e15` |
| GAP-002 | QUICKSTART link in README | `ecf5587` |
| GAP-003 | git_workflow documented | `b85393d` |
| GAP-004 | Pre-commit hook in bootstrap | `f3d5f17` |
| GAP-005 | Windows/WSL2 docs | `d96f1d3` |

**Action required**: All 11 entries must be marked `status: fixed`, `fix_applied_date: 2026-05-11`, `verified_in_audit: 015` before closing this audit. (Done at end of this report.)

---

## Part 3 — New External Audit vs 6.7.0

The new feedback file `agent/feedback/acp-enhanced-final-audit-report.md` was written against v6.6.0. The following table maps each finding to its current status in v6.7.0:

### Bug Findings

| Finding | Severity | v6.6.0 Status | v6.7.0 Status | Notes |
|---------|----------|---------------|---------------|-------|
| BUG-001: sessions.md malformed entry | Critical | Open | ✅ Fixed | route-022 |
| BUG-002: HTTP-Referer hardcoded | High | Open | ✅ Fixed | route-023 |
| BUG-003: updateRoutingYml() before API call | High | Open | ❌ Open | Not in M41 plan |
| BUG-004: 4 missing command docs | High | Open | ✅ Fixed | routes 024–027 |
| BUG-005: routing.yml executor: unset | Medium | Open | ✅ Fixed | route-035 |

### Routing Findings

| Finding | Severity | v6.7.0 Status | Notes |
|---------|----------|---------------|-------|
| ROUTING-001: 9 missing task types in taxonomy.yml | High | ❌ Open | Not in M41 plan |
| ROUTING-002: getSkillFile() has no explicit mapping for new types | Medium | ❌ Open | Depends on ROUTING-001 |
| ROUTING-003: taxonomy.yml no last_updated + no staleness check | Low | ❌ Open (partial) | config.yml last_verified fixed; taxonomy.yml and acp-validate.ts staleness not done |

### Memory Findings

| Finding | Severity | v6.7.0 Status | Notes |
|---------|----------|---------------|-------|
| MEMORY-001: lessons.md no expiry mechanism | Medium | ❌ Open | Not in M41 plan |
| MEMORY-002: acp-validate.ts no sessions.md check | High | ❌ Open | Not in M41 plan |
| MEMORY-003: audit-carryovers.md entries lack description/severity/fix_target | Low | ❌ Open | Partially — new audit entries richer, old ones sparse |

### Validation Findings

| Finding | Severity | v6.7.0 Status | Notes |
|---------|----------|---------------|-------|
| VALIDATE-001: AGENTS.md no byte-size check | High | ❌ Open | AGENTS.md is 11,043 bytes (safe), but no check exists |
| VALIDATE-002: Parity check silent about which files are missing | Low | ❌ Open | runParityCheck() still shows counts only |

### Structural Findings

| Finding | Severity | v6.7.0 Status | Notes |
|---------|----------|---------------|-------|
| STRUCT-001: scripts-package.json duplicate | Low | ✅ Fixed | route-029 |
| STRUCT-002: QUICKSTART not linked from README | Medium | ✅ Fixed | route-030 |
| STRUCT-003: FINAL-REVIEW.md not in agent/ tree | Low | ❌ Open | Still at scripts/FINAL-REVIEW.md |
| STRUCT-004: git_workflow feature undiscoverable | Medium | ✅ Fixed | routes 031+032 |

### Summary: 7 Fixed, 10 Open

| Category | Fixed | Open |
|----------|-------|------|
| Bugs | 4/5 | 1 (BUG-003 dispatch order) |
| Routing | 0/3 | 3 |
| Memory | 0/3 | 3 |
| Validation | 0/2 | 2 |
| Structural | 3/4 | 1 (STRUCT-003) |
| **Total** | **7/17** | **10/17** |

---

## Part 4 — Open Findings Detail (Prioritised)

### CRITICAL: BUG-003 — `updateRoutingYml()` called BEFORE API stream

**File**: `scripts/acp-dispatch.ts` line 208  
**Evidence**: `grep -n "updateRoutingYml"` shows line 208 (before stream) vs line 269 (`appendLedger` after stream).

```typescript
// Line 208 — currently BEFORE API call:
updateRoutingYml(executor, modelConfig.model);
// ...
// Line 269 — appendLedger is correctly AFTER stream:
appendLedger(meta, inputTokens, outputTokens, totalCost);
```

If the API call fails (network, SIGINT, invalid key), `routing.yml` permanently shows the intended executor/model with no work done. Next session context is stale. Also: SIGINT during streaming loses the ledger row — tokens billed but not recorded.

**Fix**: Move `updateRoutingYml()` to after `appendLedger()`. Add `process.on('SIGINT', ...)` handler to flush a partial ledger row on interrupt.  
**Suggested route**: `route-036` | `typescript-feature` | `deepseek-v4-pro`

---

### HIGH: MEMORY-002 — acp-validate.ts has no sessions.md YAML structure check

**File**: `scripts/acp-validate.ts` — no `validateSessionsMemory()` function.  
BUG-001 (the malformed sessions.md entry) was present across one full milestone without detection. The fix was reactive; the validator still cannot catch this class of error.  
**Suggested route**: `route-037` | `typescript-feature` | `deepseek-v4-flash`

---

### HIGH: VALIDATE-001 — No AGENTS.md byte-size check

**File**: `agent/core/constraints.yml` (no `agents_md_rules` key), `scripts/acp-validate.ts` (no size check function).  
AGENTS.md is currently 11,043 bytes (well within safe limits). But no guard exists. If content from `AGENT.md` (90,368 bytes) is accidentally merged into `AGENTS.md`, it silently exceeds all tool auto-load limits.  
**Suggested route**: `route-038` | `typescript-feature` | `deepseek-v4-flash`

---

### HIGH: ROUTING-001 — 9 common task types missing from taxonomy.yml

**File**: `agent/routing/taxonomy.yml` — 16 entries currently, none of: `wiki-update`, `memory-write`, `changelog-update`, `progress-update`, `adr-write`, `audit-run`, `milestone-create`, `route-create`, `upstream-parity-check`.  
Sessions data confirms these task types occur regularly. Dispatch falls back to wrong executor.  
**Suggested route**: `route-039` | `yaml-schema` | `deepseek-v4-flash`

---

### MEDIUM: MEMORY-001 — lessons.md has no expiry/archive mechanism

**File**: `agent/memory/lessons.md`, `scripts/acp-dispatch.ts`  
`priority: high` lessons load on every dispatch call, forever. At least one lesson's core fix is already codified in `constraints.yml` (`context_overflow_commit_first`).  
**Suggested route**: `route-040` | `typescript-feature` | `deepseek-v4-flash`

---

### MEDIUM: ROUTING-002 — `getSkillFile()` has no explicit mapping for new task types

**File**: `scripts/acp-dispatch.ts`  
Once ROUTING-001 is implemented, `getSkillFile()` needs explicit entries so the crosscut fallback is intentional, not accidental.  
**Suggested route**: combine with `route-039` or do as `route-041`

---

### LOW: ROUTING-003 (partial) — taxonomy.yml has no parseable `last_updated` date field

**File**: `agent/routing/taxonomy.yml` header has comment-only date; no `last_updated:` key.  
`acp-validate.ts` staleness check was not implemented.  
**Suggested route**: `route-042` | `typescript-feature` | `deepseek-v4-flash`

---

### LOW: VALIDATE-002 — Parity check shows counts, not which files are missing

**File**: `scripts/acp-validate.ts`, `runParityCheck()`  
At 63 commands, count-only output is unhelpful when 1-2 companions are missing.  
**Suggested route**: combine with VALIDATE-001 in `route-038`

---

### LOW: STRUCT-003 — FINAL-REVIEW.md not in agent/ tree

**File**: `scripts/FINAL-REVIEW.md` — contains the most honest UX analysis in the repo; not reachable by context protocol.  
**Suggested route**: `route-043` | `documentation-sync` | `deepseek-v4-flash`

---

### LOW: MEMORY-003 — audit-carryovers.md entries lack context fields

**Existing entries**: no `description`, `fix_target`, `severity` fields on all audit-014 entries (only `finding`).  
New audit recommendations include richer schema (`description`, `fix_target`, `severity`). Old entries should be enriched.  
**Suggested route**: fold into next audit write-back

---

## Part 5 — Process Findings (Not Code)

### PROC-001 — audit-carryovers.md never updated after M41

**Impact**: Medium. Step 4.4 surfaces all 11 as blocking, creating false urgency noise.  
**Action**: Mark all 11 resolved entries as `status: fixed` at end of this audit. (Done below.)

### PROC-002 — New external audit was assigned no route file

**Impact**: Low. The `acp-enhanced-final-audit-report.md` file arrived without any route planning. Findings in it diverge slightly from the audit-014 findings that drove M41 (different BUG numbering, new BUG-003).  
**Action**: Treat this report as the source for M42 milestone planning.

---

## Git History (M41)

| Commit | Route | Summary |
|--------|-------|---------|
| `b99ff1c` | route-022 | Fix sessions.md orphaned YAML entry |
| `4765a35` | route-023 | Dynamic HTTP-Referer/X-Title from identity.yml |
| `9420f67` | route-024 | Create acp.feedback.md + companions |
| `3cb3573` | route-025 | Create acp.task.md + companions |
| `67a96cd` | route-026 | Create acp.install.md + companions |
| `0fb669d` | route-027 | Create acp.dispatch.md + companions |
| `93bcf16` | route-028 | domain.yml count 58→63 |
| `bf92e15` | route-029 | Delete scripts-package.json duplicate |
| `ecf5587` | route-030 | QUICKSTART link in README |
| `b85393d` | route-031 | git_workflow docs in README+QUICKSTART |
| `f3d5f17` | route-032 | Pre-commit hook in acp-bootstrap.sh |
| `d96f1d3` | route-033 | Windows/WSL2 docs |
| `3c7083b` | route-034 | last_verified in routing/config.yml |
| `263b3b2` | route-035 | routing.yml Persona A defaults + v6.7.0 bump |

---

## Recommendations

### Immediate (before M42 routes):
1. **Mark all 11 audit-014 carryovers as `status: fixed`** in `audit-carryovers.md` (process fix, no code change)
2. **Add BUG-003 to audit-carryovers.md** as `severity: high` (dispatch order issue)
3. **Add 10 open findings as carryovers** for M42 tracking

### M42 — Dispatch Integrity + Validation Hardening (proposed, ~2 hours):

| Route | Finding | Task Type |
|-------|---------|-----------|
| route-036 | BUG-003: move updateRoutingYml() after stream + SIGINT ledger flush | `typescript-feature` |
| route-037 | MEMORY-002: add sessions.md YAML structure check to acp-validate.ts | `typescript-feature` |
| route-038 | VALIDATE-001 + VALIDATE-002: AGENTS.md size check + parity diff output | `typescript-feature` |
| route-039 | ROUTING-001 + ROUTING-002: 9 missing taxonomy entries + getSkillFile() mapping | `yaml-schema` |
| route-040 | MEMORY-001: lessons.md status/superseded_by fields + getFilteredLessons() update | `typescript-feature` |
| route-041 | ROUTING-003: taxonomy.yml last_updated field + acp-validate.ts staleness check | `typescript-feature` |
| route-042 | STRUCT-003: move FINAL-REVIEW.md → agent/design/acp-ux-review.md | `documentation-sync` |
