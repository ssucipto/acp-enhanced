---
id: task-255
milestone: M78
title: "Reserve integrations.coderabbit.* preference keys (off/inert defaults)"
status: completed
priority: 5
complexity: low
estimated_hours: 2
created: 2026-07-23
started: 2026-07-23
completed: 2026-07-23
route: route-244
audit_findings: [F-097-01]
depends_on: []
design_reference: [ADR-21](../../memory/decisions.md)
---

> **Amended per audit-098 (F-098-04)**: reduced from three keys to **two** — `generate_on_commit` dropped. It would reserve a key for the GATED `.coderabbit.yaml` generator (M75) with **no consumer in M78**, which is exactly the speculative-interface reservation ADR-19 cautions against. Reserve only keys with a live M78 consumer (detection reads both `enabled` and `config_path`). `generate_on_commit` is reserved in M75 when the generator lands.

## Objective

Add **two** `integrations.coderabbit.*` preferences to the configurables schema and project defaults, both defaulting to off/inert, so a fresh ACP install is unaffected and the toggle is discoverable before any integration code exists.

## Context

audit-097 gate 1 (preference opt-in). The preferences system already resolves 4-level precedence (project > workspace > user > configurable default) — structure mirrors the existing `plan.draft.create_mode` (verified audit-098: identical nesting depth resolves via `get_preference`). This task only reserves the keys — no behavior is wired to them yet (that is task-256+). Off-by-default is mandatory (ADR-21 guardrail 6).

## Steps

1. In `agent/configurables/acp.configurables.yaml`, add an `integrations:` category with a `coderabbit:` subsection defining:
   - `integrations.coderabbit.enabled` — boolean, default `false`, description "Enable optional CodeRabbit-aware behavior in ACP commands. Off by default; ACP is fully functional without CodeRabbit."
   - `integrations.coderabbit.config_path` — string, default `.coderabbit.yaml`, description "Path ACP checks to detect a CodeRabbit-configured repo."
   - (do NOT add `generate_on_commit` — deferred to M75 per F-098-04)
2. Add both ids to the `acp._index` list.
3. Mirror the two keys under `acp.integrations.coderabbit` in `agent/preferences/acp.default.yaml` with the same default values and inline comments.
4. Bump the `Version:`/`Last Updated:` headers in both files.
5. Verify resolution with `agent/scripts/acp.preferences.sh`.

## Verification

- [ ] `bash agent/scripts/acp.preferences.sh get acp integrations.coderabbit.enabled` → `false` on a clean project
- [ ] `bash agent/scripts/acp.preferences.sh get acp integrations.coderabbit.config_path` → `.coderabbit.yaml`
- [ ] `/acp-preferences-validate` (or `acp.preferences.sh validate`) passes — no schema errors
- [ ] `acp._index` contains the 2 new ids
- [ ] `generate_on_commit` is NOT present (deferred to M75)

## User-Observable Acceptance

A user can run `/acp-preferences-show acp` and discover the CodeRabbit toggle, see it is off by default, and enable it — with no change in ACP behavior until later tasks wire detection.
