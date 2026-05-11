<!-- @acp.meta.milestone
id: M40
title: Pre-Implementation Audit Protocol
status: completed
tasks: route-018, route-019, route-020, route-021
completed: 2026-05-11
version_introduced: 6.6.0
feedback_source: feedback-003-pre-implementation-audit.md
@acp.meta.end -->

# Milestone 40: Pre-Implementation Audit Protocol

**Status**: Completed  
**Completed**: 2026-05-11  
**Version**: 6.5.0 → 6.6.0  
**Feedback Source**: [feedback-003](../feedback/feedback-003-pre-implementation-audit.md)  

---

## Overview

Adds a structured pre-implementation audit mode (`/acp-audit --pre-impl`) to the ACP protocol. Before starting any coding task, the agent can now run a 4-phase readiness check: plan correctness, code cross-reference, audit carryover review, and operational completeness. Unresolved findings from any audit are persisted to `agent/memory/audit-carryovers.md` and automatically surfaced at every session start via Step 4.4 of the context-loading protocol.

---

## Deliverables

### Route-018 — Create audit-carryovers.md
- [x] `agent/memory/audit-carryovers.md` created with YAML schema
- [x] `carryovers: []` root key structure (entries stored under `carryovers:` key)
- [x] Schema documented: audit_id, finding_id, severity, file, finding, status, fix_applied_date, verified_in_audit, escalated_to
- [x] Protocol comments: write / check / update / verify / remove lifecycle

### Route-019 — acp.audit.md --pre-impl mode
- [x] Version bumped 1.0.0 → 1.1.0; Last Updated 2026-05-11
- [x] `--pre-impl` flag added to Arguments section with example invocation
- [x] Step 3b "Pre-Implementation Readiness Protocol" added (4 phases)
  - Phase 1: Plan Correctness (route/task file, files_affected, blockers)
  - Phase 2: Code Cross-Reference (field names, enums, imports, HTTP methods)
  - Phase 3: Carryover Check (reads `carryovers:` list from audit-carryovers.md)
  - Phase 4: Operational Completeness (version bump, wiki, route file)
- [x] Step 4 updated: carryover write for ALL modes (standard + --pre-impl)
- [x] Verification checklist updated
- [x] Changelog section v1.1.0 added

### Route-020 — Step 4.4 in all 3 protocol files
- [x] `AGENTS.md`: Step 4.4 audit-carryovers.md check inserted after Step 4.3
- [x] `CLAUDE.md`: Step 4.4 inserted identically
- [x] `.github/copilot-instructions.md`: Step 4.4 inserted identically
- [x] Format: surfaces pending items with ⚠️ warning; skips silently if empty/fixed

### Route-021 — Quality gate + milestone wrap-up
- [x] `agent/tasks/task-1-{title}.template.md`: quality gate HTML comment added before `## Verification`
- [x] `agent/milestones/milestone-40-pre-impl-audit-protocol.md`: created (this file)
- [x] Version bumped 6.5.0 → 6.6.0 (identity.yml, package.yaml, AGENT.md, progress.yaml)
- [x] `CHANGELOG.md`: [6.6.0] entry added
- [x] `agent/progress.yaml`: M40 status → completed (4/4 tasks), version → 6.6.0
- [x] `agent/wiki/architecture.md`: Pre-Implementation Audit mode section added
- [x] `agent/wiki/domain.yml`: audit-carryovers.md documented; --pre-impl flag documented
- [x] Route files 018–021 stamped `completed: 2026-05-11`

---

## Acceptance Criteria

- [x] `/acp-audit --pre-impl <subject>` executes 4-phase readiness check before any code is written
- [x] Phase 2 code cross-reference reads actual files to verify field names, enums, imports, HTTP methods
- [x] Phase 3 reads `carryovers:` key from audit-carryovers.md and surfaces pending items
- [x] Any audit (standard or --pre-impl) with actionable findings writes to audit-carryovers.md
- [x] Step 4.4 in all 3 protocol files reads audit-carryovers.md at session start and warns if pending
- [x] Quality gate comment in task template enforces pre-write cross-reference discipline
- [x] All wiki and protocol files updated to reflect new memory layer

---

## Design Notes

- `audit-carryovers.md` is gitignored (instance-specific state) but tracked in this repo with `-f`
- The `carryovers:` key is the root list — not individual top-level entries — to allow future metadata additions
- Step 4.4 is conditional (skips silently if file absent or all fixed) — zero noise when no carryovers exist
- Quality gate is an HTML comment — invisible in rendered Markdown, visible to the agent reading raw file
- `--pre-impl` mode extends (does not replace) standard audit — both report sections appear in output
