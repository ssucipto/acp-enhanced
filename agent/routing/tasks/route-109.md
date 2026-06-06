---
id: route-109
title: "Create E2E smoke test for acp-design-spec command"
task_type: e2e-test-write
milestone: M50
complexity: medium
executor: copilot
context_required:
  - agent/commands/acp.design-spec.md
  - agent/patterns/local.e2e-testing.md
  - e2e/acp.command-docs.test.sh
files_affected:
  - e2e/acp.design-spec.test.sh
tokens_est: 400
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-06
completed:
override_reason:
---

# Route 109: E2E Smoke Test for acp-design-spec

## Objective

Create `e2e/acp.design-spec.test.sh` following the established E2E testing pattern. The smoke test verifies the command document structure, wrappers, and template — not the full spec generation workflow (which requires a real codebase).

## Context

Per `constraints.yml`, every command must have an E2E test. The feedback-005 §5.3 specifies the smoke test assertions. Follow `agent/patterns/local.e2e-testing.md` for test structure conventions and `e2e/acp.command-docs.test.sh` as a reference.

## Changes

### Create `e2e/acp.design-spec.test.sh`

Test assertions (from feedback-005 §5.3 + ACP conventions):

1. **Command doc exists**: `agent/commands/acp.design-spec.md` present
2. **Agent Directive**: Contains `🤖 Agent Directive` block
3. **Scripts field**: Contains `Scripts:` field
4. **Verification Checklist**: Contains `## Verification Checklist`
5. **Report Structure**: Lists §1–§19 sections
6. **Related Commands**: References `acp.design-create` distinction
7. **Wrapper parity**: `.cursor/commands/acp-design-spec.md` exists
8. **Wrapper parity**: `.opencode/commands/acp-design-spec.md` exists
9. **Template exists**: `agent/templates/design-spec.template.md` present
10. **Template sections**: Template contains all 19 sections
11. **No FIFOZ hardcoded paths**: Does not contain `frontend/store/` or `backend/server.py` as literal paths
12. **Stack detection table**: Contains stack-agnostic detection instructions

### Test structure

Follow `local.e2e-testing.md` conventions:
- Bash 4+ with `set -euo pipefail` and ERR trap
- macOS + Linux compatible (BSD sed)
- Colored output (green ✅ / red ❌)
- Summary at end with pass/fail count
- Exit code 0 on all pass, 1 on any failure

## Verification

- [ ] Test file exists at `e2e/acp.design-spec.test.sh`
- [ ] All 12 assertions defined
- [ ] Uses `set -euo pipefail` with ERR trap
- [ ] macOS BSD sed compatible
- [ ] No external dependencies (pure bash)
- [ ] Test passes: `bash e2e/acp.design-spec.test.sh`
