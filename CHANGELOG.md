# Changelog

All notable changes to the Agent Context Protocol will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.4.1] - 2026-02-16

### Fixed
- **Script Color Output**: Fixed color output in install.sh and update.sh
  - Replaced unreliable ANSI escape codes with `tput` commands
  - Colors now work correctly across all shells (bash, sh, zsh)
  - No more literal escape character output
  - Added fallback for non-terminal environments
  - Removed unnecessary `-e` flag from echo commands

## [1.4.0] - 2026-02-16

### Added
- **`@git.init` Command**: Intelligent git repository initialization
  - Automatically detects project type (Node.js, Python, Rust, Go, Java, PHP, Ruby, C#, and more)
  - Generates smart `.gitignore` based on detected technology stack
  - Ensures dependency lock files are NOT ignored (package-lock.json, poetry.lock, etc.)
  - Ignores build directories (dist/, build/, target/)
  - Ignores dependency directories (node_modules/, venv/, etc.)
  - Ignores package archives (*.tgz for npm)
  - Uses web search tools for unknown project types
  - Includes 5 examples covering common and uncommon scenarios

## [1.3.2] - 2026-02-16

### Changed
- **Command Namespace**: Renamed `@acp.commit` to `@git.commit`
  - Better namespace organization (git-specific operations under `git` namespace)
  - Updated all references in AGENT.md and CHANGELOG.md
  - Command functionality unchanged, only improved organization

## [1.3.1] - 2026-02-16

### Added
- **Commit Types**: New commit types for better categorization
  - `agent`: Changes to agent/ directory only (designs, tasks, milestones, patterns)
  - `version`: Version bump only (no code changes)
- **Commit Template Enhancements**: Enhanced @git.commit template with metadata
  - Task and milestone completion tracking
  - Test statistics section (tests passing, coverage)
  - Documentation links section (design docs, API docs, related resources)
  - Scope in commit type format: `<type>(<scope>)`

### Changed
- **AGENT.md**: Added rule #9 for respecting user's intentional edits
  - Do not assume missing content needs to be added back
  - Always confirm before reverting user's manual changes
  - Read files to see current state before editing
- **@git.commit**: Clarified intelligent file staging behavior
  - Command automatically determines which files to stage
  - Decision logic for staging all vs specific files
  - Removed redundant prerequisites

### Fixed
- Clarified that `BREAKING CHANGE` is a footer, not a commit type

## [1.3.0] - 2026-02-16

### Added
- **`@git.commit` Command**: Intelligent version-aware git commit automation
  - Automatically detects version impact (major/minor/patch)
  - Updates all version files (package.json, AGENT.md, etc.)
  - Generates CHANGELOG.md entries with proper formatting
  - Creates Conventional Commits format messages
  - Includes decision tree and examples for version bumping
  - Supports semantic versioning workflow

### Changed
- **AGENT.md**: Added critical emphasis on CHANGELOG.md updates for version changes
  - New rule #7 mandates CHANGELOG.md updates for all version changes
  - Recommends using `@git.commit` for version-aware commits
  - Explains rationale for changelog discipline
  - Moved secrets handling to rule #8

## [1.2.2] - 2026-02-16

### Added
- `agent/.gitignore` file to exclude reports directory from version control
- `agent/reports/` directory created during installation
- Reports are now generated locally but not committed to git

### Changed
- `install.sh` now creates `agent/.gitignore` and `agent/reports/` directory
- `update.sh` ensures `agent/.gitignore` exists for users updating from older versions

## [1.2.1] - 2026-02-16

### Changed
- Updated installation scripts to display new ACP command format
- `install.sh` now shows all 11 ACP commands with descriptions
- `update.sh` now shows all 11 ACP commands with descriptions
- Replaced old "AGENT.md: Initialize" prompt format with `@acp.init` command
- Improved user experience for new installations and updates

## [1.2.0] - 2026-02-16

### Added
- **Package Installation Enhancements**:
  - `agent/scripts/package-install.sh` script for automated package installation
  - Support for installing patterns and design documents (not just commands)
  - `-y` flag to skip confirmation prompts for automated installations
  - Multi-directory installation from agent/ (commands, patterns, design)
  - Conflict detection and resolution

### Changed
- Renamed `@acp.install` to `@acp.package-install` for clarity
- Enhanced package installation to support all agent/ directories
- Simplified Milestone 2 scope by removing creation commands
- Updated package-install documentation with multi-directory examples

## [1.1.0] - 2026-02-16

### Added
- **ACP Commands System**: File-based command interface for ACP operations
  - Command template for creating custom commands
  - Flat directory structure with dot notation (acp.init.md)
  - 11 core commands implemented across 2 milestones:
  
  **Workflow Commands**:
    - `@acp.init` - Initialize agent context (replaces "AGENT.md: Initialize")
    - `@acp.proceed` - Continue with next task (replaces "AGENT.md: Proceed")
    - `@acp.status` - Display project status
  
  **Version Commands**:
    - `@acp.version-check` - Show current ACP version
    - `@acp.version-check-for-updates` - Check for updates
    - `@acp.version-update` - Update ACP to latest version
  
  **Documentation Commands**:
    - `@acp.update` - Update progress.yaml with latest status
    - `@acp.sync` - Synchronize documentation with source code
    - `@acp.validate` - Validate all ACP documents for consistency
  
  **Utility Commands**:
    - `@acp.report` - Generate comprehensive project status report
    - `@acp.package-install` - Install third-party command packages
  
  - Self-documenting commands with step-by-step instructions
  - Autocomplete-friendly namespace system with dot notation
  - Security considerations documented
  - Script-based package installation

- **Documentation Updates**:
  - ACP Commands section in AGENT.md with full documentation
  - Command examples in README.md
  - Updated directory structure diagrams
  - Command invocation syntax documented
  - Comprehensive command documentation with examples

### Changed
- Consolidated all scripts under `agent/scripts/` directory
- Updated installation script path in README
- Improved project organization with commands directory
- Simplified Milestone 2 scope by removing creation commands (natural language is sufficient)

## [1.0.3] - 2026-02-13

### Added
- **Template Files**: Complete set of reusable templates for all ACP document types
  - Design document template with comprehensive sections and examples
  - Requirements template for project planning
  - Milestone template with deliverables and success criteria
  - Task template with steps and verification checklist
  - Pattern template for documenting reusable patterns
  - Bootstrap template for project setup patterns
  - Progress tracking YAML template

- **Generic Patterns**: Database-agnostic, framework-independent patterns
  - TypeScript service layer pattern (applicable to any TypeScript project)

- **Installation & Update Scripts**:
  - `scripts/install.sh` - Automated installation (run from project root)
  - `scripts/update.sh` - Direct file updates (git handles diffs)
  - `scripts/check-for-updates.sh` - Automatic update checking with changelog display

- **Documentation**:
  - README with quick start guide and example projects
  - CHANGELOG for version tracking
  - AGENT.md with complete ACP methodology and update instructions

- **Features**:
  - Automatic update checking on agent initialization
  - Git-friendly workflow (no backup files)
  - Template files always overwritten on install/update
  - All URLs reference `mainline` branch
  - Sample prompts for AI agents

### Changed
- Converted project-specific remember-mcp documentation to generic templates
- Made all examples platform-agnostic and framework-independent
- Reorganized scripts into dedicated `scripts/` directory
- Simplified installation to assume execution from project root

### Removed
- All project-specific content (remember-mcp milestones, tasks, designs)
- Framework-specific patterns (TanStack Router, Firebase-specific examples)
- Project-specific TypeScript patterns (Firestore users pattern)
