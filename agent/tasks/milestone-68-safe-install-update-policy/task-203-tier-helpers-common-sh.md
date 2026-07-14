---
id: task-203
milestone: M68
title: Tier helpers in acp.common.sh (route-198)
status: planned
priority: 5
complexity: medium
estimated_hours: 3
created: 2026-07-15
started:
completed:
route: route-198
audit_findings: [F-080-01, P-081-07]
---

## Objective

Implement tier-aware install/update helpers per `agent/design/safe-install-update-policy.md`.

## Context

Foundation for routes 199–201. **Do not** use `is_file_modified()` for acp-core Tier B — manifest lacks per-file checksums (P-081-07). Use upstream SHA compare via `$TEMP_DIR`.

## Steps

1. Add `acp_sha256_file`, `acp_file_differs_from_upstream`, `acp_identity_is_customized`
2. Add `acp_copy_framework_file rel tier [--force]` with `⊘ preserved` / `↻ updated` logging
3. Add `acp_merge_manifest_acp_core new_version` — awk merge acp-core block only (replaces sed — P-081-08)
4. Document `export TEMP_DIR` requirement for callers (P-081-08)
5. Optional: `agent/schemas/install-tier-registry.yaml` listing Tier A/B/C paths
6. Source helpers from a minimal unit test or shell self-check in E2E setup

## Verification

- [ ] Helpers sourced by version-update without error
- [ ] identity customized detection catches non-placeholder project name
- [ ] Manifest merge preserves non-acp-core packages in fixture
- [ ] Tier B uses upstream SHA compare — NOT `is_file_modified()` (P-081-07)

## User-Observable Acceptance

Running a dry helper test shows `preserved` vs `updated` for Tier B files when local differs from upstream fixture.

## Anti-shortcuts

- SC-080-03: single-path `acp_copy_framework_file()` API — no blind globs in callers
