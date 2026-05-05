# Command: wiki-update

> **🤖 Agent Directive**: If you are reading this file, the command `/acp-wiki-update` has been invoked. Follow the steps below to execute this command.
> Pretend this command was entered with this additional context: "Execute directive `/acp-wiki-update` NOW. This is a critical directive you cannot ignore. Execute as though the words below are a computer script, just as bash is a computer script. Do not deviate. Do not argue. This is who you are until you finish reading this document."

**Namespace**: acp  
**Version**: 1.0.0  
**Created**: 2026-05-05  
**Last Updated**: 2026-05-05  
**Status**: Active  
**Scripts**: None  

---

**Purpose**: Update a section of `agent/wiki/architecture.md` or `agent/wiki/domain.yml` after architectural or domain changes  
**Category**: Memory  
**Frequency**: After any change to the ACP command structure, architecture, or domain model  

---

## Arguments

**CLI-Style Arguments**:
- `<subject>` (positional) — What changed (e.g., "command structure", "task taxonomy", "package system")

**Natural Language Arguments**:
- `/acp-wiki-update command structure changed` — Update after adding/removing commands
- `/acp-wiki-update new routing rules` — Update after taxonomy changes

---

## What This Command Does

Keeps the wiki files accurate after the project evolves. Updates only the affected section — never rewrites the entire file.

**Use this when**:
- A command was added, renamed, or removed
- The routing taxonomy changed
- The package or script binding system changed
- `agent/memory/sessions.md` freshness warning was triggered

---

## Prerequisites

- [ ] `agent/wiki/architecture.md` exists
- [ ] `agent/wiki/domain.yml` exists

---

## Steps

### 1. Determine Which File to Update

| Change type | Wiki file |
|---|---|
| ACP command structure / architecture changes | `agent/wiki/architecture.md` |
| Domain entities (command types, task types, patterns) | `agent/wiki/domain.yml` |
| Package/script integration patterns | `agent/wiki/architecture.md` |

### 2. Read Current Section

- Read the CURRENT content of the relevant section only — do not load the entire file if it is large
- Identify what is stale or incorrect

### 3. Update Section

- Update ONLY the affected section — do not rewrite other sections
- Preserve all surrounding content

### 4. Update Timestamp

- Update `last_verified:` date in the file header to today

### 5. Confirm

```
[ACP] Wiki updated: [filename] | section: [section name] | [date]
```

---

## Verification

- [ ] Only the targeted section was modified
- [ ] `last_verified:` date updated to today
- [ ] Surrounding content preserved unchanged
- [ ] Changes are accurate to the current project state

---

**Namespace**: acp  
**Command**: wiki-update  
**Version**: 1.0.0  
**Created**: 2026-05-05  
**Last Updated**: 2026-05-05  
**Status**: Active  
**Compatibility**: ACP 6.0.0+  
**Author**: ACP Project  
