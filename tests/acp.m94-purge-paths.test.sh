#!/usr/bin/env bash
# Unit tests for acp.m94-purge-paths.sh (M94 task-374)
# Asserts KEEP/PURGE contract on live repo history — not a dry-run-only gate.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
source "${PROJECT_ROOT}/tests/common.sh"

SCRIPT="${PROJECT_ROOT}/agent/scripts/acp.m94-purge-paths.sh"
OUT="/tmp/m94-purge-paths-test-$$.txt"

print_suite_header "acp.m94-purge-paths.sh — KEEP/PURGE (M94)"

print_test_header "S1 — script exists and bash -n"
assert_file_exists "${SCRIPT}" "m94-purge-paths script"
bash -n "${SCRIPT}"
assert_true "bash -n m94-purge-paths" $?

print_test_header "S2 — generate list"
bash "${SCRIPT}" --output "${OUT}"
assert_file_exists "${OUT}" "purge list written"
test -s "${OUT}"
assert_true "purge list non-empty" $?

print_test_header "S3 — required PURGE paths present"
assert_contains "$(cat "${OUT}")" "IP_REGISTER.md" "IP_REGISTER.md in purge list"
assert_contains "$(cat "${OUT}")" "agent/patterns/typescript/local.library-services.md" "nested local pattern in purge list"
assert_contains "$(cat "${OUT}")" "agent/design/visualizer.requirements.md" "visualizer.requirements.md in purge list"
assert_contains "$(cat "${OUT}")" ".claude/settings.local.json" "settings.local.json in purge list"
assert_contains "$(cat "${OUT}")" "agent/index/local.main.yaml" "instance index in purge list"
assert_contains "$(cat "${OUT}")" "agent/specs/local.acp-code-plugin-api.md" "instance spec in purge list"
assert_contains "$(cat "${OUT}")" "agent/proposals/acp-enhanced-cross-agent-handoff-v1.md" "instance proposal in purge list"

print_test_header "S4 — KEEP paths absent (F-136-01 / D16)"
if grep -Fxq "agent/routing/tasks/route-template.md" "${OUT}"; then
  assert_true "route-template.md must not be in purge list" 1
else
  assert_true "route-template.md not in purge list" 0
fi
if grep -Fxq "docs/USAGE.md" "${OUT}"; then
  assert_true "docs/USAGE.md must not be in purge list" 1
else
  assert_true "docs/USAGE.md not in purge list" 0
fi
if grep -Fxq "agent/routing/taxonomy.yml" "${OUT}"; then
  assert_true "taxonomy.yml must not be in purge list" 1
else
  assert_true "taxonomy.yml not in purge list" 0
fi
if grep -E '^agent/benchmarks/' "${OUT}" >/dev/null; then
  assert_true "benchmarks must not be in purge list" 1
else
  assert_true "agent/benchmarks/ not in purge list" 0
fi
if grep -Fxq "agent/design/acp-commands-design.md" "${OUT}"; then
  assert_true "protocol acp-commands-design.md must not be purged" 1
else
  assert_true "acp-commands-design.md kept" 0
fi
if grep -Fxq "agent/index/local.main.template.yaml" "${OUT}"; then
  assert_true "local.main.template.yaml must not be purged" 1
else
  assert_true "local.main.template.yaml kept" 0
fi
if grep -Fxq "agent/specs/spec.template.md" "${OUT}"; then
  assert_true "spec.template.md must not be purged" 1
else
  assert_true "spec.template.md kept" 0
fi

rm -f "${OUT}"
print_test_summary
