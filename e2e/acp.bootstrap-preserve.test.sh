#!/usr/bin/env bash
# E2E: bootstrap re-run preserves customized Tier B files (M68 / F-082-09)
# No network required — exercises create-if-absent stubs in acp-bootstrap.sh step 3+

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${PROJECT_ROOT}/tests/common.sh"

BOOTSTRAP_SCRIPT="${PROJECT_ROOT}/scripts/acp-bootstrap.sh"
TMPDIR_ROOT=""

cleanup() {
    [ -n "${TMPDIR_ROOT}" ] && [ -d "${TMPDIR_ROOT}" ] && rm -rf "${TMPDIR_ROOT}"
}
trap cleanup EXIT

print_suite_header "Bootstrap Preserve — E2E Tests"

TMPDIR_ROOT="$(mktemp -d)"
mkdir -p "${TMPDIR_ROOT}/agent/core" "${TMPDIR_ROOT}/agent/wiki" "${TMPDIR_ROOT}/agent/routing"

cat > "${TMPDIR_ROOT}/agent/core/identity.yml" << 'EOF'
project: bootstrap-preserve-e2e
type: test
description: Custom identity must survive bootstrap re-run
stack:
  - primary: Bash
team: solo-developer
EOF

cat > "${TMPDIR_ROOT}/agent/core/constraints.yml" << 'EOF'
rules:
  - preserve_constraints_marker: true
context_budget:
  layer1_max_tokens: 300
EOF

echo "custom_domain_marker: true" > "${TMPDIR_ROOT}/agent/wiki/domain.yml"

cat > "${TMPDIR_ROOT}/agent/routing/taxonomy.yml" << 'EOF'
custom_taxonomy_marker: true
task_types: {}
EOF

IDENTITY_BEFORE=$(cat "${TMPDIR_ROOT}/agent/core/identity.yml")
CONSTRAINTS_BEFORE=$(cat "${TMPDIR_ROOT}/agent/core/constraints.yml")
DOMAIN_BEFORE=$(cat "${TMPDIR_ROOT}/agent/wiki/domain.yml")
TAXONOMY_BEFORE=$(cat "${TMPDIR_ROOT}/agent/routing/taxonomy.yml")

print_test_header "B1 — bash -n acp-bootstrap.sh"
bash -n "${BOOTSTRAP_SCRIPT}"
assert_true "acp-bootstrap.sh syntax valid" $?

print_test_header "B2 — re-run bootstrap preserves customized identity.yml"
(
    cd "${TMPDIR_ROOT}"
    bash "${BOOTSTRAP_SCRIPT}" --yes > /tmp/acp-bootstrap-preserve.log 2>&1 || true
)
assert_equals "${IDENTITY_BEFORE}" "$(cat "${TMPDIR_ROOT}/agent/core/identity.yml")" "identity.yml unchanged after bootstrap re-run"

print_test_header "B3 — re-run bootstrap preserves customized constraints.yml"
assert_equals "${CONSTRAINTS_BEFORE}" "$(cat "${TMPDIR_ROOT}/agent/core/constraints.yml")" "constraints.yml unchanged"

print_test_header "B4 — re-run bootstrap preserves customized domain.yml"
assert_equals "${DOMAIN_BEFORE}" "$(cat "${TMPDIR_ROOT}/agent/wiki/domain.yml")" "domain.yml unchanged"

print_test_header "B5 — re-run bootstrap preserves customized taxonomy.yml"
assert_equals "${TAXONOMY_BEFORE}" "$(cat "${TMPDIR_ROOT}/agent/routing/taxonomy.yml")" "taxonomy.yml unchanged"

print_test_header "B6 — bootstrap still creates AGENTS.md on partial install"
assert_file_exists "${TMPDIR_ROOT}/AGENTS.md" "AGENTS.md created when absent"

print_test_summary "acp.bootstrap-preserve.test.sh"
exit $?
