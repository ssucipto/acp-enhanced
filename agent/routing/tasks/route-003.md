---
id: route-003
title: Update install/update scripts for ACP Enhanced directory layout
task_type: bash-script-refactor
milestone: none
complexity: medium
executor: deepseek-v4-pro
context_required:
  - wiki/architecture.md#command-script-binding
  - memory/patterns.md
files_affected:
  - agent/scripts/acp.install.sh
  - agent/scripts/acp.version-update.sh
tokens_est: 10000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-05-03
completed: 2026-05-03
override_reason:
depends_on: route-002  # must run after agent/ → agent/ migration is complete
---

## Context

After task-002 moves `agent/` into `agent/`, the ACP Enhanced layer directories become:
- `agent/core/` — static identity, constraints, routing session state
- `agent/memory/` — sessions.md, lessons.md, decisions.md, patterns.md (user-state files)
- `agent/routing/` — taxonomy.yml, rules.md, ledger.md, config.yml
- `agent/routing/tasks/` — routing task files
- `agent/skills/` — per-domain skill files
- `agent/wiki/` — domain.yml, architecture.md

Currently, `acp.install.sh` and `acp.version-update.sh` have NO knowledge of these directories.
A fresh `acp.install.sh` or `acp.version-update.sh` run would:
- NOT create `agent/core/`, `agent/memory/`, etc.
- NOT copy the skill files, core config, wiki, or routing files
- Leave a project without any ACP Enhanced context-loading infrastructure

This task makes install and update fully ACP Enhanced-aware.

---

## Critical Distinction: Copy vs Protect

Not all ACP Enhanced files should be blindly overwritten on update.

| Directory | On fresh install | On version-update |
| --- | --- | --- |
| `agent/core/*.yml` | Copy from repo | Overwrite (static config, no user state) |
| `agent/skills/*.md` | Copy from repo | Overwrite (content, not state) |
| `agent/wiki/*.yml`, `*.md` | Copy from repo | Overwrite (domain knowledge) |
| `agent/routing/taxonomy.yml` | Copy from repo | Overwrite |
| `agent/routing/rules.md` | Copy from repo | Overwrite |
| `agent/routing/config.yml` | Copy from repo | Overwrite |
| `agent/routing/ledger.md` | Create empty if absent | **NEVER overwrite** (user cost log) |
| `agent/routing/tasks/task-template.md` | Copy from repo | Overwrite (template only) |
| `agent/routing/tasks/task-*.md` | Do not create | **NEVER touch** (user task files) |
| `agent/memory/sessions.md` | Create empty if absent | **NEVER overwrite** (live session state) |
| `agent/memory/lessons.md` | Create empty if absent | **NEVER overwrite** (learned corrections) |
| `agent/memory/decisions.md` | Create empty if absent | **NEVER overwrite** (ADR log) |
| `agent/memory/patterns.md` | Create empty if absent | **NEVER overwrite** (reusable patterns) |

---

## Changes Required in `acp.install.sh`

After the existing directory creation block (where `agent/commands/`, `agent/scripts/`, etc.
are created), add:

```bash
# ACP Enhanced — context loading layer
echo "Installing ACP Enhanced context layer..."
mkdir -p "$TARGET_DIR/agent/core"
mkdir -p "$TARGET_DIR/agent/memory"
mkdir -p "$TARGET_DIR/agent/routing/tasks"
mkdir -p "$TARGET_DIR/agent/skills"
mkdir -p "$TARGET_DIR/agent/wiki"

# Copy static config files (always overwrite — no user state)
if [ -d "$TEMP_DIR/agent/core" ]; then
    cp "$TEMP_DIR/agent/core/"*.yml "$TARGET_DIR/agent/core/" 2>/dev/null || true
fi
if [ -d "$TEMP_DIR/agent/skills" ]; then
    cp "$TEMP_DIR/agent/skills/"*.md "$TARGET_DIR/agent/skills/" 2>/dev/null || true
fi
if [ -d "$TEMP_DIR/agent/wiki" ]; then
    cp "$TEMP_DIR/agent/wiki/"*.yml "$TARGET_DIR/agent/wiki/" 2>/dev/null || true
    cp "$TEMP_DIR/agent/wiki/"*.md  "$TARGET_DIR/agent/wiki/" 2>/dev/null || true
fi
if [ -d "$TEMP_DIR/agent/routing" ]; then
    cp "$TEMP_DIR/agent/routing/taxonomy.yml" "$TARGET_DIR/agent/routing/" 2>/dev/null || true
    cp "$TEMP_DIR/agent/routing/rules.md"     "$TARGET_DIR/agent/routing/" 2>/dev/null || true
    cp "$TEMP_DIR/agent/routing/config.yml"   "$TARGET_DIR/agent/routing/" 2>/dev/null || true
    # task-template only (never copy task-*.md files)
    cp "$TEMP_DIR/agent/routing/tasks/task-template.md" \
       "$TARGET_DIR/agent/routing/tasks/" 2>/dev/null || true
fi

# Create user-state files only if absent (never overwrite)
_create_if_absent() {
    local file="$1"; local content="$2"
    [ -f "$file" ] || echo "$content" > "$file"
}
_create_if_absent "$TARGET_DIR/agent/memory/sessions.md" \
    "# Session Memory\n# Created by acp.install.sh — do not delete\n"
_create_if_absent "$TARGET_DIR/agent/memory/lessons.md" \
    "# Lessons Log\n# Created by acp.install.sh — do not delete\n"
_create_if_absent "$TARGET_DIR/agent/memory/decisions.md" \
    "# Architecture Decision Records (ADR Log)\n# Add entries via /acp-decide command\n"
_create_if_absent "$TARGET_DIR/agent/memory/patterns.md" \
    "# Reusable Patterns\n# Created by acp.install.sh — do not delete\n"
_create_if_absent "$TARGET_DIR/agent/routing/ledger.md" \
    "# Routing Cost Ledger\n# Appended by acp-dispatch.ts on each task run\n"

echo "${GREEN}✓${NC} ACP Enhanced context layer installed"
```

---

## Changes Required in `acp.version-update.sh`

Same logic as install, but the update script uses the local project directory (not `$TARGET_DIR`).
Add after the scripts update block:

```bash
# ACP Enhanced — update static context files (preserve user-state files)
echo "Updating ACP Enhanced context layer..."
mkdir -p agent/core agent/memory agent/routing/tasks agent/skills agent/wiki

# Overwrite static files
[ -d "$TEMP_DIR/agent/core" ]   && cp "$TEMP_DIR/agent/core/"*.yml   agent/core/   2>/dev/null || true
[ -d "$TEMP_DIR/agent/skills" ] && cp "$TEMP_DIR/agent/skills/"*.md  agent/skills/ 2>/dev/null || true
[ -d "$TEMP_DIR/agent/wiki" ] && {
    cp "$TEMP_DIR/agent/wiki/"*.yml agent/wiki/ 2>/dev/null || true
    cp "$TEMP_DIR/agent/wiki/"*.md  agent/wiki/ 2>/dev/null || true
}
[ -d "$TEMP_DIR/agent/routing" ] && {
    cp "$TEMP_DIR/agent/routing/taxonomy.yml" agent/routing/ 2>/dev/null || true
    cp "$TEMP_DIR/agent/routing/rules.md"     agent/routing/ 2>/dev/null || true
    cp "$TEMP_DIR/agent/routing/config.yml"   agent/routing/ 2>/dev/null || true
    cp "$TEMP_DIR/agent/routing/tasks/task-template.md" \
       agent/routing/tasks/                   2>/dev/null || true
}

# Preserve user-state files — only create if somehow missing
[ -f "agent/memory/sessions.md"   ] || echo "# Session Memory"    > agent/memory/sessions.md
[ -f "agent/memory/lessons.md"    ] || echo "# Lessons Log"       > agent/memory/lessons.md
[ -f "agent/memory/decisions.md"  ] || echo "# ADR Log"           > agent/memory/decisions.md
[ -f "agent/memory/patterns.md"   ] || echo "# Reusable Patterns" > agent/memory/patterns.md
[ -f "agent/routing/ledger.md"    ] || echo "# Routing Ledger"    > agent/routing/ledger.md

echo "${GREEN}✓${NC} ACP Enhanced context layer updated"
```

Also update the "What was updated" completion message to include:
```
  ✓ ACP Enhanced context layer (core/, skills/, wiki/, routing/)
```

---

## Acceptance Criteria

- [ ] `acp.install.sh` creates `agent/core/`, `agent/memory/`, `agent/routing/tasks/`, `agent/skills/`, `agent/wiki/` on fresh install
- [ ] `acp.install.sh` copies all static files from repo into those directories
- [ ] `acp.install.sh` creates user-state files (`sessions.md`, `lessons.md`, `decisions.md`, `patterns.md`, `ledger.md`) with placeholder content if absent
- [ ] `acp.version-update.sh` overwrites static files (core, skills, wiki, routing config)
- [ ] `acp.version-update.sh` NEVER overwrites `sessions.md`, `lessons.md`, `decisions.md`, `patterns.md`, `ledger.md`
- [ ] `acp.version-update.sh` NEVER overwrites `agent/routing/tasks/task-*.md` (only `task-template.md`)
- [ ] Completion message in both scripts updated to include ACP Enhanced context layer
- [ ] All existing E2E tests still pass (install/update behavior unchanged for original dirs)

---

## Sequencing Note

Run after task-002. The directories being referenced (`agent/core/`, etc.) must exist in the
repo before the install/update scripts can copy from them. Task-002 creates them by migrating
from `agent/`.
