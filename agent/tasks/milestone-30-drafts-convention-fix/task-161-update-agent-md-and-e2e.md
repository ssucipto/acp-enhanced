---
id: task-161
milestone: M30
title: Update AGENT.md directory tree and add acp.drafts.test.sh
status: completed
priority: 4
complexity: low
estimated_hours: 1
created: 2026-05-05
started: 2026-05-05T00:00:00Z
completed: 2026-05-05
---

## Objective

Update AGENT.md's `agent/` directory tree section to include `agent/drafts/` with a note ("local-only planning drafts, gitignored"), and create `e2e/acp.drafts.test.sh` to verify the directory and template exist after install.

## Context

AGENT.md's directory tree is a critical reference for both human developers and agents loading context at session start. It currently doesn't show `agent/drafts/`. Adding it makes the convention discoverable.

The E2E test (`acp.drafts.test.sh`) is a fast structural check — it doesn't test the full `/acp-plan` workflow (that's out of scope), just confirms the installation invariants are met.

## Implementation

### Part 1: AGENT.md Update

Open `AGENT.md`. Find the `agent/` directory tree section (look for the code block showing `agent/commands/`, `agent/memory/`, etc.).

Add `drafts/` to the tree:
```
agent/
├── commands/       # ACP command directive docs
├── drafts/         # local-only planning drafts (gitignored content; template tracked)
├── memory/         # sessions, lessons, decisions
...
```

### Part 2: E2E Test

Create `e2e/acp.drafts.test.sh`:

```bash
#!/usr/bin/env bash
# e2e/acp.drafts.test.sh — verify agent/drafts/ convention

<!-- @acp.meta.task
topic: e2eacpdraftstestsh, verify, agentdrafts, convention
description: Update AGENT.md directory tree and add acp.drafts.test.sh
milestone: M30
status: completed
updated: 2026-05-05
@acp.meta.end -->



source "$(dirname "$0")/../tests/common.sh" 2>/dev/null || {
  pass() { echo "PASS: $1"; }
  fail() { echo "FAIL: $1"; exit 1; }
}

DRAFTS_DIR="agent/drafts"

# Test 1: directory exists
[ -d "$DRAFTS_DIR" ] && pass "agent/drafts/ directory exists" || fail "agent/drafts/ directory missing"

# Test 2: .gitkeep present
[ -f "$DRAFTS_DIR/.gitkeep" ] && pass ".gitkeep present" || fail ".gitkeep missing in agent/drafts/"

# Test 3: draft.template.md present
[ -f "$DRAFTS_DIR/draft.template.md" ] && pass "draft.template.md present" || fail "draft.template.md missing"

# Test 4: template has required structure (3 question headers)
QUESTION_COUNT=$(grep -c "^## Question" "$DRAFTS_DIR/draft.template.md" 2>/dev/null || echo 0)
[ "$QUESTION_COUNT" -ge 3 ] && pass "template has ≥3 question sections" || fail "template missing question sections (found $QUESTION_COUNT)"

# Test 5: directory is in .gitignore pattern (drafts/ content gitignored)
grep -q "drafts/" agent/.gitignore 2>/dev/null && pass "drafts/ in agent/.gitignore" || \
  grep -q "drafts/" .gitignore 2>/dev/null && pass "drafts/ in .gitignore" || \
  fail "drafts/ not found in any .gitignore"
```

Wire into `run-e2e-tests.sh` (add to the list of test files if it uses an explicit list).

## Expected Output

### Files Created
- `e2e/acp.drafts.test.sh`

### Files Updated
- `AGENT.md` (add `drafts/` to directory tree)
- `run-e2e-tests.sh` (add acp.drafts.test.sh if using explicit list)

## Verification
- [ ] `AGENT.md` directory tree shows `agent/drafts/`
- [ ] `bash e2e/acp.drafts.test.sh` passes all 5 assertions
- [ ] `bash run-e2e-tests.sh` includes and runs `acp.drafts.test.sh`

## User-Observable Acceptance
`bash run-e2e-tests.sh` shows `acp.drafts.test.sh` PASS in the output. AGENT.md directory tree is current.
