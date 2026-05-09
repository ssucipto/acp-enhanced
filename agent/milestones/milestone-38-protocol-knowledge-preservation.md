# Milestone 38: Protocol Knowledge Preservation — feedback-001 Fixes

<!-- @acp.meta.milestone
topic: protocol, knowledge-preservation, proactive-commit, session-memory, feedback
description: Implement all fixes from feedback-001 (TikrFlow knowledge loss incident) — proactive commit triggers, phase-boundary session writes, gap-check substep, knowledge-preservation constraints.
tasks: route-013
status: completed
updated: 2026-05-09
@acp.meta.end -->

**Goal**: Fix the structural causes of context-overflow knowledge loss identified in feedback-001, by adding proactive commit triggers, phase-boundary session write rules, and a gap-check validation substep to the ACP Enhanced protocol.  
**Duration**: 0.5 day  
**Priority**: High (prevents permanent loss of session knowledge to silent context overflow)

---

## Overview

Feedback item `feedback-001-proactive-commit-and-knowledge-preservation.md` documented a real incident
in the TikrFlow project where 3 sessions of ACP Enhanced work were permanently lost because `/acp-commit`
was only invoked at session end — and context overflow terminated all three sessions before the commit
could run.

The root cause was structural: `/acp-commit` was designed as a passive, end-of-session command, but
sessions can be terminated at any point by context overflow. Any work not written to disk at the moment
of discovery is permanently and silently lost.

The fix introduces a **write-ahead logging** approach: 7 trigger events require immediate memory writes,
not deferred end-of-session dumps.

---

## Deliverables

### 1. audit-008 Report
- `agent/reports/audit-008-feedback-001-knowledge-preservation.md` — full investigation of feedback-001

### 2. Context Loading Protocol Updates (all three agent entry files)
- `AGENTS.md` — Step 4 gap-check substep + Mid-Session Commit Triggers section
- `CLAUDE.md` — identical update
- `.github/copilot-instructions.md` — identical update

### 3. Constraints Update
- `agent/core/constraints.yml` — 6 new knowledge-preservation rules:
  - `write_lessons_at_discovery`
  - `write_session_at_phase_boundary`
  - `write_patterns_at_discovery`
  - `write_adr_at_decision`
  - `context_overflow_commit_first`
  - `validate_prior_session_at_start`

### 4. Command Update
- `agent/commands/acp.commit.md` — v1.0.0 → v1.1.0: phase-boundary frequency, overflow risk warning, proactive trigger list

### 5. Memory Update
- `agent/memory/lessons.md` — high-priority `acp-knowledge-gap` postmortem prepended

---

## Commit

- `4e00a90` — "fix(protocol): proactive commit triggers — feedback-001 knowledge preservation" (2026-05-09)

---

## Status: ✅ COMPLETE

All 5 deliverables shipped in commit `4e00a90` on 2026-05-09.

**Note**: Audit-009 identified 6 process compliance gaps in how this work was executed (no route file,
no session entry, stale progress.yaml, no CHANGELOG entry, AGENT.md not updated, wiki not updated).
All 6 gaps were retroactively fixed in the audit-009 compliance pass (2026-05-09).
