---
id: route-149
title: "M56-008: E2E test + cross-links + version bump 6.12.0 + CHANGELOG"
task_type: e2e-test-write
milestone: M56
complexity: medium
executor: copilot
context_required: [milestones/milestone-56-acp-integrity-command.md, routes 147-148, audit-054 NEW-054-04]
files_affected: [e2e/acp.integrity.test.sh, agent/commands/acp.review.md, agent/commands/acp.audit.md, agent/commands/acp.validate.md, agent/commands/acp.commit.md, AGENT.md, CHANGELOG.md, package.yaml, agent/core/identity.yml, agent/progress.yaml, README.md, IP_REGISTER.md, scripts/PRD-MAIN.md, agent/wiki/domain.yml]
tokens_est: 8000
created: 2026-06-07
completed: 2026-06-08
---

# Route 149: E2E Test + Release — Integrity Command Validation & v6.12.0 Ship

## Objective

Create the comprehensive E2E test suite with false-positive baseline, add cross-links, bump version, and finalize the release.

## Expected Output

### Files Created
- `e2e/acp.integrity.test.sh` — 12+ assertions

### Files Modified
- Cross-links: `acp.review.md`, `acp.audit.md`, `acp.validate.md`, `acp.commit.md`
- Version: `AGENT.md`, `package.yaml`, `agent/core/identity.yml`, `CHANGELOG.md`, `README.md`, `IP_REGISTER.md`, `scripts/PRD-MAIN.md`
- `agent/progress.yaml` — M56 complete
- `agent/wiki/domain.yml` — command count update

## E2E Test: 12+ Assertions

### Structural (7 assertions)
1. `acp.integrity.md` exists with Agent Directive
2. `code-integrity.md` skill file exists and ≤500 tokens
3. All 6 bash scripts exist and pass `bash -n`
4. `network_whitelist.yml` exists with valid YAML
5. `identity.yml` has `team_members:` field
6. `integrity-rules.md` wiki exists with 44+ rules
7. Wrapper parity: prompt + opencode for both `acp-integrity` and `acp-rule-file-audit`

### Behavioral (5+ assertions)
8. **Unicode fixture**: Create temp file with U+200D, run `acp.unicode-scan.sh`, assert finding
9. **Entropy fixture**: Create temp file with base64 blob, run `acp.entropy-scan.sh`, assert entropy >4.5
10. **Clean file**: Run `acp.unicode-scan.sh` on known-clean AGENTS.md, assert exit 0
11. **False-positive baseline (CRITICAL)**: Scan ACP codebase — assert zero CRITICAL findings
12. **False-positive baseline (HIGH)**: Scan ACP codebase — assert zero HIGH findings
13. **Manifest verify**: Run `acp.manifest-hash.sh --verify` on clean repo, assert exit 0

### Cross-Links
- `acp.review.md` → "Related: /acp-integrity — verify code trustworthiness after quality review"
- `acp.audit.md` → "/acp-integrity — systematic integrity scan (use when audit finds suspicious patterns)"
- `acp.validate.md` → "/acp-integrity --self — scan ACP framework for Unicode injection"
- `acp.commit.md` → "/acp-integrity --fast — pre-commit integrity scan"

### Version Bump: 6.11.0 → 6.12.0
- Minor bump — new command feature
- Update 8 version-bearing files
- CHANGELOG: `## [6.12.0] — 2026-06-07` with `### Added (M56)` section

## Verification

- [ ] E2E test passes all 12+ assertions
- [ ] False-positive baseline: zero CRITICAL, zero HIGH on clean ACP codebase
- [ ] Unicode fixture test detects hidden character
- [ ] All cross-links added to 4 command docs
- [ ] Version 6.12.0 across all 8 files
- [ ] CHANGELOG entry (Keep a Changelog format)
- [ ] `acp-validate` passes (version consistency)
- [ ] `acp-sync` passes (wrapper parity, domain.yml counts)

## User-Observable Acceptance

- `e2e/acp.integrity.test.sh` exits 0 with all assertions passing
- False-positive baseline test confirms tool doesn't flag clean code
- Version badge shows 6.12.0
