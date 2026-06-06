---
id: route-116
title: "Add E2E bootstrap smoke test — fresh install in temp directory"
task_type: e2e-test-write
milestone: M51
complexity: medium
executor: copilot
context_required:
  - scripts/acp-bootstrap.sh
  - agent/patterns/local.e2e-testing.md
  - e2e/acp.install.test.sh
files_affected:
  - e2e/acp.bootstrap.test.sh
tokens_est: 400
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-06
completed:
override_reason:
---

# Route 116: E2E Bootstrap Smoke Test

## Objective

Create `e2e/acp.bootstrap.test.sh` that runs the bootstrap in a temp directory and verifies the install produces the expected file counts. This test would have caught BUG-045-01 before it reached users.

## Context

Per audit-045 recommendation #4: "Create a test that runs bootstrap in a temp directory and verifies agent/commands/ has 40+ files and agent/scripts/ has 20+ files after bootstrap completes."

## Changes

### Create `e2e/acp.bootstrap.test.sh`

Test assertions:

1. **Bootstrap runs without error**: `bash scripts/acp-bootstrap.sh` in temp dir exits 0
2. **AGENTS.md created**: File exists with expected content
3. **agent/core/identity.yml created**: File exists
4. **agent/commands/ has 40+ files**: `find agent/commands -name "acp.*.md" | wc -l` ≥ 40
5. **agent/scripts/ has 20+ files**: `find agent/scripts -name "*.sh" | wc -l` ≥ 20
6. **agent/progress.yaml created**: File exists
7. **agent/routing/taxonomy.yml created**: File exists
8. **agent/memory/sessions.md created**: File exists
9. **No leftover temp files**: Cleanup works after test

### Test structure

- Create temp directory with `mktemp -d`
- Run bootstrap inside temp dir: `cd "$tmpdir" && bash "$PROJECT_ROOT/scripts/acp-bootstrap.sh" --yes`
- Verify file counts
- Clean up temp dir on exit (trap)
- Follow `local.e2e-testing.md` conventions

## Verification

- [ ] Test file exists at `e2e/acp.bootstrap.test.sh`
- [ ] `bash e2e/acp.bootstrap.test.sh` passes all assertions
- [ ] Test cleans up temp directory on success and failure
- [ ] Uses `set -euo pipefail` with ERR trap
- [ ] macOS BSD sed compatible
