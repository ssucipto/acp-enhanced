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
depends_on: [task-323, task-324]
design_reference: [agent/design/local.public-repo-privacy-purge.md](../../design/local.public-repo-privacy-purge.md)
audit_findings: ['F-118-04', 'F-119-06']
files_affected:
  - agent/scripts/acp.private-pack.sh
  - e2e/acp.private-pack.test.sh
  - package.yaml
  - AGENT.md
---

<!-- @acp.meta.task
topic: m87, private-pack, age, transport
description: Script to pack gitignored reports/feedback/drafts/clarifications/preferences into an encrypted archive for another machine.
milestone: M87
design: agent/design/local.public-repo-privacy-purge.md
incorporates: D8
depends_on: task-323, task-324
status: planned
updated: 2026-08-27
@acp.meta.end -->

## Objective

Ship `agent/scripts/acp.private-pack.sh` (pack + unpack) so the operator can move local ACP dirs between machines **without** GitHub. Align flags with **CB-1** (`age -p`, tar of named dirs, output path outside the repo).

## Context

323 proved backup by hand. This task makes it repeatable. Dirs: `reports`, `feedback`, `clarifications`, `drafts`, `preferences`, `agent/private/` if present. macOS+Linux; no `date +%N`; `set -euo pipefail` + `trap ERR`. Never pack into a tracked path.

## Steps

1. CLI: `acp.private-pack.sh pack --output PATH` and `unpack --input PATH --dest DIR [--dry-run]`. Refuse if `--output` is inside `.git/` or `git check-ignore` would not ignore it **and** it is under the repo.
2. Pack implementation: same tar+age shape as CB-1; passphrase via `age -p` (interactive) or `AGE_PASSPHRASE` env — never argv.
3. E2E: fixture dirs under `/tmp`, pack, unpack, `diff` counts. Do not pack real vendor dumps in CI.
4. Register script in `package.yaml` + AGENT.md scripts table (CHANGELOG at 332).
5. Cross-cut: if a command wrapper is added, update all five surfaces at 332.

## Verification

- [ ] Script traps ERR; `uname` sed/date safe
- [ ] Default output is outside the clone
- [ ] Unpack `--dry-run` does not write
- [ ] E2E does not upload the archive

## User-Observable Acceptance

Operator runs the script, copies one `.age` file, unpacks on another machine.

## Expected Output

### Files Created / Modified
- `agent/scripts/acp.private-pack.sh`
- E2E test
- package.yaml / AGENT.md

### Notes
The pack is not a substitute for filter-repo.
