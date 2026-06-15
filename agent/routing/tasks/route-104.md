---
id: route-104
title: "Windows install documentation + recovery path"
task_type: docs-update
milestone: M49
complexity: low
executor: copilot
context_required:
  - README.md
  - scripts/QUICKSTART.md
files_affected:
  - README.md
  - scripts/QUICKSTART.md
tokens_est: 200
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-06-06
completed:
override_reason:
---

# Route 104: Windows Install Documentation

## Objective

Add Windows-specific install guidance to README.md and QUICKSTART.md, including
Git Bash workarounds, manual recovery path, and Cursor setup instructions.

## Context

Windows user had to manually diagnose and fix a partial install. Documentation
should preempt this with known issues and recovery steps. Cursor users need
explicit setup instructions.

## Changes

### README.md — Installation section

Add Windows subsection:

```markdown
### Windows (Git Bash)

1. Open Git Bash in your project root
2. Run the bootstrap:
   ```bash
   curl -fsSL https://raw.githubusercontent.com/ssucipto/acp-enhanced/mainline/scripts/acp-bootstrap.sh | bash
   ```
3. If the install hangs at "Resolving script dependencies", kill it (Ctrl+C) and run:
   ```bash
   git clone --depth 1 -b mainline https://github.com/ssucipto/acp-enhanced.git $TEMP/acp-temp
   cp $TEMP/acp-temp/agent/scripts/*.sh agent/scripts/
   rm -rf $TEMP/acp-temp
   ```

### Cursor IDE Setup

After install, copy opencode wrappers for slash autocomplete:
```powershell
New-Item -ItemType Directory -Force -Path ".cursor\commands"
Copy-Item ".opencode\commands\acp.*.md" ".cursor\commands\" -Force
```
Reload Cursor (Ctrl+Shift+P → "Developer: Reload Window").
Type `/` in Agent chat to see `/acp-init`, `/acp-proceed`, etc.
```

### scripts/QUICKSTART.md

Add same Windows + Cursor sections.

## Verification

- [ ] README has Windows install section
- [ ] QUICKSTART has Windows + Cursor sections
- [ ] Recovery path documented (manual script copy)
- [ ] Cursor setup documented
