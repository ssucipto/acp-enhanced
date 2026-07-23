# Session: 2026-07-23

**Executor**: claude-opus-4-8
**Branch**: develop
**Tasks**: none (planning + audit session — no routing tasks completed)

## Completed
- audit-097 — optional CodeRabbit integration examined through the distributed-framework lens (consumers may lack CodeRabbit)
- plan M78 — CodeRabbit Optionality Foundation milestone + 6 tasks (255–260)
- ADR-21 — optionality foundation carved out of the ADR-19 gate (non-gated); PR-check/findings-import stay gated
- ADR-20 — backfilled the hooks `task_id`-array format (resolved dangling constraints.yml citations)
- audit-098 — pre-impl readiness review; 7 findings folded into M78 same session

## Deferred
- M78 implementation → `/acp-proceed --complete` (this session, next)
- M74–M77 PR-check / findings-import → ADR-19 adoption gate
- CRIT-065-002 merge PR#3 → mainline
- F-086-02 FIFOZ consumer verification → task-239

## Key Fact
`acp.preferences.sh` sources `acp.common.sh`, so optional-tool detection helpers that call `get_preference` must live in a dedicated script (`acp.coderabbit.sh`) sourcing preferences.sh — never in common.sh (circular source). Caught in pre-impl audit-098 before any code was written. Also: ADR-19 gates CodeRabbit *integration* (PR-check/findings-import); the *optionality foundation* (toggle + detection + docs) is a separate non-gated concern (ADR-21).
