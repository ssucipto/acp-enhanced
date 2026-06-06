---
id: route-130
title: "Version bump to 6.10.0 + CHANGELOG + sync docs for M53"
task_type: changelog-update
milestone: M53
complexity: low
executor: copilot
context_required:
  - agent/progress.yaml
  - CHANGELOG.md
  - agent/core/identity.yml
  - AGENTS.md
  - README.md
  - IP_REGISTER.md
  - scripts/PRD-MAIN.md
  - package.yaml
files_affected:
  - agent/progress.yaml
  - CHANGELOG.md
  - agent/core/identity.yml
  - AGENTS.md
  - README.md
  - IP_REGISTER.md
  - scripts/PRD-MAIN.md
  - package.yaml
tokens_est: 200
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-06
completed: 2026-06-07
override_reason:
---

# Route 130: Version Bump 6.9.5 → 6.10.0 + CHANGELOG

## Objective

Bump version to 6.10.0 (minor bump — new IDE integration feature), update CHANGELOG, sync all docs.

## Context

M53 adds Cursor IDE slash-command parity — a new integration feature. Per semver, new backwards-compatible functionality warrants a minor version bump: 6.9.5 → 6.10.0. Also fixes a pre-existing `@acp.` bug in `acp.visualize.md`.

## Changes

### 1. Version-bearing files

Bump `6.9.5` → `6.10.0` in all 8 version-bearing files.

### 2. CHANGELOG entry

```markdown
## [6.10.0] — 2026-06-06

### Added (M53 — Cursor Slash Commands Bootstrap)
- **Cursor IDE slash-command parity**: `/acp-*` commands now available as native Cursor slash commands via `.cursor/commands/` auto-generation
- `agent/scripts/acp.cursor-commands-sync.sh` — generates Cursor wrappers from `agent/commands/` sources
- Hooked into `acp.install.sh` and `acp.version-update.sh` for automatic regeneration
- Bootstrap step 6b generates `.cursor/commands/` alongside `.opencode/commands/`
- Post-install verification checks `.cursor/commands/` file count parity
- `agent/wiki/cursor-integration.md` — Cursor integration guide
- `e2e/acp.cursor-commands-sync.test.sh` — 10-assertion test (naming, parity, content)

### Fixed
- Pre-existing `@acp.` occurrences in `acp.visualize.md` replaced with `/acp-` (CARRY-047-01)
- Command-docs E2E test now 466/466 (was 465/466 with 1 `@acp.` failure)
```

### 3. IP_REGISTER + PRD-MAIN update

Add M53 entry to milestone register and PRD milestone count.

## Verification

- [ ] All 8 version-bearing files show `6.10.0`
- [ ] CHANGELOG `[6.10.0]` entry complete
- [ ] IP_REGISTER M53 entry added
- [ ] PRD-MAIN milestone count updated
- [ ] `/acp-validate` version consistency check passes
- [ ] M53 marked complete in progress.yaml
