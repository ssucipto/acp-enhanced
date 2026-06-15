---
id: route-145
title: "M56-004: git-provenance.sh + dependency-diff.sh"
task_type: bash-script-create
milestone: M56
complexity: medium
executor: copilot
context_required: [milestones/milestone-56-acp-integrity-command.md, route-142, audit-054]
files_affected: [agent/scripts/acp.git-provenance.sh, agent/scripts/acp.dependency-diff.sh]
tokens_est: 9000
created: 2026-06-07
completed: 2026-06-08
---

# Route 145: Git Provenance + Dependency Diff Scripts

## Objective

Build two P0 scripts missed by audit-053, identified by audit-054: git commit author verification and shadow dependency detection.

## Expected Output

### Files Created
- `agent/scripts/acp.git-provenance.sh`
- `agent/scripts/acp.dependency-diff.sh`

## Script Specifications

### acp.git-provenance.sh
- **Purpose**: Verify commit provenance — authors match team, critical files have task IDs
- **Input**: Git repository (default: cwd)
- **Implementation**:
  - `git log --format="%H %ae %s" -n 50` → cross-ref `agent/core/identity.yml` `team_members`
  - `git diff --stat HEAD~10` → flag commits >200 lines to auth/crypto/data-access without task ID
  - `git log --follow --format="%H %s" -- <critical-file>` → check for linked task IDs
- **Output**: `<commit-hash> <author> <finding>` per anomaly
- **Rules covered**: IG-33, IG-34, IG-35, IG-37

### acp.dependency-diff.sh
- **Purpose**: Detect shadow dependencies (imported but not in lockfile) and supply chain risks
- **Input**: Project root with `package.json` + `package-lock.json`
- **Implementation**:
  - Extract all `import`/`require` statements → compare against `package-lock.json` `packages` keys
  - Check `postinstall`/`preinstall` scripts for shell execution
  - Calculate lockfile staleness (last modified vs most recent source change)
  - Levenshtein distance check against top-1000 npm packages (embedded list)
- **Output**: `<package-name> <issue-type> [UNLISTED|STALE|TYPO|POSTINSTALL]`
- **Rules covered**: IG-27, IG-28, IG-29, IG-30, IG-31, IG-32

## Dependencies

- Requires `route-142` completion (network_whitelist.yml + identity.yml team_members field)
- Requires `jq` for JSON parsing (check availability, warn if missing)
- Requires `git` (standard in dev environment)

## Verification

- [ ] Both scripts have `set -euo pipefail` and `trap ERR`
- [ ] Both scripts pass `shellcheck --severity=error`
- [ ] `acp.git-provenance.sh` detects commit author not in team_members
- [ ] `acp.git-provenance.sh` flags >200 line commit to `src/services/auth.ts` without task ID
- [ ] `acp.dependency-diff.sh` detects `import` of package not in lockfile
- [ ] `acp.dependency-diff.sh` flags `postinstall` script containing `curl` or `wget`
- [ ] Both tested on macOS

## User-Observable Acceptance

- Running `acp.git-provenance.sh` on clean repo exits 0
- Running `acp.dependency-diff.sh` on project with shadow dependency outputs finding
