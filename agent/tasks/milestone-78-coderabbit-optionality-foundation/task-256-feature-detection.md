---
id: task-256
milestone: M78
title: "Feature-detection helpers coderabbit_available / coderabbit_active in a dedicated acp.coderabbit.sh"
status: planned
priority: 5
complexity: low
estimated_hours: 2
created: 2026-07-23
started: null
completed: null
route: route-245
audit_findings: [F-097-01, F-098-01, F-098-03, F-098-04]
depends_on: [task-255]
design_reference: [ADR-21](../../memory/decisions.md)
---

> **Amended per audit-098**: (F-098-01) helpers move OUT of `acp.common.sh` into a new dedicated `agent/scripts/acp.coderabbit.sh` — `acp.preferences.sh` **sources** `acp.common.sh` (line 32), so putting a `get_preference` call in common.sh is a circular source. The new script sources preferences.sh (which pulls in common.sh) and owns the helpers. (F-098-03) `enabled` compared with exact `== "true"` — a `false` default resolves as the non-empty string "false", so presence checks would misread it. (F-098-04) detection is **config-file-only** in M78; CLI detection deferred until the actual CLI name is verified during adoption (no speculative vendor assumption).

## Objective

Add two shared bash helpers in a new `agent/scripts/acp.coderabbit.sh` that answer "is CodeRabbit usable here?" — detection only, no findings parsing — modeled on the `command -v gh` idiom at `acp.branch-protection-setup.sh:27`.

## Context

audit-097 gates 2+3 (feature detection + graceful degradation). Detection must be pure: presence of the config file — never reading CodeRabbit output (GATED, ADR-19/ADR-21). Two helpers keep the "enabled" and "available" concerns separate so callers can degrade correctly. Layering (audit-098 F-098-01): `acp.coderabbit.sh` → sources `acp.preferences.sh` → sources `acp.common.sh`. Never the reverse.

## Steps

1. Create `agent/scripts/acp.coderabbit.sh`; source `acp.preferences.sh` (which sources common.sh + yaml-parser). Register it in `package.yaml contents.scripts` (D4 is ERROR — unregistered scripts fail CI).
2. `coderabbit_available()`:
   - Resolve `config_path` via `get_preference_or "acp" "integrations.coderabbit.config_path" ".coderabbit.yaml"`.
   - Return 0 iff that file exists at project root; else 1. **Config-file-only** — no `command -v coderabbit` (F-098-04). No output, no findings parsing.
3. `coderabbit_active()`:
   - `local enabled; enabled="$(get_preference "acp" "integrations.coderabbit.enabled" 2>/dev/null || echo false)"`
   - Return 0 only if `[[ "$enabled" == "true" ]]` **AND** `coderabbit_available`. Exact string match (F-098-03) — never `has_preference`.
4. Follow bash_rules (constraints.yml): `local` vars, quote all vars, no `set -e` without trap.
5. Header comment on each helper referencing `local.optional-external-tool.md` (task-257) and ADR-21.

## Verification

- [ ] `coderabbit_available` returns 1 in a repo with no `.coderabbit.yaml`
- [ ] `coderabbit_available` returns 0 when a `.coderabbit.yaml` is present
- [ ] `coderabbit_active` returns 1 (unusable) when `enabled=false` even if file present (opt-in wins; confirms F-098-03 fix)
- [ ] `coderabbit_active` returns 0 (usable) only when `enabled=true` AND file present
- [ ] `shellcheck agent/scripts/acp.coderabbit.sh` clean; macOS + Linux safe
- [ ] `acp.coderabbit.sh` registered in package.yaml; `acp-validate` D4 green

## User-Observable Acceptance

Any ACP script can `source acp.coderabbit.sh` and guard a CodeRabbit branch with `if coderabbit_active; then …`, guaranteed a clean no-op on a machine without CodeRabbit.
