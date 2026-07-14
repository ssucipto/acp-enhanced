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
---

## Objective

Implement tier-aware install/update helpers per `agent/design/safe-install-update-policy.md`.

## Steps

1. Add `acp_sha256_file`, `acp_file_differs_from_upstream`, `acp_identity_is_customized`
2. Add `acp_copy_framework_file rel tier [--force]` with `⊘ preserved` / `↻ updated` logging
3. Add `acp_merge_manifest_acp_core new_version` — awk merge acp-core block only
4. Optional: `agent/schemas/install-tier-registry.yaml` listing Tier A/B/C paths
5. Source helpers from a minimal unit test or shell self-check in E2E setup

## Verification

- [ ] Helpers sourced by version-update without error
- [ ] identity customized detection catches `YOUR_PROJECT_NAME`
- [ ] Manifest merge preserves non-acp-core packages in fixture

## User-Observable Acceptance

Running a dry helper test shows `preserved` vs `updated` for Tier B files when local differs from upstream fixture.
