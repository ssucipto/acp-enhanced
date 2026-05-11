---
id: route-030
title: M41b — Add QUICKSTART.md link to root README (GAP-002)
task_type: documentation-sync
milestone: M41
complexity: low
executor: deepseek-v4-flash
context_required:
  - README.md
  - scripts/QUICKSTART.md
files_affected:
  - README.md
tokens_est: 3000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-05-11
completed:
override_reason:
---

## Task Description

Add a prominent link to `scripts/QUICKSTART.md` in the root `README.md`. Currently the 6-step setup guide (with 3–4 hour time estimates) is buried in `scripts/` and not reachable from the README entry point. New users attempting setup from the README will not find it and will attempt to reverse-engineer from `AGENT.md` (90K bytes, not designed for onboarding). Closes GAP-002 from audit-014.

## Acceptance Criteria

- [ ] README hero section (near the top, before or after project description) contains a prominent link:
  ```
  → **New user?** See [scripts/QUICKSTART.md](scripts/QUICKSTART.md) — full setup in 3–4 hours.
  ```
- [ ] Link appears in the Install section or existing Quick Start section header
- [ ] The link uses a relative path (works on GitHub without absolute URLs)
- [ ] The existing "Quick Start" sections in README (lines 473, 910) also reference `scripts/QUICKSTART.md` if they don't already

## Implementation Notes

Read the current README Quick Start section (around line 473) before editing. The link should be additive — do not remove existing content. Place it where a new user's eyes will land first.
