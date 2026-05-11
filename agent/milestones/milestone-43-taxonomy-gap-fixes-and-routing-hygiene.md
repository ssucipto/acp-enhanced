<!-- @acp.meta.milestone
id: M43
title: Taxonomy Gap Fixes + Routing Hygiene
status: not-started
tasks: route-043, route-044, route-045
completed:
version_introduced: 6.8.1
feedback_source: null
audit_source: agent/reports/audit-017-taxonomy-improvement-suggestions.md
@acp.meta.end -->

# Milestone 43: Taxonomy Gap Fixes + Routing Hygiene

**Status**: Not Started  
**Target Version**: 6.8.0 → 6.8.1  
**Audit**: [audit-017](../reports/audit-017-taxonomy-improvement-suggestions.md)  
**Estimated Duration**: 1–2 hours  

---

## Overview

Resolves 3 findings from audit-017 (taxonomy improvement suggestions review):

1. **GAP-001** (High): `shell-scripting` task type is used in route-005 and route-011 but absent from `taxonomy.yml` — `acp-dispatch.ts` falls back to `claude-sonnet` (most expensive model) for these routes.
2. **R2** (Low): `ledger.md` has no documentation explaining why `executor: copilot` rows always have blank token/cost data — confusing when reviewing cost reports.
3. **R3 + OBS-001** (Low): `routing/rules.md` has no guidance on when to use `command-doc-write` vs `command-doc-update` for large section additions. Also, `checkStaleness()` in `acp-validate.ts` runs before the blocking checks, mixing informational output with validation errors.

All work is small: one YAML entry, two comment/doc additions, one function reorder. No new command docs. Patch version bump only.

---

## Route Plan

| Route | Finding(s) | Severity | Type | Est. Hours |
|-------|-----------|---------|------|-----------|
| route-043 | GAP-001 | HIGH | yaml-schema | 0.5h |
| route-044 | R2 | LOW | documentation-sync | 0.25h |
| route-045 | R3 + OBS-001 | LOW | yaml-schema + typescript-feature | 0.5h |

**Total estimate**: ~1.25 hours across 3 routes

---

## Deliverables

- [ ] `taxonomy.yml` — `shell-scripting` entry added (deepseek-v4-flash, tokens_est 4000)
- [ ] `agent/routing/ledger.md` — comment header note for copilot executor blank rows
- [ ] `agent/routing/rules.md` — guidance on command-doc-write vs command-doc-update threshold
- [ ] `scripts/acp-validate.ts` — `checkStaleness()` moved after blocking checks in no-args path
- [ ] `agent/core/identity.yml`, `package.yaml`, `AGENT.md` — version bumped to 6.8.1
- [ ] `CHANGELOG.md` — [6.8.1] entry

---

## Verification

- [ ] `grep "shell-scripting" agent/routing/taxonomy.yml` returns an entry
- [ ] `acp-dispatch.ts` MODEL_MAP lookup for `shell-scripting` resolves to `deepseek-v4-flash` executor (via taxonomy)
- [ ] `ledger.md` header includes copilot note
- [ ] `rules.md` includes command-doc threshold rule
- [ ] `acp-validate.ts` no-args path: staleness output appears after size guard and sessions check output
- [ ] `npx ts-node scripts/acp-validate.ts` exits 0 (or same exit code as before)
- [ ] Version 6.8.1 consistent across identity.yml, package.yaml, AGENT.md
