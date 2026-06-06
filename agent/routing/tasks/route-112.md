---
id: route-112
title: "Version bump to 6.9.3 + CHANGELOG + run /acp-validate"
task_type: changelog-update
milestone: M50
complexity: low
executor: copilot
context_required:
  - agent/progress.yaml
  - CHANGELOG.md
  - agent/core/identity.yml
  - AGENTS.md
  - CLAUDE.md
  - .github/copilot-instructions.md
  - README.md
  - IP_REGISTER.md
  - scripts/PRD-MAIN.md
files_affected:
  - agent/progress.yaml
  - CHANGELOG.md
  - agent/core/identity.yml
  - AGENTS.md
  - CLAUDE.md
  - .github/copilot-instructions.md
  - README.md
  - IP_REGISTER.md
  - scripts/PRD-MAIN.md
tokens_est: 200
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-06
completed: 2026-06-06
override_reason:
---

# Route 112: Version Bump to 6.9.3 + CHANGELOG

## Objective

Bump the framework version from 6.9.2 → 6.9.3, update the CHANGELOG, and run `/acp-validate` to ensure all 8 version-bearing files are consistent.

## Context

Per the post-M47/M48 lesson logged 2026-06-04: "3 stale version files found at 6.8.2 — root cause was 8 version-bearing files with zero automated consistency checking." After version bumps, run `/acp-validate` to check all 8 files.

The 8 version-bearing files are:
1. `agent/progress.yaml`
2. `agent/core/identity.yml`
3. `AGENTS.md`
4. `CLAUDE.md`
5. `.github/copilot-instructions.md`
6. `README.md`
7. `CHANGELOG.md`
8. `IP_REGISTER.md`
9. `scripts/PRD-MAIN.md`

## Changes

### 1. Bump version in `agent/progress.yaml`

```yaml
version: 6.9.3
```

### 2. Bump version in `agent/core/identity.yml`

```yaml
version: 6.9.3
```

### 3. Bump version in `AGENTS.md`

Update version header: `v6.9.3`

### 4. Bump version in `CLAUDE.md`

Update version header: `v6.9.3`

### 5. Bump version in `.github/copilot-instructions.md`

Update version header: `v6.9.3`

### 6. Add CHANGELOG entry

Under `## [6.9.3] — UNRELEASED`:

```markdown
## [6.9.3] — UNRELEASED

### New Commands
- `/acp-design-spec` — Generate Application Interface & Data-Flow Design Specifications
  from the live codebase. 19-section template based on arc42, C4 Model, IEEE 1016,
  and ISO 42010. Stack-agnostic with detection tables. Includes output template,
  E2E smoke test, and framework integration (routing.yml, taxonomy.yml).

### Added
- `agent/templates/` directory for output templates
- `agent/templates/design-spec.template.md` — 19-section spec template
- `e2e/acp.design-spec.test.sh` — 12-assertion smoke test
- `routing.yml` command_suggestions for acp-design-spec
- `taxonomy.yml` design-spec task_type
- Cross-links in acp.report.md and acp.design-create.md Related Commands
```

### 7. Run `/acp-validate`

After all version bumps, invoke `/acp-validate` to check consistency across all 8+ version-bearing files. Fix any mismatches.

## Verification

- [ ] All 8 version-bearing files show `6.9.3`
- [ ] CHANGELOG entry under `[6.9.3] — UNRELEASED`
- [ ] `/acp-validate` passes with no version mismatches
- [ ] M50 marked complete in progress.yaml
