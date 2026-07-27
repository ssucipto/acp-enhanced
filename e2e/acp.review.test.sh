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

# B1: Command doc has core scanner flags documented
print_test_header "B1 — --diff, --self, and baseline flags documented"
assert_contains "$(cat "${CMD_FILE}")" "\`--diff\`" "--diff flag in backticks"
assert_contains "$(cat "${CMD_FILE}")" "git diff --name-only" "git diff reference with --diff"
assert_contains "$(cat "${CMD_FILE}")" "\`--self\`" "--self flag in backticks"
assert_contains "$(cat "${CMD_FILE}")" "agent/scripts/" "--self references agent/scripts/"
assert_contains "$(cat "${CMD_FILE}")" "\`--baseline <file>\`" "--baseline flag documented"
assert_contains "$(cat "${CMD_FILE}")" "\`--write-baseline <file>\`" "--write-baseline flag documented"

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
assert_contains "$(cat "${CMD_FILE}")" "ACP-01" "ACP-01 — Agent Directive header (Appendix A)"
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
# Intentional negative-test strings — not real credentials; isolated in mktemp dir (review-001 CR-008).
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

# Fixture 4: missing pipefail (SH-01 violation)
cat > "${FIXTURE_DIR}/bad-shell.sh" << 'SHEOF'
#!/usr/bin/env bash
echo "no pipefail"
SHEOF

REVIEW_SCAN="${PROJECT_ROOT}/agent/scripts/acp.review-scan.sh"
assert_file_exists "${REVIEW_SCAN}" "acp.review-scan.sh exists"
bash -n "${REVIEW_SCAN}" 2>/dev/null
assert_true "acp.review-scan.sh passes bash -n" $?

print_test_header "B8 — review-scan detects EH-02 empty catch in fixture"
EH_OUT=$(bash "${REVIEW_SCAN}" "${FIXTURE_DIR}/empty-catch.ts" 2>&1 || true)
assert_contains "${EH_OUT}" "EH-02" "review-scan reports EH-02 on empty catch fixture"

print_test_header "B9 — review-scan detects SC-01 hardcoded secret in fixture"
SC_OUT=$(bash "${REVIEW_SCAN}" "${FIXTURE_DIR}/hardcoded-secret.ts" 2>&1 || true)
assert_contains "${SC_OUT}" "SC-01" "review-scan reports SC-01 on secret fixture"
assert_contains "${SC_OUT}" "CRITICAL" "SC-01 severity CRITICAL"

print_test_header "B10 — review-scan detects TS-01 any-type in fixture"
TS_OUT=$(bash "${REVIEW_SCAN}" "${FIXTURE_DIR}/any-type.ts" 2>&1 || true)
assert_contains "${TS_OUT}" "TS-01" "review-scan reports TS-01 on any-type fixture"

print_test_header "B11 — review-scan detects SH-01 missing pipefail in fixture"
SH_OUT=$(bash "${REVIEW_SCAN}" "${FIXTURE_DIR}/bad-shell.sh" 2>&1 || true)
assert_contains "${SH_OUT}" "SH-01" "review-scan reports SH-01 on bad-shell fixture"

print_test_header "B12 — review-scan --ci exits 1 on fixture violations"
bash "${REVIEW_SCAN}" --ci "${FIXTURE_DIR}" >/dev/null 2>&1 || CI_EC=$?
assert_true "review-scan --ci exits non-zero on violations" $([ "${CI_EC:-0}" -ne 0 ] && echo 0 || echo 1)

# Fixture 5: missing return type (TS-02)
cat > "${FIXTURE_DIR}/no-return-type.ts" << 'TSEOF'
export function getUser(id: string) {
  return { id };
}
TSEOF

# Fixture 6: async without try (EH-01)
cat > "${FIXTURE_DIR}/async-no-try.ts" << 'TSEOF'
export async function loadData(): Promise<void> {
  const r = await fetch("/api");
  console.log(r);
}
TSEOF

# Fixture 7: API without envelope (AP-01)
cat > "${FIXTURE_DIR}/bad-api.ts" << 'TSEOF'
export function handler(res: { json: (v: unknown) => void }) {
  res.json({ users: [] });
}
TSEOF

# Fixture 8: snake_case (NC-01)
cat > "${FIXTURE_DIR}/snake-case.ts" << 'TSEOF'
const user_name = "test";
TSEOF

print_test_header "B12b — Gate Policy and standards coverage sections in command doc"
assert_contains "$(cat "${CMD_FILE}")" "Phase 1 Gate Policy" "Phase 1 Gate Policy section present"
assert_contains "$(cat "${CMD_FILE}")" "42 built-in deterministic" "expanded Phase 1 deterministic count documented"
assert_contains "$(cat "${CMD_FILE}")" "Rule Ownership" "Rule ownership section present"
assert_contains "$(cat "${CMD_FILE}")" "/acp-integrity" "A08 ownership cross-link documented"
assert_contains "$(cat "${CMD_FILE}")" "Standards Coverage" "Standards Coverage section present"
assert_contains "$(cat "${CMD_FILE}")" "A08 Software and Data Integrity Failures" "A08 coverage row present"
assert_contains "$(cat "${CMD_FILE}")" "acp-review-ignore" "inline suppression convention documented"

print_test_header "B17 — review-scan detects TS-02 missing return type"
TS2_OUT=$(bash "${REVIEW_SCAN}" "${FIXTURE_DIR}/no-return-type.ts" 2>&1 || true)
assert_contains "${TS2_OUT}" "TS-02" "review-scan reports TS-02"

print_test_header "B18 — review-scan detects EH-01 async without try"
EH1_OUT=$(bash "${REVIEW_SCAN}" "${FIXTURE_DIR}/async-no-try.ts" 2>&1 || true)
assert_contains "${EH1_OUT}" "EH-01" "review-scan reports EH-01"

print_test_header "B19 — review-scan detects AP-01 missing data envelope"
AP_OUT=$(bash "${REVIEW_SCAN}" "${FIXTURE_DIR}/bad-api.ts" 2>&1 || true)
assert_contains "${AP_OUT}" "AP-01" "review-scan reports AP-01"

print_test_header "B20 — review-scan detects NC-01 snake_case"
NC_OUT=$(bash "${REVIEW_SCAN}" "${FIXTURE_DIR}/snake-case.ts" 2>&1 || true)
assert_contains "${NC_OUT}" "NC-01" "review-scan reports NC-01"

print_test_header "B13 — review-scan clean on entropy-clean.ts fixture"
CLEAN_FIXTURE="${PROJECT_ROOT}/agent/benchmarks/fixtures/integrity/entropy-clean.ts"
CLEAN_OUT=$(bash "${REVIEW_SCAN}" "${CLEAN_FIXTURE}" 2>&1; echo "EXIT:$?")
assert_contains "${CLEAN_OUT}" "No findings" "review-scan clean fixture silent"
assert_contains "${CLEAN_OUT}" "EXIT:0" "review-scan clean fixture exits 0"

print_test_header "B14 — Command doc has correct YAML output format example"
assert_contains "$(cat "${CMD_FILE}")" "review-NNN.md" "Output references review-NNN.md"
assert_contains "$(cat "${CMD_FILE}")" "findings_total:" "Output format has findings_total"
assert_contains "$(cat "${CMD_FILE}")" "findings_critical:" "Output format has findings_critical"

print_test_header "B15 — Total rule IDs in command doc (64 = 54 core + 10 appendix)"
RULE_COUNT=$(grep -cE '^\| (EH|TS|NC|AP|CH|SC|SH|YM|ACP)-\d+' "${CMD_FILE}" || echo "0")
echo "  Rule count: ${RULE_COUNT}"
[ "${RULE_COUNT}" -ge 64 ]
assert_true "At least 64 rule IDs found (actual: ${RULE_COUNT})" $?

print_test_header "B16 — All rule IDs have severity annotations"
RULES_WITH_SEVERITY=$(grep -cE '^\| (EH|TS|NC|AP|CH|SC|SH|YM|ACP)-\d+.*\| (CRITICAL|HIGH|MEDIUM|LOW) \|' "${CMD_FILE}" || echo "0")
echo "  Rules with severity: ${RULES_WITH_SEVERITY}"
[ "${RULES_WITH_SEVERITY}" -ge 64 ]
assert_true "All rules have severity (expected >=64, actual: ${RULES_WITH_SEVERITY})" $?

print_suite_summary "/acp-review — E2E Tests"
