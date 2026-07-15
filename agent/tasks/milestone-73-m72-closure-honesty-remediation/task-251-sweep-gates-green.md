---
id: task-251
milestone: M73
title: "Post-milestone-sweep 6/6 — tsc and gate fixes"
status: completed
priority: 4
complexity: medium
estimated_hours: 2
created: 2026-07-15
started: null
completed: null
route: route-240
audit_findings: [F-094-04]
depends_on: []
design_reference: [Design: M73 Closure Honesty](../design/m73-m72-closure-honesty-remediation.md)
---

## Objective

Fix failing post-milestone-sweep gates (currently 2/6) so task-247's closure requirement is honestly met before M73 ships.

## Context

Live sweep failures per audit-094:
- **tsc**: `import.meta` CJS errors in `scripts/acp-validate.ts`
- **token budget**: may be stale threshold or real overflow
- **gitattributes**: sweep check failing

task-247 required sweep 6/6 but no evidence it passed at closure.

## Steps

1. Run `bash agent/scripts/acp.post-milestone-sweep.sh` — capture which 4 gates fail
2. **tsc fix**: align `scripts/tsconfig.json` — `module: NodeNext`, `moduleResolution: NodeNext`, or exclude validate from CJS sweep with documented exception in sweep script
3. **token budget**: verify against current `agent/core/constraints.yml`; adjust sweep threshold OR fix real overflow
4. **gitattributes**: fix missing/incorrect `.gitattributes` entries per sweep expectation
5. Re-run sweep until 6/6; paste output in commit message or task completion note
6. Add vitest or e2e hook if sweep gates are regressable

## Verification

- [ ] `bash agent/scripts/acp.post-milestone-sweep.sh` → **6/6 PASS** (full output saved)
- [ ] `npx tsc -p scripts/` → exit 0 (if in sweep)
- [ ] `npx vitest run` → all pass
- [ ] No sweep gate disabled without design rationale in sweep script comment

## User-Observable Acceptance

Post-milestone-sweep is a reliable release gate again — M73 cannot close with 2/6.
