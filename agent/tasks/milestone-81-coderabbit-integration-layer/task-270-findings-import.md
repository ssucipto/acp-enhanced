---
id: task-270
milestone: M81
title: "acp.findings-import.sh — CodeRabbit findings → carryovers"
status: completed
priority: 5
complexity: high
estimated_hours: 6
created: 2026-07-24
started: 2026-08-14
completed: 2026-08-14
route: route-259
depends_on: [task-269]
design_reference: [agent/patterns/local.optional-external-tool.md](../../patterns/local.optional-external-tool.md)
audit_findings: [F-101-03, F-101-05]
gate: "tests/fixtures/coderabbit-findings-sample.json exists (sanitized real export) AND ADR-22 accepted"
files_affected:
  - agent/scripts/acp.findings-import.sh
  - tests/fixtures/coderabbit-findings-sample.json
  - package.yaml
  - agent/wiki/domain.yml
  - agent/wiki/coderabbit-integration.md
  - agent/integrity-manifest.yaml
---

## Objective

Ship `agent/scripts/acp.findings-import.sh` that imports CodeRabbit findings into `agent/memory/audit-carryovers.md` when `coderabbit_active`, and **no-ops silently** otherwise.

## Context

audit-101 F-101-05 / F-098-04: no speculative `--pr`/API until verified. F-101-03: match **live** carryover shape (validator maps schema `description` → field `finding`).

## Gate artifact (required before coding parser)

| Artifact | Path | Rules |
|----------|------|-------|
| Sanitized findings sample | `tests/fixtures/coderabbit-findings-sample.json` | From real consumer export; no secrets/PII; committed |

Create `tests/fixtures/` directory if absent.

## Steps

1. Confirm fixture present (or create from maintainer-supplied sanitized export).
2. Implement `acp.findings-import.sh`:
   - Source `acp.coderabbit.sh`; exit 0 immediately if `! coderabbit_active` (silent when disabled; hint path via existing helper when enabled+absent)
   - **v1 flags only:** `--dry-run`, `--input <file>`
   - **Do NOT implement `--pr` or network fetch in M81** (F-101-05) — document as deferred
   - Map severities to **lowercase** live values: `critical|high|medium|low`
   - Append entries matching live ledger shape:
     ```yaml
     - audit_id: coderabbit-import
       finding_id: CR-<stable-hash-or-vendor-id>
       severity: medium
       file: <path-or-e2e/>
       finding: "<one-line> (imported from CodeRabbit)"
       description: "<optional fuller text>"
       fix_target: "<suggested or TBD>"
       status: pending
       planned_in: M81
       fix_applied_date: null
       verified_in_audit: null
       escalated_to: null
     ```
   - **Do not** invent `source:` or `planned_in: M81-import` (F-101-03)
   - Dedup by `finding_id` (idempotent)
3. Register in `package.yaml`; update `agent/wiki/domain.yml`; wiki usage: `bash agent/scripts/acp.findings-import.sh --input …`
4. Regenerate integrity-manifest when script lands (or leave to task-274 if same PR)

## Verification

- [ ] Exit 0, no carryover writes when `enabled=false`
- [ ] `--dry-run --input tests/fixtures/coderabbit-findings-sample.json` works when active
- [ ] Re-run does not duplicate `finding_id`
- [ ] `npx tsx scripts/acp-validate.ts` accepts appended entries
- [ ] No `--pr` flag in shipped script help
- [ ] macOS + Linux clean

## User-Observable Acceptance

`bash agent/scripts/acp.findings-import.sh --input tests/fixtures/coderabbit-findings-sample.json` populates carryovers for opted-in repos; absent CodeRabbit → silent no-op.
