# ACP Enhanced — Field Feedback Report
## Submission: Pre-Implementation Readiness Audit Protocol & Carryover Tracking

**Report ID**: feedback-003  
**Date**: 2026-05-10  
**Project**: TikrFlow (timesheet & work order management SaaS)  
**ACP Version in use**: ACP Enhanced (AGENTS.md / CLAUDE.md / copilot-instructions.md pattern)  
**Executor**: claude-sonnet-4-6  
**Submitted by**: TikrFlow solo-developer, via GitHub Copilot agent session  
**Category**: Audit protocol quality — pre-implementation validation  
**Severity**: High — task-file bugs reaching implementation unchanged  
**Evidence base**: Audit-43, Audit-44, Audit-45 (M21/M22/M23 pre-implementation review cycle)  

---

## 1. Problem Statement

Three consecutive pre-implementation audits (audit-43 → audit-44 → audit-45) were required for M21, M22, and M23 before the milestones were safe to implement. Each pass found critical bugs that the previous pass missed:

| Audit | Pass | Findings | Critical | Prior carryovers |
|-------|------|----------|----------|-----------------|
| Audit-43 | Plan correctness | 12 findings | 0 | 0 |
| Audit-44 | Code cross-reference | 14 findings | 6 | 0 (not tracked) |
| Audit-45 | Final readiness | 16 findings | 7 | 2 unresolved from A44 |

**Two findings from audit-44 (NM2: category→quadrant in T167, NM4: loading guard in T159) were documented as needing fixes but were never applied. Audit-45 discovered these as new CRITICAL and HIGH findings respectively — because no mechanism existed to track whether prior audit fixes were actually made.**

Beyond the carryover tracking failure, each pass found a qualitatively different class of bug:
- **Audit-43** found: task file internal inconsistencies, wrong RBAC syntax, missing dependency declarations
- **Audit-44** found: task file code snippets using `db=Depends(get_db)` (doesn't exist), wrong `require_role()` call signature, deprecated field names
- **Audit-45** found: wrong Pydantic model field names (`wo_id` vs `work_order_id`), missing model fields accessed at runtime (`project["client_name"]`), placeholder endpoint bodies (`...`), double-write anti-patterns, invalid enum values

These are structurally different audit depths that cannot be achieved in a single pass — they require progressive reading: first task files in isolation, then task files cross-referenced against the actual codebase.

---

## 2. Root Cause Analysis

### Failure 1 — `/acp-audit` has one mode only

The current `acp.audit.md` command defines a single investigation protocol: cast the net wide, read files, generate a report. It has no concept of:
- **Depth levels** (plan-level vs code-level vs operational-level)
- **Pre-implementation readiness** as a distinct audit goal
- **Code cross-reference requirements** specific to task file audits

As a result, audit-43 did a plan-level review but didn't check task file code snippets against the actual codebase, leaving 6 critical bugs undiscovered. The deeper cross-reference was only done in audit-44 — as a second separate invocation.

### Failure 2 — No audit finding carryover tracking

Audit-44 documented NM2 (T167 category→quadrant in all 15 template entries) and NM4 (T159 loading guard) as findings requiring fixes. However:
- The audit report was created, but no tracking entry was written linking each finding to a task file change
- The next session (audit-45) re-read sessions.md and lessons.md but found no pending audit findings — because the "prior findings not yet fixed" state was never recorded
- The agent in audit-45 had to re-discover NM2 and NM4 from scratch, then escalate their severity

**The ACP system has no concept of "pending audit fixes" — a sub-category of memory between a sessions.md entry (too high-level) and a lessons.md entry (general patterns, not instance-specific actions).**

### Failure 3 — Task file code snippets are not subject to a cross-reference quality gate

Task file verification checklists and code snippets are written speculatively — the agent writing the task file does not systematically cross-reference:
- Pydantic model field names (e.g., `wo_id` vs `work_order_id`)
- Enum member values (e.g., `"billable"` vs `BillingType.TIME_AND_MATERIALS`)
- Import paths (e.g., `'../context/AuthContext'` vs `'../App'`)
- HTTP method consistency (e.g., `PUT` vs `PATCH` in checklists)
- API response shape vs what checklists verify

This means task files contain bugs at the planning stage that get silently inherited during implementation. A developer following the task file would write broken code.

### Failure 4 — Verification checklists are not a quality gate, they're documentation noise

Every task file has a "Verification" section with checkboxes. These checklists were found to contain:
- Wrong field names (e.g., `skipped_template_ids` when the API returns `skipped`)
- Wrong HTTP methods (e.g., `PUT` for a `PATCH` endpoint)
- Deprecated query parameters (e.g., `?category=development` when M6 migrated to `?quadrant=change`)
- Wrong import paths

If the verification checklist is wrong, the implementor uses it to "confirm" their implementation is correct — and the wrong implementation passes the checklist.

---

## 3. Changes Made to ACP Enhanced System Files

### 3.1 `agent/commands/acp.audit.md` — Pre-Implementation Readiness Mode Added

**Added**: A new `--pre-impl` mode to the audit command, with a 4-phase protocol:
- Phase 1: Plan correctness (task files in isolation)
- Phase 2: Code cross-reference (task snippets vs actual codebase)
- Phase 3: Prior audit carryover validation
- Phase 4: Operational completeness (runtime paths, edge cases)

**Added**: Mandatory code cross-reference checklist for any audit touching task files.

### 3.2 `agent/tasks/task-1-{title}.template.md` — Verification Checklist Quality Gate

**Added**: A warning block before the Verification section requiring cross-referencing of:
- All field names against Pydantic models (backend tasks)
- All enum values against enum definitions
- All import paths against actual file structure (frontend tasks)
- All HTTP methods against route definitions
- All API response field names against endpoint return values

### 3.3 `agent/memory/lessons.md` — Carryover patterns documented

**Added** (during audit-45 session): 4 new lessons capturing the specific code patterns that caused the bugs:
- T169 `wo_id` vs `work_order_id` + Project model has no `client_name` (priority: high)
- WOTemplateBase.billing_type must use BillingType enum, not custom strings (priority: high)
- Loading guard pattern before role-based rendering + AuthContext import path (priority: high)
- Never mix individual Firestore writes inside a loop with a batch commit (priority: normal)

### 3.4 Pending — Audit Carryover Tracking Mechanism

The most important systemic fix — a dedicated tracking mechanism for "audit findings pending fixes" — is documented below as a recommended change. It was not implemented in this session because it requires changes to the sessions.md schema or a new dedicated file (`agent/memory/audit-carryovers.md`), which may affect other projects using ACP Enhanced.

---

## 4. Recommended Changes to ACP Enhanced Framework

These changes are recommended for adoption in the ACP Enhanced framework and propagation to all projects using it.

### R1 — Add `--pre-impl` mode to `/acp-audit` command

The `/acp-audit` command should support a `--pre-impl` flag (or `--mode pre-impl`) that triggers a 4-phase structured protocol:

```
Phase 1 — Plan Correctness
  Read all task files in scope. Verify:
  - Internal consistency (steps reference valid field names, correct HTTP methods)
  - Dependency ordering (Step N doesn't use a resource created in Step N+2)
  - No placeholder bodies (...) in non-step code

Phase 2 — Code Cross-Reference  ← KEY NEW PHASE
  For each task file, read the actual codebase sections the task modifies. Verify:
  - Pydantic field names match model definitions (not assumed)
  - Enum values match enum member definitions (not free strings)
  - Import paths match actual file locations
  - HTTP method and route path match existing route table
  - Verification checklist field names match API response shapes
  - No dependency injection patterns that don't exist in the codebase

Phase 3 — Prior Carryover Validation
  Read agent/memory/audit-carryovers.md (if exists).
  For each unresolved finding, verify it was fixed before passing.

Phase 4 — Operational Completeness
  For each new endpoint, verify:
  - Auth guard present (require_role or get_current_user)
  - RBAC scoping (not just blocking the wrong role, but scoping to correct org/client)
  - Error cases handled (not-found, permission denied, concurrent writes)
  - No N+1 query loops without documented justification
```

### R2 — Add `agent/memory/audit-carryovers.md` to the ACP memory schema

A new memory file dedicated to tracking pending audit fixes — distinct from:
- `sessions.md` (too high-level, one entry per session)
- `lessons.md` (general patterns, not instance-specific actions)

**Schema**:
```yaml
# agent/memory/audit-carryovers.md
# Audit findings that require follow-up action (not yet applied)
# Remove entry when fix is confirmed applied and re-verified

- audit_id: 44
  finding_id: NM2
  severity: medium  # Severity in source audit
  task_file: agent/tasks/milestone-22-project-wo-templates/task-167-default-template-seed.md
  finding: All 15 DEFAULT_TEMPLATES use deprecated 'category' field; should use quadrant/service_type
  status: pending  # pending | in-progress | fixed
  fix_applied_date: null
  verified_in_audit: null
  escalated_to: 45-C4  # If escalated (not fixed before next audit), record here
```

**Protocol changes**:
- At end of any `/acp-audit` run that finds actionable fixes: write all action items to `audit-carryovers.md` with `status: pending`
- Step 4 of context loading should include: "Check `agent/memory/audit-carryovers.md` for open items — if any are `status: pending`, acknowledge them before starting"
- When a fix is applied: update entry to `status: fixed`, set `fix_applied_date`

### R3 — Add verification checklist quality gate to task file template

The task file template's Verification section should include a mandatory cross-reference block:

```markdown
## Verification

<!-- QUALITY GATE: Before writing checklist items for backend tasks —
     1. Read the actual Pydantic model and confirm all field names
     2. Read the enum definition and confirm all enum values used (no free strings)
     3. Confirm import paths exist in the file tree
     4. Confirm HTTP method matches the route decorator
     5. Confirm API response shape matches what you verify in the checklist
     Checklist items with wrong field names or wrong HTTP methods create
     implementation bugs that are invisible until runtime.            -->

- [ ] ...
```

### R4 — Add Code Cross-Reference Discipline to `agent/skills/` for backend and ui tasks

Backend and UI skill files should include a "Task File Code Review" section with the cross-reference discipline as a required step when writing or reviewing task files.

---

## 5. Impact Assessment

### Bugs prevented by implementing these recommendations

From the audit-43/44/45 evidence base, had the `--pre-impl` protocol and carryover tracking been in place:

| Bug | Audit found it | Would be found by |
|-----|----------------|-------------------|
| T169 `wo_id` vs `work_order_id` | A45 (C1) | Phase 2 cross-reference |
| T169 `project["client_name"]` KeyError | A45 (C2) | Phase 2 cross-reference |
| T166/T167 invalid billing_type string values | A45 (C3) | Phase 2 cross-reference |
| T167 all 15 templates still use `category` | A45 (C4) | Carryover tracking (A44 NM2) |
| T169 double-write (loop + batch) | A45 (C5) | Phase 4 operational |
| T163 placeholder body | A45 (C7) | Phase 1 plan correctness |
| T159 no loading guard / wrong import | A45 (H1) | Carryover tracking (A44 NM4) + Phase 2 |
| T176 `wo.wo_id` vs `wo.work_order_id` | A45 (H4) | Phase 2 cross-reference |

**7 of the 12 critical+high bugs from audit-45 would have been caught in audit-44 or prevented entirely if the `--pre-impl` protocol and carryover tracking had been in place.** Audit-45 as a third pass would not have been needed.

### Cost of not implementing

Without these changes, any pre-implementation readiness audit for future milestones will:
1. Require 2-3 passes to reach implementation-safe quality (as happened with M21/M22/M23)
2. Silently lose findings between passes if context window overflows mid-session
3. Generate verification checklists that contain bugs, creating false confidence during implementation

---

## 6. Changes Applied to This Project (Immediate)

| File | Change | Status |
|------|--------|--------|
| `agent/commands/acp.audit.md` | Added `--pre-impl` mode with 4-phase protocol | ✅ Applied |
| `agent/tasks/task-1-{title}.template.md` | Added verification checklist quality gate block | ✅ Applied |
| `agent/memory/lessons.md` | 4 new lessons (A45 findings) | ✅ Applied (in A45 session) |
| `agent/memory/audit-carryovers.md` | New file — create if future audits generate carryovers | ⏳ Create on first use |

---

## 7. Evidence Trail

- **Audit-43 report**: `agent/reports/audit-43-m21-m22-m23-plan-review.md`  
- **Audit-44 report**: `agent/reports/audit-44-m21-m22-m23-second-pass.md`  
- **Audit-45 report**: `agent/reports/audit-45-m21-m22-m23-final-readiness.md`  
- **Git commits**: `1ff5703` (A43+fixes), `475cb75` (A44+fixes), `f9d93a9` (A45+fixes)  
- **Lessons**: `agent/memory/lessons.md` — all entries dated 2026-07-14 and 2026-07-15
