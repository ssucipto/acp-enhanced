---
id: route-023
title: M41a — Fix HTTP-Referer placeholder in acp-dispatch.ts (BUG-002)
task_type: typescript-feature
milestone: M41
complexity: low
executor: deepseek-v4-flash
context_required:
  - wiki/architecture.md#dispatch-script-flow
  - agent/core/identity.yml
  - scripts/acp-dispatch.ts
files_affected:
  - scripts/acp-dispatch.ts
tokens_est: 5000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-05-11
completed: 2026-05-11
override_reason:
---

## Task Description

Fix the hardcoded `HTTP-Referer` and `X-Title` placeholder values in `scripts/acp-dispatch.ts` (audit-014 BUG-002). These values are sent to OpenRouter for usage attribution and rate-limit grouping. Every project that installs ACP Enhanced currently sends `"https://github.com/your-handle/your-repo"` to OpenRouter instead of its own identity.

## Acceptance Criteria

- [ ] `acp-dispatch.ts` reads `agent/core/identity.yml` at startup using `js-yaml` (already a dependency)
- [ ] `HTTP-Referer` set dynamically: `identity?.homepage ?? \`https://github.com/${identity?.repo ?? "ssucipto/acp-enhanced"}\``
- [ ] `X-Title` set dynamically: `identity?.project ?? "ACP Enhanced"`
- [ ] Fallback values are safe — no crash if `identity.yml` is missing or malformed
- [ ] No new npm dependencies required
- [ ] Existing `readAgent()` helper or equivalent used for file path resolution (consistent with codebase)
- [ ] Placeholder string `"your-handle/your-repo"` does NOT appear anywhere in the file

## Implementation Notes

```typescript
// At startup, read identity:
const identityPath = path.join(agentDir, "core", "identity.yml");
const identity = fs.existsSync(identityPath)
  ? (yaml.load(fs.readFileSync(identityPath, "utf-8")) as Record<string, unknown>)
  : {};

const repoUrl = (identity?.homepage as string) ??
  `https://github.com/${(identity?.repo as string) ?? "ssucipto/acp-enhanced"}`;
const projectName = (identity?.project as string) ?? "ACP Enhanced";

// In defaultHeaders:
defaultHeaders: {
  "HTTP-Referer": repoUrl,
  "X-Title": projectName,
}
```

Check `identity.yml` for the exact field names used (`homepage`, `project`, `repo` — verify against actual file).
