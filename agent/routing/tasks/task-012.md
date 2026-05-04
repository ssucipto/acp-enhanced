---
id: task-012
title: Add all prompt.md blocks to acp-bootstrap.sh
task_type: bash-script-fix
milestone: none
complexity: low
executor: Persona A (Copilot)
context_required: [scripts/acp-bootstrap.sh, .github/prompts/]
files_affected:
  - scripts/acp-bootstrap.sh
tokens_est: 4000
tokens_actual:
cost_est_usd:
cost_actual_usd:
created: 2026-05-04
completed:
override_reason:
---

## Problem

`scripts/acp-bootstrap.sh` currently only generates 7 `.prompt.md` files when a user runs
`acp-bootstrap.sh` to install ACP into a new project. The 50 additional commands added in
this session (`acp-proceed`, `acp-status`, `acp-plan`, etc.) are not created during install,
so new users miss VS Code Copilot slash command autocomplete for all those commands.

## Acceptance Criteria

- `acp-bootstrap.sh` section [6/7] "Creating Copilot prompt files" generates all 57 `.prompt.md`
  files (7 existing + 50 new) using `cat > ... << 'MD'` heredoc blocks.
- Each new block follows the same minimal pattern used by the existing 50 files created this
  session: `mode: agent`, `description: <from command Purpose>`, body: `Read and execute agent/commands/<file>.md`.
- The `echo -e "${GREEN}✓ Prompt files created${NC}"` line remains at the end of the section.
- No other sections of the bootstrap script are modified.
- Existing 7 blocks are left untouched.

## Implementation Plan

1. Locate insertion point: line after `acp-init.prompt.md` block, before `echo -e "${GREEN}✓ Prompt files created${NC}"`.
2. Insert 50 `cat > .github/prompts/<slug>.prompt.md << 'MD' ... MD` blocks.
3. Commands to add (slug → command-file → description):
   - acp-proceed → acp.proceed → Implement tasks — single-task (default) or autonomous milestone completion
   - acp-status → acp.status → Display current project status including milestone progress and next steps
   - acp-plan → acp.plan → Plan milestones OR tasks for undefined items in progress.yaml
   - acp-update → acp.update → Update progress.yaml with latest project status and task completion
   - acp-report → acp.report → Generate a comprehensive project status report
   - acp-resume → acp.resume → Resume work on a project by initializing context and continuing
   - acp-audit → acp.audit → Deep-dive investigation of a subject, producing a structured report
   - acp-handoff → acp.handoff → Generate a context-aware handoff report for cross-context transfer
   - acp-sync → acp.sync → Synchronize documentation with source code
   - acp-validate → acp.validate → Validate all ACP documents for structure and consistency
   - acp-index → acp.index → Manage the key file index
   - acp-spec → acp.spec → Generate a specification document from clarification or design
   - acp-task-create → acp.task-create → Create task files with milestone linking
   - acp-command-create → acp.command-create → Create command files with namespace enforcement
   - acp-design-create → acp.design-create → Create design documents with namespace enforcement
   - acp-design-reference → acp.design-reference → Discover and cross-reference design documents
   - acp-pattern-create → acp.pattern-create → Create pattern files with namespace enforcement
   - acp-clarification-create → acp.clarification-create → Create clarification documents
   - acp-clarification-address → acp.clarification-address → Address clarification responses
   - acp-clarification-capture → acp.clarification-capture → Capture decisions into permanent entity documents
   - acp-artifact-glossary → acp.artifact-glossary → Create and maintain project glossaries
   - acp-artifact-reference → acp.artifact-reference → Create reference guides for passive information
   - acp-artifact-research → acp.artifact-research → Create long-lived research artifacts
   - acp-sessions → acp.sessions → Manage and view active agent sessions across projects
   - acp-package-install → acp.package-install → Install third-party command packages from git repositories
   - acp-package-list → acp.package-list → List installed ACP packages with versions and details
   - acp-package-info → acp.package-info → Display detailed information about a specific installed package
   - acp-package-search → acp.package-search → Discover ACP packages on GitHub
   - acp-package-remove → acp.package-remove → Remove installed ACP packages and clean up manifest
   - acp-package-update → acp.package-update → Update installed ACP packages to latest versions
   - acp-package-create → acp.package-create → Create a new ACP package with full ACP installation
   - acp-package-publish → acp.package-publish → Automated package publishing with validation and testing
   - acp-package-validate → acp.package-validate → Comprehensive package validation with auto-fix
   - acp-project-create → acp.project-create → Create a new generic ACP project with guided setup
   - acp-project-list → acp.project-list → List all projects registered in global workspace
   - acp-project-info → acp.project-info → Display detailed information about a specific project
   - acp-project-set → acp.project-set → Switch to a different project in the global registry
   - acp-project-update → acp.project-update → Update project metadata in the global registry
   - acp-project-remove → acp.project-remove → Remove a project from the global registry
   - acp-projects-sync → acp.projects-sync → Discover and register unregistered ACP projects
   - acp-projects-restore → acp.projects-restore → Restore/clone missing projects from git origins
   - acp-preferences-show → acp.preferences-show → Display the effective preference set with source attribution
   - acp-preferences-get → acp.preferences-get → Resolve and display preferences for a namespace
   - acp-preferences-set → acp.preferences-set → Set a preference value at a specified level
   - acp-preferences-create → acp.preferences-create → Create preference files with default values
   - acp-preferences-validate → acp.preferences-validate → Validate all preference files against schemas
   - acp-version-check → acp.version-check → Display current ACP version and compatibility information
   - acp-version-check-for-updates → acp.version-check-for-updates → Check if a newer ACP version is available
   - acp-version-update → acp.version-update → Update ACP files to the latest version
   - git-commit → git.commit → Commit staged changes with a well-formatted conventional commit message
