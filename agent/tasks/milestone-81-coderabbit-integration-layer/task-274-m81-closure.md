---
id: task-274
milestone: M81
title: "M81 closure — ship v6.32.0"
status: completed
priority: 5
complexity: low
estimated_hours: 2
created: 2026-07-24
started: 2026-08-14
completed: 2026-08-14
route: route-263
depends_on: [task-269, task-270, task-271, task-272, task-273]
design_reference: [milestone-81](../../milestones/milestone-81-coderabbit-integration-layer.md)
audit_findings: [F-101-01]
gate: "tasks 269-273 complete; assertion-level suite green"
files_affected:
  - agent/core/identity.yml
  - package.yaml
  - AGENTS.md
  - CLAUDE.md
  - .github/copilot-instructions.md
  - AGENT.md
  - README.md
  - CHANGELOG.md
  - agent/progress.yaml
  - agent/integrity-manifest.yaml
  - agent/memory/audit-carryovers.md
  - agent/milestones/milestone-81-coderabbit-integration-layer.md
---

## Objective

Close M81: verification, **v6.32.0**, CHANGELOG, carryover settlement (F-101-01..08 → fixed), tag.

## Steps

1. Gates:
   - `npx tsx scripts/acp-validate.ts` exit 0
   - `npx vitest run` exit 0
   - `bash run-e2e-tests.sh --skip-network` — document **assertion-level** pass/fail counts (audit-099)
   - Both coderabbit E2E suites
2. Bump to 6.32.0 (historical 6.29.0 taken by M83) on **full** set (F-098-07): identity.yml, package.yaml, AGENTS.md, CLAUDE.md, copilot-instructions (via AGENTS sync), AGENT.md, README badge, CHANGELOG, progress.yaml `project.version`
3. Regenerate `agent/integrity-manifest.yaml`
4. Mark F-101-01..08 `status: fixed`, `fix_applied_date`, `verified_in_audit: audit-101` or m81-closure
5. Mark M81 + tasks completed; refresh next_steps (Aikido still deferred)
6. Tag `v6.32.0`; `/acp-commit`

## Verification

- [ ] Milestone verification checklist complete
- [ ] Optionality matrix A–D in E2E log
- [ ] ADR-22 cited in CHANGELOG
- [ ] All F-101 carryovers fixed

## User-Observable Acceptance

v6.32.0 ships optional CodeRabbit integration; default install unchanged.
