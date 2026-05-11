---
id: route-042
title: M42 — Move FINAL-REVIEW.md to agent/design/ + M42 milestone wrap-up (STRUCT-003)
task_type: documentation-sync
milestone: M42
complexity: low
executor: deepseek-v4-flash
context_required:
  - scripts/FINAL-REVIEW.md
  - agent/wiki/domain.yml
  - agent/core/identity.yml
  - agent/progress.yaml
  - CHANGELOG.md
  - agent/milestones/milestone-42-dispatch-integrity-and-validation-hardening.md
files_affected:
  - scripts/FINAL-REVIEW.md
  - agent/design/acp-ux-review.md
  - agent/wiki/domain.yml
  - agent/core/identity.yml
  - package.yaml
  - AGENT.md
  - CHANGELOG.md
  - agent/progress.yaml
  - agent/memory/audit-carryovers.md
  - agent/routing/tasks/route-036.md (completed stamp)
  - agent/routing/tasks/route-037.md (completed stamp)
  - agent/routing/tasks/route-038.md (completed stamp)
  - agent/routing/tasks/route-039.md (completed stamp)
  - agent/routing/tasks/route-040.md (completed stamp)
  - agent/routing/tasks/route-041.md (completed stamp)
  - agent/routing/tasks/route-042.md (completed stamp)
tokens_est: 5000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-05-11
completed: 2026-05-11
override_reason:
---

## Task Description

Final route of M42. Move `scripts/FINAL-REVIEW.md` to `agent/design/acp-ux-review.md` so the UX analysis is discoverable by the context-loading protocol. Then perform all M42 wrap-up steps: version bump, CHANGELOG, progress.yaml update, and route stamping.

## Context

From audit-015 STRUCT-003:
> `FINAL-REVIEW.md has useful UX analysis but lives in scripts/ outside agent/ tree — never loaded by context protocol. Should move to agent/design/acp-ux-review.md.`

## Acceptance Criteria

### STRUCT-003 — File move
- [ ] Read `scripts/FINAL-REVIEW.md` content before moving
- [ ] Create `agent/design/acp-ux-review.md` with the same content
  - Update any internal self-references from `scripts/FINAL-REVIEW.md` path to `agent/design/acp-ux-review.md`
  - Add a header note: `> *Originally at scripts/FINAL-REVIEW.md — moved to agent/design/ in M42 (route-042)*`
- [ ] Delete `scripts/FINAL-REVIEW.md`
- [ ] Update `agent/wiki/domain.yml` design section: add entry:
  ```yaml
  - name: acp-ux-review
    path: agent/design/acp-ux-review.md
    description: UX analysis of ACP workflow — command surface, cognitive load, interaction patterns
    category: design
  ```
- [ ] Search README.md and scripts/QUICKSTART.md for any links to `scripts/FINAL-REVIEW.md` and update to `agent/design/acp-ux-review.md`
- [ ] Verify: `scripts/FINAL-REVIEW.md` no longer exists; `agent/design/acp-ux-review.md` exists

### M42 version bump
- [ ] Bump version 6.7.0 → 6.8.0 in:
  - `agent/core/identity.yml` — `version:` field
  - `package.yaml` — `version:` field
  - `AGENT.md` — version badge or version field

### CHANGELOG.md entry
- [ ] Add `[6.8.0] - [today's date]` entry at top of CHANGELOG.md covering all 7 M42 routes:
  ```
  ## [6.8.0] - YYYY-MM-DD

  ### Fixed
  - dispatch.ts: `updateRoutingYml()` now executes AFTER `appendLedger()` — no stale routing.yml on API failure (BUG-003)
  - dispatch.ts: SIGINT handler flushes partial ledger row and exits cleanly without mutating routing.yml (BUG-003)

  ### Added
  - acp-validate.ts: `validateSessionsMemory()` — checks sessions.md YAML structure, reports malformed entries (MEMORY-002)
  - acp-validate.ts: `validateAgentsMdSize()` — guards AGENTS.md/CLAUDE.md/copilot-instructions.md byte size (VALIDATE-001)
  - constraints.yml: `agents_md_rules` block with max_bytes/warn_at_bytes thresholds (VALIDATE-001)
  - acp-validate.ts: parity check now prints specific missing filenames, not just counts (VALIDATE-002)
  - taxonomy.yml: 9 new task types (wiki-update, memory-write, changelog-update, progress-update, adr-write, audit-run, milestone-create, route-create, upstream-parity-check) (ROUTING-001)
  - dispatch.ts: `getSkillFile()` explicit crosscutTypes mapping for all 9 new types (ROUTING-002)
  - taxonomy.yml: parseable `last_updated:` header field (ROUTING-003)
  - acp-validate.ts: `checkStaleness()` — warns on old taxonomy.yml and model config dates (ROUTING-003)

  ### Changed
  - lessons.md: `status: archived` and `superseded_by:` fields added to schema; TikrFlow overflow lesson archived (MEMORY-001)
  - dispatch.ts: `getFilteredLessons()` skips archived lessons (MEMORY-001)

  ### Moved
  - `scripts/FINAL-REVIEW.md` → `agent/design/acp-ux-review.md` — UX analysis now in agent/ tree (STRUCT-003)
  ```

### progress.yaml update
- [ ] M42 milestone entry: `status: completed, progress: 100, tasks_completed: 7, tasks_total: 7, completed: [today]`
- [ ] `current_milestone: M42-complete`
- [ ] Add `next_steps` entry: `✅ M42 DONE: dispatch integrity + validation hardening (routes 036-042, v6.8.0)`
- [ ] Remove (or update): `📋 FUTURE: M42 — P1 visualizer (kanban, GitHub remote, multi-project)` (that was a different M42 plan — overwrite with completed entry)
- [ ] Update `project.version: 6.7.0` → `6.8.0` in progress.yaml header
- [ ] Update `description:` to reference version 6.8.0 and M42 completion

### Route stamping
- [ ] Set `completed: [today]` on all 7 route files: route-036 through route-042
- [ ] Use `git add -f` for all routing/tasks/ files (gitignored)

### Audit carryover closure
- [ ] Update `agent/memory/audit-carryovers.md`: mark all 9 audit-015 entries as:
  ```yaml
  status: fixed
  fix_applied_date: [today]
  verified_in_audit: "016"  # audit-016 will verify M42
  ```
  (Note: set `verified_in_audit: null` if audit-016 hasn't run yet — update after audit-016)

### Write M42 session entry
- [ ] Append M42 session summary to `agent/memory/sessions.md`:
  ```yaml
  - date: [today]
    executor: copilot
    tasks: [route-036, route-037, route-038, route-039, route-040, route-041, route-042]
    done:
      - fix-dispatch-routing-yml-order
      - add-sigint-ledger-flush
      - add-validate-sessions-memory
      - add-agents-md-size-guard
      - add-parity-diff-filenames
      - add-9-taxonomy-entries
      - add-getskillfile-crosscut-mapping
      - archive-tikrflow-lessons
      - add-staleness-check
      - move-final-review-to-design
    deferred: []
    key_fact: All 9 audit-015 findings resolved in M42; dispatch.ts BUG-003 was highest-risk fix.
  ```
- [ ] Use `git add -f` for sessions.md (gitignored)

## Implementation Notes

Run wrap-up steps in order: file-move → version-bump → CHANGELOG → progress.yaml → carryover closure → route stamps → session entry. Use `git add -f` for all gitignored files. Verify `git status` shows clean state for all M42 files before final commit.
