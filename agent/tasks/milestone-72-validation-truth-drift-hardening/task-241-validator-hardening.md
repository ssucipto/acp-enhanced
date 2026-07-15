---
id: task-241
milestone: M72
title: "Validator hardening — root anchor, zero-found=fail, hash sync, package.yaml, 5-surface parity"
status: completed
priority: 5
complexity: high
estimated_hours: 5
created: 2026-07-15
started: 2026-07-15T01:30:00Z
completed: 2026-07-15
completed_date: 2026-07-15T02:00:00Z
route: route-230
audit_findings: [F-091-01, F-091-02, F-091-03, F-091-04, F-091-05, F-091-14]
depends_on: [task-240]
design_reference: [Design: M72 Validation Truth](../design/m72-validation-truth-drift-hardening.md)
---

## Objective

Make `scripts/acp-validate.ts` structurally unable to produce the false-greens audit-091 found. This is the *enforcement half* that lets F-091-01..05 be stamped `fixed`.

## Context (inlined from audit-091 + design D1–D5)

- Validator resolves paths from `process.cwd()`; run from `scripts/` it prints "✅ Parity: 0 commands × 3 surfaces — all matched" and skips everything else (F-091-03).
- Size guard compares bytes only — copilot-instructions drift at identical byte count passed (F-091-01).
- package.yaml never checked despite acp.validate.md Step 2c documenting it as hard requirement (F-091-02).
- `runParityCheck()` (scripts/acp-validate.ts:189) covers 3 of 5 surfaces and filters `startsWith("acp-")`, hiding dot-named strays (F-091-04/05).

## Steps

1. **D1 root anchor**: derive `ROOT` from module location (`path.resolve(dirname(fileURLToPath(import.meta.url)), "..")`); convert all path constants to ROOT-absolute; hard-exit 1 with explicit message if `ROOT/agent/commands` missing
2. **D2 zero-found=fail**: parity and every required-population check reports ❌ + exit 1 when enumeration returns 0 items
3. **D3 hash sync**: SHA-256 content-equality check across AGENTS.md / CLAUDE.md / .github/copilot-instructions.md; ERROR names the divergent file + first differing line; keep byte-size check for 15KB budget only
4. **D4 package.yaml**: `package.yaml version == identity.yml version` (ERROR); each `agent/scripts/*.sh` on disk present in package.yaml contents + integrity-manifest.yaml (WARN this release)
5. **D5 parity**: extend to `.cursor/commands/` + `.claude/commands/` (5 surfaces incl. git.* where those surfaces carry them); flag dot-form strays (`acp.*.md`, `acp.*.prompt.md`) in any wrapper dir as ERROR
5b. **F-091-14 addability check**: gitignore check must probe *new-file addability* in tracked protocol directories (`git check-ignore` on a probe path under agent/reports/, agent/feedback/, agent/memory/, agent/tasks/ — per design D9; deliberately NOT clarifications/drafts/preferences, which are local-only by design) — ERROR if a tracked protocol dir rejects new files; also ERROR if files on disk in agent/reports/ or agent/feedback/ are untracked
6. **Vitests** (guardrail #5): ≥7 new tests with positive + negative fixtures — wrong-root failure, zero-command failure, hash mismatch, pkg version mismatch, missing 5th-surface wrapper, dot-stray detection, ignored-protocol-dir detection
7. Update the M70 Validators table in `acp.validate.md` with the new checks (severity column)

## Verification

- [ ] From repo root: 0 errors. From `scripts/` cwd: loud explicit failure
- [ ] Temporarily editing copilot-instructions.md (same-length change) → hash check FAILS
- [ ] Temporarily setting package.yaml version 0.0.0 → ERROR
- [ ] Deleting one `.claude/commands/*.md` → parity FAILS; restoring fixes it
- [ ] Planting `.opencode/commands/acp.fake.md` → stray ERROR
- [ ] `npx vitest run scripts/acp-validate.test.ts` ≥ 34 passing
- [ ] Carryovers F-091-01..05 stamped `fixed` (fix+enforcement now both landed)

## User-Observable Acceptance

`npx tsx scripts/acp-validate.ts` catches each seeded drift above; running from any cwd gives identical results or an explicit refusal — never a silent green.
