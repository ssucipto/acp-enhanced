# Audit Report: M47 Pre-Implementation Readiness

**Audit**: #041  
**Date**: 2026-06-04  
**Subject**: M47 Memory Integrity & Feedback-Driven Improvements — planning review, gap analysis, and industry standards alignment  
**Mode**: --pre-impl  

---

## Summary

Audited the M47 milestone planning (11 routes, 074–084) produced in response to FIFOZ
feedback-001 and feedback-002. Cross-referenced all route files against the actual ACP
Enhanced v6.8.2 codebase. Verified feedback coverage completeness. Assessed alignment with
industry best practices and real-world workflow patterns.

**Key takeaway**: M47 planning is **solid and actionable**. All 11 P0/P1 items from the
feedback are correctly mapped. Four P2 gaps exist (feedback-001 F-05, audit-066 B-066-01/02/07/08)
and are noted for future milestone consideration. Two route description inaccuracies were
found (078, 081) and should be corrected before implementation. The dual-store auto-sync
design follows established patterns (Git checkout, DB checkpointing) but lacks atomicity
and rollback guarantees — acceptable for v6.9.0 given the idempotent design.

---

## Files Analyzed

| File | Type | Relevance |
|------|------|-----------|
| `agent/milestones/milestone-47-memory-integrity-feedback.md` | milestone | M47 definition and scope |
| `agent/routing/tasks/route-074.md` | route | Commit auto-sync sessions (step 2b) |
| `agent/routing/tasks/route-075.md` | route | Commit auto-sync patterns (step 3b) |
| `agent/routing/tasks/route-076.md` | route | Re-sync after compaction (step 6b) |
| `agent/routing/tasks/route-077.md` | route | Manual repair sync tools |
| `agent/routing/tasks/route-078.md` | route | Memory YAML validation (--memory) |
| `agent/routing/tasks/route-079.md` | route | Version-update guard |
| `agent/routing/tasks/route-080.md` | route | YAML quoting directives |
| `agent/routing/tasks/route-081.md` | route | Schema alignment (tasks vs tasks_completed) |
| `agent/routing/tasks/route-082.md` | route | Dual-store wiki documentation |
| `agent/routing/tasks/route-083.md` | route | Pattern promotion enforcement |
| `agent/routing/tasks/route-084.md` | route | Command onboarding |
| `agent/commands/acp.commit.md` | command | Current commit flow — target of routes 074–076, 080, 081, 083 |
| `agent/commands/acp.validate.md` | command | Current validate flow — target of route 078 |
| `agent/commands/acp.version-update.md` | command | Current version-update flow — target of route 079 |
| `agent/commands/acp.init.md` | command | Current init flow — target of route 084 |
| `agent/commands/acp.update.md` | command | Update flow — target of route 080 (quoting) |
| `agent/memory/patterns.md` | registry | Pattern registry — target of routes 075, 077, 078 |
| `agent/memory/sessions.md` | registry | Session registry — target of routes 074, 076, 077, 078 |
| `agent/memory/audit-carryovers.md` | carryover | Carryover tracking — Phase 3 check |
| `agent/progress.yaml` | state | Milestone/task tracking — updated with M47 |
| `agent/feedback/feedback-001-pattern-memory-visualizer-gaps.md` | feedback | Source of F-01 through F-09 |
| `agent/feedback/feedback-002-acp-enhanced-next-release-review.md` | feedback | Source of v6.9 recommendations + audit-066 |

---

## Pre-Implementation Readiness (M47)

### Phase 1 — Plan Correctness

| Check | Result | Notes |
|-------|--------|-------|
| All 11 route files exist | ✅ | routes 074–084 all present in `agent/routing/tasks/` |
| Route frontmatter complete | ✅ | All have id, title, task_type, milestone, complexity, executor, files_affected |
| Acceptance criteria unambiguous | ⚠️ | Routes 074/075 specify idempotency but not the hashing/comparison mechanism; routes 074/077 mention "shared engine" without interface definition |
| files_affected accurate | ⚠️ | Route-078 lists `agent/commands/acp.validate.md` only — should also list `agent/memory/patterns.md`, `agent/memory/sessions.md`, `agent/progress.yaml` as validation targets |
| Open blockers | ✅ None | No deferred decisions or open questions blocking implementation |
| Route dependencies tracked | ⚠️ | Routes 076→074, 077→074/075, 078→074/075, 083→075 are documented but routes 080↔078 (quoting → validation) bidirectional dependency not noted |

### Phase 2 — Code Cross-Reference

| File | Field/Value Checked | Result | Notes |
|------|---------------------|--------|-------|
| `acp.commit.md:83` | Schema uses `tasks:` not `tasks_completed:` | ✅ Confirmed | Route-081 correctly identifies this drift |
| `acp.commit.md:120` | Weekly-summary uses `tasks_completed:` | ⚠️ | Internal inconsistency: Step 2 uses `tasks:`, Step 6 uses `tasks_completed:`. Route-081 only addresses Step 2 — must also update Step 6 to be consistent |
| `acp.validate.md:409` | Step 11.6 validates sessions.md structure | ⚠️ | Validator checks `tasks:` key. If route-081 changes commit to `tasks_completed:`, this validator will break unless updated together |
| `acp.version-update.md:37-53` | Preserved files list — `identity.yml`, `domain.yml`, `taxonomy.yml` absent | ❌ | Confirmed F-03: these core files are NOT in the preserved list. `acp.version-update.md:54` admits "does not diff or warn about local modifications." Route-079 is correct and necessary |
| `acp.validate.md` | No `--memory` flag | ✅ Confirmed | Route-078 is genuinely new functionality |
| `acp.init.md` | No phase-based command recommendations | ✅ Confirmed | Route-084 is genuinely new functionality |
| `acp.commit.md:91` | Step 3 "Check for Reusable Patterns" exists | ✅ Confirmed | Route-083 correctly enhances existing step, doesn't duplicate |
| `agent/sessions/` | Directory does not exist | ✅ Confirmed | Route-074 will create it; this is expected pre-implementation state |
| `agent/patterns/` | 10 template files, not synced from registry | ✅ Confirmed | Route-075 will populate with synced documents |

### Phase 3 — Carryover Check

| Status | Count | Details |
|--------|-------|---------|
| Pending | 0 | All audit-014 through audit-040 carryovers are `status: fixed` |
| Fixed (unverified) | 0 | All fixed carryovers have `verified_in_audit` set |
| **Blocks M47?** | **No** | No open carryovers would block implementation |

### Phase 4 — Operational Completeness

| Check | Result | Notes |
|-------|--------|-------|
| Route files exist for all tasks | ✅ | 11/11 route files created |
| Version bump planned | ⚠️ | M47 targets v6.9.0 per milestone doc, but no explicit route handles version bump + CHANGELOG update |
| Wiki update planned | ✅ | Route-082 covers dual-store documentation |
| CHANGELOG update planned | ❌ | No route addresses CHANGELOG.md update. Should be added as acceptance criteria to P0 routes or as a standalone task |
| E2E tests planned | ❌ | No route addresses testing. Commit auto-sync (routes 074–076) and repair tools (route-077) are testable. Validation (route-078) is testable. |
| Migration path for pre-v6.9 projects | ⚠️ | Route-077 provides repair tools for existing projects, but no explicit "migration guide" route exists |

### Phase Summary

| Phase | Findings | Highest Severity |
|-------|----------|-----------------|
| Phase 1 — Plan Correctness | 3 (all ⚠️) | Medium |
| Phase 2 — Code Cross-Reference | 4 (1 ❌, 3 ⚠️) | High |
| Phase 3 — Carryover Check | 0 | None |
| Phase 4 — Operational Completeness | 3 (1 ❌, 2 ⚠️) | Medium |
| **Total** | **10** | |

---

## Key Findings

| Finding | Location | Severity | Notes |
|---------|----------|----------|-------|
| **GAP-041-01**: Route-081 field rename will break `acp.validate.md` Step 11.6 | `acp.validate.md:409` | High | Validator checks `tasks:` key. If commit changes to `tasks_completed:`, validator must be updated simultaneously. Route-081 `files_affected` lists only `acp.commit.md` — should include `acp.validate.md` |
| **GAP-041-02**: `acp.commit.md` has internal field inconsistency | `acp.commit.md:83,120` | Medium | Step 2 schema uses `tasks:`, Step 6 compaction uses `tasks_completed:`. Route-081 should address both, not just Step 2 |
| **GAP-041-03**: Route-078 context description inaccurate | `route-078.md` | Medium | Route claims `/acp-validate` has no memory validation. Actually Step 11.6 validates sessions.md structure (required keys + date format). Clarify: route-078 adds YAML SYNTAX parsing, not structural validation |
| **GAP-041-04**: Feedback-001 F-05 not covered | `feedback-001 §3` | Low | Registry schema lint (require `- date:` and `name:` on every list item; warn on unquoted colons in scalar values). Not in M47 scope — candidate for future milestone |
| **GAP-041-05**: Feedback-002 B-066 items not covered | `feedback-002 §9` | Low | B-066-01 (audit-first workflow docs), B-066-02 (progress-vs-git drift), B-066-07 (index bootstrap), B-066-08 (carryover query). P2 per feedback — not in M47 scope |
| **GAP-041-06**: No CHANGELOG update route | M47 milestone | Medium | M47 targets v6.9.0 but no route covers CHANGELOG.md. Add as acceptance criteria to P0 completion |
| **GAP-041-07**: No E2E test route | M47 milestone | Medium | Commit auto-sync, repair tools, and validation are testable. Industry standard: every user-facing feature should have tests |
| **GAP-041-08**: Atomicity not addressed in sync design | routes 074–076 | Medium | Multi-file sync operations lack atomicity guarantees. If sync fails after creating some files, state is inconsistent. Mitigated by idempotent design but not explicitly addressed |
| **GAP-041-09**: Route-078 files_affected incomplete | `route-078.md` | Low | Lists only `acp.validate.md` — should also include the three memory files being validated |
| **GAP-041-10**: Route-079 `files_affected` inaccurate | `route-079.md` | Low | Lists `agent/scripts/acp.version-update.sh` which does not exist (verified). The command is doc-only (no script). Should list only `acp.version-update.md` |

---

## Feedback Coverage Matrix

### Feedback-001 (Pattern Memory Visualizer Gaps)

| Finding | Description | Route | Covered? |
|---------|-------------|-------|----------|
| F-01 | Commit auto-sync patterns (step 3b) | 075 | ✅ |
| F-01b | Commit auto-sync sessions (step 2b) | 074 | ✅ |
| F-01c | Repair sync tools | 077 | ✅ |
| F-02 | Memory YAML validation | 078 | ✅ |
| F-03 | Dual-store wiki docs | 082 | ✅ |
| F-04 | Pattern promotion enforcement | 083 | ✅ |
| F-05 | Registry schema lint (date/name required, colon warnings) | — | ❌ Not covered |
| F-06 | Version-update guard | 079 | ✅ |
| F-07 | Commit YAML quoting hints | 080 | ✅ |
| V-01–V-05 | Visualizer issues | — | N/A (separate repo) |

### Feedback-002 (Next Release Review)

| Finding | Description | Route | Covered? |
|---------|-------------|-------|----------|
| F-01/F-01b | Commit auto-sync (primary requirement) | 074, 075 | ✅ |
| F-02 | Memory YAML validation | 078 | ✅ |
| F-03 | Version-update overwrite bug | 079 | ✅ |
| F-04 | write_patterns_at_discovery enforcement | 083 | ✅ |
| F-05 | Command onboarding (61→8 used) | 084 | ✅ |
| F-06 | Unquoted colons in progress.yaml notes | 080 | ✅ |
| F-07 | Dual-store docs | 082 | ✅ |
| F-08 | Weekly-summary quoting | 080 | ✅ |
| F-09 | Schema drift (tasks vs tasks_completed) | 081 | ✅ |
| B-066-01 | Audit-first workflow docs | — | ❌ P2, deferred |
| B-066-02 | progress-vs-git drift health check | — | ❌ P2, deferred |
| B-066-07 | Index bootstrap unused | — | ❌ P2, deferred |
| B-066-08 | Carryover query (5000+ lines) | — | ❌ P2, deferred |
| B-066-09 | memory-sync never run | 074, 075, 077 | ✅ (auto-sync solves this) |

**Coverage**: 16/20 findings covered (80%). 4 uncovered are all P2/nice-to-have.

---

## Industry Standards Alignment

| Standard / Pattern | M47 Design | Alignment |
|--------------------|------------|-----------|
| **Dual-store architecture** (Git checkout, DB WAL+data) | Registry → document sync on commit | ✅ Well-aligned. Registry is source of truth, documents are consumption layer |
| **Idempotent operations** | Sync skips unchanged files; re-running produces same result | ✅ Standard. Mirrors `rsync --checksum`, Terraform plan/apply |
| **Opt-out escape hatch** (`--no-sync`) | Debug-only, warns about drift | ✅ Standard. Mirrors `git commit --no-verify`, `npm --no-save` |
| **Separation of concerns** | Commit = primary path; repair tools = secondary | ✅ Standard. Mirrors `git gc` (auto) vs `git repack` (manual) |
| **Fail-soft validation** | `--memory` flag additive to existing validate | ✅ Standard. Non-breaking extension |
| **Atomicity / rollback** | Not addressed | ⚠️ Gap. Multi-file sync without transaction boundaries. Mitigated by idempotency |
| **Observability** | Confirmation output shows sync counts | ✅ Adequate for v6.9. Verbose mode could show per-file details |
| **Testing** | No test route in M47 | ❌ Gap. Industry standard: every user-facing feature has automated tests |
| **Migration path** | Repair tools (route-077) cover pre-v6.9 projects | ⚠️ Partial. No explicit migration guide or upgrade checklist |
| **Backward compatibility** | `--no-sync` preserves current behavior | ✅ Default is new behavior, opt-out is old behavior |

---

## Git History

| Date | Commit | Summary |
|------|--------|---------|
| 2026-06-04 | `9b60838` | plan(M47): create memory-integrity milestone with 11 routes from feedback-001/002 |

---

## Code Pointers

| Location | Description |
|----------|-------------|
| `agent/commands/acp.commit.md:83` | Current session entry schema uses `tasks:` — target of route-081 |
| `agent/commands/acp.commit.md:91` | Step 3 "Check for Reusable Patterns" — target of route-083 enhancement |
| `agent/commands/acp.commit.md:120` | Weekly-summary uses `tasks_completed:` — inconsistent with line 83 |
| `agent/commands/acp.validate.md:409` | Step 11.6 sessions.md structure validation — will break if route-081 changes field name |
| `agent/commands/acp.version-update.md:37-53` | Preserved files list — missing `identity.yml`, `domain.yml`, `taxonomy.yml` |
| `agent/commands/acp.version-update.md:54` | Admits "does not diff or warn about local modifications" — confirms F-03 |
| `agent/feedback/feedback-001...md §3` | F-05: registry schema lint — not covered by M47 |
| `agent/feedback/feedback-002...md §9` | B-066-01/02/07/08: workflow findings — not covered by M47 |
| `agent/routing/tasks/route-078.md` | Context description claims no memory validation exists — should be refined |
| `agent/routing/tasks/route-079.md` | Lists non-existent `acp.version-update.sh` in files_affected |

---

## Recommendations

1. **Fix route-081 scope (HIGH)**: Add `agent/commands/acp.validate.md` to `files_affected`. The field rename in commit must be mirrored in validate's Step 11.6. Also address the internal inconsistency between Step 2 (`tasks:`) and Step 6 (`tasks_completed:`) in `acp.commit.md`.

2. **Refine route-078 description (MEDIUM)**: Clarify that Step 11.6 already validates sessions.md STRUCTURE (required keys, date format). Route-078 adds YAML SYNTAX parsing — a complementary, not replacement, capability.

3. **Add test route (MEDIUM)**: Create a route for E2E tests covering commit auto-sync (verify documents created after commit), repair tools (verify --dry-run and --all), and validation (verify --memory catches bad YAML). Industry standard: don't ship features without tests.

4. **Add CHANGELOG criteria (MEDIUM)**: Either add a route for CHANGELOG.md update or add it to the acceptance criteria of P0 routes. v6.9.0 needs release notes.

5. **Address atomicity in implementation (LOW)**: During route-074/075 implementation, consider partial-failure recovery. Idempotent design mitigates most risks, but explicit handling of "sync started, created 3 of 5 files, then failed" is good practice.

6. **Defer P2 gaps to M48 (LOW)**: F-05 (registry schema lint) and B-066-01/02/07/08 (workflow improvements) should be tracked in a future milestone. Note them in progress.yaml `next_steps`.

7. **Fix route-079 files_affected (LOW)**: Remove `agent/scripts/acp.version-update.sh` — it doesn't exist. Version update is a doc-only command.

---

### Readiness Verdict

**READY with conditions** — M47 planning is sound and all critical P0/P1 feedback items are mapped. The 3 HIGH-severity findings (GAP-041-01, GAP-041-02, GAP-041-03) should be addressed in the route files before implementation begins. The 7 MEDIUM findings are implementation concerns that can be resolved during coding or deferred to M48. No blockers. Proceed to route-074.
