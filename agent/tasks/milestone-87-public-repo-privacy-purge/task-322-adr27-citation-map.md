---
id: task-322
milestone: M87
title: "Lock ADR-27 + citation map of tracked reports/feedback"
status: completed
priority: 5
complexity: low
estimated_hours: 2
created: 2026-08-27
started: 2026-08-27
completed: 2026-08-27
phase: 1
depends_on: [task-323, task-333, task-334]
design_reference: [agent/design/local.public-repo-privacy-purge.md](../../design/local.public-repo-privacy-purge.md)
audit_findings: ['F-118-04', 'F-119-05']
files_affected:
  - agent/memory/decisions.md
  - agent/design/local.public-repo-privacy-purge.md
  - agent/milestones/milestone-87-public-repo-privacy-purge.md
---

<!-- @acp.meta.task
topic: m87, adr-27, privacy, citation-map
description: Confirm ADR-27 and cookbook; inventory every command/E2E/wiki that assumes tracked reports.
milestone: M87
design: agent/design/local.public-repo-privacy-purge.md
incorporates: D1, D6
depends_on: task-323, task-333, task-334
status: planned
updated: 2026-08-27
@acp.meta.end -->

## Objective

Produce a **path-only** citation map so 324–327 cannot miss a live reference. Confirm the design cookbook (CB-1…CB-6) has no secrets.

## Context

ADR-27 and the design already exist. **Do not start this task until 333, 334, and 323 restore tests pass.** First `/acp-proceed` is **333**, not this file.

## Steps

1. Re-read ADR-27 and design cookbook. Confirm no consumer spec bodies, no `$HOME` usernames, no vendor account identifiers.
2. Run (record **paths only** in this task’s notes):

```bash
rg -l 'agent/reports|agent/feedback|validateProtocolDirAddability|Untracked evidence' \
  agent/commands agent/scripts scripts e2e tests agent/wiki agent/patterns \
  agent/core .github docs AGENT.md README.md package.yaml
```

3. Classify each hit: (a) local writer — keep, (b) validator/E2E — 324/325, (c) install/pattern — 326, (d) leftover pointer in remaining tracked files — 327.
4. Confirm F-R006-* is **not** on the map.
5. Do not `git add` any `agent/reports/` or `agent/feedback/` bodies (CB-6).

## Verification

- [x] Cookbook CB-1…CB-6 present in design
- [x] Citation map includes at least: `acp.install.sh`, `acp.package-create.sh`, `acp.design-spec.md`, `acp.validate.md`, `acp.ci.sh`, `architecture.md`, `acp-validate.test.ts`
- [x] No new secrets in planning docs

## User-Observable Acceptance

Task notes list every file 324–327 must touch.

## Expected Output

### Files Created / Modified
- This task file (citation map notes)

### Notes
Source: audit-119. Cookbook is canonical; do not invent flags.

Citation map 2026-08-27 (paths only; `rg -l` scoped as in Steps). F-R006-* not on this map.

**(a) local writer — keep (still write under reports/; do not commit bodies)**
- agent/commands/acp.audit.md
- agent/commands/acp.report.md
- agent/commands/acp.review.md
- agent/commands/acp.integrity.md
- agent/commands/acp.feedback.md
- agent/commands/acp.handoff.md
- agent/commands/acp.receive.md
- agent/commands/acp.resume.md
- agent/commands/acp.stakeholder-report.md
- .github/prompts/acp-audit.prompt.md
- .github/prompts/acp-feedback.prompt.md
- scripts/acp-bootstrap.sh (mkdir only)
- agent/scripts/acp.version-update.sh (mkdir only)

**(b) validator / E2E / docs — task-324 / task-325**
- scripts/acp-validate.ts
- scripts/acp-validate.test.ts
- agent/commands/acp.validate.md
- agent/commands/acp.ci.md
- agent/commands/acp.clarification-address.md
- agent/commands/acp.design-spec.md
- agent/commands/acp.install.md
- agent/scripts/acp.ci.sh
- e2e/acp.audit.test.sh
- e2e/acp.tier3-memory-knowledge.test.sh
- agent/wiki/architecture.md
- agent/wiki/coderabbit-integration.md
- agent/wiki/coderabbit-local-thorough-review.md
- agent/wiki/cross-agent-handoff.md
- agent/wiki/domain.yml

**(c) install / pattern — task-326**
- agent/patterns/local.tracked-untracked-directories.md
- agent/patterns/local.rule-verification-discipline.md
- agent/commands/acp.project-create.md
- agent/scripts/acp.install.sh
- agent/scripts/acp.package-create.sh

**(d) leftover pointer in remaining tracked files — task-327**
- tests/fixtures/coderabbit-findings-sample.json
- tests/fixtures/yaml-parser-equivalence/pre-m85-ast.golden.tsv
- tests/fixtures/yaml-perf/pref-shape.yaml
- (plus sessions.md / progress.yaml active_handoff — outside this rg scope)

Cookbook CB-0a..CB-6 uses `$HOME/acp-enhanced-private` and `$(pwd)` only — no consumer spec bodies, no vendor org IDs.

