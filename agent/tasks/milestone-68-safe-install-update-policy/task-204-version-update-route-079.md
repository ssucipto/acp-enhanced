---
id: task-204
milestone: M68
title: version-update.sh route-079 implementation (route-199)
status: planned
priority: 5
complexity: high
estimated_hours: 6
created: 2026-07-15
started:
completed:
route: route-199
---

## Objective

Ship route-079 in shell: flags, tier copy, no blind core/wiki/routing overwrites.

## Steps

1. Parse `--diff`, `--preserve-project-core`, `--force`, `--yes`
2. Entry check: `AGENTS.md` or `AGENT.md` present
3. Replace L192–201 blind `cp` with `acp_copy_framework_file` per tier
4. Tier C: commands, scripts, schemas, skills (skip local.*), templates, triple-sync AGENTS
5. Tier D: `acp_merge_manifest_acp_core` instead of sed-only manifest hack
6. `--diff` early exit with action report
7. Remove or guard `cat > agent/.gitignore` to create-if-absent only

## Verification

- [ ] route-079 checklist all pass
- [ ] `bash -n agent/scripts/acp.version-update.sh`
- [ ] Customized identity.yml survives default run (manual or E2E)

## User-Observable Acceptance

`/acp-version-update` on a project with customized `identity.yml` completes without changing that file; output lists preserved paths.
