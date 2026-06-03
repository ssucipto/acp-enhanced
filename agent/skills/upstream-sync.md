<skill name="upstream-sync" mention="@{upstream}">
<rules>
- Read ALL upstream source files before making any HAVE/PARTIAL/PORT/DEFER/DIVERGED assignment — no exceptions
- Source priority order (mandatory, in sequence): (1) AGENT.md (2) agent/commands/*.md (3) agent/scripts/*.sh (4) agent/milestones/*.md (5) sample agent/tasks/ at least 2-3 per active milestone (6) agent/design/*.md for complex features (7) CHANGELOG.md as cross-reference only
- CHANGELOG.md is NOT the source of truth for feature behaviour — use it only to pin version numbers and check that no feature was missed across the other sources
- Every HAVE/PARTIAL/PORT/DEFER/DIVERGED assignment must cite the specific upstream source file that justifies it
- Bidirectional comparison is mandatory: for any feature being considered HAVE or DIVERGED, open and read the ACP Enhanced equivalent file (same command doc or script) and compare it against the upstream file. Cite both files in the rationale. A matching directory name or command title is NOT evidence of equivalence.
- DIVERGED is a first-class decision code: use it when BOTH upstream and ACP Enhanced have an implementation of the same feature but they are intentionally different. The ACP Enhanced version must NOT be overwritten. Document specifically what diverged and why it must stay different.
- For PORT items: read the actual upstream script source file before performing any macOS compat check — never assess compat from a feature name or CHANGELOG description
- macOS compat check must cite specific bash 4+ constructs found in the actual source code: mapfile, readarray, declare -A (associative arrays), [[ =~ ]] (regex matching), printf '%q', ${!var[@]} (nameref), process substitution <()
- BSD sed difference: upstream may use `sed -i` without an argument — ACP Enhanced requires `sed -i ''` on macOS
- Naming translation rule: upstream @acp.foo → ACP Enhanced /acp-foo (at-sign → slash, dot → hyphen after namespace)
- DEFER the pluggable driver system (driver.yaml, acp.driver-yaml.sh, ext points marker.mint / query.run / workflow.run) unless the project explicitly requires MCP runtime integration
- When sampling agent/tasks/, prefer tasks from the most recent milestones (higher M-numbers carry more implementation detail for features added in later versions)
- Post-port safety gate (mandatory before closing any PORT task): run `bash run-e2e-tests.sh` and confirm ≥95% pass rate. Also verify the PORTED code itself is macOS bash 3.2-compatible — the upstream compat check proves upstream compatibility, not ACP Enhanced port compatibility.
</rules>

<patterns>
## Upstream source URLs (prmichaelsen/agent-context-protocol, branch: mainline)

```
AGENT.md (canonical, 2100+ lines):
  https://raw.githubusercontent.com/prmichaelsen/agent-context-protocol/mainline/AGENT.md

Commands directory listing:
  https://github.com/prmichaelsen/agent-context-protocol/tree/mainline/agent/commands

Scripts directory listing:
  https://github.com/prmichaelsen/agent-context-protocol/tree/mainline/agent/scripts

Milestones directory listing:
  https://github.com/prmichaelsen/agent-context-protocol/tree/mainline/agent/milestones

Tasks directory listing:
  https://github.com/prmichaelsen/agent-context-protocol/tree/mainline/agent/tasks

Design directory listing:
  https://github.com/prmichaelsen/agent-context-protocol/tree/mainline/agent/design

CHANGELOG (cross-reference only):
  https://raw.githubusercontent.com/prmichaelsen/agent-context-protocol/mainline/CHANGELOG.md
```

## Feature parity matrix table format

```markdown
| Feature | Upstream Source File | Upstream Version | ACP Enhanced Status | Decision | Rationale |
|---|---|---|---|---|---|
| @acp.meta-scan.sh | agent/scripts/acp.meta-scan.sh | v5.38.0 | acp.meta-scan.sh (full POSIX awk) | HAVE | Identical POSIX awk implementation |
| Pluggable driver system | agent/design/local.pluggable-driver-system.md | v7.0.0 | Not present | DEFER | Requires MCP runtime; out of ACP Enhanced scope |
```

## macOS compat verdict table format

```markdown
| Feature | macOS (bash 3.2) | No-Deps | Token Budget | Naming | Verdict |
|---|---|---|---|---|---|
| acp.driver-yaml.sh | ✅ POSIX awk, no mapfile/declare -A | ✅ | ✅ | @acp.driver-yaml → /acp-driver-yaml | PORT with rename |
| sessions script | ⚠️ line 47: mapfile used; POSIX workaround: while IFS= read -r | ✅ | ✅ | already present | PORT with bash 3.2 fix |
```

## Decision code definitions

| Code | Meaning |
|---|---|
| HAVE | ACP Enhanced has a full equivalent — verified by reading both upstream AND ACP Enhanced source files |
| PARTIAL | ACP Enhanced has part of the feature; specific gaps documented with file references |
| DIVERGED | Both upstream and ACP Enhanced have an implementation but they are intentionally different; the ACP Enhanced version must NOT be overwritten. Document what diverged and why. |
| PORT | Feature is genuinely missing; should be ported after compat check passes AND post-port safety gate confirmed |
| DEFER | Feature exists upstream but does not apply to ACP Enhanced (e.g., MCP-dependent features, Claude Code-only features) |
</patterns>

<anti_patterns>
- NEVER assign a decision from CHANGELOG descriptions alone — always open the actual upstream source file
- NEVER assign HAVE or DIVERGED without opening the ACP Enhanced equivalent file — a matching directory name or command title is not evidence of equivalence
- NEVER guess macOS compat — always read the script source and cite the specific construct and line number
- NEVER translate @acp.foo to @acp-foo — the correct ACP Enhanced form is /acp-foo (slash prefix, hyphen separator)
- NEVER load the full upstream CHANGELOG as the first source — it is 150KB and should be read last as cross-reference
- NEVER mark PORT without first completing the macOS + no-deps compat check (a PORT with unknown compat is not actionable)
- NEVER close a PORT task without running the post-port safety gate — `bash run-e2e-tests.sh` must pass on the ported code in ACP Enhanced, not just on the upstream source
- NEVER run `git merge upstream/mainline` or `git merge prmichaelsen/mainline` — upstream rewrote history at v6.0.0 (see ADR-7); there is no shared ancestor and merge will corrupt the ACP Enhanced repository
- NEVER `git cherry-pick` upstream commits — ACP Enhanced has diverged significantly across every subsystem; cherry-pick without bidirectional analysis will silently overwrite ACP Enhanced's intentional differences
- NEVER skip reading agent/commands/*.md — CHANGELOG often omits flag details, argument shapes, and step-level behaviour that command files contain
- NEVER skip reading agent/scripts/*.sh — scripts are the ground truth for bash version requirements and external tool dependencies
- NEVER assume a feature listed in CHANGELOG was fully implemented — always verify against the actual command/script file
</anti_patterns>
</skill>
