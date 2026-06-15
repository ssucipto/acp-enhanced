---
id: task-178
milestone: M35
title: Add placeholder detection to acp-validate.ts
status: completed
priority: 3
complexity: medium
estimated_hours: 2.5
created: 2026-05-05
started: 2026-05-06T00:00:00Z
completed: 2026-05-06
---

<!-- @acp.meta.task
topic: add, placeholder, detection, to, acp-validatets
description: Add placeholder detection to acp-validate.ts
milestone: M35
status: completed
updated: 2026-05-05
@acp.meta.end -->


## Objective

Extend `scripts/acp-validate.ts` to detect `{placeholder}` patterns (unresolved template variables) in lines 3–4 of every `agent/commands/*.md` file, excluding fenced code blocks.

## Context

ACP commands are generated from `agent/commands/*.template.md` files. Unresolved placeholders (e.g., `{COMMAND_NAME}`, `{namespace}`) indicate a template was instantiated without substitution. Lines 3–4 are the critical directive line and pretend-context line. False positives in code blocks must be excluded.

## Implementation

In `scripts/acp-validate.ts`, add a new validation pass:

```typescript
function validatePlaceholders(filePath: string): ValidationError[] {
  const errors: ValidationError[] = [];
  const lines = fs.readFileSync(filePath, 'utf8').split('\n');
  
  let inCodeBlock = false;
  
  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];
    
    // Track fenced code blocks
    if (/^```/.test(line)) {
      inCodeBlock = !inCodeBlock;
      continue;
    }
    
    if (inCodeBlock) continue;
    
    // Check lines 3 and 4 (0-indexed: 2 and 3) only
    // These are the directive line and pretend-context line
    if (i === 2 || i === 3) {
      const placeholderPattern = /\{[A-Z_a-z][A-Z_a-z0-9]*\}/g;
      const matches = line.match(placeholderPattern);
      if (matches) {
        for (const match of matches) {
          errors.push({
            file: filePath,
            line: i + 1,
            message: `Unresolved placeholder: ${match}`,
            severity: 'error'
          });
        }
      }
    }
  }
  
  return errors;
}
```

Wire `validatePlaceholders` into the main validation loop that iterates over `agent/commands/*.md`.

Include in the final report summary: "Placeholder check: N files checked, M errors found".

## Implementation Notes

- Read `scripts/acp-validate.ts` fully before editing to understand the existing `ValidationError` type and report structure
- The `i === 2 || i === 3` line indices target lines 3 and 4 (1-based user-facing)
- Pattern `{WORD}` — only flag identifiers inside braces: letters, digits, underscores; no spaces
- Do not flag `{1}`, `{2}` (regex capture groups — numeric-only content)

## Expected Output

### Files Updated
- `scripts/acp-validate.ts`

## Verification
- [ ] `npx ts-node scripts/acp-validate.ts` compiles without TypeScript errors
- [ ] A test command file with `{COMMAND_NAME}` on line 3 produces a validation error
- [ ] A test command file with `{COMMAND_NAME}` inside a code block does NOT produce an error
- [ ] The summary output includes placeholder check results

## User-Observable Acceptance
Running `npx ts-node scripts/acp-validate.ts` from repo root detects any accidentally-committed unresolved placeholders in command directive lines and reports them with file path and line number.
