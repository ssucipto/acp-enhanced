# Pattern: Rule Verification Discipline

<!-- @acp.meta.pattern
topic: review-scan, verification, proxy, invariant, feedback-008, false-positive
description: Assert the invariant a guard is named for — never a correlated proxy (dir exists, status strings agree, wrong schema key).
applies_to: review-scan, integrity-guards, agent-protocol, testing
status: active
updated: 2026-08-14
@acp.meta.end -->

**Category**: Testing / Code  
**Source**: FIFOZ feedback-008 · M86 task-317 · Related: `local.false-green-contracts.md` (FG-3)

---

## Overview

A guard named for an invariant that actually checks a **correlate** of that invariant
certifies nothing — and is worse than no guard, because it is trusted. feedback-008
raised this from scanner bugs to a **critical** protocol failure after three independent
guards failed the same way in one engagement.

**Rule:** assert the invariant, not a correlate.

---

## When to Use

✅ **Use when:**
- Authoring or reviewing Phase 1 review-scan rules
- Adding “ready / complete / available” guards in scripts or agent steps
- Writing acceptance criteria that claim something is **absent** or **present**

❌ **Don't use as an excuse to skip:**
- Cheap probes that *are* the invariant (e.g. `command -v jq` when the tool is jq)
- Explicit SKIP when the real check cannot run (FG-5) — announce understatement

---

## Three proxy failures (feedback-008)

| Guard (named for) | Proxy it checked | Invariant it should check | Consequence |
|-------------------|------------------|---------------------------|-------------|
| YM-01/YM-02 can run | `scripts/node_modules/` **directory exists** | `gray-matter` + `js-yaml` **resolve** under `scripts/` | 72 fabricated HIGH findings (`ERR_MODULE_NOT_FOUND` reported as “frontmatter does not parse”) |
| Task stamp / complete | Two **status strings agree** | Verification checklist boxes / acceptance actually executed | Unchecked boxes stamped done |
| Carryover “absent” | `finding_id:` key missing | ID absent across **all ledger schemas** (`id:` + `finding_id:`) | Critical carryover falsely retracted |

Canonical illustration for YM: **`scripts/node_modules/` existing must not certify YAML parse capability.**

---

## Core principles

1. **Name = check** — the probe must be the named capability, not a precondition.
2. **Absence ≠ presence** — absence claims need a tool that covers the whole search space; presence is self-verifying.
3. **True-positive fixture required** — a rule that has never fired on a deliberate bad fixture is unverified.
4. **Degraded runs announce** — if the invariant cannot be checked, SKIP/warn loudly; never invent findings from setup errors (task-316).

---

## Checklist — adding a new review-scan rule

Before merging a new rule ID into `acp.review-scan.sh` / `acp.review.md`:

- [ ] **Invariant written in one sentence** (what must be true in first-party code)
- [ ] **Probe asserts that invariant** (not dir existence, string equality, or a single schema key)
- [ ] **True-positive fixture** under the review corpus / E2E that fires the rule on deliberate bad input
- [ ] **False-positive fixture** (comment / string / vendored path / implied option) that must **not** fire
- [ ] **Setup failure path** does not emit the rule (missing deps → skip/CI fail-closed, not a finding)
- [ ] **`review_rg_dir` / find excludes** stay aligned if the rule walks trees
- [ ] Documented in `acp.review.md` with Phase 1 ownership

---

## Anti-patterns

### ❌ Directory / file existence as “capability”

```bash
# Bad — proxy
[[ -d scripts/node_modules ]] && run_yaml_rules

# Good — invariant (task-316)
(cd scripts && node -e 'Promise.all([import("gray-matter"),import("js-yaml")])…')
```

### ❌ Substring match for commands

```bash
# Bad — matches comments
[[ "$line" == *"trap"* && "$line" == *" EXIT"* ]]

# Good — lexical statement + skip comments (SH-04)
[[ "$stripped" =~ (^|[\;\&\|][[:space:]]*)trap[[:space:]]+[^\#]*[[:space:]]EXIT([[:space:]]|$|\;) ]]
```

### ❌ Single-key ledger grep for absence

```bash
# Bad — blind to legacy `- id:` schema
grep -c "finding_id: CO-725" agent/memory/audit-carryovers.md

# Good — cover both schemas / use a corpus-aware query tool
```

---

## Related

- [`local.false-green-contracts.md`](./local.false-green-contracts.md) — FG-3 output contract; FG-2/5/7 empty/SKIP
- Local scanner merge notes (gitignored under `agent/reports/` after ADR-27)
- Finding IDs in `agent/memory/audit-carryovers.md`

---

**Status**: Active  
**Last Updated**: 2026-08-14  
**Contributors**: FIFOZ field feedback → ACP Enhanced M86
