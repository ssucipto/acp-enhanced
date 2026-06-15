---
id: route-096
title: "Add --validate flag to /acp-commit"
task_type: command-doc-update
milestone: M49
complexity: low
executor: copilot
context_required:
  - agent/commands/acp.commit.md
  - agent/commands/acp.validate.md
files_affected:
  - agent/commands/acp.commit.md
tokens_est: 150
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-06
completed:
override_reason:
---

# Route 096: --validate Flag on /acp-commit

## Objective

Add `--validate` flag to `/acp-commit` that runs `/acp-validate` before the
commit steps. Catches issues (version drift, YAML errors, parity gaps) before
they're committed.

## Context

`/acp-validate` was run only once this session (explicitly invoked). The version
drift bug would have been caught immediately if validate ran as part of commit.

## Changes

### acp.commit.md — Arguments

Add to arguments table:
```
| `--validate` | Run /acp-validate before committing (catches version drift, YAML errors, parity gaps) |
```

### acp.commit.md — New Step 0a

Add before Step 0:
```
### 0a. Pre-commit Validation (--validate only)

> Skip if --validate not passed.

Run /acp-validate. If validation fails (exit 1):
- Report the failures
- Abort commit — fix issues first
If validation passes with warnings only:
- Show warnings
- Proceed with commit
```

## Verification

- [ ] `--validate` flag documented
- [ ] Validation failure blocks commit
- [ ] Validation warnings allow commit
- [ ] Without `--validate`, behavior unchanged
