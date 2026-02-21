# Changelog

All notable changes to the Agent Context Protocol will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.8.0] - 2026-02-21

### Added
- **@acp.package-publish Command** - Automated package publishing workflow
  - 11-step publishing workflow from validation to testing
  - Delegates to @git.commit for version/CHANGELOG management (avoids logic duplication)
  - Automatic version bump detection from Conventional Commits
  - Analyzes commits for breaking changes, features, and fixes
  - User confirmation for version number (Y/n/custom)
  - Branch validation (main, master, mainline, release, custom)
  - Remote status checking (prevents overwriting)
  - Git tag creation (vX.Y.Z format)
  - Push to remote (commits and tags)
  - Post-publish test installation from remote
  - Comprehensive error handling at each step
  - Shell script: `agent/scripts/acp.package-publish.sh`

### Changed
- Milestone 4 progress: 73% → 82% (9/11 tasks complete)
- Phase 4 (Publishing) complete

## [2.7.0] - 2026-02-21

### Changed
- **Enhanced @acp.validate Command** - Added strict namespace validation
  - STRICT enforcement: All patterns/commands/designs MUST have namespace prefix
  - In packages: Use package namespace (e.g., firebase.pattern.md)
  - In projects: Use local namespace (e.g., local.pattern.md)
  - ERROR for files missing namespace prefix (not just warning)
  - Exception: Template files (*.template.md) don't need namespace
  - Added Step 8: Validate Namespace Conventions
  - Context-aware validation (package vs project detection)
  - Checks for reserved namespace violations (acp, local, core, system, global)
  - Updated verification checklist with namespace checks
  - Updated example output with namespace validation section
  - Added computer roleplay directive to command header
  - Version bump: 1.0.0 → 2.0.0 (breaking - new strict validation)
- Milestone 4 progress: 64% → 73% (8/11 tasks complete)
- Phase 3 (Validation) complete

## [2.6.0] - 2026-02-21

### Changed
- **Enhanced @acp.validate Command** - Added namespace validation and reserved name checking
  - Added Step 8: Validate Namespace Conventions
  - Context-aware validation (package vs project detection)
  - Validates command/pattern/design filenames use correct namespace
  - Checks for reserved namespace violations (acp, local, core, system, global)
  - Updated verification checklist with namespace checks
  - Updated example output with namespace validation section
  - Added computer roleplay directive to command header
  - Version bump: 1.0.0 → 2.0.0 (breaking - new validation checks)
- Milestone 4 progress: 64% → 73% (8/11 tasks complete)
- Phase 3 (Validation) complete

## [2.5.0] - 2026-02-21

### Added
- **@acp.package-validate Command** - Comprehensive package validation system
  - Shell-based validation (YAML structure, file existence, namespace consistency, git setup, README)
  - Test installation to temporary directory with automatic cleanup
  - Remote repository availability checking via git ls-remote
  - Unlisted files detection (finds files not in package.yaml)
  - Validation score calculation and comprehensive reporting
  - Fixable issues identification for LLM auto-fix
  - Command documentation with examples and troubleshooting
  - Shell script: `agent/scripts/acp.package-validate.sh`

### Changed
- Milestone 4 progress: 55% → 64% (7/11 tasks complete)
- Phase 3 (Validation) started with Task 20 complete

## [2.4.0] - 2026-02-21

### Changed
- Enhanced `agent/commands/command.template.md` with computer roleplay directive
  - Clarifies that agent should execute command directives as instructions
  - Improves command execution clarity and consistency

## [2.3.0] - 2026-02-21

### Added
- **@acp.command-create Command** - LLM-based command creation
  - Context-aware namespace detection
  - Collects command-specific fields (category, frequency)
  - Automatic package.yaml and README.md updates
  - Draft file support
- **@acp.design-create Command** - LLM-based design document creation
  - Context-aware namespace detection
  - Automatic package.yaml and README.md updates
  - Draft file support
- **Design: install-local-patterns-feature** - Proposal for --install-local flag
  - Install local namespace patterns from source repos with namespace conversion
  - Enable sharing of implementation patterns between packages

### Changed
- Milestone 4 progress: 55% (6/11 tasks complete)
- Phase 2 (Entity Creation) complete - all 3 entity creation commands implemented

## [2.2.3] - 2026-02-21

### Added
- **Pattern: library-services** - Service layer, database layer, and API client layer architecture
  - Three-layer architecture for TypeScript libraries
  - Complete implementation examples for each layer
  - Dependency injection pattern
  - Testing examples with mocks
  - Benefits, trade-offs, and usage guidance
  - Demonstrates @acp.pattern-create command in action

## [2.2.2] - 2026-02-20

### Added
- **@acp.pattern-create Command** - LLM-based pattern creation (no shell script needed)
  - Context-aware namespace detection
  - Chat-based information collection
  - Draft file support
  - Automatic package.yaml and README.md updates
  - Command documentation complete

### Changed
- Simplified entity creation approach: LLM handles creation directly via command directives
- Removed unnecessary shell script (agent/scripts/acp.pattern-create.sh)
- Entity creation commands are now pure LLM directives (more intelligent and flexible)

## [2.2.1] - 2026-02-20

### Added
- **Task 15: Namespace Utilities** - Context-aware namespace detection and validation
  - Added `is_acp_package()` - Detects if directory is ACP package
  - Added `infer_namespace()` - Infers namespace from package.yaml, directory name, or git remote
  - Added `validate_namespace()` - Validates format and checks reserved names (acp, local, core, system, global)
  - Added `get_namespace_for_file()` - Returns package namespace or "local" for non-packages
  - Added `validate_namespace_consistency()` - Checks for conflicts between sources
- **Task 16: README Update Utilities** - Automatic README.md content list generation
  - Added `update_readme_contents()` - Updates README from package.yaml
  - Added `generate_contents_section()` - Generates formatted markdown lists
  - Added `add_file_to_readme()` - Convenience wrapper
  - Uses HTML comment markers for section boundaries
  - Extracts file names and descriptions from package.yaml

### Changed
- Enhanced `agent/scripts/acp.common.sh` with 8 new utility functions
- Milestone 4 progress: 27% (3/11 tasks complete)

## [2.2.0] - 2026-02-20

### Added
- **Milestone 4: ACP Package Development System** - Comprehensive planning complete
  - Created design document with complete architecture and specifications
  - Created milestone document with 11 tasks across 6 phases
  - Created 11 task documents (task-14 through task-24)
  - Estimated effort: 45-58 hours over 6-8 weeks
- **Clarification System** - 4 clarification documents with 214 questions answered
  - clarification-1: Package create enhancements (31 questions)
  - clarification-2: Package development commands (62 questions)
  - clarification-3: Draft files and schema validation (73 questions)
  - clarification-4: Implementation edge cases (48 questions)
- **Task 14 Complete: YAML Schema System** - Pure bash YAML validator
  - Created `agent/schemas/package.schema.yaml` with comprehensive schema definition
  - Implemented `agent/scripts/acp.yaml-validate.sh` (pure bash, zero dependencies)
  - Validates required fields, types, patterns, lengths, reserved names
  - Tested with valid and invalid package.yaml files
  - Provides helpful error messages
- **New Commands Planned** (to be implemented in M4):
  - `@acp.pattern-create` - Create patterns with namespace enforcement
  - `@acp.command-create` - Create commands with namespace enforcement
  - `@acp.design-create` - Create design documents with namespace enforcement
  - `@acp.package-validate` - Comprehensive package validation with auto-fix
  - `@acp.package-publish` - Automated publishing workflow

### Changed
- Updated `@acp.package-create` command with chat-based collection and target directory support
- Project status changed to in_progress with current_milestone: M4
- Milestone 4 progress: 9% (1/11 tasks complete)

## [2.1.4] - 2026-02-18

### Added
- **CRITICAL: Never Reject User Requests Directive**: Added as Best Practice #1 in AGENT.md
  - Agents must NEVER reject requests based on session duration, token context limits, session cost, or task complexity
  - Emphasizes that users have the right to request any work they need
  - Agents should break down complex tasks and work iteratively
  - Marked with 🚨 CRITICAL warning indicators for maximum visibility
  - Positioned as the most important best practice for agent behavior

### Changed
- Renumbered existing best practices (CHANGELOG.md guideline is now #8, secrets handling remains in sequence)

## [2.1.3] - 2026-02-18

### Added
- **Package Management Commands**: Complete package management system with 6 new commands
  - `@acp.package-search` - Search for available ACP packages
  - `@acp.package-list` - List installed packages
  - `@acp.package-remove` - Remove installed packages
  - `@acp.package-info` - Display package information
  - `@acp.package-update` - Update installed packages
  - `@acp.package-install` - Enhanced with manifest support
- **Manifest System**: YAML-based package metadata
  - `agent/manifest.template.yaml` for package authors
  - Tracks package name, version, description, author
  - Lists all files (commands, patterns, designs)
  - Documents dependencies on other packages
  - Enables selective installation and updates
- Supporting shell scripts for all package commands
- Milestone 3 completed (100% - all 13 tasks done)

## [2.1.2] - 2026-02-18

### Changed
- **Command Display**: Refactored command list display into shared `display_available_commands()` function
  - Added new function in `acp.common.sh` for consistent command display
  - Updated `acp.install.sh` to use shared function
  - Updated `acp.version-update.sh` to use shared function
  - Now displays all 19 commands including 6 package management commands
  - Eliminates code duplication (reduced from 40+ lines to 1 function call)

## [2.1.1] - 2026-02-18

### Fixed
- **Script Installation**: Install and update scripts now copy all *.sh files dynamically
  - Previously hardcoded list was missing new package management scripts
  - `acp.package-search.sh`, `acp.package-list.sh`, `acp.package-remove.sh`, `acp.package-info.sh`, `acp.package-update.sh` now properly installed
  - Future-proof: any new scripts will be automatically copied
  - Simplified code from 10 lines to 4 lines using find command

## [2.1.0] - 2026-02-18

### Added
- **Dependency Checking System**: Project dependency compatibility validation for npm, pip, cargo, and go packages
  - Automatic package manager detection
  - Version compatibility checking with color-coded output
  - User prompts with recommendations for missing dependencies
  - Integration with package installation flow
  - Respects `--yes` flag for CI/CD automation
- Added 6 dependency checking functions to `acp.common.sh`:
  - `detect_package_manager()` - Detects npm/pip/cargo/go
  - `check_npm_dependency()` - Validates npm packages
  - `check_pip_dependency()` - Validates Python packages
  - `check_cargo_dependency()` - Validates Rust packages
  - `check_go_dependency()` - Validates Go packages
  - `validate_project_dependencies()` - Main validation function

### Changed
- Enhanced `acp.package-install.sh` with dependency validation before installation
- Updated project status to "completed" - all 3 milestones (16 tasks) complete
- Milestone 3 progress: 78% → 100%

### Verified
- Pure bash YAML parser (`acp.yaml.sh`) already implemented and functional
- Based on fiftydinar/yaml-parser (MIT license)
- Provides yaml_get(), yaml_set(), yaml_has_key(), yaml_get_array()

## [2.0.0] - 2026-02-18

### Changed
- **BREAKING**: All core ACP scripts renamed with `acp.` prefix for namespace protection
  - `check-for-updates.sh` → `acp.version-check-for-updates.sh`
  - `common.sh` → `acp.common.sh`
  - `install.sh` → `acp.install.sh`
  - `package-install.sh` → `acp.package-install.sh`
  - `uninstall.sh` → `acp.uninstall.sh`
  - `update.sh` → `acp.version-update.sh`
  - `version.sh` → `acp.version-check.sh`
  - `yaml.sh` → `acp.yaml.sh`
- **BREAKING**: Script names now perfectly align with command names
  - `@acp.version-check` → `acp.version-check.sh`
  - `@acp.version-update` → `acp.version-update.sh`
  - `@acp.package-install` → `acp.package-install.sh`
- Installation and update scripts now automatically remove deprecated script names
- All 84+ references updated across documentation

### Added
- `cleanup_deprecated_scripts()` function in `acp.common.sh`
- Automatic cleanup of old script names during install/update

### Migration Guide
**For Users**: No action required if using commands (`@acp.*`)
- Commands still work the same way
- Scripts are called internally by ACP

**For Direct Script Users**: Update script paths
- Old: `./agent/scripts/update.sh`
- New: `./agent/scripts/acp.version-update.sh`

**Why This Change**:
- Enables third-party packages to add their own scripts without conflicts
- Perfect alignment between command names and script names
- Clear namespace ownership (`acp.*` = core, `firebase.*` = firebase package)

## [1.4.3] - 2026-02-16

### Fixed
- **Script Color Output**: Updated remaining shell scripts to use `tput` for colors
  - Updated acp.version-check-for-updates.sh to use tput pattern
  - Updated unacp.install.sh to use tput pattern
  - Updated acp.version-check.sh to use tput pattern
  - Updated package-acp.install.sh to use tput pattern
  - All 6 scripts now use consistent, reliable color handling
  - Removed `echo -e` flags (not needed with tput)
  - Colors work correctly across all shells (bash, sh, zsh)

## [1.4.2] - 2026-02-16

### Changed
- **Script Output**: Added "Git Commands Available" section to acp.install.sh and acp.version-update.sh
  - Separate section highlighting @git.init and @git.commit commands
  - Improves discoverability of git workflow commands for new users
  - Clear separation between ACP commands and Git commands

## [1.4.1] - 2026-02-16

### Fixed
- **Script Color Output**: Fixed color output in acp.install.sh and acp.version-update.sh
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
- `acp.install.sh` now creates `agent/.gitignore` and `agent/reports/` directory
- `acp.version-update.sh` ensures `agent/.gitignore` exists for users updating from older versions

## [1.2.1] - 2026-02-16

### Changed
- Updated installation scripts to display new ACP command format
- `acp.install.sh` now shows all 11 ACP commands with descriptions
- `acp.version-update.sh` now shows all 11 ACP commands with descriptions
- Replaced old "AGENT.md: Initialize" prompt format with `@acp.init` command
- Improved user experience for new installations and updates

## [1.2.0] - 2026-02-16

### Added
- **Package Installation Enhancements**:
  - `agent/scripts/package-acp.install.sh` script for automated package installation
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
  - `scripts/acp.install.sh` - Automated installation (run from project root)
  - `scripts/acp.version-update.sh` - Direct file updates (git handles diffs)
  - `scripts/acp.version-check-for-updates.sh` - Automatic update checking with changelog display

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

