---
id: task-329
milestone: M87
title: "acp.private-pack.sh for machine transport"
status: planned
priority: 4
complexity: medium
estimated_hours: 3
created: 2026-08-27
started: null
completed: null
phase: 4
depends_on: [task-323]
design_reference: [agent/design/local.public-repo-privacy-purge.md](../../design/local.public-repo-privacy-purge.md)
audit_findings: ['F-118-04']
files_affected:
  - agent/scripts/acp.private-pack.sh
  - package.yaml
  - AGENT.md
---

<!-- @acp.meta.task
topic: m87, private-pack, age, transport
description: Script to pack gitignored reports/feedback/drafts/clarifications/preferences into an encrypted archive for another machine.
milestone: M87
design: agent/design/local.public-repo-privacy-purge.md
incorporates: D8
depends_on: task-323
status: planned
updated: 2026-08-27
@acp.meta.end -->

## Objective

Ship `agent/scripts/acp.private-pack.sh` (pack + unpack) so the operator can move local ACP dirs between machines **without** GitHub.

## Context

323 proved the backup idea. This task makes it repeatable: pack `reports`, `feedback`, `clarifications`, `drafts`, `preferences`, and `agent/private/` if present. Never write the archive inside a tracked path. macOS+Linux; no `date +%N`; trap errors (no bare `set -e`).

## Steps

1. Implement pack: tar the gitignored dirs, encrypt (`age` preferred; document gpg fallback), write to a caller-supplied path **outside** the repo by default.
2. Implement unpack: decrypt + extract into `agent/` with a dry-run flag.
3. Refuse to pack if output path is inside `.git/` or would be `git add`-able.
4. E2E: fixture dirs, pack, unpack to temp, compare counts. Do not pack real vendor dumps in CI.
5. Register in `package.yaml`, AGENT.md scripts table, CHANGELOG at **ship** (task-332), not in this task unless shipping early.
6. Cross-cut: if adding a command wrapper, update AGENT/README/package together at 332.

## Verification

- [ ] Script traps ERR; macOS-safe
- [ ] Pack file is gitignored / outside repo
- [ ] Unpack restores fixture tree
- [ ] E2E does not upload the archive

## User-Observable Acceptance

Operator runs the script, copies one encrypted file to another machine, unpacks, and `/acp-audit` history is back locally.

## Expected Output

### Files Created / Modified
- `agent/scripts/acp.private-pack.sh`
- E2E test
- package.yaml / AGENT.md (or defer listing to 332)

### Notes
The pack is not a substitute for filter-repo.
