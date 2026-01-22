# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Comprehensive documentation improvements
  - Enhanced README.md with troubleshooting section and documentation badge
  - Created CONTRIBUTING.md with complete contribution guide
  - Expanded docs/architecture.md with detailed technical design and data flow
  - Improved documentation structure and developer onboarding

## [0.1.0] - 2024-01-01

### Added

- Initial release
  - Console coding agent with DevContainer support
  - Step-based execution with Git integration
  - Structured logging and traceability
  - Rich TUI interface
  - Core workflow: Plan → Retrieve → Patch → Verify → Iterate
  - Configuration management
  - Container execution support
  - Step journaling in JSONL format

### Technical Implementation

- Ruby ≥ 3.2 support
- Dependency on smart_agent, smart_prompt, smart_rag, ruby_rich
- Git-based version control and checkpoints
- Docker/DevContainer integration
- Modular architecture with clear separation of concerns

### Core Features

- [x] CLI with init and chat commands
- [x] DevContainer execution support
- [x] Step journaling system (JSONL)
- [x] Automatic Git commits per step
- [x] Basic TUI for step list and logs
- [x] Patch and verify cycle
- [x] Configuration file support
- [x] Container execution
- [x] Multi-step task management

### Known Limitations

- No step branching or rollback yet (v0.2)
- No diff preview or command confirmation (v0.2)
- No dangerous command interception (v0.2)
- No RAG-based code retrieval (v0.2)

---

## Changelog Format

This project uses [Keep a Changelog](https://keepachangelog.com/) format:

- **[Unreleased]**: Next release
- **[0.1.0]**: Initial release (v0.1.0)

### Types of Changes

- **Added**: New features
- **Changed**: Changes in existing functionality
- **Deprecated**: Soon-to-be removed features
- **Removed**: Now removed features
- **Fixed**: Bug fixes
- **Security**: Security vulnerability fixes

### Versioning

This project uses [Semantic Versioning](https://semver.org/):
- **MAJOR** version (breaking changes)
- **MINOR** version (new features, backwards compatible)
- **PATCH** version (bug fixes, backwards compatible)

---

## Planned Features (v0.2)

- [ ] Step branching and rollback commands
- [ ] Diff preview and confirmation
- [ ] Dangerous command interception
- [ ] RAG-based code retrieval
- [ ] Replay verification
- [ ] Multi-agent parallel execution
- [ ] Execution trace storage in RAG
- [ ] Container snapshots
- [ ] Headless mode for CI/CD
- [ ] MCP protocol integration
- [ ] PR generation
- [ ] Multi-run management

---

## [Source Code](https://github.com/your-org/smartcoder/tree/main)

[Unreleased]: https://github.com/your-org/smartcoder/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/your-org/smartcoder/releases/tag/v0.1.0
