#!/usr/bin/env bash
# E2E Tests for /acp-receive incoming protocol (M67 route-191)
# Structural assertions + behavioral git drift check against fixtures

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${PROJECT_ROOT}/tests/common.sh"

CMD_FILE="${PROJECT_ROOT}/agent/commands/acp.receive.md"
VALID_FIXTURE="${PROJECT_ROOT}/agent/benchmarks/fixtures/handoff/executor-m51-anonymized.md"
DRIFT_FIXTURE="${PROJECT_ROOT}/agent/benchmarks/fixtures/handoff/drift-wrong-sha.md"
RESUME_FILE="${PROJECT_ROOT}/agent/commands/acp.resume.md"
SCHEMA_FILE="${PROJECT_ROOT}/agent/schemas/progress.schema.yaml"
VALIDATE_TS="${PROJECT_ROOT}/scripts/acp-validate.ts"

# Extract git_commit from handoff frontmatter
handoff_git_pin() {
  local file="$1"
  sed -n '/^git_commit:/s/^git_commit:[[:space:]]*//p' "$file" | head -1 | tr -d ' "\r'
}

# Mimics acp.receive.md Step 3 drift check
handoff_drift_status() {
  local file="$1"
  local pin head
  pin="$(handoff_git_pin "$file")"
  head="$(git -C "${PROJECT_ROOT}" rev-parse HEAD 2>/dev/null || echo "")"
  if [ -z "${pin}" ] || [ -z "${head}" ]; then
    echo "DRIFT"
    return
  fi
  if [ "${head}" = "${pin}" ] || [[ "${head}" == "${pin}"* ]] || [[ "${pin}" == "${head}"* ]]; then
    echo "match"
  else
    echo "DRIFT"
  fi
}

print_suite_header "/acp-receive — E2E Tests (M67)"

# ── Command doc structure ─────────────────────────────────────

print_test_header "R1 — acp.receive.md exists with Agent Directive"
assert_file_exists "${CMD_FILE}" "acp.receive.md exists"
assert_contains "$(head -10 "${CMD_FILE}")" "Agent Directive" "Agent Directive header present"

CMD_CONTENT="$(cat "${CMD_FILE}")"

print_test_header "R2 — Required sections and resolution chain"
assert_contains "${CMD_CONTENT}" "## Steps" "Steps section present"
assert_contains "${CMD_CONTENT}" "## Verification" "Verification section present"
assert_contains "${CMD_CONTENT}" "active_handoff.path" "--latest resolution documented"
assert_contains "${CMD_CONTENT}" "HANDOFF-LATEST.md" "HANDOFF-LATEST fallback documented"
assert_contains "${CMD_CONTENT}" "ACP Receive] handoff loaded" "status banner documented"

print_test_header "R3 — Receive steps cover drift and checklist"
assert_contains "${CMD_CONTENT}" "Git Drift Warning" "git drift step present"
assert_contains "${CMD_CONTENT}" "Session Gap Warning" "session gap step present"
assert_contains "${CMD_CONTENT}" "Assignment Checklist" "assignment checklist step present"
assert_contains "${CMD_CONTENT}" "handoff_mode: executor" "executor mode handling documented"

# ── Fixture references ────────────────────────────────────────

print_test_header "R4 — Drift fixture exists with fake SHA"
assert_file_exists "${DRIFT_FIXTURE}" "drift-wrong-sha.md exists"
assert_contains "$(cat "${DRIFT_FIXTURE}")" "deadbeefdeadbeefdeadbeefdeadbeefdeadbeef" "fake git pin present"

print_test_header "R5 — Valid fixture exists"
assert_file_exists "${VALID_FIXTURE}" "executor-m51-anonymized.md exists"

# ── Behavioral drift checks ─────────────────────────────────────

print_test_header "R6 — Drift fixture triggers DRIFT (behavioral)"
DRIFT_RESULT="$(handoff_drift_status "${DRIFT_FIXTURE}")"
if [ "${DRIFT_RESULT}" = "DRIFT" ]; then
  echo "✓ Drift fixture correctly reports DRIFT"
else
  echo "✗ Expected DRIFT for drift fixture, got: ${DRIFT_RESULT}"
  exit 1
fi

print_test_header "R7 — Valid fixture git pin matches HEAD (behavioral)"
# Update valid fixture pin to current HEAD for match test
CURRENT_HEAD="$(git -C "${PROJECT_ROOT}" rev-parse HEAD)"
TEMP_FIXTURE="$(mktemp)"
sed "s/^git_commit:.*/git_commit: ${CURRENT_HEAD}/" "${VALID_FIXTURE}" > "${TEMP_FIXTURE}"
MATCH_RESULT="$(handoff_drift_status "${TEMP_FIXTURE}")"
rm -f "${TEMP_FIXTURE}"
if [ "${MATCH_RESULT}" = "match" ]; then
  echo "✓ Valid fixture pattern matches HEAD when pin aligned"
else
  echo "✗ Expected match when pin equals HEAD, got: ${MATCH_RESULT}"
  exit 1
fi

print_test_header "R8 — Receive banner format derivable from drift status"
BANNER="[ACP Receive] handoff loaded | git ${DRIFT_RESULT} | mode executor"
assert_contains "${BANNER}" "git DRIFT" "banner includes DRIFT for drift fixture"

# ── Resume integration + schema ───────────────────────────────

print_test_header "R9 — acp.resume.md documents handoff path integration"
assert_contains "$(cat "${RESUME_FILE}")" "acp.receive.md" "resume references receive"
assert_contains "$(cat "${RESUME_FILE}")" "@<path>" "resume documents @path argument"
assert_contains "$(cat "${RESUME_FILE}")" "Steps 1–6" "resume delegates receive steps 1-6"

print_test_header "R10 — progress.schema.yaml has active_handoff field"
assert_contains "$(cat "${SCHEMA_FILE}")" "active_handoff:" "active_handoff in schema"
assert_contains "$(cat "${SCHEMA_FILE}")" "to_executor:" "to_executor field in schema"
assert_contains "$(cat "${SCHEMA_FILE}")" "superseded" "status enum includes superseded"

print_test_header "R11 — validateActiveHandoff exported in acp-validate.ts"
assert_contains "$(cat "${VALIDATE_TS}")" "validateActiveHandoff" "validateActiveHandoff function exists"
assert_contains "$(cat "${VALIDATE_TS}")" "runActiveHandoffValidation" "runActiveHandoffValidation wired"

print_test_header "R12 — package.yaml registers acp.receive.md"
assert_contains "$(cat "${PROJECT_ROOT}/package.yaml")" "acp.receive.md" "acp.receive in package.yaml"

print_test_summary
