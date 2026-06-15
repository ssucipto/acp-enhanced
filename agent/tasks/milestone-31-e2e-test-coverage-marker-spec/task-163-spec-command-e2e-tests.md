---
id: task-163
milestone: M31
title: Write e2e/acp.spec.test.sh (command doc format smoke test)
status: completed
priority: 3
complexity: low
estimated_hours: 2
created: 2026-05-05
started: 2026-05-05T00:00:00Z
completed: 2026-05-05
---

## Objective

Create `e2e/acp.spec.test.sh` — a structural smoke test that verifies the `acp.spec.md` command doc has the required format, and that `agent/specs/spec.template.md` is present and correctly structured.

## Context

`agent/commands/acp.spec.md` (v1.1.0) implements spec creation with FR-IDs, Behavior Tables, and OQ resolution. `agent/specs/spec.template.md` is the template for generated specs. Neither has any automated test.

This is a **format/structure test** (does the file exist and have required sections?) not a behavioral test (does the agent execute the command correctly?). Behavioral tests require LLM execution and are out of scope for E2E bash tests.

## Implementation

Test cases:
1. `agent/commands/acp.spec.md` exists
2. File contains `# Command: spec` header
3. File contains `**Version**:` field
4. File contains `**Status**: Active`
5. File contains at least one occurrence of `FR-` (FR-ID references)
6. File contains `Behavior Table` or `## Behavior` section
7. `agent/specs/spec.template.md` exists
8. Template contains `@acp.meta.spec` marker (template must have the marker block)
9. Template contains `requirements:` field (inside the marker)
10. Template contains `## Purpose` section

```bash
#!/usr/bin/env bash
# e2e/acp.spec.test.sh — smoke test for @acp.spec command doc and spec template

<!-- @acp.meta.task
topic: e2eacpspectestsh, smoke, test, for, acpspec, command, doc, and, spec, template
description: Write e2e/acp.spec.test.sh (command doc format smoke test)
milestone: M31
status: completed
updated: 2026-05-05
@acp.meta.end -->



ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SPEC_CMD="$ROOT/agent/commands/acp.spec.md"
SPEC_TMPL="$ROOT/agent/specs/spec.template.md"

pass() { echo "PASS: $1"; }
fail() { echo "FAIL: $1"; FAILURES=$((FAILURES+1)); }
FAILURES=0

[ -f "$SPEC_CMD" ] && pass "acp.spec.md exists" || fail "acp.spec.md missing"
grep -q "# Command: spec" "$SPEC_CMD" && pass "spec header present" || fail "spec header missing"
grep -q "Version" "$SPEC_CMD" && pass "Version field present" || fail "Version field missing"
grep -q "Active" "$SPEC_CMD" && pass "Status: Active present" || fail "Status: Active missing"
grep -q "FR-\|R[0-9]" "$SPEC_CMD" && pass "FR-ID references present" || fail "No FR-ID references in spec.md"
grep -qi "behavior table\|## behavior\|behavior.*table" "$SPEC_CMD" && pass "Behavior Table section present" || fail "Behavior Table section missing"
[ -f "$SPEC_TMPL" ] && pass "spec.template.md exists" || fail "spec.template.md missing"
grep -q "@acp.meta.spec" "$SPEC_TMPL" && pass "spec template has @acp.meta.spec marker" || fail "spec template missing @acp.meta.spec marker"
grep -q "requirements:" "$SPEC_TMPL" && pass "spec template has requirements: field" || fail "spec template missing requirements: field"
grep -q "## Purpose" "$SPEC_TMPL" && pass "spec template has Purpose section" || fail "spec template missing Purpose section"

[ "$FAILURES" -eq 0 ] && echo "All spec tests passed" || { echo "$FAILURES test(s) failed"; exit 1; }
```

## Expected Output

### Files Created
- `e2e/acp.spec.test.sh`

## Verification
- [ ] `bash e2e/acp.spec.test.sh` passes all 10 assertions
- [ ] Test completes in <1 second

## User-Observable Acceptance
`bash run-e2e-tests.sh` shows `acp.spec.test.sh` PASS. If `acp.spec.md` is corrupted or missing required sections in future, this test catches it immediately.
