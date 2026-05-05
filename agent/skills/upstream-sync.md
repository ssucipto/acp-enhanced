<skill name="upstream-sync">
<rules>
- Read ALL upstream source files before making any HAVE/PARTIAL/PORT/DEFER assignment — no exceptions
- Source priority order (mandatory, in sequence): (1) AGENT.md (2) agent/commands/*.md (3) agent/scripts/*.sh (4) agent/milestones/*.md (5) sample agent/tasks/ at least 2-3 per active milestone (6) agent/design/*.md for complex features (7) CHANGELOG.md as cross-reference only
- CHANGELOG.md is NOT the source of truth for feature behaviour — use it only to pin version numbers and check that no feature was missed across the other sources
- Every HAVE/PARTIAL/PORT/DEFER assignment must cite the specific upstream source file that justifies it
- For PORT items: read the actual upstream script source file before performing any macOS compat check — never assess compat from a feature name or CHANGELOG description
- macOS compat check must cite specific bash 4+ constructs found in the actual source code: mapfile, readarray, declare -A (associative arrays), [[ =~ ]] (regex matching), printf '%q', ${!var[@]} (nameref), process substitution <()
- BSD sed difference: upstream may use `sed -i` without an argument — ACP Enhanced requires `sed -i ''` on macOS
- Naming translation rule: upstream @acp.foo → ACP Enhanced /acp-foo (at-sign → slash, dot → hyphen after namespace)
- DEFER the pluggable driver system (driver.yaml, acp.driver-yaml.sh, ext points marker.mint / query.run / workflow.run) unless the project explicitly requires MCP runtime integration
- Never mark a feature HAVE based on directory name or command title alone — open and read the actual file content to verify behaviour matches
- When sampling agent/tasks/, prefer tasks from the most recent milestones (higher M-numbers carry more implementation detail for features added in later versions)
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
| HAVE | ACP Enhanced has a full equivalent — verified by reading both upstream and local source |
| PARTIAL | ACP Enhanced has part of the feature; specific gaps documented with file references |
| PORT | Feature is genuinely missing; should be ported after compat check passes |
| DEFER | Feature exists upstream but does not apply to ACP Enhanced (e.g., MCP-dependent features, Claude Code-only features) |
</patterns>

<anti_patterns>
- NEVER assign a decision from CHANGELOG descriptions alone — always open the actual upstream source file
- NEVER guess macOS compat — always read the script source and cite the specific construct and line number
- NEVER translate @acp.foo to @acp-foo — the correct ACP Enhanced form is /acp-foo (slash prefix, hyphen separator)
- NEVER load the full upstream CHANGELOG as the first source — it is 150KB and should be read last as cross-reference
- NEVER mark PORT without first completing the macOS + no-deps compat check (a PORT with unknown compat is not actionable)
- NEVER skip reading agent/commands/*.md — CHANGELOG often omits flag details, argument shapes, and step-level behaviour that command files contain
- NEVER skip reading agent/scripts/*.sh — scripts are the ground truth for bash version requirements and external tool dependencies
- NEVER assume a feature listed in CHANGELOG was fully implemented — always verify against the actual command/script file
</anti_patterns>
</skill>
