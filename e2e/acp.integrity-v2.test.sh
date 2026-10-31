#!/usr/bin/env bash
# E2E Tests for /acp-integrity Phase 2 (M58 v2.0)
# Structural + confidence ceiling + script behavioral checks

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${PROJECT_ROOT}/tests/common.sh"

CMD_FILE="${PROJECT_ROOT}/agent/commands/acp.integrity.md"
SKILL_FILE="${PROJECT_ROOT}/agent/skills/code-integrity.md"
WIKI_FILE="${PROJECT_ROOT}/agent/wiki/integrity-rules.md"
TAINT_FIXTURE="${PROJECT_ROOT}/agent/benchmarks/fixtures/taint-flow"

print_suite_header "/acp-integrity v2.0 — Phase 2 E2E (M58)"

print_test_header "S1 — integrity-rules.md Cat 8 with confidence columns (not DEFERRED)"
assert_not_contains "$(cat "${WIKI_FILE}")" "DEFERRED to v2.0 (M58)" "Cat 8/10 not marked DEFERRED"
assert_contains "$(cat "${WIKI_FILE}")" "Max Confidence" "Cat 8 has Max Confidence column"
assert_contains "$(cat "${WIKI_FILE}")" "IG-45" "IG-45 documented in Cat 8"

print_test_header "S2 — acp.integrity.md Phase 2 + self-protection protocol"
assert_contains "$(cat "${CMD_FILE}")" "Phase 2" "Phase 2 section present"
assert_contains "$(cat "${CMD_FILE}")" "Self-Protection Protocol" "Self-protection protocol present"
assert_contains "$(cat "${CMD_FILE}")" "REQUIRES_HUMAN_REVIEW" "Human review verdict documented"

print_test_header "S3 — code-integrity.md Phase 2 guidance"
assert_contains "$(cat "${SKILL_FILE}")" "Phase 2" "Skill mentions Phase 2"
assert_contains "$(cat "${SKILL_FILE}")" "v2.0" "Skill version v2.0"

print_test_header "B4 — Cat 8 rules: no confidence HIGH in wiki (max MEDIUM)"
cat8=$(sed -n '/Category 8/,/Category 9/p' "${WIKI_FILE}")
assert_not_contains "${cat8}" "confidence: HIGH" "Cat 8 wiki has no confidence HIGH"
assert_contains "${cat8}" "MEDIUM" "Cat 8 wiki documents MEDIUM ceiling"

print_test_header "B5 — Cat 9 v2.0 rules: confidence LOW only"
cat9=$(sed -n '/Category 9/,/Category 10/p' "${WIKI_FILE}")
assert_contains "${cat9}" "IG-53" "IG-53 present"
assert_contains "${cat9}" "LOW" "Cat 9 v2.0 rules LOW confidence"

print_test_header "B6 — Cat 10 rules: LOW except IG-61 HIGH"
cat10=$(sed -n '/Category 10/,/Category 11/p' "${WIKI_FILE}")
assert_contains "${cat10}" "IG-61" "IG-61 present"
assert_contains "${cat10}" "unicode-scan" "IG-61 script-backed"

print_test_header "B7 — Self-protection: continue scanning (do NOT self-halt)"
assert_contains "$(cat "${CMD_FILE}")" "CONTINUE" "Self-protection says CONTINUE"
assert_contains "$(cat "${CMD_FILE}")" "do NOT self-halt" "Explicit do NOT self-halt"

print_test_header "B8 — phase2 flag documented"
assert_contains "$(cat "${CMD_FILE}")" "Run Phase 2 semantic" "phase2 flag documented"

print_test_header "B9 — taint-scan.sh detects IG-45 on vulnerable fixture"
taint_out=$(bash "${PROJECT_ROOT}/agent/scripts/acp.taint-scan.sh" "${TAINT_FIXTURE}/ig-45-vulnerable.js" 2>&1; echo "EXIT:$?")
assert_contains "${taint_out}" "IG-45" "IG-45 finding on vulnerable fixture"
assert_contains "${taint_out}" "EXIT:0" "taint-scan exits 0 with findings"

print_test_header "B10 — taint-scan.sh clean on safe fixture"
safe_out=$(bash "${PROJECT_ROOT}/agent/scripts/acp.taint-scan.sh" "${TAINT_FIXTURE}/ig-45-safe.js" 2>&1; echo "EXIT:$?")
assert_contains "${safe_out}" "EXIT:0" "Safe fixture exits 0"
assert_not_contains "${safe_out}" "IG-45" "Safe fixture has no IG-45"

print_test_header "B11 — memory-scan.sh extracts constraints + memory files"
mem_out=$(bash "${PROJECT_ROOT}/agent/scripts/acp.memory-scan.sh" 2>&1; echo "EXIT:$?")
assert_contains "${mem_out}" "constraints_hard_rules" "Memory scan outputs hard rules"
assert_contains "${mem_out}" "memory_files" "Memory scan lists memory files"
assert_contains "${mem_out}" "EXIT:0" "memory-scan exits 0"

print_test_header "B12 — Phase 2 scripts pass bash -n"
for s in acp.taint-scan.sh acp.memory-scan.sh; do
  bash -n "${PROJECT_ROOT}/agent/scripts/${s}" 2>/dev/null
  assert_true "bash -n ${s}" $?
done

print_test_header "B13 — taint-flow manifest has max_confidence + ci_blocking"
manifest="${TAINT_FIXTURE}/manifest.yaml"
assert_contains "$(cat "${manifest}")" "max_confidence:" "manifest encodes max_confidence"
assert_contains "$(cat "${manifest}")" "ci_blocking: false" "manifest marks taint fixtures non-blocking in CI"

print_test_header "B14 — full taint fixture matrix (6 vulnerable rules)"
for pair in 45 46 47 48 49 50; do
  vuln="${TAINT_FIXTURE}/ig-${pair}-vulnerable.js"
  safe="${TAINT_FIXTURE}/ig-${pair}-safe.js"
  vuln_out=$(bash "${PROJECT_ROOT}/agent/scripts/acp.taint-scan.sh" "${vuln}" 2>&1; echo "EXIT:$?")
  safe_out=$(bash "${PROJECT_ROOT}/agent/scripts/acp.taint-scan.sh" "${safe}" 2>&1; echo "EXIT:$?")
  assert_contains "${vuln_out}" "IG-${pair}" "IG-${pair} finding on vulnerable fixture"
  assert_contains "${vuln_out}" "EXIT:0" "IG-${pair} vulnerable exits 0"
  assert_not_contains "${safe_out}" "IG-${pair}" "IG-${pair} clean on safe fixture"
  assert_contains "${safe_out}" "EXIT:0" "IG-${pair} safe exits 0"
done

print_test_header "B15 — taint-scan --ci does not fail on MEDIUM findings"
ci_out=$(bash "${PROJECT_ROOT}/agent/scripts/acp.taint-scan.sh" --ci "${TAINT_FIXTURE}/ig-45-vulnerable.js" 2>&1; echo "EXIT:$?")
assert_contains "${ci_out}" "MEDIUM" "Phase 2 taint finding at MEDIUM"
assert_contains "${ci_out}" "EXIT:0" "taint-scan --ci exits 0 on MEDIUM-only findings"

print_test_header "B16 — IG-50 reports LOW confidence ceiling"
ig50_out=$(bash "${PROJECT_ROOT}/agent/scripts/acp.taint-scan.sh" "${TAINT_FIXTURE}/ig-50-vulnerable.js" 2>&1)
assert_contains "${ig50_out}" "[LOW]" "IG-50 finding uses LOW confidence"

FIX_ROOT="$(mktemp -d)"
trap 'rm -rf "${FIX_ROOT}"' EXIT

print_test_header "B17 — memory-scan takes the root from the environment"
mem_root="${FIX_ROOT}/o'brien"
mkdir -p "${mem_root}/agent/core" "${mem_root}/agent/memory" "${mem_root}/agent/scripts"
cp "${PROJECT_ROOT}/agent/scripts/acp.memory-scan.sh" "${mem_root}/agent/scripts/"
echo "rules: []" > "${mem_root}/agent/core/constraints.yml"
echo "note" > "${mem_root}/agent/memory/sessions.md"
mem_quote=$(bash "${mem_root}/agent/scripts/acp.memory-scan.sh" 2>&1; echo "EXIT:$?")
assert_contains "${mem_quote}" "file: agent/memory/sessions.md" "relative path with a quote in the root"
assert_contains "${mem_quote}" "EXIT:0" "memory-scan exits 0 with a quote in the root"

print_test_header "B18 — CRLF loader output: overrides and baseline keys still match"
crlf_dir="${FIX_ROOT}/crlf"
mkdir -p "${crlf_dir}/bin"
printf 'import sys\nsys.stdout.buffer.write(b"DISABLED:IG-14\\r\\nSEVERITY:IG-17|LOW\\r\\n")\n' > "${crlf_dir}/loader.py"
crlf_out=$(IG_RULE_OVERRIDE_LOADER="${crlf_dir}/loader.py" bash -c '
  source "$1/agent/scripts/acp.integrity-output.sh"
  ig_load_rule_overrides
  ig_rule_is_disabled IG-14 && echo DISABLED-OK
  [[ "$(ig_rule_severity_override IG-17)" == "LOW" ]] && echo SEVERITY-OK
' _ "${PROJECT_ROOT}" 2>&1)
assert_contains "${crlf_out}" "DISABLED-OK" "disable survives a CRLF line"
assert_contains "${crlf_out}" "SEVERITY-OK" "severity survives a CRLF line"
real_python="$(command -v python3)"
printf '#!/bin/sh\n"%s" "$@" | sed "s/$/\\r/"\n' "${real_python}" > "${crlf_dir}/bin/python3"
chmod +x "${crlf_dir}/bin/python3"
echo '{"entries":[{"rule":"IG-01","file":"a.ts","snippet_hash":"abc"}]}' > "${crlf_dir}/baseline.json"
base_out=$(PATH="${crlf_dir}/bin:${PATH}" IG_BASELINE_FILE="${crlf_dir}/baseline.json" bash -c '
  source "$1/agent/scripts/acp.integrity-output.sh"
  ig_load_baseline
  ig_baseline_contains "IG-01|a.ts|abc" && echo BASELINE-OK
' _ "${PROJECT_ROOT}" 2>&1)
assert_contains "${base_out}" "BASELINE-OK" "baseline key survives a CRLF line"

print_test_header "B19 — bun.lock: IG-31 sees it, IG-32 flags it, IG-29 stays off"
bun_root="${FIX_ROOT}/bun"
mkdir -p "${bun_root}/src"
git -C "${bun_root}" init -q
git -C "${bun_root}" config user.email e2e@example.com
git -C "${bun_root}" config user.name e2e
echo '{"name":"demo","dependencies":{}}' > "${bun_root}/package.json"
echo "import x from 'not-declared';" > "${bun_root}/src/a.ts"
echo "lock 1" > "${bun_root}/bun.lock"
git -C "${bun_root}" add -A
git -C "${bun_root}" commit -qm "T-1: base" --date="2020-01-01T00:00:00"
GIT_COMMITTER_DATE="2020-01-01T00:00:00" git -C "${bun_root}" commit -q --amend --no-edit --date="2020-01-01T00:00:00"
echo '{"name":"demo","version":"1.0.0","dependencies":{}}' > "${bun_root}/package.json"
git -C "${bun_root}" add -A
git -C "${bun_root}" commit -qm "T-2: bump package.json"
echo "lock 2" >> "${bun_root}/bun.lock"
git -C "${bun_root}" add -A
git -C "${bun_root}" commit -qm "chore: touch only the lockfile"
lock_hash="$(git -C "${bun_root}" rev-parse --short=7 HEAD)"
bun_out=$(bash "${PROJECT_ROOT}/agent/scripts/acp.dependency-diff.sh" "${bun_root}" 2>&1; echo "EXIT:$?")
assert_contains "${bun_out}" "${lock_hash}" "IG-32 reports the lockfile-only commit"
assert_not_contains "${bun_out}" "IG-29" "IG-29 stays off without LOCK_FILE"
git -C "${bun_root}" reset -q --hard HEAD~1
GIT_COMMITTER_DATE="2020-01-01T00:00:00" git -C "${bun_root}" log -1 --format=%h >/dev/null
stale_out=$(bash -x "${PROJECT_ROOT}/agent/scripts/acp.dependency-diff.sh" "${bun_root}" 2>&1)
assert_contains "${stale_out}" "lock_ts=" "IG-31 evaluates bun.lock"

print_test_header "B20 — dependency names cannot reach Python source"
dep_root="${FIX_ROOT}/dep"
mkdir -p "${dep_root}"
echo '{"name":"demo","dependencies":{"lodahs":"1.0.0","lod'"'"'sh":"1.0.0"}}' > "${dep_root}/package.json"
echo "{}" > "${dep_root}/package-lock.json"
dep_out=$(bash "${PROJECT_ROOT}/agent/scripts/acp.dependency-diff.sh" "${dep_root}" 2>&1)
assert_contains "${dep_out}" "potential typosquat: lodahs" "ordinary typosquat found"
assert_contains "${dep_out}" "potential typosquat: lod'sh" "a quoted name is checked too"

print_suite_summary
