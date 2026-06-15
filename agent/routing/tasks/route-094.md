---
id: route-094
title: "Triple-file parity check in /acp-validate"
task_type: command-doc-update
milestone: M49
complexity: low
executor: copilot
context_required:
  - agent/commands/acp.validate.md
files_affected:
  - agent/commands/acp.validate.md
tokens_est: 200
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-06
completed:
override_reason:
---

# Route 094: Triple-File Parity Check

## Objective

Add command wrapper parity to `/acp-validate` — for each command doc in
`agent/commands/`, check that corresponding `.github/prompts/*.prompt.md` and
`.opencode/commands/*.md` wrappers exist. Warn if missing. Skip template files.

## Context

Every `/acp-*` command needs 3 files. Twice this session wrappers were forgotten
(caught by audit-042, audit-044). An automated check prevents this.

## Changes

### acp.validate.md — New Step (after namespace validation)

Add parity check step:

```markdown
### X. Validate Command Wrapper Parity (v6.9.2+)

For each `agent/commands/acp.*.md` (excluding templates):
- Check `.github/prompts/acp.{name}.prompt.md` exists → ✅ / ⚠️ MISSING
- Check `.opencode/commands/acp.{name}.md` exists → ✅ / ⚠️ MISSING

⚠️ Warnings only — do not fail validate. Template files and non-acp commands
   (git.*) are skipped.
```

## Verification

- [ ] Missing wrapper produces ⚠️ warning
- [ ] All wrappers present → ✅
- [ ] Templates and git.* commands skipped
- [ ] Warnings do not affect exit code
