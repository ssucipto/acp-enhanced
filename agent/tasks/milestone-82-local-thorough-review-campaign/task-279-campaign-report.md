---
id: task-279
milestone: M82
title: "Campaign report + M81 fixture gap note"
status: planned
priority: 5
complexity: low
estimated_hours: 1
created: 2026-07-24
started: null
completed: null
depends_on: [task-278]
files_affected:
  - agent/reports/review-002-local-thorough-campaign.md
  - agent/progress.yaml
  - agent/wiki/coderabbit-integration.md
---

## Objective

Publish the campaign summary report, update progress next_steps, and document honestly how (not) this relates to the M81 ADR-22 fixture gate.

## Steps

1. Write `agent/reports/review-002-local-thorough-campaign.md`:
   - Scope, commands, finding counts (ACP vs CLI)
   - Top themes / carryover IDs created
   - Chunks skipped and why
2. Update `progress.yaml`: M82 → completed (when done); `recent_work`; `next_steps` (keep M81 fixture as primary product unblocker).
3. Wiki note: CLI campaign artifacts are **not** a substitute for `tests/fixtures/coderabbit-findings-sample.json` (PR-comment shape). Optional: if a sanitized CLI `--agent` sample is committed for importer *exploration*, label it `*-cli-agent-sample.json` and mark **insufficient for ADR-22 gate**.
4. No version bump unless this campaign also ships code fixes (those should be separate fix commits / patch release).

## Verification

- [ ] review-002 exists and links to chunk MANIFEST
- [ ] M81 gate language remains accurate
- [ ] `current_milestone` still M81 unless maintainer switches

## User-Observable Acceptance

Clear written record of the thorough local review, with an unambiguous statement that M81 still needs the PR findings fixture.
