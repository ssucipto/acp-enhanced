# Audit Report: M55 `/acp-review` — Milestone & Task Readiness Audit

**Audit**: #051  
**Date**: 2026-06-07  
**Subject**: Deep audit of M55 milestone definition, 10 routes, gap review, and alignment with industry best practices  
**Source Documents**: feedback-006 v3.0, milestone-55, routes-131–140, audit-050, ACP taxonomy/routing/identity files  

---

## Summary

M55 is well-scoped and correctly positioned as a framework capability for ACP's TypeScript/React/mobile audience. The 10-route structure follows established ACP patterns and the gap review from audit-050 caught the critical scope error. However, this audit found **13 new findings** — 1 critical (missing skill catalog entry), 4 high (executor misassignment, missing package.yaml entry, E2E gap, CHANGELOG format), and 8 medium/low (cross-link omissions, verification gaps, best-practice refinements).

**Readiness verdict**: PROCEED WITH REVISIONS — the 13 findings should be addressed before implementation begins. None are blockers; all have clear resolutions.

---

## Files Analyzed

| File | Type | Relevance |
|------|------|-----------|
| `agent/milestones/milestone-55-acp-review-command.md` | milestone | Primary planning document |
| `agent/routing/tasks/route-131.md` through `route-140.md` | route | 10 implementation tasks |
| `agent/feedback/feedback-006-acp-review-command-upstream-v3.md` | feedback | Source proposal |
| `agent/reports/audit-050-feedback-006-review-command-scope-analysis.md` | audit | Prior scope audit |
| `agent/routing/taxonomy.yml` | config | Task type definitions — integration target |
| `agent/core/routing.yml` | config | Command suggestions — integration target |
| `agent/core/identity.yml` | core | Project identity and stack |
| `AGENTS.md` | protocol | Context loading — cross-link target |
| `package.yaml` | package | ACP package manifest — missing `/acp-review` entry |
| `agent/skills/` existing files | skill | Reference for code-review.md format |

---

## Key Findings

### F-001: CRITICAL — Skill catalog entry missing from taxonomy planning
**Location**: route-134 + route-132  
**Severity**: CRITICAL  

The milestone and route-134 plan to add 4 task types to `taxonomy.yml` but do **not** plan to add `code-review` to the `skills_catalog` section. The `skills_catalog` maps skill names to their @-mention triggers, file paths, and task type triggers. Without this entry:

1. `@{code-review}` won't be recognized as a valid @-mention
2. The skill won't be auto-loaded for any task type
3. `acp-dispatch.ts` won't know about the skill

**Resolution**: Add to route-134: "Add `code-review` to `skills_catalog` with mention: `@{code-review}`, file: `agent/skills/code-review.md`, triggers: `[code-review-targeted, code-review-full, code-review-security, code-review-ci]`."

### F-002: HIGH — Route 132 executor mismatch
**Location**: route-132  
**Severity**: HIGH  

Route 132 (skill file) is assigned `executor: deepseek-v4-flash` and `task_type: command-doc-write`. But:
- The taxonomy maps `command-doc-write` → `executor: deepseek-v4-pro`, not flash
- The feedback-006 explicitly **disqualifies** Flash for this skill: "Flash / Flash-Max: DO NOT USE for this skill — disqualified"
- The skill file contains rationale for WHY Flash is disqualified — using Flash to write it creates a self-referential paradox

**Resolution**: Change route-132 executor to `copilot` (matches ACP conventions for cross-cutting/scoping tasks) or `deepseek-v4-pro`. The route describes creating a skill FILE, which is a design/writing task better suited to a higher-capability executor.

### F-003: HIGH — Missing `package.yaml` entry for new command
**Location**: Missing from all routes and milestone  
**Severity**: HIGH  

ACP uses `package.yaml` to declare commands for installation and discovery. Every command shipped in ACP must have a `package.yaml` entry with `name`, `description`, and `directory`. The existing commands (acp.audit, acp.design-spec, acp.stakeholder-report) all have entries. `/acp-review` does not have a planned entry.

A missing package.yaml entry means:
- `/acp-package-install` won't discover the command
- `/acp-package-validate` won't verify it
- Users can't install the command as a standalone package

**Resolution**: Add Task M55-011 (or fold into route-131): "Add `/acp-review` entry to `package.yaml` with command metadata, script dependencies (none), and experimental: false."

### F-004: HIGH — E2E test only covers structural + behavioral but not carryover integration
**Location**: route-136  
**Severity**: HIGH  

Route-136 plans 12 assertions (6 structural + 6 behavioral). The behavioral assertions cover rule detection and CI mode, but do **not** cover the `--carryover` flag, which is the most operationally impactful feature — it bridges the review to ACP's existing `audit-carryovers.md` system. Without testing this path, carryover integration could silently break.

**Resolution**: Add assertion 13: "Run `/acp-review --carryover` on fixture with SC-01 violation, verify finding appears in `agent/memory/audit-carryovers.md` with correct finding_id and severity."

### F-005: HIGH — CHANGELOG format mismatch
**Location**: route-139  
**Severity**: MEDIUM (elevated to HIGH per audit practice)  

The CHANGELOG follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) format. Route-139 says "Add CHANGELOG entry for: New Commands, New Skills, New Specs" but ACP's CHANGELOG uses categories: `Added`, `Changed`, `Deprecated`, `Removed`, `Fixed`, `Security`. The task should specify which category each deliverable maps to.

**Resolution**: Update route-139: specify CHANGELOG entries under `### Added` for: command, skill, spec, taxonomy types, OR under project-specific categories like `### New Commands`, `### New Skills`, `### New Specs` if those custom headers are already used in the project's CHANGELOG.

### F-006: MEDIUM — Missing cross-link target: `acp.validate.md`
**Location**: route-137  
**Severity**: MEDIUM  

The `/acp-review` command validates code against standards. The `/acp-validate` command validates ACP structure against schemas. These are semantically related ("review" vs "validate") and users will confuse them. A cross-reference in `acp.validate.md` explaining the difference is needed.

**Resolution**: Add `agent/commands/acp.validate.md` to route-137 cross-link targets with a disambiguation note: "`/acp-validate` checks ACP framework structure (schemas, sessions, versions). `/acp-review` checks user project code against quality/security standards."

### F-007: MEDIUM — Missing cross-link target: `acp.repair-tools.test.sh`
**Location**: route-137  
**Severity**: MEDIUM  

The `e2e/acp.repair-tools.test.sh` validates ACP's repair tools. If `/acp-review` creates carryovers, the user might want to run repair tools to resolve them. A cross-reference in the repair tools section is appropriate.

**Resolution**: Add to route-137 OR add to command doc's Related section: `acp-repair-tools — resolve carryover findings from reviews`.

### F-008: MEDIUM — No feedback loop to feedback-006 author
**Location**: milestone, route-138  
**Severity**: MEDIUM  

The audit-050 findings (F1: scope correction, F3: self-review appendix) represent material changes to the original proposal. The feedback-006 author should be notified of these deviations. ACP has `agent/feedback/` but no mechanism for "response to feedback."

**Resolution**: Add to route-138 or create task M55-012: "Add `feedback-006-response.md` to agent/feedback/ documenting how audit-050 modified the proposal (full ruleset ships + self-review appendix added)." This closes the feedback loop.

### F-009: MEDIUM — No `--diff` or `--since` flag for incremental reviews
**Location**: Missing from command design  
**Severity**: MEDIUM  

The proposal includes `--baseline` for diffing against previous review reports, but no `--diff` or `--since <commit>` flag for reviewing only changed files (git diff). This is a standard CI feature — most linters and reviewers (ESLint, SonarQube, CodeQL) support reviewing only changed files to reduce noise and cost.

**Resolution**: Add to route-131 command design: optional `--diff` flag that limits review scope to files changed since last commit or named ref. Can use `git diff --name-only HEAD~1` to determine scope.

### F-010: LOW — Route numbering skips 132 vs milestone task numbering mismatch
**Location**: routes vs milestone  
**Severity**: LOW  

The milestone uses task IDs M55-001 through M55-010. The routes use route-131 through route-140. There's no mapping table between them. During implementation, agents might confuse route IDs with milestone task IDs.

**Resolution**: Add a mapping column to the milestone's §4 Tasks table: `Route | Task | Deliverable`. Example: `131 | M55-001 | acp.review.md`.

### F-011: LOW — No severity-report flag for CI output parsing
**Location**: route-136 (E2E)  
**Severity**: LOW  

The `--ci` flag produces compact output, but the E2E test doesn't verify the exact output format (machine-parseable). For CI integration (GitHub Actions annotations, CodeClimate format), a defined output schema per severity is valuable.

**Resolution**: Add to route-136: "Verify `--ci` output format matches `[SEVERITY] file:line ruleID — message` (per CR-04)."

### F-012: LOW — Missing `assert_contains` test for disqualified executors in skill file
**Location**: route-136 (E2E), route-132  
**Severity**: LOW  

The skill file must explicitly disqualify Flash and Flash-Max (§2.7). The E2E test should verify the disqualification text exists in the skill file so it doesn't accidentally get omitted during compression.

**Resolution**: Add structural assertion to route-136 (now assertion 14): `assert_contains "agent/skills/code-review.md" "Flash" "Disqualifies Flash executor"`.

### F-013: LOW — Verification checklist missing E2E integration test
**Location**: milestone §6  
**Severity**: LOW  

The verification checklist has 10 items but misses: "E2E test integrated into run-e2e-tests.sh (test appears in 44-test suite)." The test file will be created but needs to be discoverable by the test runner.

**Resolution**: Add verification item: "`acp.review.test.sh` appears in `run-e2e-tests.sh` test discovery (listed in CI output)."

---

## Key Decisions

1. **Full ruleset ships** — audit-050 confirmed the v3 ruleset targets the right audience (TypeScript/React/mobile developers adopting ACP for their projects)
2. **Self-review appendix added** — ACP's own bash/YAML/MD standards are an appendix, not the main ruleset
3. **Flash remains disqualified** — the rationale in feedback-006 §2.7 is sound; route-132 executor must be upgraded

---

## Readiness Verdict

| Category | Count | Highest Severity |
|----------|-------|-----------------|
| CRITICAL | 1 | F-001: Missing skill catalog entry |
| HIGH | 4 | F-002: Executor mismatch, F-003: Missing package.yaml, F-004: Carryover E2E gap, F-005: CHANGELOG format |
| MEDIUM | 5 | F-006–F-008, F-009 (--diff flag) |
| LOW | 3 | F-010–F-013 |
| **Total** | **13** | |

**VERDICT**: PROCEED WITH REVISIONS. Address all 5 CRITICAL+HIGH findings before starting implementation. The remaining 8 MEDIUM+LOW findings can be addressed during implementation without blocking.

---

## Revised Task Count

| Route | Task | Deliverable | Hours | Change |
|-------|------|-------------|-------|--------|
| 131 | M55-001 | acp.review.md (add `--diff` flag F-009) | 4 | +0.5h |
| 132 | M55-002 | code-review.md (executor → copilot F-002) | 2 | — |
| 133 | M55-003 | code-quality.standards.md | 1 | — |
| 134 | M55-004 | taxonomy (add skill catalog F-001) | 0.5 | +0.25h |
| 135 | M55-005 | routing command suggestions | 0.25 | — |
| 136 | M55-006 | E2E (add carryover + disqualified + CI format F-004/F-011/F-012) | 2.5 | +0.5h |
| 137 | M55-007 | Cross-links (add acp.validate.md F-006) | 1 | +0.25h |
| 138 | M55-008 | Post-audit gaps (add feedback response F-008) | 1.5 | +0.5h |
| 139 | M55-009 | Version bump + CHANGELOG (format fix F-005) | 0.5 | — |
| 140 | M55-010 | Self-review appendix + mobile | 0.5 | — |
| **NEW** | M55-011 | `package.yaml` entry (F-003) | 0.25 | new |
| **Total** | **11 tasks** | | **~14h** | (+2.25h) |
