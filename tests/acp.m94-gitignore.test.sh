#!/usr/bin/env bash
# Gitignore syntax for ADR-29 (M94 task-375). CB-2 exact dummies: local.dummy.md
# NEVER local-dummy.md (F-137-03).

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
source "${PROJECT_ROOT}/tests/common.sh"
cd "${PROJECT_ROOT}"

print_suite_header "ADR-29 gitignore CB-2 (M94)"

print_test_header "S1 — PURGE dummies ignored (local.dummy.md, not local-dummy.md)"
mkdir -p agent/patterns/typescript
touch agent/routing/tasks/route-999.md \
  agent/design/local.dummy.md \
  agent/patterns/local.dummy.md \
  agent/patterns/typescript/local.dummy.md

git check-ignore -q agent/routing/tasks/route-999.md
assert_true "route-999.md ignored" $?
git check-ignore -q agent/design/local.dummy.md
assert_true "design/local.dummy.md ignored" $?
git check-ignore -q agent/patterns/local.dummy.md
assert_true "patterns/local.dummy.md ignored" $?
git check-ignore -q agent/patterns/typescript/local.dummy.md
assert_true "nested typescript/local.dummy.md ignored" $?
git check-ignore -q .claude/settings.local.json
assert_true ".claude/settings.local.json ignored" $?
touch agent/specs/local.dummy.md agent/index/local.main.yaml
git check-ignore -q agent/specs/local.dummy.md
assert_true "specs/local.dummy.md ignored" $?
git check-ignore -q agent/index/local.main.yaml
assert_true "index/local.main.yaml ignored" $?

print_test_header "S1b — ADR-31 progress.local.yaml ignored"
touch agent/progress.local.yaml
git check-ignore -q agent/progress.local.yaml
assert_true "progress.local.yaml ignored" $?
rm -f agent/progress.local.yaml

print_test_header "S2 — KEEP files not ignored"
if git check-ignore -q agent/routing/tasks/route-template.md; then
  assert_true "route-template.md must NOT be ignored" 1
else
  assert_true "route-template.md not ignored" 0
fi
if git check-ignore -q agent/design/design.template.md; then
  assert_true "design.template.md must NOT be ignored" 1
else
  assert_true "design.template.md not ignored" 0
fi
if git check-ignore -q agent/design/acp-commands-design.md; then
  assert_true "acp-commands-design.md must NOT be ignored" 1
else
  assert_true "acp-commands-design.md not ignored" 0
fi
if git check-ignore -q agent/index/local.main.template.yaml; then
  assert_true "local.main.template.yaml must NOT be ignored" 1
else
  assert_true "local.main.template.yaml not ignored" 0
fi
if git check-ignore -q agent/specs/spec.template.md; then
  assert_true "spec.template.md must NOT be ignored" 1
else
  assert_true "spec.template.md not ignored" 0
fi

print_test_header "S3 — F-137-03 local-dummy.md must NOT be treated as proof"
touch agent/design/local-dummy.md
if git check-ignore -q agent/design/local-dummy.md; then
  # Hyphen form matching ignore would make CB-2 false-green; must stay unignored
  # unless a broader rule hits it. Fail the suite if hyphen form is ignored
  # while we claim local.* works.
  assert_true "hyphen local-dummy.md should not match local.* (document F-137-03)" 1
else
  assert_true "local-dummy.md does not match local.* (F-137-03)" 0
fi

rm -f agent/routing/tasks/route-999.md \
  agent/design/local.dummy.md \
  agent/patterns/local.dummy.md \
  agent/patterns/typescript/local.dummy.md \
  agent/design/local-dummy.md \
  agent/specs/local.dummy.md

print_test_summary
