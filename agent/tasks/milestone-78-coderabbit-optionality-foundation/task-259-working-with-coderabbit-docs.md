---
id: task-259
milestone: M78
title: "Working with CodeRabbit — how-to documentation"
status: planned
priority: 4
complexity: low
estimated_hours: 2.5
created: 2026-07-23
started: null
completed: null
route: route-248
audit_findings: [F-097-01]
depends_on: [task-255, task-256]
design_reference: [ADR-21](../../memory/decisions.md)
---

## Objective

Write `agent/docs/working-with-coderabbit.md` — the user-facing guide the developer asked for: what CodeRabbit is, how to turn the optional integration on/off in ACP, exactly what changes when it is on vs off, and the roadmap for the gated PR-check work.

## Context

audit-097 non-gated docs deliverable. Must make the *optional* nature unmistakable (ACP works fully without CodeRabbit) and set honest expectations that PR-check integration is gated per ADR-19 — not yet available.

## Steps

1. Create `agent/docs/working-with-coderabbit.md` covering:
   - **What CodeRabbit is** (LLM PR review + 40+ engines; free tier exists) — 1 short paragraph, link to source.
   - **Is it required?** No. ACP's `/acp-review` + carryover loop are fully functional standalone. CodeRabbit augments, never replaces them.
   - **Enabling it**: `/acp-preferences-set acp integrations.coderabbit.enabled true` (+ `config_path` if non-default). Show the default-off state.
   - **What ACP does when on vs off** — table mirroring the audit-097 degradation matrix, marking which rows are live in M78 vs GATED.
   - **Detection**: how ACP decides a repo is CodeRabbit-configured (`.coderabbit.yaml` / CLI).
   - **Roadmap / PR-check**: clearly state PR-check, findings-import, and `.coderabbit.yaml` generation are GATED under ADR-19 until CodeRabbit is operational on a repo with 2+ weeks of findings — with a pointer to `/acp-plan M74`.
2. Add a one-line pointer from `AGENTS.md`/`README.md` (respect AGENTS.md byte budget — constraints.yml `agents_md_rules`; a link, not content).
3. Cross-reference audit-097, ADR-19, ADR-21.

## Verification

- [ ] Guide states integration is optional and off by default
- [ ] on/off behavior table marks GATED rows distinctly from live M78 rows
- [ ] PR-check explicitly described as gated (ADR-19) with the unblock path
- [ ] Enable/disable commands are copy-pasteable and correct
- [ ] AGENTS.md pointer added without exceeding `warn_at_bytes` (12KB)

## User-Observable Acceptance

A developer who has never used CodeRabbit can read one page and know whether to enable it, how, and what they get — with no surprise that PR review is not yet wired.
