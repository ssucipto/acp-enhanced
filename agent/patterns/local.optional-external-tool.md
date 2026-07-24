# Optional External-Tool Integration Pattern

<!-- @acp.meta.pattern
topic: optional, external-tool, integration, feature-detection, preferences, graceful-degradation, coderabbit
description: Three-gate contract (opt-in -> detection -> silent degradation) for integrating an external tool ACP consumers may not have installed
applies_to: integration, scripting, preferences
status: active
updated: 2026-07-23
@acp.meta.end -->

**Category**: Architecture
**Version**: 1.0.0
**Created**: 2026-07-23
**Source**: audit-097, audit-098, ADR-21

---

## Overview

ACP Enhanced is a distributed framework: whatever integration code it ships lands in repositories where the external tool (CodeRabbit, Aikido, …) is **not installed**. This pattern makes such integrations **optional by construction** — a fresh install with the tool absent behaves exactly as before — through three independent gates that must all hold before any tool-specific behavior runs:

1. **Opt-in** — a preference, default off.
2. **Detection** — the tool/config is actually present.
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
2. **Opt-in is authoritative.** Even when the tool is present, do nothing unless the user enabled it.
3. **Detection is cheap and output-free.** Check for a config file or `command -v` — never parse the tool's output.
4. **Layer downward only.** A tool script sources `acp.preferences.sh` (→ `acp.common.sh`). Never make `acp.common.sh` depend on preferences — preferences.sh already sources it (circular source, audit-098 F-098-01).

---

## Implementation

### The three gates

| Gate | Mechanism | Default |
|------|-----------|---------|
| 1. Opt-in | `integrations.<tool>.enabled` preference | `false` |
| 2. Detection | `<tool>_available()` — config file present / `command -v` | n/a |
| 3. Degradation | `<tool>_active()` = enabled AND available; else silent no-op | skip |

### Reference implementation — `agent/scripts/acp.coderabbit.sh`

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
- **`agent/scripts/acp.branch-protection-setup.sh:27`** — the *required*-dependency inverse (`gh` absent = error)
- **`agent/wiki/coderabbit-integration.md`** — user-facing guide for the CodeRabbit instance of this pattern

---

## Checklist for Implementation

- [ ] Preference `integrations.<tool>.enabled` exists, default `false`
- [ ] Detection helper is output-free and config/`command -v`-based
- [ ] `<tool>_active()` requires enabled AND available, exact `== "true"`
- [ ] Every tool-specific branch has a tested absent path (exit 0, silent)
- [ ] Helper lives in a dedicated script sourcing preferences (not common.sh)
- [ ] No ACP command's correctness depends on the tool

---

**Status**: Active
**Recommendation**: Use for every optional third-party integration in ACP; CodeRabbit (M78) is the reference instance, Aikido is the next expected consumer.
**Last Updated**: 2026-07-23
**Contributors**: ACP Project
