---
id: task-240
milestone: M72
title: "Drift closures — versions, instruction-file sync, script registrations"
status: planned
priority: 5
complexity: low
estimated_hours: 2
created: 2026-07-15
started: null
completed_date: null
route: route-229
audit_findings: [F-091-01, F-091-02, F-091-14]
depends_on: []
design_reference: [Design: M72 Validation Truth](../design/m72-validation-truth-drift-hardening.md)
---

## Objective

Fix the two high-severity drift findings from audit-091 — the *fix half* only. Per guardrail #1 these carryovers are NOT stamped `fixed` until task-241 lands the matching enforcement.

## Context (inlined from audit-091)

- `.github/copilot-instructions.md` header reads **v6.24.0**; AGENTS.md/CLAUDE.md read v6.26.0. The pre-commit sync hook that `acp-bootstrap.sh` installs for consumers is absent from this repo's `.git/hooks/`.
- `package.yaml` reads **version: 6.21.1** vs canonical 6.26.0 (identity.yml).
- Unregistered in `package.yaml` contents AND `agent/integrity-manifest.yaml`: `acp.cursor-commands-sync.sh`, `acp.claude-commands-sync.sh`, `acp.post-milestone-sweep.sh`.
- F-091-14: `agent/.gitignore:5` (`reports/`) overrides the root `!agent/reports/` whitelist — only 26 reports tracked; audit-078..090 (incl. M71 closure evidence) not in version control.

## Steps

1. `cp AGENTS.md .github/copilot-instructions.md` (byte-identical; verify with `md5 -q` triple match)
2. Set `package.yaml → version: 6.26.0` (current shipped version; task-247 bumps to 6.27.0 at release)
3. Install the AGENTS.md sync pre-commit hook block (same block `acp-bootstrap.sh` step 8 writes) into `.git/hooks/pre-commit`, appending if a hook exists (design D6)
4. Register the 3 scripts in `package.yaml` contents (name + version + description, matching existing entries' shape) and in `agent/integrity-manifest.yaml`
5. Fix `agent/.gitignore`: remove the `reports/` rule (or add `!reports/` below it); `git add agent/reports/` to restore audit-078..090 and all untracked protocol evidence to version control

## Verification

- [ ] `md5 -q AGENTS.md CLAUDE.md .github/copilot-instructions.md` — three identical hashes
- [ ] `grep "^version:" package.yaml` → 6.26.0
- [ ] `grep -c "commands-sync\|post-milestone-sweep" package.yaml` ≥ 3; same for integrity-manifest.yaml
- [ ] `.git/hooks/pre-commit` contains the ACP sync marker and is executable
- [ ] `git check-ignore agent/reports/probe.md` → not ignored; `git ls-files agent/reports | wc -l` covers all reports on disk
- [ ] Carryovers F-091-01/02/14 remain `pending` (stamped only with task-241, per guardrail #1)

## User-Observable Acceptance

Editing AGENTS.md and committing auto-updates CLAUDE.md + copilot-instructions.md in the same commit.
