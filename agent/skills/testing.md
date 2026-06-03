<skill name="testing" mention="@{testing}">
<rules>
- E2E tests live in `e2e/acp.*.test.sh` — integration tests requiring full script chain
- Unit tests live in `tests/acp.*.test.sh` — pure function tests, offline only
- All tests must source `tests/common.sh` for assert_equals, assert_contains, etc.
- Test files must be executable: `chmod +x`
- Use a `setup()` and `teardown()` function with a temp directory per test file
- TEMP_DIR pattern: `TEMP_DIR="$(mktemp -d)"` ; cleanup in teardown with `rm -rf`
- E2E tests must NOT call real GitHub API — mock or skip network calls
- Assertion format: `assert_equals "expected" "actual" "test description"`
- Test output: `PASS: test description` or `FAIL: test description`
- Exit code: 0 if all pass, 1 if any fail
- Test count must be reported at end: `Tests: N passed, M failed`
- E2E tests that install packages must clean up agent/ after each test case
- Never use `sleep` in tests — it makes CI slow and flaky
</rules>

<patterns>
Test file header:
```bash
#!/usr/bin/env bash
# e2e/acp.foo.test.sh — E2E tests for /acp-foo command script
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
source "${ROOT_DIR}/tests/common.sh"

TEMP_DIR=""
PASS_COUNT=0
FAIL_COUNT=0

setup() {
  TEMP_DIR="$(mktemp -d)"
  cd "${TEMP_DIR}"
  # Minimal ACP install for tests
  mkdir -p agent/scripts agent/commands
  cp "${ROOT_DIR}/agent/scripts/acp.common.sh" agent/scripts/
  cp "${ROOT_DIR}/agent/scripts/acp.yaml-parser.sh" agent/scripts/
}

teardown() {
  cd "${ROOT_DIR}"
  rm -rf "${TEMP_DIR}"
}
```

Test case pattern:
```bash
test_foo_does_x() {
  setup
  # arrange
  echo "name: test-pkg" > agent/package.yaml

  # act
  output="$(bash "${ROOT_DIR}/agent/scripts/acp.foo.sh" --option 2>&1)"
  exit_code=$?

  # assert
  assert_equals "0" "${exit_code}" "foo exits 0 on success"
  assert_contains "expected text" "${output}" "foo outputs expected text"

  teardown
  PASS_COUNT=$((PASS_COUNT + 1))
}
```

Test runner at end of file:
```bash
test_foo_does_x
test_foo_fails_on_invalid_input
# ... more tests

echo ""
echo "Tests: ${PASS_COUNT} passed, ${FAIL_COUNT} failed"
[[ "${FAIL_COUNT}" -eq 0 ]] || exit 1
```
</patterns>

<anti_patterns>
- NEVER test implementation details — test observable behaviour only
- NEVER use global state between test cases — always setup/teardown
- NEVER skip the teardown — leaked temp dirs cause CI disk issues
- NEVER assert on line numbers or exact error message phrasing — those change
- NEVER run E2E tests that require network access in unit test files
</anti_patterns>
</skill>
