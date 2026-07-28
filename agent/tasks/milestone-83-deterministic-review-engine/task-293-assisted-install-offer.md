---
id: task-293
milestone: M83
title: "Assisted installer + version-update offer hook with nag discipline"
status: completed
priority: 3
complexity: medium
estimated_hours: 4
created: 2026-07-27
started: 2026-07-27
completed: 2026-07-27
phase: 4
depends_on: [task-291, task-292]
audit_findings: []
files_affected:
  - agent/scripts/acp.dupehound.sh
  - agent/commands/acp.version-update.md
  - agent/commands/acp.version-check-for-updates.md
  - agent/configurables/acp.configurables.yaml
  - agent/preferences/acp.default.yaml
  - agent/wiki/dupehound-integration.md
---

## Objective

Add a consented, ranked installer for dupehound and surface it at most once per ACP version from the version-update path.

## Context

Per ADR-23 decision 3: ACP may install third-party binaries **with explicit consent, via trusted package managers only**. ACP never handles raw binary bytes and never installs a language toolchain.

Ranked install methods — note that 1 and 3 need no Rust at all:

| Priority | Method | Verifies | Needs Rust |
|---|---|---|---|
| 1 | `brew install rafaelpta/dupehound/dupehound` | brew checksums | no |
| 2 | `cargo install dupehound` | crates.io checksums | yes (only if already present) |
| 3 | GitHub release binary | — | no — **printed, never executed** |

The consent-prompt idiom already exists at `acp.package-install.sh:527`.

## Steps

1. Add an `install` subcommand to `acp.dupehound.sh`:
   - detect available installers in priority order
   - show what will run, plus the v0.1.2 / 153-download maturity caveat
   - `read -p "Proceed? (y/N)"`; on `N` record the decline and exit 0
   - on `y` run the single package-manager command, re-check `command -v`, confirm
   - if no installer found: print the releases URL and stop — never curl a binary
2. Add `integrations.dupehound.install_prompt_version` (default `""`) to configurables **and to the `_index:` array** — see the note below (F-104-01).
3. Offer hook in `/acp-version-update` Step 5 ("Suggest Next Actions") and in `/acp-version-check-for-updates`:
   - show only when `install_prompt_version != current ACP version`
   - stamp the current version on accept **or** decline
   - suppress entirely when `enabled: false`
4. Document the flow in `agent/wiki/dupehound-integration.md`.


> **(F-104-01 — HIGH, silent failure)** Any new preference key MUST also be appended to the
> `_index:` array in `agent/configurables/acp.configurables.yaml`. That array is what
> `generate_preferences` iterates (`acp.preferences.sh:223-256`); keys absent from it are
> silently omitted from generated preference files, and **no validator catches this**.

## Verification

- [ ] Declining exits 0, records the version, and does not re-prompt on the next run
- [ ] Prompt reappears only after an ACP version bump
- [ ] `enabled: false` suppresses the offer permanently
- [ ] No-installer path prints the URL and never downloads
- [ ] Rust is never installed; `cargo` is used only when already present
- [ ] Non-interactive/CI contexts never block on the prompt

## User-Observable Acceptance

A user is told once per ACP upgrade that dupehound is available, can install it with one confirmation, and is never nagged again.
