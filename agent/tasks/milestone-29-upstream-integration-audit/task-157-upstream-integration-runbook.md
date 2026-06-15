---
id: task-157
milestone: M29
title: Create upstream integration runbook pattern
status: completed
priority: 3
complexity: low
estimated_hours: 2
created: 2026-05-05
started: 2026-05-05T00:00:00Z
completed: 2026-05-05
---

<!-- @acp.meta.task
topic: create, upstream, integration, runbook, pattern
description: Create upstream integration runbook pattern
milestone: M29
status: completed
updated: 2026-05-05
@acp.meta.end -->


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
4. For features that exist in BOTH: open both the upstream file AND the ACP Enhanced file and compare line-by-line. If they differ intentionally → assign DIVERGED (not HAVE) and document the divergence. If they are equivalent → assign HAVE with a citation of both files.
5. For any genuine gap: check the 4 constraints (macOS, no-deps, token budget, naming)
6. Assign HAVE/PARTIAL/DIVERGED/PORT/DEFER in parity matrix
7. Update `agent/design/local.upstream-parity-matrix.md`
8. For PORT items: create tasks in next available milestone; each task must include the post-port safety gate: run `bash run-e2e-tests.sh` and verify the ported code itself is bash 3.2-compatible
9. Update ADR-7 and ADR-8 if integration strategy changes

### 3. Naming Translation Rule
```
upstream uses: @acp.<name>
ACP Enhanced uses: /acp-<name>
Rule: globally replace @acp.<name> → /acp-<name>
      @acp-<name> is NEVER valid — hyphen after @ is wrong
```

### 4. Why No Git Merge — CRITICAL
- **NEVER run `git merge upstream/mainline`** — upstream rewrote history at v6.0.0; no shared ancestor exists; merge will corrupt the ACP Enhanced repository
- **NEVER `git cherry-pick` upstream commits** — ACP Enhanced has diverged significantly across every subsystem; cherry-pick without bidirectional analysis will silently overwrite intentional differences
- All upstream integration is manual: read upstream files → compare with ACP Enhanced files → port only after analysis
- See ADR-7 for full context

### 5. Reference Documents
- ADR-7: upstream integration strategy
- ADR-8: no-re-port rule
- `agent/design/local.upstream-parity-matrix.md`: current parity state

## Expected Output

### Files Created
- `agent/patterns/local.upstream-integration-runbook.md`

## Verification
- [ ] File exists and is ≤80 lines
- [ ] Naming translation rule section is present and correct
- [ ] Step-by-step process has ≥8 steps (including DIVERGED comparison step and post-port safety gate)
- [ ] "Why No Git Merge" section explicitly states NEVER git merge and NEVER git cherry-pick
- [ ] DIVERGED decision code is defined
- [ ] References to ADR-7, ADR-8, and parity matrix are present

## User-Observable Acceptance
A fresh agent session can run the next upstream integration cycle by reading only this runbook + the parity matrix. The 2026-05-05 deep-dive analysis does not need to be repeated.
