---
id: task-205
milestone: M68
title: install.sh tier preserve + manifest merge (route-200)
status: planned
priority: 5
complexity: medium
estimated_hours: 4
created: 2026-07-15
started:
completed:
route: route-200
---

## Objective

Safe reinstall: preserve Tier B, merge manifest, fix Windows xargs.

## Steps

1. Replace `cp agent/core/*.yml` with tier-aware copy (reuse common.sh helpers) — F-080-07
2. Wiki/routing/skills: same tier rules as version-update; preserve `local.*` skills
3. Replace manifest `cat >` block with `acp_merge_manifest_acp_core` or create-if-absent on first install — F-080-06, SC-080-04
4. Replace `xargs -n1 basename` loops (L470–472) with while-read basename loop — F-080-11
5. Extend install overwrite/preserve banner to match design tiers

## Verification

- [ ] Reinstall with 2 packages in manifest — both remain (F-080-06)
- [ ] Customized domain.yml preserved (F-080-03 parity)
- [ ] Windows Git Bash manifest generation (CI or local) — F-080-11

## User-Observable Acceptance

Running `acp.install.sh` twice does not reset `identity.yml` or wipe non-acp-core packages from manifest.yaml.
