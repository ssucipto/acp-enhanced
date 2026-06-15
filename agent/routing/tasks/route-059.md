---
id: route-059
title: R3+R4 — acp-bootstrap.sh Flag Parsing (--team-size, --generate-prompts)
task_type: bash-scripting
milestone: M44
complexity: medium
executor: deepseek-v4-pro
context_required: [scripts/acp-bootstrap.sh, agent/manifest.yaml]
design_reference: Manifest scaffold config at agent/manifest.yaml → scaffold
files_affected: [scripts/acp-bootstrap.sh]
tokens_est: 5000
created: 2026-06-03
completed: 2026-06-03
depends_on: [route-046, route-049]
---

# R3+R4: acp-bootstrap.sh Flag Parsing

**Source**: audit-022 R3/R4 (P1/P2), audit-027 GAP-022

## Problem

Routes 046 and 049 added the YAML config (`agent/manifest.yaml → scaffold`) but `acp-bootstrap.sh` doesn't read or use these flags. The config is dead without the script.

## Implementation

Add flag parsing to `acp-bootstrap.sh`:

```bash
# Read scaffold config from manifest
TEAM_SIZE="small"        # default
GENERATE_PROMPTS="false" # default

# --team-size flag
--team-size solo|small|team → set TEAM_SIZE
# Result: controls which files/directories are created

# --generate-prompts flag
--generate-prompts → override manifest (opt-in)

# Manifest overrides
# Read agent/manifest.yaml → scaffold.team_size, scaffold.generate_prompts
```

## File Lists Per Team Size

| Team Size | agent/ dirs | Commands | .github/prompts | .opencode/commands |
|-----------|:---:|:---:|:---:|:---:|
| solo | core + memory + wiki | 10 essential | 0 (opt-in) | 10 |
| small | + skills + routing + commands + scripts | 30 | 0 | 30 |
| team | + all 20+ dirs | 63 | 63 (opt-in) | 63 |

## Acceptance Criteria

- [ ] `acp-bootstrap.sh` reads `agent/manifest.yaml → scaffold` block
- [ ] `--team-size solo|small|team` flag parsed and respected
- [ ] `--generate-prompts` flag enables .github/prompts/ generation
- [ ] Solo: ~30 files, Small: ~80 files, Team: ~310 files
- [ ] Manifest `generate_prompts: false` skips prompt generation by default
- [ ] Backward compatible: no flag = small (current behavior)
