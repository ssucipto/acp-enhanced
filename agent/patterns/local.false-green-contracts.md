# Pattern: False-Green Contracts (FG-1…FG-7)

> M86 task-306 · Source: FIFOZ feedback-009 / audit-114 F-114-05…07
> Binding: `agent/core/constraints.yml` → `bash_rules`

Agents and CI scripts must not report success when nothing meaningful ran,
when status was inferred from the wrong signal, or when probes ran in the
wrong shell context.

## FG-1 — `set +e` does not suppress `trap ERR`

**Bad:**
```bash
set +e
cmd
rc=$?
set -e
```
Under `trap … ERR`, `cmd` failure still fires the trap and aborts before `rc=$?`.

**Good:**
```bash
if cmd; then
  rc=0
else
  rc=$?
fi
```

## FG-2 — Never PASS with zero units executed

An empty `--only` plan, a filter that matches nothing, or a skipped-all matrix
must **FAIL** (or SKIP with an explicit reason) — never exit 0 as success.

## FG-3 — Assert the output contract, not exit code alone

When the contract is “prints PASS/FAIL table”, “writes report”, or “emits
JSON”, grepping/asserting that output is required. Exit 0 alone is insufficient
(scripts can exit 0 after printing nothing useful).

## FG-4 — Probe dependencies in the execution context

Probes that check for helpers (`yaml_get`, `gh`, etc.) must run in the same
context the script will use (`bash -c '…'` / the script’s sourced libs), not
the agent’s interactive shell where functions may already be defined.

## FG-5 — Tri-state SKIP ≠ PASS

`SKIP` (missing optional tool, platform OOS) is not success. Aggregators must
distinguish PASS / FAIL / SKIP; a run that is all-SKIP must not be reported as
green verification.

## FG-6 — Dry-run ≠ verification

`--dry-run` / plan-only modes must not satisfy “verified” acceptance criteria.
Verification requires a real execution path with non-zero executed steps.

## FG-7 — Fail-closed on unknown / empty selection

Unknown gate names, empty job lists after filtering, and missing config keys
fail closed. Do not invent defaults that silently drop coverage.

## See also

- `agent/skills/scripts.md` — scripts skill paragraph linking here
- `agent/core/constraints.yml` — `bash_rules` named FG entries
