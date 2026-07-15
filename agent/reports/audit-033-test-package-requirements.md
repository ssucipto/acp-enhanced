# Audit Report: Test Package Requirements Analysis

**Audit**: #033  
**Date**: 2026-06-03  
**Subject**: Comprehensive test strategy for ACP Enhanced — functional, regression, security, cross-platform, and accountability testing

## Current Test Coverage

| Layer | Files | Assertions | Covers |
|-------|:-----:|:----------:|--------|
| E2E tests | 31 | ~523 | Package commands, project registry, preferences, sessions, YAML parser |
| Unit tests | 7 | ~160 | YAML parser, preferences, project registry, validate.ts |
| **Total** | **38** | **~683** | |

### Coverage Gaps (v6.8.2 features)

| Feature | Tests? | Risk |
|---------|:------:|------|
| Light-mode protocol | ❌ | High — core UX change, agents must load correct files |
| @-mention skills catalog | ❌ | Medium — taxonomy.yml format changed |
| Parallel task schema | ❌ | Medium — DAG validation could break dispatch |
| Command discoverability | ❌ | Low — YAML config only, no runtime logic |
| Auto-populate lessons | ❌ | High — commit protocol change, data integrity |
| Observability section | ❌ | Medium — new schema in progress.yaml |
| Bootstrap flags (--team-size) | ❌ | High — affects every new install |
| Sessions.md compaction | ❌ | Low — edge case (>15 entries) |
| Cross-platform (macOS/Linux/WSL) | 🟡 Partial | Medium — no CI verification |

## Test Package Requirements

### Tier 1 — Functional Correctness (P0)

Ensures every feature works as documented. These are the "does it do what it says" tests.

**Test area: Light-mode protocol**
| Test | What it verifies | Type |
|------|-----------------|:----:|
| `test_light_mode_loads_correct_files` | Agent reads identity + progress + sessions only | Protocol |
| `test_full_mode_loads_all_6_steps` | Agent reads core + taxonomy + skill + memory + reference | Protocol |
| `test_current_mode_tracks_in_routing_yml` | context_modes.current is set after loading | Protocol |
| `test_full_recommended_for_architecture_tasks` | recommend_full_for list triggers suggestion | Protocol |
| `test_light_recommended_for_bug_fixes` | recommend_light_for list triggers suggestion | Protocol |

**Test area: @-mention skills**
| Test | What it verifies | Type |
|------|-----------------|:----:|
| `test_skills_catalog_has_7_entries` | All 7 skills mapped | Schema |
| `test_each_skill_has_unique_mention` | No duplicate @{name} values | Schema |
| `test_each_mention_maps_to_existing_file` | agent/skills/{name}.md exists | File existence |
| `test_task_type_has_valid_mention_ref` | Every task_type.mention references a catalog entry | Schema |

**Test area: Parallel task schema**
| Test | What it verifies | Type |
|------|-----------------|:----:|
| `test_parallel_task_type_in_taxonomy` | task_type: parallel exists | Schema |
| `test_sub_task_schema_valid` | task.schema.yaml validates required fields | Schema |
| `test_circular_dependency_detected` | A→B→A raises validation error | Validation |
| `test_orchestrator_workers_type_exists` | task_type: orchestrator-workers exists | Schema |

**Test area: Bootstrap**
| Test | What it verifies | Type |
|------|-----------------|:----:|
| `test_team_size_solo_creates_30_files` | solo generates ~30 files | File count |
| `test_team_size_small_creates_80_files` | small generates ~80 files | File count |
| `test_team_size_team_creates_310_files` | team generates ~310 files | File count |
| `test_generate_prompts_flag` | --generate-prompts creates .github/prompts/ | File existence |
| `test_scaffold_config_read_from_manifest` | Manifest overrides are respected | Config |

**Test area: Observability**
| Test | What it verifies | Type |
|------|-----------------|:----:|
| `test_observability_section_exists` | progress.yaml has observability: block | Schema |
| `test_observability_has_this_week` | this_week fields populated | Schema |

**Test area: Common.yaml-parser**
| Test | What it verifies | Type |
|------|-----------------|:----:|
| All 89 existing parser tests | Parser handles all YAML edge cases | Already passing ✅ |

### Tier 2 — Regression Prevention (P1)

Ensures new changes don't break existing functionality. These are "does it still work" tests.

| Test area | How to verify | Frequency |
|-----------|---------------|:---------:|
| All 31 existing E2E tests | `bash run-e2e-tests.sh` | Every commit |
| Package install → list → info → remove cycle | Full lifecycle E2E | Every release |
| Preferences get → set → validate → preset cycle | Preferences E2E | Every release |
| YAML parser version bump backwards compat | Parse old format files | Every release |
| Project registry create → set → update → remove | Registry E2E | Every release |

### Tier 3 — Cross-Platform Compatibility (P1)

Ensures the system works across all target environments.

| Platform | Shell | CI | Risk |
|----------|-------|:--:|------|
| macOS (default /bin/bash 3.2) | bash 3.2 | GitHub Actions (macos-latest) | BSD sed, date +%N |
| Linux (Ubuntu) | bash 4+ | GitHub Actions (ubuntu-latest) | GNU sed, date +%N |
| Windows (WSL2) | bash 4+ | Manual | Path separators, CRLF |

**Critical platform-specific checks:**
- `sed -i` → portable sed+mv pattern (macOS vs GNU)
- `date +%N` → nanosecond compatibility (absent on macOS)
- `tput` → color output (absent in some CI)
- Shebang → `#!/usr/bin/env bash` vs `#!/bin/bash` (path differences)

### Tier 4 — Security Audit (P2)

Ensures the protocol doesn't introduce vulnerabilities. ACP Enhanced is a documentation/scripting framework — surface area is minimal.

| Risk | Check | Mitigation |
|------|-------|-----------|
| Path traversal in package install | Resolves relative paths correctly | ✅ Already handled (rejects `../` targets) |
| Command injection in YAML parser | Parser doesn't eval input | ✅ Pure AST-based, no eval |
| Manifest tampering | Checksum verification | ✅ Checksum comparison on update |
| Source URL spoofing | Clones from declared URLs only | ✅ `source:` field in manifest |
| Sensitive data in memory files | logs, sessions, lessons are gitignored | ✅ agent/.gitignore covers reports/ |

### Tier 5 — User Accountability (P2)

Ensures the system delivers what it promises. These are behavioral tests.

| Check | What it verifies |
|-------|-----------------|
| All 63 commands have a Purpose: field | Every command doc is self-documenting |
| All 48 M1-M44 milestones complete | No milestone marked in_progress = 0% |
| CHANGELOG matches progress.yaml versions | Version history is consistent |
| route-NNN.md files match their milestone | Task IDs reference real milestones |
| M44 routes 047-059 have completed: dates | All implemented tasks stamped |

## Build Priority

| Phase | Scope | Est. Effort | Files |
|:-----:|-------|:-----------:|-------|
| **Phase 1** | P0 functional tests (30+ tests) | 4-6 hours | `tests/acp.light-mode.test.sh`, `tests/acp.at-mention.test.sh`, `tests/acp.parallel.test.sh`, `tests/acp.bootstrap-flags.test.sh`, `tests/acp.observability.test.sh` |
| **Phase 2** | Regression + cross-platform hardening | 2-3 hours | CI workflow update, platform fixes |
| **Phase 3** | Security + accountability | 1-2 hours | `tests/acp.security.test.sh`, `tests/acp.accountability.test.sh` |

## Test Framework

Reuse existing `tests/common.sh` patterns. All new tests follow:
- Test file: `tests/acp.{feature}.test.sh`
- Setup: `setUp` function with fixture directory
- Assertions: `assert_equals`, `assert_contains`, `assert_file_exists` from common.sh
- Runner: Automatically discovered by `run-e2e-tests.sh`
- CI: GitHub Actions matrix on push to mainline
