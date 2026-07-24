---
id: task-271
milestone: M81
title: ".coderabbit.yaml starter template + documentation"
status: planned
priority: 5
complexity: low
estimated_hours: 2
created: 2026-07-24
started: null
completed: null
route: route-260
depends_on: [task-269]
design_reference: [agent/wiki/coderabbit-integration.md](../../wiki/coderabbit-integration.md)
---

## Objective

Ship a **starter** `.coderabbit.yaml` template and documentation so CodeRabbit consumers can bootstrap quickly. This is **not** the full patterns/lessons generator (deferred).

## Context

audit-097 noted a generated `.coderabbit.yaml` is inert in non-CodeRabbit repos. A static template is safe for all installs; copying it is opt-in via maintainer or future `project-create` hook.

## Steps

1. Add `agent/templates/coderabbit.yaml.template` with commented sections:
   - Path instructions aligned to ACP repo layout (`agent/`, `scripts/`, `e2e/`)
   - Plain-English pre-merge checks referencing `/acp-review` policy map lite (task-269)
2. Document in `agent/wiki/coderabbit-integration.md`:
   - "Bootstrap CodeRabbit" section: copy template, install GitHub app, enable preference
   - Explicit: template is manual copy today; auto-generate deferred
3. Optional: `bash agent/scripts/acp.coderabbit.sh hint` mentions template path when enabled+absent

## Verification

- [ ] Template is valid YAML (parseable)
- [ ] Wiki bootstrap section complete with copy commands
- [ ] No `generate_on_commit` preference added (deferred — no generator yet)
- [ ] Template does not reference Aikido

## User-Observable Acceptance

The one CodeRabbit consumer can copy the template, commit `.coderabbit.yaml`, set `enabled: true`, and pass `coderabbit_active` without custom ACP code.
