# Audit Report: M39/M40 Route Files — Gap Check and Implementation Readiness

**Audit**: #011  
**Date**: 2026-05-11  
**Subject**: Routes 014–021 (M39 git branch awareness + M40 pre-implementation audit protocol)
created in audit-010. Gap check and readiness assessment before implementation begins.

---

## Summary

8 route files were created based on the 9 findings in audit-010. All 8 routes are structurally
sound and internally consistent. 3 high-severity gaps and 3 medium/low-severity gaps were found,
none of which block M39 implementation. M39 (routes 014–016, 017 with fix) is ready to proceed.
M40 requires route-019 acceptance criteria correction before implementation.

**Verdict**: Implement M39 first. Fix 3 gaps in routes before starting M40. Total additional
work: ~15 minutes of route file corrections.

---

## Files Analyzed

| File | Type | Relevance |
|------|------|-----------|
| `agent/routing/tasks/route-014.md` | route | M39/T1 — identity.yml git_workflow block |
| `agent/routing/tasks/route-015.md` | route | M39/T2 — Step 1b branch check |
| `agent/routing/tasks/route-016.md` | route | M39/T3 — acp.commit.md Step 0 branch guard |
| `agent/routing/tasks/route-017.md` | route | M39/T4 — milestone-39 file + version bump |
| `agent/routing/tasks/route-018.md` | route | M40/T1 — audit-carryovers.md creation |
| `agent/routing/tasks/route-019.md` | route | M40/T2 — acp.audit.md --pre-impl mode |
| `agent/routing/tasks/route-020.md` | route | M40/T3 — Step 4.4 carryover check |
| `agent/routing/tasks/route-021.md` | route | M40/T4 — task template quality gate + milestone-40 |
| `agent/reports/audit-010-feedback-002-003-implementation-plan.md` | report | Source plan |
| `AGENTS.md:28-75` | protocol | Context-loading Steps 1–6; Step 4 sub-step structure |
| `agent/commands/acp.commit.md:62-120` | command | Existing Steps 1–7; session entry schema |
| `agent/commands/acp.audit.md:1-150` | command | Single investigation mode; Steps 0–5 |
| `agent/core/identity.yml:1-30` | core | No git_workflow block; version 6.4.13 |
| `AGENT.md:4` | readme | `**Version**: 6.4.13` — version field exists |
| `agent/progress.yaml:1-15` | tracking | version 6.4.13, M38-complete |
| `CHANGELOG.md:1-40` | changelog | Most recent entry [6.4.13] |
| `agent/milestones/milestone-38-protocol-knowledge-preservation.md` | reference | Milestone format reference |

---

## Findings

| # | Route | Severity | Finding |
|---|-------|----------|---------|
| G1 | 017 | **High** | Title includes "acp-bootstrap.sh" — work that was explicitly deferred in audit-010 |
| G2 | 017 | **High** | Milestone-39 acceptance criteria lists routes 014–016 as tasks but omits route-017 itself |
| G3 | 019 | **High** | Acceptance criteria contradiction: "Existing Steps 0–5 behaviour unchanged" but Step 4 IS changed (carryover write added to all modes) |
| G4 | 017/021 | **Medium** | No wiki file updates in either wrap-up route — potential audit-009-style compliance gap post-M39/M40 |
| G5 | 018 | **Medium** | YAML key ambiguity in carryovers file — entries under `carryovers:` key but Step 4.4 protocol doesn't specify key path |
| G6 | 015 | **Low** | "Do not proceed. Wait for developer to switch branch." — passive language; agent may interpret as indefinite block |

---

## Gap Detail

### G1 — route-017 title includes deferred work (acp-bootstrap.sh)

**Location**: `agent/routing/tasks/route-017.md:2`  
**Text**: `title: M39 — Create milestone-39 file and acp-bootstrap.sh git_workflow template`

The title references `acp-bootstrap.sh`. This work was explicitly deferred in audit-010 (F5: `/acp-init`
branch setup, marked as "Defer" in the implementation plan, noted as "M41?"). The acceptance criteria
for route-017 correctly omits `acp-bootstrap.sh` — the title is a copy-paste artifact from early planning
notes. An implementor reading only the title may attempt to touch `scripts/acp-bootstrap.sh`, which is
out of scope.

**Fix**: Correct the title to `M39 — Create milestone-39 file, update progress.yaml, bump to v6.5.0`

---

### G2 — milestone-39 self-reference omits route-017

**Location**: `agent/routing/tasks/route-017.md` acceptance criterion 2  
**Text**: `Milestone references route-014, route-015, route-016 as its tasks`

Route-017 is itself a task of M39 (the wrap-up/bookkeeping task). The milestone-39 file it creates
should list all 4 tasks: route-014, route-015, route-016, AND route-017. Without this, the milestone
file will be internally inconsistent (tracking only 3 of 4 tasks) and future compliance checks will flag
the gap.

Cross-reference: M38 milestone file has `tasks: route-013` — it correctly lists the single route that
delivered it. M39 has 4 routes and should list all 4.

**Fix**: Amend acceptance criterion 2 to: "Milestone references route-014, route-015, route-016, route-017 as its tasks"

---

### G3 — route-019 acceptance criteria contradiction on Step 4 change

**Location**: `agent/routing/tasks/route-019.md` acceptance criterion 8  
**Text**: `Existing Steps 0–5 behaviour unchanged when --pre-impl is NOT passed`

The implementation notes for route-019 say:

> "Step 4 addition (apply to ALL audit modes): If this audit produced findings requiring action:
> append each to `agent/memory/audit-carryovers.md` with `status: pending`."

This IS a change to Step 4 regardless of whether `--pre-impl` is passed. The acceptance criterion
claiming Steps 0–5 are "unchanged" directly contradicts this. An implementor following the criteria
literally will not add the carryover write to the standard Step 4 — defeating a key purpose of M40
(carryover tracking after ANY audit, not just pre-impl audits).

**Fix**: Replace criterion 8 with two clearer items:
- `Step 4 (Generate Report) updated for ALL modes: after findings → write actionable items to audit-carryovers.md`
- `Steps 0–3 and Step 5 unchanged when --pre-impl NOT passed`

---

### G4 — Wiki files not included in M39 or M40 wrap-up routes

**Location**: `route-017.md` and `route-021.md` `files_affected:` lists  
**Pattern**: Compare to audit-009 compliance — it found wiki/architecture.md and wiki/domain.yml
were not updated when M38 was complete, requiring retroactive fixes.

Route-017 (M39 wrap-up) `files_affected` lists: milestone-39 file, progress.yaml, CHANGELOG.md.  
Route-021 (M40 wrap-up) `files_affected` lists: task template, milestone-40 file, progress.yaml,
CHANGELOG.md, identity.yml, package.yaml, AGENT.md.

Neither route includes:
- `agent/wiki/architecture.md` — protocol architecture docs (Step 1b is a new protocol step)
- `agent/wiki/domain.yml` — domain taxonomy (new git_workflow field, new audit modes)

If these are skipped, a future compliance audit (audit-012?) will find the same gap pattern as
audit-009. The wiki updates are small (one section each) but must be included.

**Fix**: Add wiki files to `files_affected` in route-017 and route-021, and add acceptance
criteria items for each:
- **route-017**: `agent/wiki/architecture.md` — add note on git branch awareness to the
  context-loading protocol section; `agent/wiki/domain.yml` — add `git_workflow` to schema fields
- **route-021**: `agent/wiki/architecture.md` — add pre-impl audit mode section; `agent/wiki/domain.yml`
  — add `audit_carryovers` to memory layer entries

---

### G5 — YAML key path ambiguity in audit-carryovers.md schema

**Location**: `route-018.md` implementation notes (last block)

The file schema ends with `carryovers: []` as the initial state. This implies all entries live
under a `carryovers:` YAML key. However:

1. Route-020 Step 4.4 protocol says "if any entries have `status: pending`" — it doesn't specify
   `carryovers[*].status`, just `entries`. An agent implementing Step 4.4 may read the file as a
   root-level list instead of under `carryovers:`.
2. Route-019 Phase 3 says "read `agent/memory/audit-carryovers.md`; for each `status: pending`
   entry" — same ambiguity.

If different parts of the protocol access the file with different assumed structures, the carryover
tracking will silently fail (entries written under `carryovers:` not read by Step 4.4 reading the
root level, or vice versa).

**Fix**: Make the key path explicit in both route-020 and route-019:
- route-018: add a note: "Entries are stored under the `carryovers:` key (not at root level)"
- route-020 Step 4.4: change to "read the `carryovers:` list from `audit-carryovers.md`"
- route-019 Phase 3: change to "read `carryovers:` list from `audit-carryovers.md`"

---

### G6 — route-015 passive stop language

**Location**: `route-015.md` Step 1b implementation notes  
**Text**: `"Do not proceed. Wait for developer to switch branch."`

"Wait for developer" is ambiguous for an automated agent — it could mean hold the current session
open indefinitely, or simply not continue. In practice, most LLM sessions don't "wait" — they
just stop and the user re-invokes. The language should match the actual behavior: output the warning,
end the current action, and let the developer re-invoke on the correct branch.

**Fix**: Change to: "Output the warning and stop. Do not continue any task steps. The developer
must switch branches and re-invoke the session."

---

## Implementation Readiness Summary

| Route | Status | Blocker |
|-------|--------|---------|
| route-014 | ✅ Ready | None |
| route-015 | ⚠️ Minor fix needed | G6 (low — update passive language before implementing) |
| route-016 | ✅ Ready | None |
| route-017 | ⚠️ Fix before implementing | G1 (title), G2 (milestone task list), G4 (wiki files) |
| route-018 | ✅ Ready | G5 is a note fix — clarify key path in route notes before implementing |
| route-019 | ⚠️ Fix before implementing | G3 (acceptance criteria contradiction), G5 (key path) |
| route-020 | ⚠️ Minor fix needed | G5 (key path reference in Step 4.4 text) |
| route-021 | ⚠️ Fix before implementing | G4 (wiki files missing from scope) |

**M39 is implementation-ready after fixing routes 015 and 017.**  
**M40 requires route-019 fix (G3) before implementation.**

---

## Recommended Fixes (All Fixes)

Apply all 6 fixes to route files before starting implementation. Estimated time: 15 minutes.

| Fix | Route | Change |
|-----|-------|--------|
| F-G1 | route-017 | Title: remove "acp-bootstrap.sh" reference |
| F-G2 | route-017 | Acceptance criterion 2: add route-017 to milestone task list |
| F-G3 | route-019 | Split criterion 8 into two items — carryover write applies to ALL modes |
| F-G4a | route-017 | Add wiki/architecture.md + wiki/domain.yml to files_affected + criteria |
| F-G4b | route-021 | Add wiki/architecture.md + wiki/domain.yml to files_affected + criteria |
| F-G5a | route-018 | Add note: entries stored under `carryovers:` key, not root level |
| F-G5b | route-019 | Phase 3: specify `carryovers:` key path when reading file |
| F-G5c | route-020 | Step 4.4: specify `carryovers:` key path when reading file |
| F-G6 | route-015 | Step 1b stop language: replace "wait for developer" with active stop instruction |
