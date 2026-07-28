# CodeRabbit Policy Map Lite (M81 / ADR-22)

**Status**: active  
**Updated**: 2026-07-27  
**Source**: `/acp-review` 64-rule ruleset + M83 deterministic expansion  
**Purpose**: Assign owners for CodeRabbit-aware `/acp-review` annotations. Does **not** replace ACP review.

## Binding rules

1. **Phase 1 deterministic rules are never deferred** to CodeRabbit — they always run via `acp.review-scan.sh` / Phase 1 path.
2. `owner: coderabbit` / `both` on Phase 2 means **annotate** (“also covered by CodeRabbit — verify via PR or findings-import”), never skip ACP review when inactive.
3. ACP-owned governance / protocol / agent-context rules stay `acp`.
4. `/acp-validate` owns structural ACP parity checks (`YM-03`, `ACP-02`); `/acp-integrity` owns OWASP A08:2025 integrity coverage. Neither is a CodeRabbit-deferral surface.

## Phase 1 — never deferred (owner: acp)

| rule_id | owner | phase | notes |
|---------|-------|-------|-------|
| EH-01 | acp | 1 | Phase 1 never deferred |
| EH-02 | acp | 1 | Phase 1 never deferred |
| EH-03 | acp | 1 | Phase 1 never deferred |
| EH-04 | acp | 1 | Phase 1 never deferred |
| EH-07 | acp | 1 | Phase 1 never deferred |
| EH-08 | acp | 1 | Phase 1 never deferred |
| EH-09 | acp | 1 | Phase 1 never deferred |
| SC-01 | acp | 1 | Phase 1 never deferred |
| SC-03 | acp | 1 | Phase 1 never deferred |
| SC-08 | acp | 1 | Phase 1 never deferred |
| SC-10 | acp | 1 | Phase 1 never deferred |
| SC-13 | acp | 1 | Phase 1 never deferred |
| SC-14 | acp | 1 | Phase 1 never deferred |
| SC-15 | acp | 1 | Phase 1 never deferred |
| SC-16 | acp | 1 | Phase 1 never deferred |
| SC-18 | acp | 1 | Phase 1 never deferred |
| TS-01 | acp | 1 | Phase 1 never deferred |
| TS-02 | acp | 1 | Phase 1 never deferred |
| TS-03 | acp | 1 | Phase 1 never deferred |
| TS-04 | acp | 1 | Phase 1 never deferred |
| TS-06 | acp | 1 | Phase 1 never deferred |
| TS-07 | acp | 1 | Phase 1 never deferred |
| TS-08 | acp | 1 | Phase 1 never deferred |
| TS-13 | acp | 1 | Phase 1 never deferred |
| AP-01 | acp | 1 | Phase 1 never deferred |
| AP-09 | acp | 1 | Phase 1 never deferred |
| NC-01 | acp | 1 | Phase 1 never deferred |
| NC-02 | acp | 1 | Phase 1 never deferred |
| NC-04 | acp | 1 | Phase 1 never deferred |
| NC-06 | acp | 1 | Phase 1 never deferred |
| NC-09 | acp | 1 | Phase 1 never deferred |
| CH-01 | acp | 1 | Phase 1 never deferred |
| CH-03 | acp | 1 | Phase 1 never deferred |
| CH-06 | acp | 1 | Phase 1 never deferred |
| CH-07 | acp | 1 | Phase 1 never deferred |
| SH-01 | acp | 1 | Phase 1 never deferred |
| SH-02 | acp | 1 | Phase 1 never deferred |
| SH-04 | acp | 1 | Phase 1 never deferred |
| YM-01 | acp | 1 | Phase 1 never deferred |
| YM-02 | acp | 1 | Phase 1 never deferred |
| ACP-01 | acp | 1 | Phase 1 never deferred |
| ACP-03 | acp | 1 | Phase 1 never deferred |

### Optional Local Analyzer

| rule_id | owner | phase | notes |
|---------|-------|-------|-------|
| SH-03 | acp | 1b | Optional local analyzer via `shellcheck` when installed |

## Phase 2 — overlap candidates (annotation when `coderabbit_active`)

| rule_id | owner | phase | notes |
|---------|-------|-------|-------|
| SC-02 | both | 2 | Input validation — CR may comment |
| SC-05 | both | 2 | Secrets in logs — CR/secrets engines |
| YM-03 | validate | 2 | Version consistency — `/acp-validate` owned |
| ACP-02 | validate | 2 | Command E2E coverage — `/acp-validate` owned |

**A08 note**: Software/data integrity failures map to `/acp-integrity` (`IG-*`), not this CodeRabbit-aware `/acp-review` ownership map.

**Count**: 42 built-in Phase 1 + 1 optional analyzer + 4 Phase 2 rows = **47** mapped.

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
- [ADR-23](../memory/decisions.md) — local deterministic analyzers  
- `agent/commands/acp.review.md` — full 64-rule table  
- `agent/wiki/coderabbit-integration.md` — enablement guide  
