---
id: task-179
milestone: M35
title: Add header format and command/prompt/opencode parity check to acp-validate.ts
status: completed
priority: 3
complexity: medium
estimated_hours: 2
created: 2026-05-05
started: 2026-05-06T00:00:00Z
completed: 2026-05-06
---

<!-- @acp.meta.task
topic: add, header, format, and, commandpromptopencode, parity, check, to, acp-validatets
description: Add header format and command/prompt/opencode parity check to acp-validate.ts
milestone: M35
status: completed
updated: 2026-05-05
@acp.meta.end -->


## Objective

Extend `scripts/acp-validate.ts` with two new checks:
1. Every `agent/commands/*.md` file has required frontmatter fields: Namespace, Version, Status, Scripts
2. The count of files in `agent/commands/`, `.github/prompts/`, and `.opencode/commands/` are all equal (parity check)

## Context

Required frontmatter fields are defined in `agent/schemas/command.schema.yaml`. Missing fields mean a command was incompletely created. The parity check (all 3 file surfaces have same count) enforces the triple-file architecture — if a command file exists without a corresponding prompt and opencode file, it's incomplete.

## Implementation

### Check 1: Frontmatter field validation

```typescript
const REQUIRED_FRONTMATTER_FIELDS = ['Namespace', 'Version', 'Status', 'Scripts'];

function validateFrontmatter(filePath: string): ValidationError[] {
  const errors: ValidationError[] = [];
  const content = fs.readFileSync(filePath, 'utf8');
  
  // Extract frontmatter block (between first pair of --- delimiters)
  const frontmatterMatch = content.match(/^---\n([\s\S]*?)\n---/);
  if (!frontmatterMatch) {
    return [{ file: filePath, line: 1, message: 'Missing YAML frontmatter (--- block)', severity: 'error' }];
  }
  
  const frontmatter = frontmatterMatch[1];
  
  for (const field of REQUIRED_FRONTMATTER_FIELDS) {
    if (!new RegExp(`^${field}:`, 'm').test(frontmatter)) {
      errors.push({
        file: filePath,
        line: 1,
        message: `Missing required frontmatter field: ${field}`,
        severity: 'warning'
      });
    }
  }
  
  return errors;
}
```

### Check 2: Triple-file parity check

```typescript
function validateCommandParity(): ValidationError[] {
  const errors: ValidationError[] = [];
  
  const commandFiles = glob('agent/commands/acp.*.md');
  const promptFiles = glob('.github/prompts/acp-*.prompt.md');
  const opencodeFiles = glob('.opencode/commands/acp-*.md');
  
  const commandCount = commandFiles.length;
  const promptCount = promptFiles.length;
  const opencodeCount = opencodeFiles.length;
  
  if (commandCount !== promptCount) {
    errors.push({
      file: 'agent/commands/',
      line: 0,
      message: `Parity mismatch: ${commandCount} command files vs ${promptCount} VS Code prompt files`,
      severity: 'warning'
    });
  }
  
  if (commandCount !== opencodeCount) {
    errors.push({
      file: 'agent/commands/',
      line: 0,
      message: `Parity mismatch: ${commandCount} command files vs ${opencodeCount} opencode files`,
      severity: 'warning'
    });
  }
  
  return errors;
}
```

Wire both checks into the main validation flow. Include counts in the summary:
```
Frontmatter check: 58 files checked, 2 warnings
Parity check: 58 commands / 57 prompts / 58 opencode — 1 mismatch
```

## Implementation Notes

- Read `scripts/acp-validate.ts` fully before editing
- Use the existing glob utility in the file (or Node.js `fs.readdirSync` + filter)
- Report mismatches as `warning` not `error` (they indicate incomplete creation, not corruption)
- The `Scripts:` frontmatter field may be an array — the check should accept either `Scripts:` alone or `Scripts:\n  -`

## Expected Output

### Files Updated
- `scripts/acp-validate.ts`

## Verification
- [ ] `npx ts-node scripts/acp-validate.ts` compiles without errors
- [ ] A test file missing `Status:` frontmatter produces a warning
- [ ] If `agent/commands/` count differs from `.github/prompts/` count, parity warning is shown
- [ ] Summary line shows counts for both new checks

## User-Observable Acceptance
Running `npx ts-node scripts/acp-validate.ts` detects commands missing required frontmatter fields, and reports when the 3 command file surfaces are out of sync.
