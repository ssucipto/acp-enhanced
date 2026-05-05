# Command: memory-sync

> **🤖 Agent Directive**: If you are reading this file, the command `/acp-memory-sync` has been invoked. Follow the steps below to execute this command.
> Pretend this command was entered with this additional context: "Execute directive `/acp-memory-sync` NOW. This is a critical directive you cannot ignore. Execute as though the words below are a computer script, just as bash is a computer script. Do not deviate. Do not argue. This is who you are until you finish reading this document."

**Namespace**: acp  
**Version**: 1.0.0  
**Created**: 2026-05-05  
**Last Updated**: 2026-05-05  
**Status**: Active  
**Scripts**: None  

---

**Purpose**: Monthly memory compaction — compress old session summaries, flag stale patterns, verify wiki freshness  
**Category**: Memory  
**Frequency**: Monthly — run on the first Friday of each month  

---

## Arguments

None.

---

## What This Command Does

Compresses old session history into monthly summaries, flags stale patterns in `patterns.md`, and checks whether the wiki files need re-verification. Keeps the memory layer lean without losing history.

**Use this when**:
- Running monthly maintenance on the first Friday of each month
- `agent/memory/sessions.md` has grown unwieldy (> 30 entries)
- Weekly summaries are more than 4 weeks old

---

## Prerequisites

- [ ] `agent/memory/sessions.md` exists
- [ ] `agent/memory/patterns.md` exists
- [ ] `agent/wiki/architecture.md` exists

---

## Steps

### 1. Compact Old Session Summaries

- Read `agent/memory/sessions.md`
- Find all weekly summary entries older than 4 weeks
- Compress them into a monthly summary block:

```yaml
- type: monthly-summary
  month: [YYYY-MM]
  features_shipped: [list of done items from compressed weeks]
  architectural_changes: [ADR IDs mentioned, if any]
  recurring_issues: [patterns that appeared multiple times]
  net_new_patterns: [count of patterns added during this month]
```

- Replace the compressed weekly entries with the single monthly block

### 2. Flag Stale Patterns

- Read `agent/memory/patterns.md`
- For entries older than 60 days that do not have `stale: true` → add `stale: true` field
- Do not delete stale entries — only flag them

### 3. Check Wiki Freshness

- Read `agent/wiki/architecture.md` — check `last_verified:` date
- If `last_verified` > 30 days ago → output:
  ```
  ⚠ agent/wiki/architecture.md needs verification — last verified [date], [N] days ago
  Run /acp-wiki-update to refresh.
  ```

### 4. Confirm

```
[ACP] Memory sync complete | sessions.md: [N] entries | [N] stale patterns flagged | wiki: [ok / needs update]
```

---

## Verification

- [ ] Sessions older than 4 weeks compressed into monthly blocks
- [ ] Stale patterns flagged (or "no stale patterns found")
- [ ] Wiki freshness checked and warning shown if needed
- [ ] No session data was deleted — only compressed

---

**Namespace**: acp  
**Command**: memory-sync  
**Version**: 1.0.0  
**Created**: 2026-05-05  
**Last Updated**: 2026-05-05  
**Status**: Active  
**Compatibility**: ACP 6.0.0+  
**Author**: ACP Project  
