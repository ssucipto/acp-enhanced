---
id: task-004
title: Fix e2e test assertions and skill files for /acp-* syntax
task_type: e2e-test-write
milestone: none
complexity: low
executor: deepseek-v4-flash
context_required:
  - memory/patterns.md
  - wiki/domain.yml#test_suites
files_affected:
  # E2E tests with breaking assertions (assert @acp. string in script output)
  - e2e/acp.project-set.test.sh    # line 214: assert_contains "@acp.project-create"
  - e2e/acp.project-list.test.sh   # lines 31,45: assert_contains "@acp.project-create"
  # Skill files (authoritative AI agent instructions — must use current syntax)
  - agent/skills/commands.md
  - agent/skills/testing.md
  - agent/skills/crosscut.md
  # Low-priority sweep (design docs, milestones, remaining scripts, blog)
  - agent/design/*.md               # historical but consistency matters
  - agent/milestones/*.md           # planning history
  - agent/patterns/*.md
  - agent/artifacts/*.template.md
  - agent/specs/*.md
  - agent/scripts/acp.meta-scan.sh
  - agent/scripts/acp.package-create.sh
  - agent/scripts/acp.package-publish.sh
  - agent/scripts/acp.package-validate.sh
  - agent/scripts/acp.project-info.sh
  - agent/scripts/acp.project-list.sh
  - agent/scripts/acp.project-remove.sh
  - agent/scripts/acp.project-set.sh
  - agent/scripts/acp.projects-sync.sh
  - README.md                       # if not already covered by task-001
tokens_est: 5000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-05-03
completed: 2026-05-03
override_reason:
depends_on: task-001  # task-001 changes command file content — these tests must match
---

## Context

After task-001 changes all `@acp.X` → `/acp-X` in command files and scripts, three e2e test
assertions will fail because they assert the OLD syntax in script output:

```
e2e/acp.project-set.test.sh:214
  assert_contains "$output" "@acp.project-create" "Should suggest creating project"

e2e/acp.project-list.test.sh:31
  assert_contains "$output" "@acp.project-create" "Should suggest creating projects"

e2e/acp.project-list.test.sh:45
  assert_contains "$output" "@acp.project-create" "Should suggest creating projects"
```

These assertions check the terminal output of `acp.project-list.sh` and `acp.project-set.sh`
scripts. After task-001 updates those scripts' output from `@acp.project-create` to
`/acp-project-create`, these tests will produce false failures.

Additionally, the skill files (`agent/skills/*.md` → after task-002: `agent/skills/*.md`)
are loaded as authoritative AI agent instructions. They still contain `@acp.*` references
which would give the AI conflicting guidance after task-001 establishes `/acp-*` as canonical.

---

## Breaking Fixes (must complete before running E2E suite after task-001)

Update the three failing assertions:

```bash
# acp.project-list.test.sh — two assertions
sed -i '' 's|"@acp\.project-create"|"/acp-project-create"|g' \
  e2e/acp.project-list.test.sh

# acp.project-set.test.sh — one assertion
sed -i '' 's|"@acp\.project-create"|"/acp-project-create"|g' \
  e2e/acp.project-set.test.sh
```

Verify fix:
```bash
bash e2e/acp.project-list.test.sh
bash e2e/acp.project-set.test.sh
```

---

## Skill Files Update (authoritative AI context — high priority)

The skill files at `agent/skills/` are loaded by AI agents as the authoritative per-domain
instructions. Any `@acp.*` references inside them would cause the AI to output the old syntax.

```bash
for f in agent/skills/*.md; do
  sed -i '' 's|`@acp\.\([a-z-]*\)`|`/acp-\1`|g' "$f"
  sed -i '' 's|@acp\.\([a-z-]*\)|/acp-\1|g' "$f"
done
```

---

## Consistency Sweep (lower priority — no breakage, but confusing for humans)

These files won't cause test failures or wrong AI output, but leave stale syntax in
project documentation. Run as a batch after the breaking fixes:

```bash
# Design docs, milestones, patterns, specs, templates
for f in agent/design/*.md agent/milestones/*.md agent/patterns/*.md \
          agent/artifacts/*.template.md agent/specs/*.md \
          agent/clarifications/*.template.md; do
  [ -f "$f" ] && sed -i '' 's|@acp\.\([a-z-]*\)|/acp-\1|g' "$f"
done

# Remaining scripts (echo/comment refs only — no assertions)
for f in agent/scripts/acp.meta-scan.sh \
          agent/scripts/acp.package-create.sh \
          agent/scripts/acp.package-publish.sh \
          agent/scripts/acp.package-validate.sh \
          agent/scripts/acp.project-info.sh \
          agent/scripts/acp.project-list.sh \
          agent/scripts/acp.project-remove.sh \
          agent/scripts/acp.project-set.sh \
          agent/scripts/acp.projects-sync.sh; do
  sed -i '' 's|@acp\.\([a-z-]*\)|/acp-\1|g' "$f"
done
```

Files intentionally NOT updated:
- `CHANGELOG.md` — historical log, intentionally preserves original syntax as written
- `blog/blog-00001-acp-intro.md` — published blog post, intentionally historical
- `agent/memory/sessions.md`, `agent/memory/lessons.md` — user-created state, do not touch

---

## Final Verification

After all four tasks complete, zero `@acp.` references should remain anywhere except
CHANGELOG.md and blog/ (historical records):

```bash
grep -rn '@acp\.' . \
  --include="*.md" --include="*.sh" --include="*.ts" --include="*.yml" \
  --exclude-dir=.git \
  | grep -v "CHANGELOG.md" \
  | grep -v "^./blog/"
```

Expected output: empty.

---

## Acceptance Criteria

- [ ] `e2e/acp.project-list.test.sh` passes with `/acp-project-create` assertions
- [ ] `e2e/acp.project-set.test.sh` passes with `/acp-project-create` assertion
- [ ] All skill files (`agent/skills/*.md`) use `/acp-*` syntax
- [ ] Full E2E suite passes: `bash run-e2e-tests.sh`
- [ ] Final grep check returns zero `@acp.` refs (excluding CHANGELOG.md and blog/)
