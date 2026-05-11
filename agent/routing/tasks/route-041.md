---
id: route-041
title: M42 — taxonomy.yml last_updated field + checkStaleness() in acp-validate.ts (ROUTING-003)
task_type: typescript-feature
milestone: M42
complexity: low
executor: deepseek-v4-flash
context_required:
  - agent/routing/taxonomy.yml
  - agent/routing/config.yml
  - scripts/acp-validate.ts
  - agent/reports/audit-015-m41-verification-and-final-audit-assessment.md
files_affected:
  - scripts/acp-validate.ts
tokens_est: 4000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-05-11
completed:
override_reason:
---

## Task Description

Add staleness detection to `acp-validate.ts`. The `taxonomy.yml` file currently has a comment-only date (`# Generated 2026-05-01`) but no parseable YAML field. Route-039 will add the `last_updated:` field — this route adds the validate check that reads it.

**Coordination note**: This route depends on route-039 having already added `last_updated: 2026-05-11` to `taxonomy.yml`'s header block. Implement in order: 036 → 037 → 038 → 039 → 040 → **041**.

## Context

From audit-015 ROUTING-003:
> `taxonomy.yml has no parseable last_updated date field; acp-validate.ts staleness check not implemented. config.yml last_verified was added (route-034) but taxonomy.yml header has comment-only date, no YAML field.`

Route-034 added `last_verified: 2026-05-11` to each model in `config.yml`. The same pattern needs to be applied to `taxonomy.yml` and enforced by validate.

## Acceptance Criteria

### taxonomy.yml header (conditional — may already be done by route-039)
- [ ] Verify `agent/routing/taxonomy.yml` has parseable `last_updated:` field in header block
- [ ] If route-039 already added it: skip this step and note it in implementation
- [ ] If route-039 did not add it: add `last_updated: 2026-05-11` and `version: 1.1.0` to the header

### checkStaleness() in acp-validate.ts
- [ ] Add `checkStaleness()` function to `scripts/acp-validate.ts`
- [ ] **taxonomy.yml staleness check**:
  - Read `last_updated:` from `agent/routing/taxonomy.yml` header
  - Parse as ISO date
  - If more than 90 days ago: print `⚠️ taxonomy.yml: last_updated is [N] days ago — verify task types are current`
  - If field missing: print `⚠️ taxonomy.yml: no last_updated field — staleness unknown`
- [ ] **config.yml model freshness check**:
  - Read each model entry from `agent/routing/config.yml`
  - For each model, read `last_verified:` date
  - If more than 180 days ago: print `⚠️ routing/config.yml: [model-name] last_verified [N] days ago — check pricing/availability`
  - If field missing: print `⚠️ routing/config.yml: [model-name] has no last_verified date`
- [ ] Both checks print summary even when no warnings: `✅ Staleness: taxonomy.yml [N] days old, all models verified within 180 days`
- [ ] `checkStaleness()` returns boolean (false if any warnings triggered — warning-level, not error)
- [ ] Called from no-args validate path (informational output, non-blocking — does not fail validate run)

### Date arithmetic
- [ ] Use `Date.now()` and `new Date(dateString).getTime()` for day calculation
- [ ] Handle invalid date strings gracefully (warn + skip, do not crash)
- [ ] Days calculation: `Math.floor((Date.now() - date.getTime()) / (1000 * 60 * 60 * 24))`

## Implementation Notes

This is a low-complexity route — most of the logic is date arithmetic and file reading. The key constraint is that staleness warnings are informational, not hard failures. The validate run should still exit 0 even if staleness is detected, to avoid blocking CI on routine taxonomy drift.
