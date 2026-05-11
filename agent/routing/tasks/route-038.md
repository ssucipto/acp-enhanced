---
id: route-038
title: M42 — AGENTS.md byte-size guard + parity diff filenames (VALIDATE-001 + VALIDATE-002)
task_type: typescript-feature
milestone: M42
complexity: medium
executor: copilot
context_required:
  - scripts/acp-validate.ts
  - agent/core/constraints.yml
  - agent/reports/audit-015-m41-verification-and-final-audit-assessment.md
files_affected:
  - scripts/acp-validate.ts
  - agent/core/constraints.yml
tokens_est: 5000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-05-11
completed:
override_reason:
---

## Task Description

Two related validate.ts improvements bundled into one route:

**VALIDATE-001**: Add an `AGENTS.md` byte-size check. AGENTS.md is currently 11,043 bytes (safe), but there is no guard. If content from AGENT.md (90,368 bytes) is accidentally merged, it silently breaks tool auto-load limits without any warning.

**VALIDATE-002**: Update `runParityCheck()` to print the specific filenames that are missing, not just a count. At 63 commands, count-only output requires manual directory diff to act on.

## Context

From audit-015:
- **VALIDATE-001**: `No AGENTS.md byte-size check — accidental bloat silently breaks tool auto-load limits`
- **VALIDATE-002**: `parity check reports count mismatch but not which specific files are missing`

## Acceptance Criteria

### VALIDATE-001 — AGENTS.md byte-size guard

#### constraints.yml update
- [ ] Add `agents_md_rules:` block to `agent/core/constraints.yml`:
  ```yaml
  agents_md_rules:
    max_bytes: 15000        # ~15KB hard limit — exceeding this may break tool auto-load
    warn_at_bytes: 12000   # ~12KB soft warning threshold
    rationale: "AGENTS.md, CLAUDE.md, and copilot-instructions.md are auto-loaded by some tools; must stay compact"
    files_to_check:
      - AGENTS.md
      - CLAUDE.md
      - .github/copilot-instructions.md
  ```

#### acp-validate.ts function
- [ ] Add `validateAgentsMdSize()` function to `scripts/acp-validate.ts`
- [ ] Read `agents_md_rules` from `agent/core/constraints.yml`
- [ ] For each file in `files_to_check`:
  - Get byte size via `fs.statSync(filePath).size` (handle file-not-found: warn + skip)
  - If `size > max_bytes`: print `❌ [file]: [N] bytes — exceeds [max] byte limit` and mark FAIL
  - If `size > warn_at_bytes`: print `⚠️ [file]: [N] bytes — approaching [max] byte limit`
  - Otherwise: print `✅ [file]: [N] bytes`
- [ ] Called from no-args validate path
- [ ] Returns boolean (true = all within limits)

### VALIDATE-002 — Parity diff filenames

#### Update runParityCheck()
- [ ] Build three normalized sets from directory contents:
  - `commandsSet`: extract command names from `agent/commands/acp.*.md` (strip `acp.` prefix and `.md` suffix)
  - `promptsSet`: extract command names from `.github/prompts/acp-*.prompt.md` (strip `acp-` prefix and `.prompt.md` suffix)
  - `opencodeSet`: extract command names from `.opencode/commands/acp-*.md` (strip `acp-` prefix and `.md` suffix)
- [ ] Compute missing companions for each command in `commandsSet`:
  - If name not in `promptsSet`: print `❌ Parity: acp.{name}.md has no prompt companion (.github/prompts/acp-{name}.prompt.md)`
  - If name not in `opencodeSet`: print `❌ Parity: acp.{name}.md has no opencode companion (.opencode/commands/acp-{name}.md)`
- [ ] Also check reverse: any prompt/opencode file with no matching command doc
- [ ] On full match: print `✅ Parity: [N] commands × 3 surfaces — all matched`
- [ ] Preserve existing count summary in addition to per-file output (don't remove the summary line)

## Implementation Notes

Read the current `runParityCheck()` and surrounding code carefully. The normalization step (stripping prefixes/suffixes) is the key to making the comparison work correctly. Use `Set.prototype.has()` for O(1) lookup. Handle edge cases: hidden files, template files (`.template.md`), files starting with `acp-` but not commands.
