---
id: task-274
milestone: M81
title: "M81 closure — ship v6.29.0"
status: planned
priority: 5
complexity: low
estimated_hours: 2
created: 2026-07-24
started: null
completed: null
route: route-263
depends_on: [task-269, task-270, task-271, task-272, task-273]
design_reference: [milestone-81](../../milestones/milestone-81-coderabbit-integration-layer.md)
---

## Objective

Close M81: full verification, version bump to **v6.29.0**, CHANGELOG, progress.yaml, milestone doc status, git tag.

## Steps

1. Run gates:
   - `npx tsx scripts/acp-validate.ts` exit 0
   - `npx vitest run` exit 0
   - `bash run-e2e-tests.sh --skip-network` — full suite green (assertion-level count documented)
   - `bash e2e/coderabbit-optionality.test.sh` + `bash e2e/coderabbit-integration.test.sh`
2. Bump version 6.28.2 → 6.29.0 (identity.yml, package.yaml, AGENTS.md, CHANGELOG, progress.yaml `project.version`)
3. Regenerate `agent/integrity-manifest.yaml` if scripts changed
4. Mark M81 + tasks 269–274 `completed` in progress.yaml and milestone doc
5. Update `next_steps`: M81 complete; note Aikido still deferred
6. Tag `v6.29.0`; `/acp-commit` session entry

## Verification

- [ ] All M81 verification gates in milestone doc checked
- [ ] Optionality matrix A–D verified in E2E output log
- [ ] ADR-22 referenced in CHANGELOG
- [ ] `current_milestone` updated appropriately post-closure

## User-Observable Acceptance

`v6.29.0` ships CodeRabbit integration for opted-in repos; default install unchanged.
