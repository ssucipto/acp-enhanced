---
id: task-152
milestone: M27
title: Fix run-e2e-tests.sh hang on network-dependent tests
status: not_started
priority: 5
complexity: medium
estimated_hours: 1.5
created: 2026-05-04
started:
completed:
---

<!-- @acp.meta.task
topic: fix, run-e2e-testssh, hang, on, network-dependent, tests
description: Fix run-e2e-tests.sh hang on network-dependent tests
milestone: M27
status: draft
updated: 2026-05-04
@acp.meta.end -->


## Objective

Fix `run-e2e-tests.sh` hanging indefinitely when running 8 network-dependent tests. After the fix, the runner must complete in under 60 seconds on a machine without internet or with slow network.

## Context

The test runner uses:
```bash
output=$(bash "$test_file" 2>&1)
```
This blocks indefinitely when a test calls `git clone` or `git fetch` inside the subshell (no TTY, no timeout). 8 tests exhibit this behavior:

- `acp.experimental-features.test.sh`
- `acp.index.test.sh`
- `acp.package-install-list.test.sh`
- `acp.package-search.test.sh`
- `acp.package-update.test.sh`
- `acp.projects-sync.test.sh`
- `acp.script-command-binding.test.sh`
- `acp.template-files.test.sh`

**macOS constraint**: No `timeout` command (GNU coreutils). Must use background job + kill-guard pattern.

## Implementation

### Fix 1: Add per-test timeout via background job + kill-guard (macOS-compatible)

Replace the blocking capture:
```bash
output=$(bash "$file" 2>&1)
exit_code=$?
```

With a macOS-safe timeout wrapper:
```bash
TIMEOUT_SECS=30
tmpout=$(mktemp)
bash "$file" > "$tmpout" 2>&1 &
test_pid=$!
( sleep "$TIMEOUT_SECS" && kill "$test_pid" 2>/dev/null ) &
guard_pid=$!
wait "$test_pid" 2>/dev/null
exit_code=$?
kill "$guard_pid" 2>/dev/null
wait "$guard_pid" 2>/dev/null
output=$(cat "$tmpout")
rm -f "$tmpout"
if [[ $exit_code -eq 143 || $exit_code -eq 137 ]]; then
  exit_code=124  # normalize to timeout exit code
fi
```

### Fix 2: Add `--skip-network` flag

Add CLI flag support so CI can skip network tests:
```bash
SKIP_NETWORK=false
for arg in "$@"; do
  [[ "$arg" == "--skip-network" ]] && SKIP_NETWORK=true
done
```

Mark network tests with a header comment `# ACP_NETWORK_TEST=true` and skip if `$SKIP_NETWORK` is true.

Add the marker to all 8 affected test files.

## Expected Output

### Files Modified
- `run-e2e-tests.sh` — timeout wrapper + `--skip-network` flag
- `e2e/acp.experimental-features.test.sh` — add `# ACP_NETWORK_TEST=true` header
- `e2e/acp.index.test.sh` — add `# ACP_NETWORK_TEST=true` header
- `e2e/acp.package-install-list.test.sh` — add `# ACP_NETWORK_TEST=true` header
- `e2e/acp.package-search.test.sh` — add `# ACP_NETWORK_TEST=true` header
- `e2e/acp.package-update.test.sh` — add `# ACP_NETWORK_TEST=true` header
- `e2e/acp.projects-sync.test.sh` — add `# ACP_NETWORK_TEST=true` header
- `e2e/acp.script-command-binding.test.sh` — add `# ACP_NETWORK_TEST=true` header
- `e2e/acp.template-files.test.sh` — add `# ACP_NETWORK_TEST=true` header

## Verification
- [ ] `bash run-e2e-tests.sh --skip-network` completes in < 60 seconds
- [ ] `bash run-e2e-tests.sh --skip-network 2>&1 | grep -E "Tests Run|Pass Rate"` shows all non-network tests passing
- [ ] No test hangs indefinitely (kill guard fires within 30s)

## User-Observable Acceptance
`bash run-e2e-tests.sh --skip-network` completes and prints a summary in under 60 seconds.
