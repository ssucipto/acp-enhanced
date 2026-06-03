<skill name="typescript" mention="@{typescript}">
<rules>
- TypeScript files live in `scripts/` (dispatch, validate, etc.)
- Use strict TypeScript: `"strict": true` in tsconfig (no implicit any)
- Use `fs` built-in — no third-party file I/O libraries beyond what's in `scripts/package.json`
- YAML parsing in TS: use `js-yaml` (already a dependency)
- Frontmatter parsing: use `gray-matter` (already a dependency)
- OpenRouter API: use the `openai` SDK pointed at OPENROUTER_BASE
- All API keys from environment variables only — never hardcoded
- Use `process.exit(1)` with a descriptive error message on failure
- Stream responses with `stream: true` — don't wait for full completion
- Token cost calculation: `(tokens * cost_per_1m) / 1_000_000`
- Ledger rows appended with `appendFileSync` — never overwrite ledger.md
- routing.yml is the only file written per-session by dispatch — keep it minimal
</rules>

<patterns>
Read .agent file safely:
```typescript
function readAgent(relPath: string): string {
  const full = path.join(".agent", relPath);
  if (!existsSync(full)) return "";
  return readFileSync(full, "utf-8");
}
```

Token estimation (4 chars ≈ 1 token):
```typescript
function estimateTokens(text: string): number {
  return Math.ceil(text.length / 4);
}
```

Ledger append row:
```typescript
function appendLedger(meta: Record<string, any>, inputTokens: number, outputTokens: number, costUsd: number) {
  const date = new Date().toISOString().slice(0, 10);
  const row = `| ${date} | ${meta.id} | ${meta.task_type} | ${meta.executor} | ${inputTokens} | ${outputTokens} | $${costUsd.toFixed(4)} | |\n`;
  appendFileSync(path.join(".agent", "routing/ledger.md"), row);
}
```

Frontmatter task file parsing:
```typescript
const { data: meta, content: taskContent } = matter(readFileSync(taskPath, "utf-8"));
```
</patterns>

<anti_patterns>
- NEVER hardcode API keys — always `process.env.OPENROUTER_API_KEY`
- NEVER use `any` types — use `Record<string, unknown>` or define interfaces
- NEVER overwrite ledger.md — only append
- NEVER call the API without streaming — large responses will timeout
- NEVER load the entire sessions.md — use getLastNSessions(3)
</anti_patterns>
</skill>
