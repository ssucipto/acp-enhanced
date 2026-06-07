# Skills: code-review

> **Command binding**: `/acp-review`  
> **Executor**: copilot  
> **Token budget**: ≤500 tokens  

---

## Executor Selection

| Executor | Scope |
|----------|-------|
| copilot | TypeScript/JS/React/React Native code review (primary) |
| composer-2.5 | Full-project OWASP + MASVS |
| deepseek-v4-pro | Cross-component consistency, cost-efficient dispatch |
| kimi-k2.6 | Polyglot codebases |
| qwen3-235b | CI/high-volume batch |

**Disqualified**: deepseek-v4-flash, deepseek-v4-flash-max — cannot sustain cross-file reasoning for security/consistency checks.

---

## Review Workflow

1. **Pick executor** from table above based on `--rules` flag and project size
2. **Read command spec**: `agent/commands/acp.review.md`
3. **Apply rules**: All 54 rules across 7 categories
4. **Scope rules**: Mobile rules (SC-19–SC-23) fire only for React Native/Expo
5. **ACP self-review**: Appendix A auto-activates when `agent/commands/` exists
6. **Output**: Structured YAML findings in `agent/reports/review-NNN.md`
7. **Never auto-fix** — report only

---

## Compact OWASP → Rule Mapping

| OWASP | Rule IDs |
|-------|---------|
| A01:2025 Broken Access Control | SC-06, SC-07, SC-08, SC-09 |
| A02:2025 Security Misconfig | SC-10, SC-11, SC-12, SC-13 |
| A03:2025 Supply Chain | SC-14, SC-15 |
| A04:2025 Cryptography | SC-16, SC-17, SC-18 |
| A05:2025 Input/Secrets | SC-01–SC-05 |
| A09:2025 Security Logging | SC-24, SC-25 |
| A10:2025 Exception Handling | EH-01–EH-11 |
| MASVS-STORAGE | SC-19 |
| MASVS-PLATFORM | SC-20 |
| MASVS-NETWORK | SC-21 |
| MASVS-CODE | SC-22 |
| MASVS-AUTH | SC-23 |

---

## Quality Gates

- Critical findings always reported (override severity filter)
- `--ci` exits 1 on CRITICAL/HIGH
- Findings reference exact file:line
- UUID tracking on carryovers for resolution verification

## Chunking Strategy (>20 files)

For codebases exceeding 20 files, avoid token overrun:
1. **Summary-first**: Apply all 54 rules at category level — produce per-category counts
2. **Prioritize HIGH+**: Only per-file scan files with CRITICAL/HIGH findings
3. **Batch by category**: 10 files/turn for DeepSeek V4 Pro, 5 files/turn for copilot
4. **Aggregate**: Combine category batches into single `review-NNN.md` report
5. **Timeout guard**: If any batch exceeds 8K tokens, emit `[TRUNCATED]` marker and note remaining files

This maps to ACP's parallel/orchestrator-workers pattern for cost-efficient large reviews.
