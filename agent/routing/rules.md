# Routing Rules — Human-readable complement to taxonomy.yml
# AI reads this when taxonomy.yml match is ambiguous

## Priority Order (when task spans multiple domains)
1. Task touches architecture or requires reasoning about the whole system → claude-sonnet
2. Task creates a NEW bash script from scratch (complex logic) → deepseek-v4-pro
3. Task creates a NEW command doc (complex directive writing) → deepseek-v4-pro
4. Task fixes or updates existing bash/command/TS → deepseek-v4-flash
5. Task only writes/updates tests → deepseek-v4-flash
6. Task runs tests locally → local-script
7. Default → deepseek-v4-pro

## Code Review Priority (v6.11.0, M55)
When routing a code review task:
1. Full-project review with all 54 rules + OWASP + MASVS → code-review-full (copilot)
2. Security-only review (--rules security) → code-review-security (copilot)
3. Targeted review with --rules flag (1-2 categories) → code-review-targeted (deepseek-v4-pro)
4. CI pipeline review with --ci flag → code-review-ci (qwen3-235b)
5. Flash/Flash-Max are DISQUALIFIED for all review tasks — cannot sustain cross-file reasoning

## Override Triggers
- Developer adds `override_executor: [model]` to task frontmatter → use that model
- Task has `risk: critical` → escalate to claude-sonnet regardless of other rules
- Task is in lessons.md with a routing correction → follow lessons.md

## Ambiguity Resolution
When a task could be either command-doc-write or bash-script-create:
  - If the primary output is a .md file → command-doc-write
  - If the primary output is a .sh file → bash-script-create
  - If both → bash-script-create (higher complexity, drives the command doc)

When uncertain between deepseek-v4-flash and deepseek-v4-pro:
  - Prefer flash for tasks ≤ 3 files and no cross-component reasoning
  - Prefer pro for tasks touching acp.common.sh or the YAML parser

When uncertain between command-doc-write and command-doc-update:
  - Adding a new protocol section with > 20 lines of new directive text → command-doc-write
  - Updating/correcting existing content (< 20 net new lines) → command-doc-update
  - Rewriting > 50% of an existing command doc → command-doc-write
  - New route with no existing command doc at all → command-doc-write
