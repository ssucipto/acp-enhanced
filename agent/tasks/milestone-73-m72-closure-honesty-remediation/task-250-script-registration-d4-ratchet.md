---
id: task-250
milestone: M73
title: "Script registration completeness + D4 WARN→ERROR ratchet"
status: completed
priority: 4
complexity: medium
estimated_hours: 2
created: 2026-07-15
started: null
completed: null
route: route-239
audit_findings: [F-094-06, F-094-07]
depends_on: [task-248]
design_reference: [Design: M73 Closure Honesty](../design/m73-m72-closure-honesty-remediation.md)
---

## Objective

Register 14 on-disk `agent/scripts/*.sh` missing from `package.yaml` and ratchet D4 from WARN to ERROR so unregistered scripts fail CI.

## Context

audit-094 found 14 scripts on disk not in `package.yaml` contents.scripts (F-094-07). M72 D4 landed as WARN-only; design promised ERROR ratchet next release (F-094-06).

**Scripts to register** (verify live disk list — audit-094 cited):
`acp.backfill-markers.sh`, `acp.dependency-diff.sh`, `acp.driver-yaml.sh`, `acp.entropy-scan.sh`, `acp.git-provenance.sh`, `acp.integrity-output.sh`, `acp.manifest-hash.sh`, `acp.memory-scan.sh`, `acp.network-whitelist-validate.sh`, `acp.pattern-scan.sh`, `acp.review-scan.sh`, `acp.taint-scan.sh`, `acp.unicode-scan.sh` (+ any others found by diff).

## Steps

1. Generate authoritative diff: `comm -23 <(ls agent/scripts/*.sh | xargs -n1 basename | sort) <(yq '.contents.scripts[].name' package.yaml | sort)` (or equivalent)
2. Add each missing script to `package.yaml` with `name`, `description`, `type` matching existing entries
3. Regenerate `agent/integrity-manifest.yaml` via `bash agent/scripts/acp.manifest-hash.sh`
4. Change `acp-validate.ts` unregistered-script check: WARN → ERROR
5. Add vitest: unregistered fixture script on disk → validator exit 1

## Verification

- [ ] `comm` diff empty — every `agent/scripts/*.sh` in package.yaml
- [ ] `bash agent/scripts/acp.manifest-hash.sh --verify` → clean
- [ ] `npx tsx scripts/acp-validate.ts` → exit 0
- [ ] Vitest negative case: temp unregistered script → ERROR
- [ ] `npx vitest run` → all pass

## User-Observable Acceptance

Adding a new script without registering it breaks `acp-validate` in CI — drift cannot hide.
