---
id: task-326
milestone: M87
title: "Pattern, project-create, and install gitignores"
status: planned
priority: 4
complexity: low
estimated_hours: 2
created: 2026-08-27
started: null
completed: null
phase: 2
depends_on: [task-324]
design_reference: [agent/design/local.public-repo-privacy-purge.md](../../design/local.public-repo-privacy-purge.md)
audit_findings: ['F-118-05', 'F-118-06', 'F-119-03', 'F-119-08']
files_affected:
  - agent/patterns/local.tracked-untracked-directories.md
  - agent/commands/acp.project-create.md
  - agent/scripts/acp.install.sh
  - agent/scripts/acp.package-create.sh
---

<!-- @acp.meta.task
topic: m87, pattern, project-create, gitignore-heredoc
description: Align pattern and new-project gitignore templates with ADR-27. Live gitignore writer is acp.install.sh, not bootstrap.
milestone: M87
design: agent/design/local.public-repo-privacy-purge.md
incorporates: D2, D5
depends_on: task-324
status: planned
updated: 2026-08-27
@acp.meta.end -->

## Objective

New installs and the tracked-untracked pattern must gitignore report/feedback **bodies** (`**` + keepers), matching **CB-2**. This public AE repo must **not** document `git add -f` for reports.

## Context

audit-119: `scripts/acp-bootstrap.sh` only `mkdir`s `agent/reports` — it does **not** write `agent/.gitignore`. The heredoc is `agent/scripts/acp.install.sh:162-173` (still D9). `acp.package-create.sh:807-811` uses `agent/reports/*.md` / `agent/feedback/*.md`, which **misses nested files**.

## Steps

1. Pattern: reports/feedback = local like drafts; cite ADR-27. Remove “force-add to share reports” as the default for **this** public protocol repo. Optional tracking may remain as a consumer-fork note, not AE `origin`.
2. `acp.project-create.md`: replace “D9: reports/ and feedback/ are tracked” with CB-2-equivalent patterns (`**`, keepers).
3. `acp.install.sh` heredoc: same CB-2 block as `agent/.gitignore`.
4. `acp.package-create.sh` generated `.gitignore`: `agent/reports/**` and `agent/feedback/**` with `!` keepers — not `*.md`.
5. Attribution one-liner (F-118-06): consumer **names** may appear in CHANGELOG/README if already public; consumer **internals** never go in git.
6. Bootstrap: no gitignore change required unless a later grep shows a heredoc (322 map).

## Verification

- [ ] `rg 'D9: reports' agent/commands agent/scripts agent/patterns` is empty
- [ ] Install heredoc contains `reports/**` and `!reports/.gitkeep`
- [ ] Package-create gitignore does not use `agent/reports/*.md` as the only ignore
- [ ] Pattern does not instruct AE maintainers to `git add -f` reports

## User-Observable Acceptance

A project installed from AE templates does not commit audit reports by default.

## Expected Output

### Files Created / Modified
- files_affected list above

### Notes
F-118-06 is policy text, not a dump of feedback files.
