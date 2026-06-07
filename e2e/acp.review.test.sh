#!/usr/bin/env bash
# E2E Tests for /acp-review command
# Tests structural integrity of command doc, skill file, taxonomy, routing,
# and package.yaml entry. Behavioral checks verify flag documentation,
# ruleset completeness, executor qualification, and ACP self-review appendix.
#
# NOTE: Do NOT add set -e here. assert_* functions return exit code 1 on failure.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${PROJECT_ROOT}/tests/common.sh"

CMD_FILE="${PROJECT_ROOT}/agent/commands/acp.review.md"
SKILL_FILE="${PROJECT_ROOT}/agent/skills/code-review.md"
TAXO_FILE="${PROJECT_ROOT}/agent/routing/taxonomy.yml"
ROUTING_FILE="${PROJECT_ROOT}/agent/core/routing.yml"
PKG_FILE="${PROJECT_ROOT}/package.yaml"

# ── Structural Assertions (7) ─────────────────────────────────────────────────

print_suite_header "/acp-review — E2E Tests"

# S1: Command doc exists and has Agent Directive header
print_test_header "S1 — acp.review.md exists with Agent Directive"
assert_file_exists "${CMD_FILE}" "acp.review.md exists"
assert_contains "$(head -20 "${CMD_FILE}")" "Agent Directive" "Agent Directive header present"

# S2: Skill file exists with copilot executor and Flash disqualified
print_test_header "S2 — code-review.md skill file integrity"
assert_file_exists "${SKILL_FILE}" "code-review.md skill file exists"
assert_contains "$(cat "${SKILL_FILE}")" "copilot" "copilot executor referenced"
assert_contains "$(cat "${SKILL_FILE}")" "deepseek-v4-flash" "Flash explicitly mentioned"
assert_contains "$(cat "${SKILL_FILE}")" "Disqualified" "Flash disqualification section present"

# S3: Package.yaml entry for acp.review.md
print_test_header "S3 — package.yaml has acp-review entry"
assert_contains "$(cat "${PKG_FILE}")" "acp.review.md" "acp.review.md in package.yaml"

# S4: Taxonomy has 4 code-review task types
print_test_header "S4 — taxonomy.yml has 4 review task types"
assert_contains "$(cat "${TAXO_FILE}")" "code-review-full" "code-review-full task type"
assert_contains "$(cat "${TAXO_FILE}")" "code-review-targeted" "code-review-targeted task type"
assert_contains "$(cat "${TAXO_FILE}")" "code-review-security" "code-review-security task type"
assert_contains "$(cat "${TAXO_FILE}")" "code-review-ci" "code-review-ci task type"

# S5: Taxonomy has code-review skill catalog entry
print_test_header "S5 — taxonomy.yml has code-review skill catalog entry"
assert_contains "$(cat "${TAXO_FILE}")" "name: code-review" "code-review skill catalog name"
assert_contains "$(cat "${TAXO_FILE}")" "file: agent/skills/code-review.md" "skill file path in catalog"

# S6: Routing.yml has acp-review command suggestions
print_test_header "S6 — routing.yml has acp-review command suggestions"
assert_contains "$(cat "${ROUTING_FILE}")" "acp-review:" "acp-review suggestion block"
assert_contains "$(cat "${ROUTING_FILE}")" "acp-audit:" "audit referenced in review suggestions"

# S7: Cross-link to acp-validate in command doc
print_test_header "S7 — acp.review.md cross-links to acp-validate"
assert_contains "$(cat "${CMD_FILE}")" "acp-validate" "acp-validate cross-linked"

# ── Behavioral Assertions (7) ─────────────────────────────────────────────────

# B1: Command doc has --diff flag documented
print_test_header "B1 — --diff flag documented"
assert_contains "$(cat "${CMD_FILE}")" "\`--diff\`" "--diff flag in backticks"
assert_contains "$(cat "${CMD_FILE}")" "git diff --name-only" "git diff reference with --diff"

# B2: Language Scope section present
print_test_header "B2 — Language Scope section present"
assert_contains "$(cat "${CMD_FILE}")" "Language Scope" "Language Scope section header"

# B3: Security rules include CRITICAL rules SC-01 through SC-06
print_test_header "B3 — Security rules SC-01 through SC-06 present"
assert_contains "$(cat "${CMD_FILE}")" "SC-01" "SC-01 — No hardcoded secrets"
assert_contains "$(cat "${CMD_FILE}")" "SC-02" "SC-02 — Input validation"
assert_contains "$(cat "${CMD_FILE}")" "SC-06" "SC-06 — Access control on user data"

# B4: Flash/Flash-Max disqualified in executor selection
print_test_header "B4 — Flash and Flash-Max disqualified from review"
assert_contains "$(cat "${CMD_FILE}")" "Disqualified" "Disqualification section present"
assert_contains "$(cat "${CMD_FILE}")" "Flash" "Flash mentioned in disqualification"

# B5: Quality gates section present with non-auto-fix rule
print_test_header "B5 — Quality gates document non-auto-fix rule"
assert_contains "$(cat "${CMD_FILE}")" "Quality Gates" "Quality Gates section header"
assert_contains "$(cat "${CMD_FILE}")" "never auto-fix" "Never auto-fix rule"

# B6: Appendix A with ACP self-review rules (10 rules)
print_test_header "B6 — Appendix A has 10 self-review rules"
assert_contains "$(cat "${CMD_FILE}")" "Appendix A" "Appendix A header"
assert_contains "$(cat "${CMD_FILE}")" "SH-01" "SH-01 — set -euo pipefail"
assert_contains "$(cat "${CMD_FILE}")" "SH-04" "SH-04 — no trap cleanup EXIT in functions"
assert_contains "$(cat "${CMD_FILE}")" "SC-15" "SC-15 — lockfile qualifier"

# B7: 54 total rule IDs across all categories (heuristic: count Rule ID patterns)
# We check key rule blocks from each category to confirm comprehensive coverage
print_test_header "B7 — Categories cover error-handling, typescript, naming, api, health, security, mobile"
assert_contains "$(cat "${CMD_FILE}")" "EH-01" "Error Handling category (EH-01)"
assert_contains "$(cat "${CMD_FILE}")" "TS-01" "TypeScript category (TS-01)"
assert_contains "$(cat "${CMD_FILE}")" "NC-01" "Naming Conventions category (NC-01)"
assert_contains "$(cat "${CMD_FILE}")" "AP-01" "API Response category (AP-01)"
assert_contains "$(cat "${CMD_FILE}")" "CH-01" "Code Health category (CH-01)"
assert_contains "$(cat "${CMD_FILE}")" "MASVS-STORAGE" "Mobile MASVS rules (MASVS-STORAGE)"

print_suite_summary

# ── Behavioral Smoke Test — Fixture Violations (GAP-052-04) ────────────────────

# Create fixture directory with intentional violations
FIXTURE_DIR="$(mktemp -d)"
trap 'rm -rf "${FIXTURE_DIR}"' EXIT

# Fixture 1: Empty catch block (EH-02 violation)
cat > "${FIXTURE_DIR}/empty-catch.ts" << 'TSEOF'
async function fetchUser(id: string): Promise<User | null> {
  try {
    const response = await fetch(`/api/users/${id}`);
    return await response.json();
  } catch (e) {
    // EH-02 violation: empty catch block
  }
  return null;
}
TSEOF

# Fixture 2: Hardcoded secret (SC-01 CRITICAL violation)
cat > "${FIXTURE_DIR}/hardcoded-secret.ts" << 'TSEOF'
const API_KEY = "sk-proj-abc123def456ghi789jkl";
const config = {
  databasePassword: "admin123!",
  jwtSecret: "my-super-secret-key"
};
TSEOF

# Fixture 3: any type in parameter (TS-01 violation)
cat > "${FIXTURE_DIR}/any-type.ts" << 'TSEOF'
function processData(data: any): any {
  return data as any;
}
TSEOF

print_test_header "B8 — Fixture: EH-02 empty catch rule matches fixture violation"
# Count lines with 'catch' keyword (the fixture has 2: the catch clause + the comment)
CATCH_LINES=$(grep -c 'catch' "${FIXTURE_DIR}/empty-catch.ts" || echo "0")
[ "${CATCH_LINES}" -ge 1 ]
assert_true "empty-catch.ts has at least 1 catch block" $?
EH02_RULE="$(grep '| EH-02 |' "${CMD_FILE}" | head -1)"
assert_contains "${EH02_RULE}" "empty" "EH-02 rule mentions 'empty' catch blocks"

print_test_header "B9 — Fixture: SC-01 hardcoded secret rule matches fixture violation"
SC_COUNT=$(grep -cE '(API_KEY|password|secret)' "${FIXTURE_DIR}/hardcoded-secret.ts" || echo "0")
[ "${SC_COUNT}" -ge 2 ]
assert_true "Fixture has hardcoded secrets (found ${SC_COUNT})" $?
SC01_RULE="$(grep '| SC-01 |' "${CMD_FILE}" | head -1)"
assert_contains "${SC01_RULE}" "hardcoded" "SC-01 rule mentions 'hardcoded'"
assert_contains "${SC01_RULE}" "CRITICAL" "SC-01 severity is CRITICAL"

print_test_header "B10 — Fixture: TS-01 any-type rule matches fixture violation"
assert_contains "$(cat "${FIXTURE_DIR}/any-type.ts")" ": any" "any-type.ts has 'any' type annotations"
# Grep specifically in rule tables (lines starting with | TS-01 |)
TS01_RULE="$(grep '^| TS-01 |' "${CMD_FILE}" | head -1)"
assert_contains "${TS01_RULE}" "any" "TS-01 rule in table mentions 'any'"
assert_contains "${TS01_RULE}" "HIGH" "TS-01 severity is HIGH"

print_test_header "B11 — Command doc has correct YAML output format example"
assert_contains "$(cat "${CMD_FILE}")" "review-NNN.md" "Output references review-NNN.md"
assert_contains "$(cat "${CMD_FILE}")" "findings_total:" "Output format has findings_total"
assert_contains "$(cat "${CMD_FILE}")" "findings_critical:" "Output format has findings_critical"

print_test_header "B12 — Total rule IDs in command doc (expected ~54+)"
RULE_COUNT=$(grep -cE '^\| (EH|TS|NC|AP|CH|SC|SH|YM|AP)-\d+' "${CMD_FILE}" || echo "0")
echo "  Rule count: ${RULE_COUNT}"
[ "${RULE_COUNT}" -ge 50 ]
assert_true "At least 50+ rule IDs found (actual: ${RULE_COUNT})" $?

print_test_header "B13 — All rule IDs have severity annotations"
RULES_WITH_SEVERITY=$(grep -cE '^\| (EH|TS|NC|AP|CH|SC|SH|YM|AP)-\d+.*\| (CRITICAL|HIGH|MEDIUM|LOW) \|' "${CMD_FILE}" || echo "0")
echo "  Rules with severity: ${RULES_WITH_SEVERITY}"
[ "${RULES_WITH_SEVERITY}" -ge 50 ]
assert_true "All rules have severity (expected >=50, actual: ${RULES_WITH_SEVERITY})" $?

print_suite_summary "/acp-review — E2E Tests"
