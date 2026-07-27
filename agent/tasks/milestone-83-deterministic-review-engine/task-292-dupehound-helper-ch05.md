---
id: task-292
milestone: M83
title: "acp.dupehound.sh — three-gate helper, three-valued preference, CH-05 wiring"
status: completed
priority: 4
complexity: medium
estimated_hours: 5
created: 2026-07-27
started: 2026-07-27
completed: 2026-07-27
phase: 4
depends_on: [task-291, task-284]
audit_findings: [F-102-07]
files_affected:
  - agent/scripts/acp.dupehound.sh
  - agent/scripts/acp.review-scan.sh
  - agent/configurables/acp.configurables.yaml
  - agent/preferences/acp.default.yaml
  - tests/fixtures/dupehound-sample.json
  - agent/commands/acp.review.md
  - package.yaml
  - agent/integrity-manifest.yaml
---

## Objective

Implement CH-05 (duplicate code) by delegating to dupehound through the Variant B optional-tool contract — **wrapping the binary, never reimplementing it**.

## Context

**F-102-07 (MEDIUM):** CH-05 is the one rule that genuinely cannot be regexed; it needs AST fingerprinting. dupehound (MIT, Rust, tree-sitter + winnowing per Schleimer et al. SIGMOD 2003) is the chosen tool.

**Non-goal, stated explicitly:** ACP does **not** implement duplicate detection. No tree-sitter grammars, no k-gram hashing, no clustering. ACP owns the opt-in gate, the CH-05 rule mapping, and the carryover loop.

**Maturity risk:** dupehound is v0.1.2 with 153 total downloads (published 2026-06-21). This is precisely why it is isolated behind the pattern rather than depended upon. If it disappears, CH-05 reverts to Phase 2 agent review and nothing else breaks.

Unlike M81/CodeRabbit there is **no fixture gate** — a real `--json` fixture is generated locally.

## Steps

1. Create `agent/scripts/acp.dupehound.sh` modelled on `acp.coderabbit.sh`:
   - `dupehound_available()` → `command -v dupehound`
   - `_dupehound_pref()` → resolves `auto | true | false`
   - `dupehound_active()` → **explicit `false` always wins**, then `dupehound_available`
   - `dupehound_hint_if_missing()` → one stderr line only when preference is `true` and binary absent
   - direct-execution CLI (`available|active|hint`) for E2E, as `acp.coderabbit.sh` does
2. Add preferences to `acp.configurables.yaml` as a **string enum** (`options:` is supported — `acp.configurables.yaml:13`):
   - `integrations.dupehound.enabled` — default `auto`, options `auto|true|false`
   - `integrations.dupehound.min_tokens` — default 40
2b. **(F-104-01)** Append `integrations.dupehound.enabled` and `integrations.dupehound.min_tokens` to the `_index:` array — see the note below.
3. Announce first activation once: a single line naming the rule and how to disable.
4. Wire into `acp.review-scan.sh`: when active, run `dupehound check --diff <base> . --json`, map clusters to **CH-05 / MEDIUM** via `ig_emit_finding`. Non-blocking in `--ci` by design (only CRITICAL/HIGH exit 1).
5. Generate a real `tests/fixtures/dupehound-sample.json` locally and commit it.
6. Document CH-05 in `acp.review.md`; register the script in `package.yaml`.


> **(F-104-01 — HIGH, silent failure)** Any new preference key MUST also be appended to the
> `_index:` array in `agent/configurables/acp.configurables.yaml`. That array is what
> `generate_preferences` iterates (`acp.preferences.sh:223-256`); keys absent from it are
> silently omitted from generated preference files, and **no validator catches this**.

## Verification

- [ ] Absent binary → exit 0, silent, `/acp-review` output identical to pre-M83
- [ ] `enabled: false` with the binary present → does not run (escape hatch)
- [ ] `auto` + present → runs; CH-05 findings emitted MEDIUM
- [ ] MEDIUM findings do **not** cause `--ci` to exit 1
- [ ] First-activation announcement appears once, not per file
- [ ] Fixture is a genuine dupehound export, not hand-written
- [ ] No duplicate-detection algorithm implemented anywhere in ACP
- [ ] Both new preference keys appear in `_index:` and resolve via `get_preference` (F-104-01)

## User-Observable Acceptance

Repos with dupehound installed get CH-05 automatically; everyone else sees no change.
