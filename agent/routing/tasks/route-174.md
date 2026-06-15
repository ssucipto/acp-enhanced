---
id: route-174
title: Add ## Steps to integrity/review; ## Verification to 5 commands
task_type: command-doc-update
milestone: M62
complexity: low
executor: copilot
context_required:
  - skills/commands.md
files_affected:
  - agent/commands/acp.integrity.md
  - agent/commands/acp.review.md
  - agent/commands/acp.dispatch.md
  - agent/commands/acp.feedback.md
  - agent/commands/acp.install.md
  - agent/commands/acp.task.md
  - agent/commands/acp.visualize.md
tokens_est: 6000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-15
started: 2026-06-15
completed: 2026-06-15
override_reason:
---

## Objective

Bring all command docs to structural conformance: add a `## Steps` section to `acp.integrity.md` and `acp.review.md`, and a `## Verification` section to the 5 commands lacking one.

## Context

`acp.integrity.md` and `acp.review.md` lack `## Steps` (audit-065 HIGH-065-002); 5 commands lack `## Verification` (MED-065-003): dispatch, feedback, install, task, visualize. After route-161 wires structural validation into CI, these become hard failures — fix them so CI can hard-fail going forward.

## Steps

1. For `acp.integrity.md` / `acp.review.md`: add a `## Steps` section that serves as a numbered entry-point/overview to their existing rule tables (these commands organize content as rule catalogues; add Steps that walk the agent through invocation → scan → report → carryover, referencing the tables).
2. For dispatch/feedback/install/task/visualize: add a `## Verification` checklist with checkboxes appropriate to each command's effects.
3. Follow `agent/skills/commands.md` conventions (imperative voice, Expected Outcome).
4. Coordinate with route-161: once all are conformant, flip the CI structural check from warn to hard-fail.

## Expected Output

### Files Modified
- 7 command docs (2 gain `## Steps`, 5 gain `## Verification`)

## Verification (double-verify)

- [ ] **Automated**: `/acp-validate` + CI structural check pass for all command docs; flip to hard-fail
- [ ] **Manual**: each edited doc has the required section with meaningful content (not a stub)
- [ ] No duplicate/conflicting sections introduced

## User-Observable Acceptance

- All 68 command docs have Steps + Verification
- CI structural check is hard-fail and green

## Addresses

audit-065 HIGH-065-002 (H7), MED-065-003 (M2) — consolidated register
