---
id: task-276
milestone: M82
title: "Document chunked CodeRabbit CLI playbook"
status: completed
priority: 5
complexity: medium
estimated_hours: 2
created: 2026-07-24
started: null
completed: 2026-07-24
depends_on: [task-275]
files_affected:
  - agent/wiki/coderabbit-local-thorough-review.md
  - agent/wiki/coderabbit-integration.md
---

## Objective

Write a maintainer playbook for thorough **local** CodeRabbit CLI review of ACP Enhanced, given the binding constraint that the CLI is **diff-only**.

## Steps

1. Create `agent/wiki/coderabbit-local-thorough-review.md` covering:
   - Diff-only limitation + “too many files” narrowing
   - Auth/org notes (Rygan login vs `ssucipto/acp-enhanced` owner)
   - Chunk table (`scripts/`, `agent/scripts/`, `e2e/`, `tests/`, `.github/workflows/`, recent-tag window)
   - Commands: `--agent`, `--light`, `--dir`, `--base`, `--base-commit`
   - Artifact layout: `agent/reports/coderabbit-local-YYYY-MM-DD/*.json`
   - Sanitization checklist (tokens, emails, private URLs)
   - Explicit: CLI sample ≠ ADR-22 PR fixture
2. Add a short pointer from `agent/wiki/coderabbit-integration.md` → this playbook.
3. Dry-run one chunk command from the playbook; record whether it produced a diff or needs a historical window.

## Verification

- [ ] Playbook exists and is runnable by a future agent without re-deriving limits
- [ ] Integration wiki links to it
- [ ] At least one dry-run command documented with expected outcome (diff vs no-changes)

## User-Observable Acceptance

A new agent can run the campaign from the wiki alone.
