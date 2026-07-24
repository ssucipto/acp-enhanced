# CodeRabbit Policy Map Lite (M81 / ADR-22)

**Status**: active  
**Updated**: 2026-07-24  
**Source**: `/acp-review` 64-rule ruleset + audit-101 F-101-07  
**Purpose**: Assign owners for CodeRabbit-aware `/acp-review` annotations. Does **not** replace ACP review.

## Binding rules

1. **Phase 1 deterministic rules are never deferred** to CodeRabbit — they always run via `acp.review-scan.sh` / Phase 1 path.
2. `owner: coderabbit` / `both` on Phase 2 means **annotate** (“also covered by CodeRabbit — verify via PR or findings-import”), never skip ACP review when inactive.
3. ACP-owned governance / protocol / agent-context rules stay `acp`.

## Phase 1 — never deferred (owner: acp)

| rule_id | owner | phase | notes |
|---------|-------|-------|-------|
| EH-01 | acp | 1 | Phase 1 never deferred |
| EH-02 | acp | 1 | Phase 1 never deferred |
| SC-01 | acp | 1 | Secrets — layered defense; CR may also flag |
| TS-01 | acp | 1 | Phase 1 never deferred |
| TS-02 | acp | 1 | Phase 1 never deferred |
| AP-01 | acp | 1 | Phase 1 never deferred |
| NC-01 | acp | 1 | Phase 1 never deferred |
| SH-01 | acp | 1 | Phase 1 never deferred |

## Phase 2 — overlap candidates (annotation when `coderabbit_active`)

| rule_id | owner | phase | notes |
|---------|-------|-------|-------|
| TS-03 | both | 2 | Cast discipline — CR engines often flag |
| TS-07 | both | 2 | `unknown` in catch — lint overlap |
| TS-08 | both | 2 | null safety — lint/SAST overlap |
| SC-02 | both | 2 | Input validation — CR may comment |
| SC-03 | both | 2 | Dangerous sinks — CR/SAST overlap |
| SC-05 | both | 2 | Secrets in logs — CR/secrets engines |
| CH-06 | both | 2 | console.log in prod — lint overlap |
| CH-07 | both | 2 | Unused imports — lint overlap |
| EH-03 | both | 2 | Swallowed errors — semantic + lint |
| SC-14 | coderabbit | 2 | Dependency CVEs — prefer commercial engines; annotate when CR active |
| YM-01 | acp | 2 | ACP YAML hygiene — ACP-owned |
| YM-03 | acp | 2 | Version consistency — ACP-owned |
| ACP-01 | acp | 2 | Command directive headers — ACP-owned |
| ACP-02 | acp | 2 | Command E2E coverage — ACP-owned |
| SH-02 | acp | 2 | macOS/BSD sed — ACP script ownership |

**Count**: 8 Phase 1 + 15 Phase 2 rows = **23** mapped (≥15 required).

## How `/acp-review` uses this map

When `coderabbit_active` is false: ignore this map; full ACP review.  
When true: Phase 1 unchanged; for Phase 2 rows with `owner: coderabbit|both`, add annotation pointing to PR review and:

```bash
bash agent/scripts/acp.findings-import.sh --input <export.json>
```

(Script ships in task-270; until then, annotation may say “import TBD — verify on PR”.)

## References

- [ADR-22](../memory/decisions.md) — CodeRabbit-only carve-out  
- [ADR-21](../memory/decisions.md) — optionality foundation  
- `agent/commands/acp.review.md` — full 64-rule table  
- `agent/wiki/coderabbit-integration.md` — enablement guide  
