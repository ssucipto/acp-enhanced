---
id: route-178
title: "Add cross-file consistency validators to acp-validate.ts + constraints.yml rules"
task_type: typescript-feature
milestone: M62
complexity: medium
executor: deepseek-v4-pro
context_required: [scripts/acp-validate.ts, scripts/acp-validate.test.ts, agent/core/constraints.yml, agent/progress.yaml, agent/memory/sessions.md]
files_affected:
  - scripts/acp-validate.ts
  - scripts/acp-validate.test.ts
  - agent/core/constraints.yml
tokens_est: 8000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-15
started: 2026-06-15
completed: 2026-06-15
override_reason:
---

# Route 178: Cross-file consistency validators + constraints.yml rules

## Context

Today's M61 autonomous completion exposed 15 shortcuts across 3 rounds. Ten of those
would have been caught by automated consistency checks — but no such checks exist.
This route adds them to `acp-validate.ts` so `/acp-validate` catches version drift,
stale tracking, missing tags, blank verification gates, and gitignore/gitattributes
misconfiguration before they reach human review.

Additionally, add two rules to `constraints.yml`:
- `test_quality_gate` — a hard rule that unit tests must assert behavior, not just types
- `post_milestone_sweep` — a hook referencing the new sweep script (to be added in route-179)

## Objective

Add 7 cross-file consistency validators to `acp-validate.ts` with corresponding unit
tests, plus 2 constraints.yml entries. No new bash scripts in this route.

## Acceptance Criteria

- `/acp-validate` reports: version inconsistency across files, stale next_steps,
  milestone doc version drift, blank verification gates, missing git tags,
  .gitignore conflicts for tracked files, missing .gitattributes coverage
- All 7 validators have unit tests in `acp-validate.test.ts` (at least 1 test each,
  including a pass case and a fail case)
- Existing tests continue to pass (`vitest run` green, all 33+ tests)
- `constraints.yml` has new `test_quality_gate` rule and `post_milestone_sweep` hook
- `tsc --noEmit` passes

## Expected Output

### Files Created
- None (all changes are modifications)

### Files Modified
- `scripts/acp-validate.ts` — add 7 exported validator functions grouped under a
  `## ── Cross-file Consistency ──` section comment, each wired into `runConsistencyScan()`
  (or the existing `main()`)
- `scripts/acp-validate.test.ts` — add unit tests for all 7 new validators
- `agent/core/constraints.yml` — add `test_quality_gate` under `rules:` and
  `post_milestone_sweep` under `hooks:pre_commit:` (second entry)

## Validator Specifications

### 1. `validateVersionConsistency(files: string[]): ValidationError[]`
Agreed version-files:
  - `agent/core/identity.yml` (version field)
  - `AGENTS.md` (first line: `> vX.Y.Z —`)
  - `CLAUDE.md` (first line: `> vX.Y.Z —`)
  - `CHANGELOG.md` (first `## [X.Y.Z]` entry)
All four must report the same version. Mismatch = error.

### 2. `validateNextStepsFreshness(progressPath: string): ValidationError[]`
Parse `agent/progress.yaml` → `current_milestone` and `next_steps[0]`.
If `next_steps[0]` text contains the string of `current_milestone` (e.g.
next_steps says M61 but current_milestone is M62), it's a warning — the next
step should point to the next milestone, not the current one.
Also warn if next_steps is empty.

### 3. `validateMilestoneDocVersion(milestonePath: string, identityVersion: string): ValidationError[]`
Read the milestone doc `**Target version**` line. Compare to `identity.yml` version.
Mismatch = error. Target version older than identity version = warning (possible stale).

### 4. `validateVerificationGates(milestonePath: string): ValidationError[]`
Read the `## Industry-Standard Verification (double-verify gate)` section.
Flag any bullet that is purely aspirational text (no checkmark, no
`✅`/`❌`/`⏳` prefix, no pass/fail data) as a warning.
If the entire section is missing, error for M58+ milestones (required section).

### 5. `validateGitTagsExist(version: string): ValidationError[]`
Run `git tag --list "v{version}"`. If empty, error. The identity.yml version
should always have a matching annotated git tag.

### 6. `validateGitignoreConflicts(trackedFiles: string[]): ValidationError[]`
For each file in `trackedFiles`, run `git check-ignore <file>`. If the file is
ignored (exit 0), emit a warning. The file is tracked by an ACP task but blocked
by .gitignore.

### 7. `validateGitattributesCoverage(scriptsDir: string): ValidationError[]`
Check `.gitattributes` for LF enforcement rules. If `scriptsDir` contains `.ts`
or `.json` files but `.gitattributes` has no `*.ts text eol=lf` or
`*.json text eol=lf` rules, emit a warning.

## Integration

Wire all 7 validators into a single `runConsistencyScan()` function called from
`main()` (or the existing `run*` dispatch). Each validator should run independently —
failure of one does not prevent others from running.

## Constraints.yml

### `test_quality_gate` rule:
```yaml
  - test_quality_gate: when a task includes a step requiring unit tests, at least
      one test must assert on output values (not just types). A test whose only
      assertion is `typeof result === "string"` is a bug, not a test — reject it.
```

### `post_milestone_sweep` hook:
```yaml
  pre_commit:
    - task_id: pre-commit-rule-audit
      description: "Scan ACP rule files for Unicode injection before commit"
    - task_id: post-milestone-sweep
      description: "Run post-milestone sweep after /acp-proceed --complete (acp.post-milestone-sweep.sh)"
```

## Verification

- [ ] `vitest run` passes all existing + new tests
- [ ] `tsc --noEmit` clean
- [ ] `/acp-validate` reports version inconsistency when identity.yml differs from AGENTS.md
- [ ] `/acp-validate` warns when next_steps[0] references current milestone
- [ ] `/acp-validate` errors when milestone doc target version != identity version
- [ ] `/acp-validate` warns on blank verification gate bullets
- [ ] `/acp-validate` errors when git tag for current version is missing
- [ ] `/acp-validate` warns when .gitignore blocks a tracked file path
- [ ] `/acp-validate` warns when .gitattributes lacks TS/JSON LF rules
- [ ] `constraints.yml` has both new entries
- [ ] `constraints.yml` is valid YAML

## User-Observable Acceptance

- Running `/acp-validate` after a version bump but before a git tag emits:
  `❌ Missing git tag for vX.Y.Z. Run: git tag -a vX.Y.Z -m "..." <commit>`
- Running `/acp-validate` when CHANGELOG has been updated but AGENTS.md hasn't emits:
  `❌ Version inconsistency: identity.yml=vX.Y.Z, AGENTS.md=vX.Y.W`
- Running `/acp-validate` on a milestone doc with a blank verification gate emits:
  `⚠️  agent/milestones/milestone-N.md: verification gate item is blank (no pass/fail/⏳)`
