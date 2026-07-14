# Design: M72 — Validation Truth & Drift Hardening

<!-- @acp.meta.design
topic: validation, drift, parity, ci, audit-091
description: Close audit-091 findings — make drift structurally impossible to miss, not just currently absent
status: active
updated: 2026-07-15
@acp.meta.end -->

**Source**: audit-091 (`agent/reports/audit-091-whole-system-gaps-standards.md`)
**Created**: 2026-07-15
**Planned version**: 6.27.0

---

## Problem

Audit-091 found the system's *shipped state* healthy but its *enforcement layer* full of holes with one shared root cause: **derived and metadata surfaces that nothing checks**. Two version-bearing files drifted for multiple releases (`copilot-instructions.md` v6.24.0, `package.yaml` 6.21.1) and passed a green validator because the size guard compares bytes (not content), the version-header check reads one file, and the package.yaml check documented in `acp.validate.md` Step 2c was never implemented. The parity check covers 3 of 5 wrapper surfaces, is blind to dot-named strays, and vacuously passes with "0 commands × 3 surfaces — all matched" when run from the wrong cwd — which is the invocation `acp.validate.md` Step 11.6 documents.

## Design Decisions

**D1 — cwd-independence by construction.** `scripts/acp-validate.ts` derives `ROOT` from its own module location (`path.resolve(dirname(fileURLToPath(import.meta.url)), "..")`), never from `process.cwd()`. Every path constant becomes ROOT-absolute. Fallback guard: if `ROOT/agent/commands` does not exist, exit 1 with an explicit "not an ACP repo root" error. No silent skips for structural directories.

**D2 — zero-found is a failure, not a pass.** Any check that enumerates a required population (command docs, wrapper files, schema files) and finds zero MUST report ❌ and set exit code 1. "0 × N surfaces — all matched" class of vacuous greens is banned. Optional populations (e.g., `agent/driver.yaml`) keep their documented skip-silently behavior.

**D3 — content-hash instruction-file sync.** Replace/augment the byte-size guard: AGENTS.md, CLAUDE.md, `.github/copilot-instructions.md` must be **content-identical** (SHA-256 compare). Mismatch = ERROR listing which file diverges and the first differing line. Size check remains for the 15KB budget only.

**D4 — implement package.yaml as the hard requirement Step 2c already documents.** `package.yaml → version:` must equal `identity.yml → version:` (ERROR on mismatch). Also verify every `agent/scripts/*.sh` present on disk appears in `package.yaml` contents and `agent/integrity-manifest.yaml` (WARN per missing entry — becomes ERROR one release later).

**D5 — five-surface parity + stray detection.** `runParityCheck()` compares `agent/commands/{acp,git}.*.md` against all four wrapper dirs: `.github/prompts/`, `.opencode/commands/`, `.cursor/commands/`, `.claude/commands/`. Additionally, any file in a wrapper dir matching the dot-form `acp.*.md` / `acp.*.prompt.md` is flagged as a stray duplicate (ERROR). git.* commands are included in cursor/claude surfaces (they exist there) and excluded from prompts/opencode (historical scope) — the check encodes this asymmetry explicitly rather than ignoring git.*.

**D6 — dogfood the sync hook.** The AGENTS.md → CLAUDE.md + copilot-instructions.md pre-commit hook that `acp-bootstrap.sh` installs for consumers gets installed in this repo. D3 remains the backstop for hook-bypassing edits.

**D7 — ShellCheck gate, ratcheted.** New CI job (SHA-pinned action) running shellcheck over `agent/scripts/*.sh`, `scripts/*.sh`, `e2e/*.sh`, `tests/*.sh`. Initial gate at `--severity=error` to land green, ratchet to `warning` in a follow-up once findings are triaged. Sourced-library pipefail exemptions (`acp.common.sh`, `acp.yaml-parser.sh`, `acp.driver-yaml.sh`, `acp.integrity-output.sh`) documented with inline `# shellcheck` directives and a rationale note in `agent/skills/scripts.md`.

**D8 — v6.27.0 (minor).** New validator capabilities + new CI gate = minor bump per SemVer. Full release discipline: CHANGELOG entry, tag, package.yaml (now enforced by D4), instruction-file headers (enforced by D3).

## Anti-Shortcut Guardrails (binding for all M72 tasks)

1. **No doc-only fixes.** A drift finding is `fixed` only when the fix lands *together with* the enforcement check that would have caught it (F-091-01/02 close only alongside task-241 validators).
2. **No vacuous greens** (D2) — reviewer must grep new checks for zero-population behavior.
3. **No carryover stamped `fixed` without re-verification** in the M72 closure audit (audit-092), matching the M71/audit-090 protocol.
4. **No command-doc edit without wrapper regen** — after editing any `agent/commands/*.md`, run all four sync/generation paths and re-run parity.
5. **No untested validator change** — every new/changed check in `acp-validate.ts` ships with a vitest (positive + negative fixture), keeping the 28-test suite growing.
6. **No release without the full chain** — CHANGELOG + tag + package.yaml + instruction headers; D4/D3 make skipping mechanically fail.
7. **Memory writes at moment of discovery** — sessions/lessons/decisions written per phase, not end-of-milestone dump.
8. **Repo-root discipline** — all documented invocations run from repo root; D1 makes wrong-cwd fail loudly instead of lying.
9. **No mixed commits** — pre-existing Claude-integration working-tree changes are committed as their own logical commit (task-245) before validator work begins on the same files.

## Out of Scope

- M58 Phase-2 semantic integrity rules (still gated on ADR-10 conditions).
- FIFOZ consumer verification — remains task-239 (M71, ops-blocked); not duplicated here.
- Full shellcheck warning-level cleanup (ratchet follow-up after error-level lands).
