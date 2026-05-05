---
id: task-157
milestone: M29
title: Create upstream integration runbook pattern
status: not_started
priority: 3
complexity: low
estimated_hours: 2
created: 2026-05-05
started:
completed:
---

## Objective

Create `agent/patterns/local.upstream-integration-runbook.md` — a reusable step-by-step runbook for future upstream sync cycles, so the next integration analysis doesn't require a full-session deep-dive from scratch.

## Context

The 2026-05-05 upstream integration analysis was thorough but ad-hoc. It surfaced important insights (git history rewrite means no merge possible, code-level audit before porting, naming convention translation needed) that are now in ADR-7 and ADR-8. But the *process* itself — how to do a sync cycle efficiently — should be captured as a reusable pattern.

The runbook should be short (≤50 lines) and actionable: someone returning for the next upstream sync should be able to execute it without reading the full ADR history.

## Implementation

Create `agent/patterns/local.upstream-integration-runbook.md` with sections:

### 1. When to Run
- "Run when upstream releases a new minor or major version"
- "Check https://github.com/prmichaelsen/agent-context-protocol/blob/mainline/CHANGELOG.md"

### 2. Step-by-Step Process
1. Read upstream CHANGELOG since last sync version (look for `key_fact` in sessions.md for last checked version)
2. For each new feature: check ACP Enhanced codebase before assuming it's missing
3. Run code-level audit: `grep -r "feature-keyword" agent/commands/ agent/scripts/`
4. For any genuine gap: check the 4 constraints (macOS, no-deps, token budget, naming)
5. Assign HAVE/PARTIAL/PORT/DEFER in parity matrix
6. Update `agent/design/local.upstream-parity-matrix.md`
7. For PORT items: create tasks in next available milestone
8. Update ADR-7 and ADR-8 if integration strategy changes

### 3. Naming Translation Rule
```
upstream uses: @acp.<name>
ACP Enhanced uses: /acp-<name>
Rule: globally replace @acp.<name> → /acp-<name>
      @acp-<name> is NEVER valid — hyphen after @ is wrong
```

### 4. Why No Git Merge
- Upstream rewrote history at v6.0.0 (no shared ancestry)
- See ADR-7 for full context

### 5. Reference Documents
- ADR-7: upstream integration strategy
- ADR-8: no-re-port rule
- `agent/design/local.upstream-parity-matrix.md`: current parity state

## Expected Output

### Files Created
- `agent/patterns/local.upstream-integration-runbook.md`

## Verification
- [ ] File exists and is ≤60 lines
- [ ] Naming translation rule section is present and correct
- [ ] Step-by-step process has ≥7 steps
- [ ] References to ADR-7, ADR-8, and parity matrix are present

## User-Observable Acceptance
A fresh agent session can run the next upstream integration cycle by reading only this runbook + the parity matrix. The 2026-05-05 deep-dive analysis does not need to be repeated.
