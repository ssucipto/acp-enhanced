---
id: route-054
title: R6 Phase 2+3 — Update Context Protocol for @-Mention Skills
task_type: docs-update
milestone: M44
complexity: low
executor: deepseek-v4-flash
context_required: [.github/copilot-instructions.md, CLAUDE.md]
design_reference: [Skills → @-Mention Pattern](../design/local.skills-at-mention-pattern.md)
files_affected: [.github/copilot-instructions.md, CLAUDE.md]
tokens_est: 2000
created: 2026-06-03
completed: 2026-06-03
depends_on: [route-053]
---

# R6 Phases 2+3: Update Context Protocol

Replace auto-load Step 3 with @-mention documentation. Add @-mention detection.

## Acceptance Criteria

- [ ] Full mode Step 3 replaced with "Skills are Now @-Mention Invoked"
- [ ] "Skills Catalog" reference pointing to `routing.yml → skills_catalog`
- [ ] @-mention detection: agent reads skill file when user types `@{skill-name}`
- [ ] Brief acknowledgement format: `[@commands] Loaded command doc conventions.`
- [ ] CLAUDE.md synced from copilot-instructions.md
