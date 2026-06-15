# Milestone 55: `/acp-review` — Code Review & Standards Enforcement Command

**Milestone**: M55  
**Version Target**: 6.11.0  
**Priority**: medium-high  
**Status**: completed  
**Started**: —  
**Target**: —  
**Estimated Weeks**: 1.5–2
**Estimated Hours**: ~14
**Feedback Source**: feedback-006 (v3.0)
**Audit References**: audit-050 (scope correction), audit-051 (readiness gaps)
**Design Reference**: feedback-006 (self-contained design)  

---

## 1. Goal

Ship the `/acp-review` command as a framework capability that enables ACP adopters to enforce code quality, security, and consistency standards across their codebases. The command targets TypeScript/React/React Native/Expo/Node.js projects — the primary audience for ACP Enhanced.

---

## 2. Deliverables

| # | Deliverable | Description |
|---|-------------|-------------|
| 1 | `agent/commands/acp.review.md` | Command document with embedded 54-rule reference |
| 2 | `agent/skills/code-review.md` | 500-token agent prompt for `@code-review` skill |
| 3 | `agent/specs/code-quality.standards.md` | **MERGED INTO COMMAND DOC** (audit-052 decision). The `acp.review.md` command doc IS the spec — 54 rules with severities, scopes, OWASP mappings, and quality gates are fully self-documenting. A separate spec file would create version drift. See audit-052 GAP-052-06. |
| 4 | `agent/commands/acp.review.md` — Appendix A | ACP self-review rules (SH-01–SH-04, YM-01–YM-03, AP-01–AP-03) |
| 5 | `agent/routing/taxonomy.yml` updates | 4 new task types: code-review-targeted, code-review-full, code-review-security, code-review-ci |
| 6 | `agent/core/routing.yml` updates | Command suggestions for acp-review + cross-references |
| 7 | `e2e/acp.review.test.sh` | Structural E2E (10 assertions) + behavioral smoke test |
| 8 | `agent/wiki/domain.yml` update | New command entry in commands section |
| 9 | Cross-links | AGENTS.md, README, CHANGELOG, acp.audit.md, acp.commit.md |
| 10 | Cursor + OpenCode wrappers | Auto-generated during version update |

---

## 3. Gap Review (from audit-050 + final review)

### G-001: SC-15 (lockfile) — gitignore conflict
**Severity**: MEDIUM  
**Issue**: Rule SC-15 requires `package-lock.json` to be committed. ACP Enhanced itself gitignores `scripts/package-lock.json`. The rule needs a qualifier: "required for `npm ci` reproducible builds; may be gitignored in framework/protocol projects where lockfiles are development-only."  
**Resolution**: Add qualifier to SC-15 in command doc.

### G-002: Language-agnostic coverage gap
**Severity**: LOW  
**Issue**: All 54 rules target TypeScript/Node.js. Projects using Python, Go, Rust get zero relevant rules. This is acceptable for v1.0.0 given the audience, but the command doc should note the TypeScript/JS focus and define a language-detection strategy for future expansion.  
**Resolution**: Add "Language Scope" section to command doc noting TypeScript-first design.

### G-003: Cross-links completeness
**Severity**: LOW  
**Issue**: §5.5 lists 5 cross-link targets but misses `acp.commit.md` (pre-commit hook) and `acp.cost-report.md` (review cost tracking).  
**Resolution**: Add all cross-links during implementation.

### G-004: E2E behavioral test
**Severity**: MEDIUM  
**Issue**: §5.4 proposes structural checks only (files exist, wrappers present). Need at least one behavioral test: create a fixture directory with intentional EH-02 (empty catch block) and SC-01 (hardcoded secret) violations, run `/acp-review` with `--ci`, and verify findings return with correct rule IDs and severities.  
**Resolution**: Add behavioral smoke test to E2E file.

### G-005: CR-02 — Large codebase token overrun
**Severity**: HIGH  
**Issue**: The feedback identifies CR-02 as a HIGH-severity issue. For codebases with >20 files, the agent may exceed context budget. The proposed chunking (10 files/turn for V4 Pro) maps to ACP's existing parallel/orchestrator-workers pattern.  
**Resolution**: Document chunking strategy in skill file. For scope >20 files: category summary first, then per-file HIGH+ findings.

### G-006: OS-01 — OWASP mapping table size
**Severity**: MEDIUM  
**Issue**: CR-09 notes that the OWASP mapping must fit within the 500-token skill file budget. The full mapping (~20 entries) may exceed this.  
**Resolution**: Embed mapping as compact inline references in rule definitions rather than a separate table. Use abbreviated format: `(A10:2025)` inline.

---

## 4. Tasks (Revised: audit-051 — 11 tasks, ~14h)

| Route | Task | Deliverable | Phase | Hours |
|-------|------|-------------|-------|-------|
| 131 | M55-001 | `acp.review.md` (add `--diff` flag) | P0 | 4.5 |
| 132 | M55-002 | `code-review.md` (copilot executor) | P0 | 2 |
| 133 | M55-003 | `code-quality.standards.md` | P0 | 1 |
| 134 | M55-004 | `taxonomy.yml` (4 types + skill catalog) | P1 | 0.75 |
| — | M55-005 | `routing/rules.md` + `routing/config.yml` | P1 | 0.5 |
| 135 | M55-006 | `core/routing.yml` command suggestions | P1 | 0.25 |
| 136 | M55-007 | `acp.review.test.sh` (14 assertions) | P1 | 2.5 |
| 137 | M55-008 | Cross-links (7 files, incl. acp.validate.md) | P2 | 1.25 |
| 138 | M55-009 | Post-audit gaps (G-001–G-006 + feedback loop) | P2 | 1.5 |
| 139 | M55-010 | Version bump 6.11.0 + CHANGELOG | P2 | 0.5 |
| 141 | M55-011 | `package.yaml` entry (F-003) | P1 | 0.25 |

### Phase 1 — Core Command Infrastructure (P0)

#### Route 131 / M55-001: Create command document `acp.review.md`
- **Objective**: Create the full command document following ACP command doc conventions
- **Estimated Hours**: 4.5
- **Output**: `agent/commands/acp.review.md`
- **Contents**:
  - Agent Directive header
  - All 6 arguments + `--diff` flag (audit-051 F-009)
  - Language Scope section (TypeScript-first, extensible — audit-050 G-002)
  - Embedded 54-rule reference (6 category tables)
  - Output format specification
  - Quality gates (8 rules from §2.6)
  - Executor selection guide (§2.7)
  - Verification checklist
  - Related commands section (incl. acp-validate disambiguation)

#### Route 132 / M55-002: Create skill file `code-review.md`
- **Executor**: copilot (was: deepseek-v4-flash — audit-051 F-002: Flash is disqualified by the proposal)
- **Objective**: Create the 500-token `@code-review` agent skill
- **Estimated Hours**: 2
- **Output**: `agent/skills/code-review.md`
- **Contents**:
  - When to load (4 task types)
  - Priority order: CRITICAL → HIGH → MEDIUM → LOW with category mapping
  - Output discipline (chunking strategy for >20 files — audit-051 G-005)
  - Executor notes: qualified (Composer 2.5, V4 Pro, Kimi K2.6, Qwen3) and × disqualified (Flash, Flash-Max) with rationale
  - Carryover integration
  - Scope detection for ACP self-review rules
  - OWASP mapping: compact inline format `(A10:2025 EH-01)` — audit-051 G-006

#### Route 133 / M55-003: Create spec file `code-quality.standards.md`
- **Objective**: Formal R1–R12 testable requirements
- **Estimated Hours**: 1
- **Output**: `agent/specs/code-quality.standards.md`

### Phase 2 — Framework Integration (P1)

#### Route 134 / M55-004: Update `routing/taxonomy.yml`
- **Objective**: Add 4 task types + skill catalog entry (audit-051 F-001)
- **Estimated Hours**: 0.75
- **Output**: Updated `agent/routing/taxonomy.yml`
- **Task types**: code-review-targeted, code-review-full, code-review-security, code-review-ci
- **Skill catalog**: `@{code-review}` → `agent/skills/code-review.md` → triggers: [code-review-targeted, code-review-full, code-review-security, code-review-ci]

#### M55-005: Update `routing/rules.md` and `routing/config.yml`
- **Estimated Hours**: 0.5

#### Route 135 / M55-006: Update `core/routing.yml`
- **Estimated Hours**: 0.25

#### Route 141 / M55-011: Add `package.yaml` entry (NEW — audit-051 F-003)
- **Objective**: Register /acp-review command for installation and discovery
- **Estimated Hours**: 0.25
- **Output**: Updated `package.yaml`
- **Entry**: `name: acp-review`, `description: Standards enforcement for code quality and security`, `directory: commands`

### Phase 3 — E2E Test (P1)

#### Route 136 / M55-007: Create E2E smoke test
- **Estimated Hours**: 2.5
- **Output**: `e2e/acp.review.test.sh`
- **Assertions** (target: 14 — audit-051 F-004, F-011, F-012):
  - Structural (7): command doc, skill file, spec file, Agent Directive, taxonomy entries, wrappers, Flash disqualified in skill file
  - Behavioral (7): EH-02 violation, SC-01 violation, finding format, severity, rule ID, exit code, carryover creation, `--ci` output format `[SEVERITY] file:line ruleID — message`

### Phase 4 — Cross-links & Documentation (P2)

#### Route 137 / M55-008: Cross-link updates
- **Estimated Hours**: 1.25
- **Output**: Updates to AGENTS.md, README.md, CHANGELOG.md, agent/wiki/domain.yml, acp.audit.md, acp.commit.md, acp.validate.md (audit-051 F-006)

#### Route 138 / M55-009: Address post-audit gaps (audit-050 G-001–G-006 + audit-051 findings)
- **Estimated Hours**: 1.5
- **Includes**:
  - SC-15 lockfile gitignore qualifier (G-001)
  - Language Scope section (G-002)
  - Cross-link verification (G-003)
  - Chunking strategy documentation (G-005)
  - OWASP mapping compaction (G-006)
  - `agent/feedback/feedback-006-response.md` documenting audit-driven deviations (audit-051 F-008)

#### Route 139 / M55-010: Version bump + CHANGELOG
- **Estimated Hours**: 0.5
- **CHANGELOG**: Use `### Added` section per Keep a Changelog (audit-051 F-005)

---

## 5. Milestone-Specific Parallel Mitigations (audit-050 F6)

| Risk | Mitigation |
|------|-----------|
| CR-02: Token overrun (>20 files) | Chunk by category, 10 files/turn for V4 Pro, summary-first |
| Rules don't fire on non-TS project | `--scope` flag + language detection note |
| OWASP mapping exceeds skill budget | Compact inline format: `(A10:2025 EH-01)` |
| Self-assessed "fixed" without verification | §2.6 QG8: re-verification required |

---

## 6. Verification Checklist (Revised: audit-051)

- [ ] `acp.review.md` has Agent Directive header
- [ ] `acp.review.md` includes `--diff` and Language Scope sections
- [ ] `code-review.md` ≤ 500 tokens
- [ ] `code-review.md` explicitly disqualifies Flash/Flash-Max (F-012)
- [ ] 4 new task types in taxonomy.yml
- [ ] Skill catalog entry for `@{code-review}` in taxonomy.yml (F-001)
- [ ] `package.yaml` entry for acp-review (F-003)
- [ ] Route-132 executor is copilot (not Flash — F-002)
- [ ] E2E: structural assertions ×7 (incl. Flash disqualified in skill file)
- [ ] E2E: behavioral assertions ×7 (incl. carryover creation, `--ci` format)
- [ ] E2E: test appears in run-e2e-tests.sh test discovery (F-013)
- [ ] All cross-links created (incl. acp.validate.md — F-006)
- [ ] `feedback-006-response.md` documents audit-driven deviations (F-008)
- [ ] G-001 through G-006 resolved
- [ ] Version bumped to 6.11.0
- [ ] CHANGELOG uses `### Added` format (F-005)
- [ ] Cursor/OpenCode wrappers generated
