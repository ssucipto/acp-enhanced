---
id: task-260
milestone: M78
title: "M78 closure — validate, ship v6.28.0, close carryover F-097-01"
status: planned
priority: 5
complexity: low
estimated_hours: 2
created: 2026-07-23
started: null
completed: null
route: route-249
audit_findings: [F-097-01, F-098-07]
depends_on: [task-255, task-256, task-257, task-258, task-259]
design_reference: [ADR-21](../../memory/decisions.md)
---

> **Amended per audit-098 (F-098-07)**: version bump uses the `/acp-version-update` mechanism and must stamp all version-carrying files so the acp-validate header-sync gate (AGENTS.md == identity.yml) passes: `CLAUDE.md`, `AGENT.md`, `AGENTS.md`, `.github/copilot-instructions.md`, `README.md`, `CHANGELOG.md`, `package.yaml`, `agent/core/identity.yml`, `agent/progress.yaml`.

## Objective

Close M78 honestly: green validation + tests, ship v6.28.0, mark carryover F-097-01 fixed (foundation half), and confirm no gated work leaked in.

## Context

Follows the closure-honesty lessons from audit-094/M73 — no self-cert of unbuilt work, no false `completed`. The foundation half of F-097-01 is resolved here; the integration half stays open under ADR-19.

## Steps

1. Run `npx tsx scripts/acp-validate.ts` → exit 0.
2. Run `npx vitest run` and the E2E suite incl. `e2e/coderabbit-optionality.test.sh` → all green.
3. **Leak check**: confirm no `.coderabbit.yaml` generator, `acp.findings-import.sh`, or recurring-task rewire was added (grep) — ADR-21 guardrail 3.
4. Bump version to 6.28.0 via `/acp-version-update` across all 9 version-stamped files (see amendment note); add CHANGELOG entry citing audit-097, audit-098, ADR-21. Confirm acp-validate header-sync gate (AGENTS.md == identity.yml) passes.
5. In `agent/memory/audit-carryovers.md`, set F-097-01 `status: fixed`, `fix_applied_date: <today>`, and a note that the integration/PR-check half remains gated under ADR-19 (do NOT delete the entry until re-verified).
6. Check the M78 verification gates in the milestone doc with evidence; update progress.yaml M78 → completed.
7. Run the post-milestone sweep if applicable.

## Verification

- [ ] `acp-validate` exit 0; vitest + E2E green
- [ ] Leak-check grep confirms zero gated artifacts present
- [ ] v6.28.0 stamped; CHANGELOG entry present
- [ ] F-097-01 `status: fixed` with gated-remainder note; entry retained
- [ ] M78 milestone gates checked with evidence; progress.yaml M78 = completed
- [ ] ADR-19 remains unmodified (no M74–M77 entries created)

## User-Observable Acceptance

v6.28.0 ships the optionality foundation; a fresh install behaves identically to v6.27.2 unless the user opts in, and the carryover ledger honestly reflects foundation-done / integration-gated.
