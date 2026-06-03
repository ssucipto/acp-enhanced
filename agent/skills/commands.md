<skill name="commands" mention="@{commands}">

> **Naming convention**: Before writing any command references, read  
> `agent/patterns/local.command-naming-convention.md` for the canonical  
> naming table, invocation format, and upstream porting rules.

<rules>
- Every command file MUST begin with the 🤖 Agent Directive block (see pattern below)
- The directive block title must match the filename: `acp.foo.md` → `# Command: foo`
- Every command MUST have a `**Scripts**: None` or `**Scripts**: acp.foo.sh` field in the header
- Every command MUST have a `## Steps` section with numbered, actionable steps
- Every command MUST have a `## Verification` section with checkboxes
- Arguments section must include an Arguments table AND an Argument Parsing sub-section
- Use `--skip <items>` pattern for commands that support skipping steps
- Use natural language matching (not strict flag parsing) in all argument descriptions
- Commands are agent directives — write steps as imperatives addressed to "you" (the agent)
- Never write steps as suggestions; write them as obligations ("Read X", "Create Y", "Output Z")
- Related Commands section must link to actual sibling command files
</rules>

<patterns>
Directive block header (copy verbatim, adjust command name):
```markdown
# Command: foo

> **🤖 Agent Directive**: If you are reading this file, the command `/acp-foo` has been invoked. Follow the steps below to execute this command.

**Namespace**: acp
**Version**: 1.0.0
**Created**: YYYY-MM-DD
**Last Updated**: YYYY-MM-DD
**Status**: Active
**Scripts**: None
```

Step with skip annotation:
```markdown
### 1. Step Title

**Skip item**: `checks` | **Skipped by**: `--quick`

[Step description]

**Actions**:
- Do X
- Do Y

**Expected Outcome**: [what should be true after this step]
```

Argument table:
```markdown
| Argument | Aliases | Description |
|---|---|---|
| `--quick` | `-q` | Fast mode: skips X, Y, Z |
| `--skip <items>` | | Comma-separated list: `a`, `b`, `c` |
```
</patterns>

<anti_patterns>
- Do NOT write commands as shell scripts — commands are LLM directives
- Do NOT use passive voice in steps ("X should be read" → "Read X")
- Do NOT omit the Expected Outcome from steps
- Do NOT create commands without E2E tests
- Do NOT version bump on non-breaking changes (patch only for fixes)
</anti_patterns>
</skill>
