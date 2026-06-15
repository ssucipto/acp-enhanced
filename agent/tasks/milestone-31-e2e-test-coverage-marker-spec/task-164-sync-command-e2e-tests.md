---
id: task-164
milestone: M31
title: Write e2e/acp.sync.test.sh (sync command + meta-scan integration)
status: completed
priority: 3
complexity: low
estimated_hours: 2
created: 2026-05-05
started: 2026-05-05T00:00:00Z
completed: 2026-05-05
---

## Objective

Create `e2e/acp.sync.test.sh` — a structural smoke test verifying `acp.sync.md` has all required Steps 1.3–1.6 (marker-stream integration), references `acp.meta-scan.sh` correctly, and the sync command doc format is intact.

## Context

`agent/commands/acp.sync.md` (572 lines) is one of the most complex command docs. It integrates with `acp.meta-scan.sh` in Steps 1.3–1.6 to build a marker-stream inventory. This integration is critical for spec↔task↔code traceability. A structural test catches accidental deletion or corruption of these steps.

This is a **format/integration-path test** — verifying the command doc describes the correct integration, not that an LLM executes it correctly.

## Implementation

Test cases:
1. `agent/commands/acp.sync.md` exists
2. File references `acp.meta-scan.sh` (integration point present)
3. File contains Step 1.3 or "meta-scan" in the sync steps
4. File contains `covers:` (spec-task traceability field referenced)
5. File contains `incorporates:` (design-task traceability field referenced)
6. File is ≥100 lines (not accidentally truncated)
7. `agent/scripts/acp.meta-scan.sh` exists (the script it references)
8. `acp.meta-scan.sh` is executable (or at least present)

```bash
#!/usr/bin/env bash
# e2e/acp.sync.test.sh — smoke test for @acp.sync command doc and meta-scan integration

<!-- @acp.meta.task
topic: e2eacpsynctestsh, smoke, test, for, acpsync, command, doc, and, meta-scan, integration
description: Write e2e/acp.sync.test.sh (sync command + meta-scan integration)
milestone: M31
status: completed
updated: 2026-05-05
@acp.meta.end -->



ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SYNC_CMD="$ROOT/agent/commands/acp.sync.md"
META_SCAN="$ROOT/agent/scripts/acp.meta-scan.sh"

pass() { echo "PASS: $1"; }
fail() { echo "FAIL: $1"; FAILURES=$((FAILURES+1)); }
FAILURES=0

[ -f "$SYNC_CMD" ] && pass "acp.sync.md exists" || fail "acp.sync.md missing"
grep -q "meta-scan" "$SYNC_CMD" && pass "acp.sync.md references meta-scan" || fail "meta-scan not referenced in acp.sync.md"
grep -q "covers:" "$SYNC_CMD" && pass "covers: field referenced in sync" || fail "covers: not referenced in sync"
grep -q "incorporates:" "$SYNC_CMD" && pass "incorporates: field referenced in sync" || fail "incorporates: not referenced in sync"
LINE_COUNT=$(wc -l < "$SYNC_CMD")
[ "$LINE_COUNT" -ge 100 ] && pass "acp.sync.md is ≥100 lines ($LINE_COUNT)" || fail "acp.sync.md suspiciously short ($LINE_COUNT lines)"
[ -f "$META_SCAN" ] && pass "acp.meta-scan.sh exists" || fail "acp.meta-scan.sh missing"
grep -q "@acp.meta" "$META_SCAN" && pass "meta-scan.sh references @acp.meta sentinel" || fail "meta-scan.sh missing @acp.meta sentinel reference"

[ "$FAILURES" -eq 0 ] && echo "All sync tests passed" || { echo "$FAILURES test(s) failed"; exit 1; }
```

## Expected Output

### Files Created
- `e2e/acp.sync.test.sh`

## Verification
- [ ] `bash e2e/acp.sync.test.sh` passes all 7 assertions
- [ ] Test completes in <1 second

## User-Observable Acceptance
`bash run-e2e-tests.sh` shows `acp.sync.test.sh` PASS. Critical meta-scan integration points in sync are structurally verified.
