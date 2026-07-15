# ACP Enhanced — Field Feedback Report
## Submission: Bootstrap Cursor slash commands during install / update

**Report ID**: feedback-001  
**Date**: 2026-06-06  
**Project**: SmartDojo (Rygan) — Emergent → Firebase / Firestore / Cloud Run migration  
**ACP Version in use**: 6.9.2  
**Executor**: maintainer  
**Category**: gap — IDE integration parity (OpenCode vs Cursor)  
**Severity**: medium  
**Upstream repo**: https://github.com/ssucipto/acp-enhanced  
**Status**: open — local workaround implemented in SmartDojo; proposing upstream adoption  

---

## 1. Problem Statement

ACP Enhanced documents and promotes command invocation as `/acp-<name>` (slash + hyphen). Install and version-update already bootstrap **OpenCode** slash commands into `.opencode/commands/`, but there is **no equivalent bootstrap for Cursor**.

On a fresh `acp.install.sh` run in Cursor, developers cannot type `/acp-init` from the `/` menu. The only workable paths are:

- `@agent/commands/acp.init.md` (file reference — awkward, not discoverable)
- `@acp-init` (inconsistent; depends on editor indexing, not a first-class slash command)

This creates a **false expectation**: AGENT.md and every command directive say `/acp-init`, but Cursor users hit a dead end until they manually wire integration.

OpenCode and Cursor should have **parity** at install time, the same way `.opencode/commands/` is copied today.

---

## 2. Root Cause Analysis

| Factor | Detail |
|--------|--------|
| **Design assumption** | ACP assumes slash commands work uniformly across AI IDEs |
| **Actual Cursor behaviour** | Cursor discovers slash commands only from `.cursor/commands/*.md` at project root (and `~/.cursor/commands/` globally) — it does **not** read `.opencode/commands/` |
| **Partial prior art** | `acp.design-spec.md` mentions adding `.cursor/commands/acp-design-spec.md` manually; no generator or install hook exists upstream |
| **Install script gap** | `acp.install.sh` and `acp.version-update.sh` copy `.opencode/commands/` but never create `.cursor/commands/` or `.cursor/rules/` |
| **Agent protocol gap** | No upstream rule telling Cursor agents that `@acp-*` aliases must **execute** (not merely read) the matching `agent/commands/` file |

The gap is **bootstrap / packaging**, not command spec quality. Canonical sources in `agent/commands/` are correct; the missing layer is IDE-specific entrypoints.

---

## 3. Proposed Fix (upstream)

### 3.1 Add `agent/scripts/acp.cursor-commands-sync.sh` to ACP core

Generate `.cursor/commands/<slash-name>.md` from every `agent/commands/acp.*.md` and `git.*.md`:

| Source | Generated slash command |
|--------|-------------------------|
| `agent/commands/acp.init.md` | `.cursor/commands/acp-init.md` → `/acp-init` |
| `agent/commands/acp.design-spec.md` | `.cursor/commands/acp-design-spec.md` → `/acp-design-spec` |

**Naming rule**: replace `.` with `-` in the basename (`acp.init` → `acp-init`).

**Wrapper content** (thin — do not duplicate full command bodies):

```markdown
---
description: "<extracted from **Purpose**: line in source>"
---

# ACP Command: /acp-init

Execute ACP Enhanced command `/acp-init`.

1. Read and follow **every step** in `agent/commands/acp.init.md`.
2. Treat text after the command in the user's message as command arguments.
3. Run the command header from the source file, then continue unless the source explicitly waits for input.

**Canonical source**: `agent/commands/acp.init.md`
**Equivalent invocations**: `/acp-init`, `@acp-init`, `@agent/commands/acp.init.md`
```

`description` frontmatter improves discoverability in Cursor's `/` picker.

### 3.2 Hook into install and version-update

In **`acp.install.sh`** (after `.opencode/commands/` copy):

```bash
if [ -f "$TARGET_DIR/agent/scripts/acp.cursor-commands-sync.sh" ]; then
    chmod +x "$TARGET_DIR/agent/scripts/acp.cursor-commands-sync.sh"
    "$TARGET_DIR/agent/scripts/acp.cursor-commands-sync.sh"
fi
```

In **`acp.version-update.sh`** (same placement, after opencode sync):

```bash
./agent/scripts/acp.cursor-commands-sync.sh
```

Post-install verification should report:

```
✓ cursor slash commands (.cursor/commands/) — N files
```

### 3.3 Ship `.cursor/rules/acp-slash-commands.mdc` (optional but recommended)

Always-on Cursor rule (`alwaysApply: true`) that defines:

- `/acp-*` is canonical in Cursor
- `@acp-*` and `@agent/commands/acp.*.md` are **execution aliases**, not read-only refs
- Agents must load and run the full `agent/commands/` spec

This closes the behavioural gap when users fall back to `@` references.

### 3.4 Documentation in ACP wiki / AGENT.md

Add a short **Cursor integration** section (or `agent/wiki/cursor.md`):

- How slash commands are generated
- When to re-run sync (after new commands or `acp.version-update`)
- Troubleshooting (reload window if `/` menu stale)

Do **not** bloat `AGENTS.md` with project content — keep IDE integration in wiki or a dedicated doc linked from install output.

### 3.5 Extend `/acp-command-create` (future)

When a new command is created via `/acp-command-create`, auto-regenerate `.cursor/commands/` (and optionally `.opencode/commands/`) so parity is maintained without a manual step.

### 3.6 Acceptance criteria

- [ ] Fresh `acp.install.sh` produces `.cursor/commands/` with one file per `acp.*.md` and `git.*.md` command
- [ ] `acp.version-update.sh` regenerates `.cursor/commands/` without overwriting user customisations in `agent/commands/`
- [ ] Install summary lists cursor command count alongside opencode command count
- [ ] E2E test: `tests/e2e/acp.cursor-commands-sync.sh` (or similar) asserts file count parity and naming
- [ ] Documented in AGENT.md or agent wiki

---

## 4. Evidence

### 4.1 Observed behaviour (SmartDojo, 2026-06-06)

- ACP 6.9.2 installed; `.opencode/commands/` present (67 files)
- `.cursor/commands/` **absent** after install
- User could only invoke via `@agent/commands/...` or `@acp-*`, not `/acp-*`
- `acp.design-spec.md` line ~557 references manual `.cursor/commands/` creation — confirms intent, not automation

### 4.2 Reference implementation (SmartDojo local workaround)

Files added in consuming project (candidates for upstream port):

| File | Role |
|------|------|
| `agent/scripts/acp.cursor-commands-sync.sh` | Generator script |
| `.cursor/commands/*.md` | 67 generated wrappers |
| `.cursor/rules/acp-slash-commands.mdc` | Always-on agent protocol |
| `docs/workflows/cursor-acp-enhanced.md` | Consumer-facing integration guide |

Local patches to install/update scripts (should move upstream):

- `agent/scripts/acp.install.sh` — call sync after opencode copy
- `agent/scripts/acp.version-update.sh` — call sync + list in summary

### 4.3 Cursor slash command mechanics (external)

Cursor discovers commands from `.cursor/commands/*.md`; filename becomes `/command-name`. YAML `description` frontmatter populates the picker. See [Cursor plugins reference — Commands format](https://cursor.com/docs/reference/plugins).

### 4.4 Parity comparison

| Artifact | OpenCode (today) | Cursor (today) | Cursor (proposed) |
|----------|------------------|----------------|-------------------|
| Slash command dir | `.opencode/commands/` | — | `.cursor/commands/` |
| Install bootstrap | ✅ `acp.install.sh` | ❌ | ✅ sync script |
| Version update | ✅ `acp.version-update.sh` | ❌ | ✅ sync script |
| Agent alias protocol | N/A | ❌ | ✅ `.cursor/rules/` |

---

## 5. Suggested upstream PR checklist

1. Add `agent/scripts/acp.cursor-commands-sync.sh` to acp-enhanced repo (copy from SmartDojo reference or reimplement)
2. Wire into `acp.install.sh` and `acp.version-update.sh`
3. Add bundled `.cursor/rules/acp-slash-commands.mdc` template (or generate on install)
4. Add `agent/wiki/cursor-integration.md` (or section in existing wiki)
5. Add E2E test for sync output count and naming
6. Update install post-verify block to check `.cursor/commands/` count ≥ `agent/commands/acp.*.md` count
7. Mention in CHANGELOG under 6.10.x

---

## 6. Non-goals / constraints

- **Do not duplicate** full command bodies into `.cursor/commands/` — wrappers only; `agent/commands/` stays canonical
- **Do not** require Cursor-specific logic inside individual `agent/commands/*.md` files
- **Preserve** `.opencode/commands/` as-is; this proposal adds Cursor parity, not a replacement
- **Optional**: allow `agent/preferences/cursor.yml` to disable generation for teams that do not use Cursor

---

## 7. How to action this feedback

**For ACP Enhanced maintainers:**

1. Review reference implementation in SmartDojo (`agent/scripts/acp.cursor-commands-sync.sh`)
2. Port script + install hooks into `acp-enhanced` mainline
3. Close this feedback when released in a tagged ACP version

**For SmartDojo (until upstream merge):**

- Keep local sync script and generated `.cursor/commands/`
- Re-run `./agent/scripts/acp.cursor-commands-sync.sh` after each `acp.version-update.sh`
- Remove local install-script patches once upstream ships the same behaviour

---

*Submitted via `/acp-feedback` pattern — SmartDojo migration project, Cursor + ACP Enhanced bootstrap gap.*
