---
id: route-154
title: "M57-005: E2E test + cross-links + version bump 6.12.1 + CHANGELOG"
task_type: e2e-test-write
milestone: M57
complexity: medium
executor: copilot
context_required: [milestones/milestone-57-recurring-tasks-scheduler.md, routes 150-153]
files_affected: [e2e/acp.recurring-tasks.test.sh, agent/commands/acp.review.md, agent/commands/acp.integrity.md, AGENT.md, CHANGELOG.md, package.yaml, agent/core/identity.yml, agent/progress.yaml, README.md, IP_REGISTER.md]
tokens_est: 6000
created: 2026-06-08
completed: 2026-06-08
---

# Route 154: E2E Test + Release — Recurring Tasks Validation & v6.12.1 Ship

## Objective

Create E2E test suite for recurring tasks scheduler, add cross-links, bump version, and finalize release.

## Expected Output

### Files Created
- `e2e/acp.recurring-tasks.test.sh` — 10+ assertions

### Files Modified
- Cross-links: `acp.review.md`, `acp.integrity.md` (add recurring tasks reference)
- Version: `AGENT.md`, `package.yaml`, `agent/core/identity.yml`, `CHANGELOG.md`, `README.md`, `IP_REGISTER.md`
- `agent/progress.yaml` — M57 complete

## E2E Test: 12 Assertions

### Structural (5)
1. `progress.yaml` has `recurring_tasks:` block with ≥5 entries
2. `progress.template.yaml` has `recurring_tasks:` section
3. AGENTS.md contains "Step 4.5" or "Scheduled Review Due Check"
4. `constraints.yml` has `hooks:` block with `pre_commit_rule_file_audit`
5. `progress.schema.yaml` validates recurring_tasks fields

### Behavioral (7)
6. Schema: all 5 default tasks have all required fields (id, command, frequency/trigger, executor, last_run, next_due, status, description)
7. Frequency/trigger validation: tasks have either `frequency` or `trigger` (mutually exclusive)
8. Status validation: all entries have valid status values
9. Command reference: every `command` starts with `/acp-`
10. Executor cross-validation: every `executor` exists in taxonomy.yml
11. Overdue simulation: create temp progress.yaml with past next_due, verify overdue detection
12. Disabled exclusion: task with `status: disabled` excluded from overdue count

## Cross-Links
- `acp.review.md` → "Schedule with /acp-status — recurring_tasks in progress.yaml"
- `acp.integrity.md` → "Schedule with /acp-status — recurring_tasks in progress.yaml"

## Version Bump: 6.12.0 → 6.12.1
- Patch bump — protocol enhancement, no new commands
- CHANGELOG: `## [6.12.1] — 2026-06-08` with `### Added (M57)` section

## Verification

- [ ] E2E test: 10/10 assertions pass
- [ ] All cross-links added
- [ ] Version 6.12.1 across all 8 files
- [ ] CHANGELOG entry (Keep a Changelog format)
- [ ] `acp-validate` passes (version consistency)

## User-Observable Acceptance

- `e2e/acp.recurring-tasks.test.sh` exits 0
- `/acp-status` shows M57 complete
- Version badge shows 6.12.1
