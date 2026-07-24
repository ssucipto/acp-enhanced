---
id: task-270
milestone: M81
title: "acp.findings-import.sh — CodeRabbit findings → carryovers"
status: planned
priority: 5
complexity: high
estimated_hours: 6
created: 2026-07-24
started: null
completed: null
route: route-259
depends_on: [task-269]
design_reference: [agent/patterns/local.optional-external-tool.md](../../patterns/local.optional-external-tool.md)
gate: "Archived real CodeRabbit export samples required before coding import parser"
---

## Objective

Ship `agent/scripts/acp.findings-import.sh` that imports CodeRabbit PR review findings into `agent/memory/audit-carryovers.md` when `coderabbit_active`, and **no-ops silently** otherwise.

## Context

This is the core M75 deliverable from the original roadmap, scoped CodeRabbit-only. Format must be designed from **archived real findings** (2-week gate artifact), not vendor documentation alone.

## Steps

1. Collect/archive sample CodeRabbit output from consumer repo (JSON export, GitHub review comments API dump, or CLI output — whichever is available).
2. Add fixture: `tests/fixtures/coderabbit-findings-sample.json` (sanitized, no secrets).
3. Implement `acp.findings-import.sh`:
   - Source `acp.coderabbit.sh`; exit 0 immediately if `! coderabbit_active`
   - Flags: `--dry-run`, `--input <file>`, `--pr <number>` (if API path)
   - Map severity → carryover schema (`critical|high|medium|low`)
   - Dedup by `finding_id` (idempotent re-import)
   - Append `status: pending`, `planned_in: M81-import`, `source: coderabbit`
4. Register script in `package.yaml`; update `agent/wiki/domain.yml` E2E mapping.
5. Command doc stub or section in `acp.coderabbit.sh` header / wiki (no full `/acp-findings-import` command doc unless maintainer requests — script-first per ADR-13).

## Verification

- [ ] `bash agent/scripts/acp.findings-import.sh` exits 0 with no output when `enabled=false`
- [ ] `--dry-run --input tests/fixtures/coderabbit-findings-sample.json` prints mapped entries when `enabled=true` + config present
- [ ] Re-run does not duplicate existing `finding_id`
- [ ] Carryover schema validates via `acp-validate`
- [ ] macOS + Linux clean

## User-Observable Acceptance

Maintainer runs one command after a CodeRabbit-reviewed PR and sees findings in `audit-carryovers.md` ready for `/acp-audit` closure workflow — without touching Aikido.
