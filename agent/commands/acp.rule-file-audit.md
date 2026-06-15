# Command: rule-file-audit

> **🤖 Agent Directive**: If you are reading this file, the command `/acp-rule-file-audit` has been invoked. This is an alias for `/acp-integrity --self --fast`. Follow `agent/commands/acp.integrity.md` with those flags.

**Namespace**: acp  
**Version**: 1.0.0  
**Created**: 2026-06-07  
**Status**: Active  
**Scripts**: acp.unicode-scan.sh  

---

**Purpose**: Fast scan of ACP rule files for Unicode injection and hidden instructions (alias for `/acp-integrity --self --fast`)  
**Category**: Security / Integrity  
**Frequency**: Pre-commit  

---

## Steps

1. Read and execute `agent/commands/acp.integrity.md` with arguments `--self --fast`.
2. Report findings using the integrity output format.

## Verification

- [ ] Unicode scan runs against `AGENTS.md`, `agent/core/`, `agent/skills/`, and command wrappers
- [ ] Exit 1 on CRITICAL/HIGH findings when `--ci` is passed through
