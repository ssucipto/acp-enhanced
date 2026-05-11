---
id: route-034
title: M41b — Add last_verified dates to routing/config.yml (OBS-002)
task_type: yaml-schema
milestone: M41
complexity: low
executor: deepseek-v4-flash
context_required:
  - agent/routing/config.yml
files_affected:
  - agent/routing/config.yml
tokens_est: 3000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-05-11
completed:
override_reason:
---

## Task Description

Add `last_verified: 2026-05-11` to each model entry in `agent/routing/config.yml`. DeepSeek pricing changes frequently and the file currently has no freshness indicator, meaning stale prices can silently inflate cost estimates. Closes OBS-002 from audit-014.

## Acceptance Criteria

- [ ] Each model entry (`claude-sonnet`, `deepseek-v4-flash`, `deepseek-v4-pro`, `gemini-flash`, and any others) gains a `last_verified: 2026-05-11` field
- [ ] Comment added at top of `config.yml` or in each model entry: `# Update last_verified whenever prices are checked against provider pricing pages`
- [ ] Prices themselves are NOT changed (this task is adding the field only; price verification is a separate concern)
- [ ] YAML remains valid after edits

## Implementation Notes

Read the full `agent/routing/config.yml` before editing to see all model entries and their current structure. Place `last_verified:` immediately after `cost_output_per_1m:` in each entry for consistent ordering.
