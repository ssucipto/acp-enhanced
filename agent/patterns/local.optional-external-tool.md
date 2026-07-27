# Optional External-Tool Integration Pattern

<!-- @acp.meta.pattern
topic: optional, external-tool, integration, feature-detection, preferences, graceful-degradation, coderabbit
description: Three-gate contract (opt-in -> detection -> silent degradation) for integrating an external tool ACP consumers may not have installed
applies_to: integration, scripting, preferences
status: active
updated: 2026-07-27
@acp.meta.end -->

**Category**: Architecture
**Version**: 1.1.0
**Created**: 2026-07-23
**Source**: audit-097, audit-098, audit-102, audit-103, ADR-21, ADR-23

---

## Overview

ACP Enhanced is a distributed framework: whatever integration code it ships lands in repositories where the external tool (CodeRabbit, Aikido, `shellcheck`, `gitleaks`, `dupehound`, ...) is **not installed**. This pattern makes such integrations **optional by construction** — a fresh install with the tool absent behaves exactly as before — through three independent gates that must all hold before any tool-specific behavior runs.

Two variants are allowed:

- **Variant A: opt-in authoritative** — default for cloud tools and any tool that fails the Variant B eligibility test.
- **Variant B: detection-as-consent** — allowed only for a narrow class of local analyzers that are offline, read-only, and no-egress in the ACP code path.

Both variants still use the same three gates:

1. **Preference gate** — explicit user setting, defaulting to safe behavior.
2. **Detection gate** — the tool/config is actually present.
3. **Graceful degradation** — absence is a silent no-op, never an error.

**Binding rule**: the tool **augments, never gates** an ACP code path. No ACP command becomes incorrect or fails because the tool is missing.

---

## When to Use This Pattern

✅ **Use when:**
- Integrating a third-party tool that ACP consumers may or may not have (CodeRabbit, Aikido, a CLI, a cloud service).
- The integration is additive — ACP works fully without it.

❌ **Don't use when:**
- The tool is a hard prerequisite for the command to function at all (e.g. `gh` in `acp.branch-protection-setup.sh` — there, absence is a real error, exit non-zero). That is a *required*-dependency check, the inverse of this pattern.

---

## Core Principles

1. **Absence is normal, not an error.** Disabled or missing → silent success (exit 0), unlike a required dependency.
2. **Variant choice is explicit.** Use Variant A unless the tool passes the Variant B eligibility test in this document.
3. **Detection is cheap and output-free.** Check for a config file or `command -v` — never parse the tool's output just to decide whether it is installed.
4. **Explicit `false` always wins.** Under Variant B, auto-detection may enable the tool only when the preference is unset; an explicit `integrations.<tool>.enabled: false` must disable it.
5. **Layer downward only.** A tool script sources `acp.preferences.sh` (→ `acp.common.sh`). Never make `acp.common.sh` depend on preferences — preferences.sh already sources it (circular source, audit-098 F-098-01).
6. **Assisted install stays bounded.** ACP may offer installation only with explicit consent and only via trusted package managers already present on the host. Never download binaries directly, never curl-pipe installers, and never install Rust/toolchains on the user's behalf.

---

## Implementation

### Variant A — opt-in authoritative

Use Variant A for CodeRabbit, Aikido, and any other tool where privacy, egress, mutation, or output-contract uncertainty means ACP must not infer consent from mere presence.

| Gate | Mechanism | Default |
|------|-----------|---------|
| 1. Preference | `integrations.<tool>.enabled` preference | `false` |
| 2. Detection | `<tool>_available()` — config file present / `command -v` | n/a |
| 3. Degradation | `<tool>_active()` = enabled AND available; else silent no-op | skip |

Reference implementation: `agent/scripts/acp.coderabbit.sh`

```bash
# Sourced library — do NOT `set -e` (would leak into caller's shell).
_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${_DIR}/acp.preferences.sh"   # brings get_preference (+ common.sh)

coderabbit_available() {              # Gate 2 — config-file detection only
  local cfg; cfg="$(get_preference_or acp integrations.coderabbit.config_path .coderabbit.yaml)"
  [[ -f "$cfg" ]]
}

coderabbit_active() {                 # Gates 1 AND 2
  local en; en="$(get_preference acp integrations.coderabbit.enabled 2>/dev/null || echo false)"
  [[ "$en" == "true" ]] && coderabbit_available   # exact ==true (a false default is non-empty)
}
```

Callers guard tool-specific work with the active-check:

```bash
source agent/scripts/acp.coderabbit.sh
if coderabbit_active; then
  # CodeRabbit-aware branch
else
  : # nothing — identical to a repo that never heard of CodeRabbit
fi
```

### Variant B — detection-as-consent

Use Variant B only for **local deterministic analyzers** that satisfy **all** of the following:

1. **Offline**: the ACP code path does not require network access and does not send repo data to a third party.
2. **Read-only**: normal invocation only inspects the workspace; it does not rewrite project files, install hooks, or mutate git state.
3. **No egress**: the tool's ACP integration never uploads, syncs, or phones home as part of detection or scanning.

Examples in ADR-23 scope: `shellcheck`, `gitleaks`, `dupehound` when used strictly as local analyzers.

Variant B behavior:

| Preference state | Tool detected? | Result |
|------|-----------|---------|
| explicit `false` | yes/no | disabled |
| explicit `true` | yes | enabled |
| explicit `true` | no | silent no-op |
| unset | yes | enabled |
| unset | no | silent no-op |

Implementation rule: Variant B is **detection-as-consent, not detection-overrides-consent**. Auto-enable is allowed only when the preference is unset. Once the user writes `false`, ACP must skip the tool even if it is installed everywhere.

### Assisted install boundary

If a Variant B tool is absent, ACP may offer to install it only with explicit consent and only through a trusted package manager already available on the machine:

- `brew install <tool>` is allowed when `brew` is already present.
- `cargo install <tool>` is allowed when `cargo` is already present.
- Direct binary download is never allowed.
- Curl-pipe/bootstrap installers are never allowed.
- Installing Rust or another language toolchain just to obtain the tool is never allowed.

If the package manager is absent, ACP may explain the prerequisite but must not bootstrap it.

### Checklist for choosing a variant

- If the tool is cloud-backed, output-shaped by vendor behavior, or sends data off-host, use **Variant A**.
- If the tool mutates the workspace or repo as part of normal use, use **Variant A**.
- Only choose **Variant B** when the tool is offline + read-only + no-egress, and the explicit-`false` escape hatch is implemented.
- ADR-19, ADR-21, and ADR-22 remain in force for CodeRabbit and Aikido. Variant B must not be applied to them by analogy.

---

## Anti-Patterns

### ❌ Testing preference truthiness by presence

**Why it's bad**: a boolean `false` default resolves as the non-empty string `"false"`, so `has_preference` / `[[ -n "$v" ]]` reports it as "set/on" (audit-098 F-098-03).

```bash
# ❌ Bad — "false" is non-empty
if has_preference acp integrations.coderabbit.enabled; then act; fi
# ✅ Good — exact match
[[ "$(get_preference acp integrations.coderabbit.enabled)" == "true" ]] && act
```

### ❌ Putting the detection helper in `acp.common.sh`

**Why it's bad**: `acp.preferences.sh` sources `acp.common.sh`; a `get_preference` call from common.sh is a circular source (audit-098 F-098-01). **Instead**: a dedicated `acp.<tool>.sh` that sources preferences.

### ❌ Designing against the tool's output before it exists

**Why it's bad**: reserving keys or parsing formats for a tool you haven't run yet is speculative (ADR-19). **Instead**: reserve only keys with a live consumer; defer output-shaped work until real adoption.

---

## Related

- **[ADR-21](../memory/decisions.md)** — CodeRabbit optionality foundation carved out of the ADR-19 gate
- **[ADR-23](../memory/decisions.md)** — local deterministic analyzers, Variant B, assisted install boundaries
- **`agent/scripts/acp.branch-protection-setup.sh:27`** — the *required*-dependency inverse (`gh` absent = error)
- **`agent/wiki/coderabbit-integration.md`** — user-facing guide for the CodeRabbit instance of this pattern

---

## Checklist for Implementation

- [ ] Variant A or Variant B is chosen explicitly and justified against this document
- [ ] Preference `integrations.<tool>.enabled` exists
- [ ] Detection helper is output-free and config/`command -v`-based
- [ ] Variant A: `<tool>_active()` requires enabled AND available, exact `== "true"`
- [ ] Variant B: explicit `false` disables the tool even when detected; unset + detected may enable it
- [ ] Every tool-specific branch has a tested absent path (exit 0, silent)
- [ ] Helper lives in a dedicated script sourcing preferences (not common.sh)
- [ ] No ACP command's correctness depends on the tool
- [ ] Any assisted install path uses `brew`/`cargo` only with explicit consent, never direct binary download

---

**Status**: Active
**Recommendation**: Use for every optional third-party integration in ACP; CodeRabbit (M78) is the reference instance, Aikido is the next expected consumer.
**Last Updated**: 2026-07-27
**Contributors**: ACP Project
