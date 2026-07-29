---
id: task-305
milestone: M85
title: "Fix | truncation in AST encoding — writer and reader together"
status: not_started
priority: 5
complexity: medium
estimated_hours: 4
created: 2026-07-28
started: null
completed: null
phase: 1
depends_on: [task-297]
audit_findings: [F-112-01, F-112-02]
files_affected:
  - agent/scripts/acp.yaml-parser.sh
  - tests/acp.yaml-parser.test.sh
---

## Objective

Stop the YAML parser silently truncating any value that contains a `|`, by fixing the AST writer and reader in the same change.

## Context

**F-112-01 (HIGH).** The live AST writers at `agent/scripts/acp.yaml-parser.sh:444` and `:484` emit `${next_id}|${type}|${key}|${value}|${parent_id}|` with **no escaping**. `get_field()` (`:84`) splits with `cut -d'|'`, so an embedded pipe shifts every later field.

Reproduced:

```yaml
piped: "a|b|c"
```

| | Value |
|---|---|
| AST record | `2\|scalar\|piped\|"a\|b\|c"\|0\|` |
| `yaml_get` returns | `"a` |
| Expected | `a\|b\|c` |

19 files source this parser — `acp.install.sh`, `acp.package-install.sh`, `acp.package-publish.sh` among them. A manifest or preference value containing `|` is corrupted with no error.

**F-112-02 (MEDIUM).** `add_node()` (`:60-73`) *does* escape `|`, and has **zero call sites**. It is dead code. Anyone reading it concludes escaping exists when the live paths do none. Note that `cut -d'|'` would not honour `\|` anyway — which is why writer and reader must change together.

This task runs **before** task-299 so the encoding is settled before the splitter is rewritten; otherwise the reader gets written twice.

## Steps

1. Choose one encoding and document it in the file header. Escaping `|` as `\|` is the obvious candidate, but confirm the reader can distinguish `\|` from a literal backslash followed by a delimiter before committing to it.
2. Apply it at both live writers (`:444`, `:484`). They are duplicated — consider collapsing them into one helper so a third writer cannot drift again.
3. Make the reader honour the encoding. `cut` cannot; this is unblocked by task-299's parameter-expansion splitter, so coordinate the two.
4. Resolve dead `add_node()`: either delete it, or make it the single writer the other two call. Do not leave a third encoding opinion in the file.
5. Add assertions to `tests/acp.yaml-parser.test.sh` covering `|` in values, `|` in keys, a trailing `|`, a value that is only `|`, and a literal backslash next to a pipe.
6. Check whether any committed YAML in the repo currently contains `|` in a value and would change behaviour — report what you find.

## Verification

- [ ] `piped: "a|b|c"` round-trips through `yaml_parse` → `yaml_get` intact
- [ ] `|` in a key round-trips
- [ ] Value that is exactly `|` round-trips
- [ ] Literal backslash adjacent to a pipe is not mangled
- [ ] `yaml_set` writing a `|`-containing value, then `yaml_get`, returns it intact
- [ ] All 89 + 11 existing assertions still pass
- [ ] Only one AST-writing code path remains, or all paths share one encoding helper
- [ ] Any repo YAML whose parse changes is listed in the task notes

## User-Observable Acceptance

A preference or package-manifest value containing `|` — for example a description with `a | b` — survives `yaml_get` instead of being silently cut at the first pipe.
