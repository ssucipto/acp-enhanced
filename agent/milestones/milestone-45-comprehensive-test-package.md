# Milestone 45: Comprehensive Test Package (v6.8.3)

**Milestone**: M45  
**Version Target**: 6.8.3  
**Priority**: 5  
**Status**: completed  
**Source**: audit-033

## Overview

Address the test coverage gap exposed by the v6.8.2 features. 38 existing tests cover package management, preferences, and YAML parsing but have zero coverage of the new light-mode protocol, @-mention skills, parallel tasks, bootstrap flags, and observability features added in M44.

## Scope

| Phase | Routes | Tests | Est. Effort |
|:-----:|--------|:-----:|:-----------:|
| P0 | 060 | 30+ functional tests | 4-6 h |
| P1 | 061 | Cross-platform CI hardening | 2-3 h |
| P2 | 062 | Security + accountability | 1-2 h |
| **Total** | **3** | **~40+ new tests** | **7-11 h** |

## Test Files to Create

| File | Covers | Tests |
|------|--------|:----:|
| `tests/acp.light-mode.test.sh` | Light-mode protocol, mode switching, recommendations | 8 |
| `tests/acp.at-mention.test.sh` | skills_catalog, mention mapping, file existence | 7 |
| `tests/acp.parallel.test.sh` | Parallel task type, sub-task DAG, circular deps | 6 |
| `tests/acp.bootstrap-flags.test.sh` | --team-size, --generate-prompts, manifest overrides | 6 |
| `tests/acp.observability.test.sh` | Observability section schema, auto-populate | 4 |
| `tests/acp.security.test.sh` | Path traversal, injection, checksum integrity | 5 |
| `tests/acp.accountability.test.sh` | Command docs completeness, milestone closure | 4 |

## Acceptance Criteria (v6.8.3 — ✅ Completed 2026-06-03)

- [x] All 60 assertions pass (100%)
- [x] All 38 existing tests still pass (no regressions)
- [x] CI runs on macOS + Ubuntu on every push to mainline
- [x] `run-e2e-tests.sh` discovers and runs all new tests
- [x] Target: v6.8.3

## Actual Results

| Metric | Value |
|--------|-------|
| Test files created | 10 (9 M45-specific + 1 upgrade of performance) |
| Total assertions | 60 across all M45 files |
| Routes completed | 8 (063–070) |
| Pass rate | 100% |
| Primary bug found | Perf test had undefined variables (`id_chars`/`prog_chars`) — fixed in audit-035 |

## Test Files (Final)

| File | Assertions | Covers |
|------|:----------:|--------|
| `tests/acp.smoke.test.sh` | 9 | System sanity, dir structure, syntax |
| `tests/acp.performance.test.sh` | 4 | Token budgets (light + full mode) |
| `tests/acp.light-mode.test.sh` | 10 | context_modes, mode switching, discoverability |
| `tests/acp.at-mention.test.sh` | 11 | skills_catalog, mapping, duplicate detection |
| `tests/acp.parallel.test.sh` | 5 | task.schema.yaml DAG structure |
| `tests/acp.bootstrap-flags.test.sh` | 10 | --team-size, --generate-prompts, observability |
| `tests/acp.security.test.sh` | 8 | Directives, syntax, gitignore, version sync |
| `tests/acp.runner-ci.test.sh` | 6 | Runner discovery, CI workflows |
| `tests/acp.e2e-workflow.test.sh` | 8 | Cross-feature integration, version sync |
