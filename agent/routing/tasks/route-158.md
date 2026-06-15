---
id: route-158
title: "M58-004: E2E test + cross-links + version bump 6.13.0 + CHANGELOG"
task_type: e2e-test-write
milestone: M58
complexity: medium
executor: copilot
context_required: [milestones/milestone-58-acp-integrity-v2-semantic-analysis.md, routes 155-157]
files_affected: [e2e/acp.integrity-v2.test.sh, agent/commands/acp.integrity.md, agent/commands/acp.review.md, AGENT.md, CHANGELOG.md, package.yaml, agent/core/identity.yml, agent/progress.yaml, README.md, IP_REGISTER.md]
tokens_est: 8000
created: 2026-06-08
completed: 2026-06-15
---

# Route 158: E2E Test + Release — v2.0 Validation & v6.13.0 Ship

## Objective

Create E2E test suite for Phase 2 semantic analysis, update cross-links, bump version, and finalize release.

## Expected Output

### Files Created
- `e2e/acp.integrity-v2.test.sh` — 10+ assertions

### Files Modified
- Cross-links: `acp.review.md` (already linked), `acp.audit.md`
- Version: `AGENT.md`, `package.yaml`, `agent/core/identity.yml`, `CHANGELOG.md`, `README.md`, `IP_REGISTER.md`
- `agent/progress.yaml` — M58 complete

## E2E Test: 10+ Assertions

### Structural (3)
1. `integrity-rules.md` has Cat 8 rules with confidence columns (not marked DEFERRED)
2. `acp.integrity.md` has "Phase 2" or "Semantic Analysis" section
3. `code-integrity.md` mentions "Phase 2" or "v2.0"

### Behavioral (7+)
4. All Cat 8 rules: no `confidence: HIGH` — max MEDIUM
5. All Cat 9 rules: `confidence: LOW` only
6. All Cat 10 rules: `confidence: LOW` only (except IG-61)
7. No v2.0 rule carries `confidence: HIGH` (excluding IG-61)
8. Self-protection protocol: "do NOT self-halt" or "continue" present for Cat 9
9. `verdict: REQUIRES_HUMAN_REVIEW` present in command doc output format
10. `--phase2` flag documented in arguments

## Version Bump: 6.12.1 → 6.13.0
- Minor bump — significant new feature (Phase 2 semantic analysis)
- CHANGELOG: `## [6.13.0] — 2026-06-08` with `### Added (M58)` section

## Verification

- [ ] E2E test: 10+ assertions pass
- [ ] Cross-links updated
- [ ] Version 6.13.0 across all 8 files
- [ ] CHANGELOG entry (Keep a Changelog format)
- [ ] `acp-validate` + `acp-sync` pass
- [ ] No v2.0 finding carries `confidence: HIGH` (except IG-61)

## User-Observable Acceptance

- `e2e/acp.integrity-v2.test.sh` exits 0
- `/acp-integrity --phase2` is documented
- Version badge shows 6.13.0
