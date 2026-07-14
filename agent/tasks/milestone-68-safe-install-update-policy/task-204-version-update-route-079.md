---
id: task-204
milestone: M68
title: version-update.sh route-079 implementation (route-199)
status: completed
priority: 5
complexity: high
estimated_hours: 7
created: 2026-07-15
started:
completed: 2026-07-15
route: route-199
audit_findings: [F-080-01, F-080-02, F-080-03, F-080-04, F-080-09, P-081-01, P-081-02, P-081-08]
---

## Objective

Ship route-079 in shell: flags, tier copy, no blind core/wiki/routing overwrites. **Real implementation** — not doc-only (SC-080-01).

## Steps

1. Parse `--diff`, `--preserve-project-core`, `--force`, `--yes`
2. Entry check: `AGENTS.md` or `AGENT.md` present (F-080-09)
3. `export TEMP_DIR` before sourcing tier helpers (P-081-08)
4. Replace L192–201 blind `cp` with `acp_copy_framework_file` per tier
5. Tier C commands: copy **only** `acp.*.md` and `git.*.md` — skip other namespaces (P-081-01)
6. Tier C skills: skip `local.*.md` — match install.sh L190 (P-081-02)
7. Tier C: scripts, schemas, templates, triple-sync AGENTS → CLAUDE + copilot
8. Tier D: `acp_merge_manifest_acp_core` instead of sed-only manifest (P-081-08, F-004)
9. `--diff` early exit with action report
10. `agent/.gitignore` create-if-absent only

## Verification

- [ ] route-079 checklist all pass in shell
- [ ] `bash -n agent/scripts/acp.version-update.sh`
- [ ] No `cp "$TEMP_DIR/agent/core/"*.yml` glob remains
- [ ] Third-party command file survives update (P-081-01)
- [ ] `local.*` skill survives update (P-081-02)
- [ ] Customized identity.yml survives default run

## User-Observable Acceptance

`/acp-version-update` on a project with customized `identity.yml` completes without changing that file; output lists preserved paths.

## Anti-shortcuts

- SC-080-01: do NOT stamp route-079 complete here — wait for route-202 E2E
- SC-080-03: no blind `cp` globs
