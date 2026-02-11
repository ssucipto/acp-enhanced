# Changelog

All notable changes to the Agent Context Protocol will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
