#!/usr/bin/env bash
# E2E Tests for /acp-handoff v2 dual mode (M67 route-190)
# Structural assertions on command doc + executor fixture §4 template

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${PROJECT_ROOT}/tests/common.sh"

CMD_FILE="${PROJECT_ROOT}/agent/commands/acp.handoff.md"
FIXTURE="${PROJECT_ROOT}/agent/benchmarks/fixtures/handoff/executor-m51-anonymized.md"

print_suite_header "/acp-handoff v2 — E2E Tests (M67)"

# ── Command doc structure ───────────────────────────────────────

print_test_header "H1 — acp.handoff.md exists with Agent Directive"
assert_file_exists "${CMD_FILE}" "acp.handoff.md exists"
assert_contains "$(head -10 "${CMD_FILE}")" "Agent Directive" "Agent Directive header present"

print_test_header "H2 — v2.0.0 version declared"
CMD_CONTENT="$(cat "${CMD_FILE}")"
assert_contains "${CMD_CONTENT}" "2.0.0" "Version 2.0.0 present"

print_test_header "H3 — Dual mode flags documented"
assert_contains "${CMD_CONTENT}" "mode executor" "executor mode flag documented"
assert_contains "${CMD_CONTENT}" "mode cross-repo" "cross-repo mode flag documented"
assert_contains "${CMD_CONTENT}" "to <target>" "to target flag documented"
assert_contains "${CMD_CONTENT}" "scope <slug>" "scope flag documented"

print_test_header "H4 — Required sections present"
assert_contains "${CMD_CONTENT}" "## Steps" "Steps section present"
assert_contains "${CMD_CONTENT}" "## Verification" "Verification section present"
assert_contains "${CMD_CONTENT}" "## Executor Handoff Template" "Executor template section present"
assert_contains "${CMD_CONTENT}" "active_handoff" "active_handoff update documented"

print_test_header "H5 — Related commands include receive and resume"
assert_contains "${CMD_CONTENT}" "acp.receive.md" "receive command linked"
assert_contains "${CMD_CONTENT}" "acp.resume.md" "resume command linked"

# ── Executor fixture §4 headers ───────────────────────────────

print_test_header "H6 — Executor fixture exists"
assert_file_exists "${FIXTURE}" "executor-m51-anonymized.md exists"

FIXTURE_CONTENT="$(cat "${FIXTURE}")"

print_test_header "H7 — Fixture has YAML frontmatter with executor mode"
assert_contains "${FIXTURE_CONTENT}" "handoff_mode: executor" "fixture handoff_mode executor"
assert_contains "${FIXTURE_CONTENT}" "git_commit:" "fixture git_commit present"
assert_contains "${FIXTURE_CONTENT}" "to_executor: cursor" "fixture to_executor present"

print_test_header "H8 — All mandatory §4 template headers in fixture"
SECTION_HEADERS=(
  "## Model / executor requirements"
  "## Start here (receiving agent)"
  "## Problem / context"
  "## Locked decisions (do not re-litigate)"
  "## Assignment"
  "## Plan reference"
  "## What NOT to do"
  "## State to update as you work"
  "## Adjacent context (out of scope for this handoff)"
  "## Return handoff (when you finish or block)"
  "## Reference chain"
)
for hdr in "${SECTION_HEADERS[@]}"; do
  assert_contains "${FIXTURE_CONTENT}" "${hdr}" "fixture has ${hdr}"
done

print_test_header "H9 — Fixture assignment and NOT list populated"
assert_contains "${FIXTURE_CONTENT}" "Implement" "fixture assignment mode"
assert_contains "${FIXTURE_CONTENT}" "Do not modify acp.handoff.md" "fixture NOT list present"

print_test_header "H10 — Cross-repo default documented in command"
assert_contains "${CMD_CONTENT}" "Default: \`cross-repo\`" "cross-repo default documented"

print_test_summary
