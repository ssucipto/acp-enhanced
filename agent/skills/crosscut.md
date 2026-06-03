<skill name="crosscut" mention="@{crosscut}">
<rules>
- AGENT.md is the primary human-facing documentation — update it when adding commands, patterns, or changing the directory structure
- README.md is for external consumers — update it when public-facing behaviour changes
- CHANGELOG.md uses Keep a Changelog format + semver; add entry for EVERY release
- progress.yaml is the task tracking source of truth — update it BEFORE and AFTER task work
- Package.yaml at repo root describes the ACP core package — keep commands list in sync
- When adding a new command: update AGENT.md Commands section, README, CHANGELOG, package.yaml
- When adding a new script: update AGENT.md Scripts section and package.yaml scripts array
- When adding a new schema: update AGENT.md Schemas section
- Version bump rules: major for breaking changes, minor for new features, patch for bug fixes
- The copilot-instructions.md in .github/ must stay in sync with root AGENTS.md (copy, not symlink, on Windows)
</rules>

<patterns>
CHANGELOG entry format:
```markdown
## [X.Y.Z] - YYYY-MM-DD

### Added
- **Feature name** — brief description. Motivation sentence.

### Changed
- **Component name** — what changed and why.

### Fixed
- **Bug description** — root cause and fix.
```

AGENT.md command entry (in the Commands section table):
```markdown
| `/acp-foo` | Brief one-line description | `acp.foo.md` |
```

Package.yaml command entry:
```yaml
- name: acp.foo
  description: Brief description
  file: agent/commands/acp.foo.md
  scripts: []
```
</patterns>

<anti_patterns>
- NEVER update only one of {AGENT.md, README.md, CHANGELOG.md, package.yaml} on a release — update all four
- NEVER add implementation details to README.md — keep it user-facing
- NEVER put the current date in AGENT.md body (only in CHANGELOG)
- NEVER skip a CHANGELOG entry — every change must be traceable
</anti_patterns>
</skill>
