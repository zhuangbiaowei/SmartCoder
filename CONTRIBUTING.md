# Contributing to SmartCoder

Thank you for your interest in contributing to SmartCoder! This document provides guidelines and information to help you contribute effectively.

## Table of Contents

- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Code Style](#code-style)
- [Project Structure](#project-structure)
- [Running Tests](#running-tests)
- [Documentation Guidelines](#documentation-guidelines)
- [Pull Request Process](#pull-request-process)
- [Getting Help](#getting-help)

---

## Getting Started

### Prerequisites

Before contributing to SmartCoder, ensure you have the following installed:

- **Ruby 3.2 or higher** - [Install Ruby](https://www.ruby-lang.org/en/downloads/)
- **Bundler** - For managing Ruby dependencies
- **Git** - For version control
- **Docker** (optional) - For DevContainer testing

```bash
# Check Ruby version (must be 3.2+)
ruby --version

# Install Bundler
gem install bundler

# Check Git
git --version
```

### Development Setup

Follow these steps to set up your development environment:

1. **Fork and Clone the Repository**

   ```bash
   # Fork the repository on GitHub, then clone your fork
   git clone https://github.com/your-username/smartcoder.git
   cd smartcoder
   ```

2. **Install Dependencies**

   ```bash
   bundle install
   ```

3. **Run the Test Suite**

   ```bash
   bundle exec rspec
   ```

4. **Build and Install Locally**

   ```bash
   gem build smartcoder.gemspec
   gem install ./smartcoder-0.1.0.gem
   ```

5. **Verify Installation**

   ```bash
   smartcoder --help
   ```

---

## Development Workflow

### Git Branch Naming Conventions

Use the following prefix patterns for branch names:

- `feature/` - New features
  - Example: `feature/diff-preview`
  - Example: `feature/step-branching`

- `bugfix/` - Bug fixes
  - Example: `bugfix/git-commit-failure`
  - Example: `bugfix/tui-rendering-issue`

- `docs/` - Documentation updates
  - Example: `docs/update-architecture-guide`
  - Example: `docs/api-documentation`

- `refactor/` - Code refactoring
  - Example: `refactor/workflow-engine`
  - Example: `refactor/step-journal`

- `test/` - Test additions or improvements
  - Example: `test/add-workflow-specs`
  - Example: `test/edge-case-coverage`

### Commit Message Format

We use [Conventional Commits](https://www.conventionalcommits.org/) for commit messages:

```
<type>(<scope>): <subject>

<body>

<footer>
```

#### Types

- `feat` - New feature
- `fix` - Bug fix
- `docs` - Documentation changes
- `style` - Code style changes (formatting, no logic change)
- `refactor` - Code refactoring
- `perf` - Performance improvements
- `test` - Test additions or changes
- `chore` - Maintenance tasks

#### Examples

```
feat(workflow): add step branching capability

Implement the ability to create alternative branches from any
step in the workflow, enabling exploration of different
implementation paths.

Closes #42
```

```
fix(container): handle missing devcontainer CLI gracefully

When devcontainer CLI is not available, fall back to host
execution instead of raising an error.

Fixes #15
```

```
docs(readme): add troubleshooting section

Add common troubleshooting tips and solutions for
frequently encountered issues.
```

### Development Cycle

1. Create a feature branch from `main`
2. Make your changes following code style guidelines
3. Add or update tests
4. Run the full test suite
5. Commit with conventional commit messages
6. Push to your fork
7. Create a Pull Request

---

## Code Style

### Ruby Style Guide

We generally follow the [Ruby Style Guide](https://rubystyle.guide/):

- Use 2 spaces for indentation (no tabs)
- Use `frozen_string_literal: true` at the top of all files
- Use meaningful variable and method names
- Write methods that do one thing well
- Keep lines under 100 characters
- Use snake_case for variables and methods
- Use PascalCase for classes and modules
- Use SCREAMING_SNAKE_CASE for constants

### Code Quality Standards

```ruby
# frozen_string_literal: true

module SmartCoder
  class Example
    def initialize(name:, options: {})
      @name = name
      @options = DEFAULT_OPTIONS.merge(options)
    end

    def process
      # Single responsibility: clear purpose
      validate_inputs
      execute
      log_result
    end

    private

    def validate_inputs
      raise ArgumentError, "Name cannot be empty" if @name.empty?
    end
  end
end
```

### Documentation in Code

- Add comments for complex logic only
- Prefer self-documenting code over comments
- Use `#` for single-line comments
- Document public API methods with RDoc comments:

```ruby
# Executes a command in the container and returns the output.
#
# @param command [String] The command to execute
# @return [String, String, Process::Status] stdout, stderr, and status
def run(command)
  # implementation
end
```

---

## Project Structure

```
smartcoder/
├── bin/
│   └── smartcoder           # CLI entry point
├── lib/
│   └── smartcoder/
│       ├── version.rb       # Version constant
│       ├── cli.rb           # Command-line interface (init, chat)
│       ├── config.rb        # Configuration management (.smartcoder.yml)
│       ├── step.rb          # Step data structure
│       ├── step_journal.rb  # Step journaling (JSONL format)
│       ├── git_client.rb    # Git operations wrapper
│       ├── container_runner.rb  # Container execution
│       ├── tui.rb           # Terminal user interface
│       ├── workflow.rb      # Main workflow engine
│       └── run_manager.rb   # Run lifecycle management
├── docs/
│   ├── architecture.md      # Technical architecture
│   ├── technical-spec.md     # Technical specifications
│   ├── requirements.md       # Product requirements
│   └── TODO.md              # Development roadmap
├── CHANGELOG.md             # Version history
├── CONTRIBUTING.md          # This file
├── README.md                # User documentation
└── smartcoder.gemspec       # Gem specification
```

### Key Modules

- **CLI** (`cli.rb`) - Entry point for `smartcoder init` and `smartcoder chat` commands
- **Config** (`config.rb`) - Loads and manages `.smartcoder.yml` configuration
- **Workflow** (`workflow.rb`) - Orchestrates the Plan → Retrieve → Patch → Verify cycle
- **RunManager** (`run_manager.rb`) - Manages run lifecycle and directory structure
- **StepJournal** (`step_journal.rb`) - Writes step records in JSONL format
- **GitClient** (`git_client.rb`) - Wraps Git operations (status, commit)
- **ContainerRunner** (`container_runner.rb`) - Executes commands in DevContainer or host
- **TUI** (`tui.rb`) - Renders terminal UI for steps and logs

---

## Running Tests

### Test Framework

We use **RSpec** for testing. Configure your test environment:

```bash
# Run all tests
bundle exec rspec

# Run with coverage
COVERAGE=1 bundle exec rspec

# Run specific test file
bundle exec rspec spec/workflow_spec.rb

# Run specific test by line number
bundle exec rspec spec/workflow_spec.rb:42

# Run tests matching a pattern
bundle exec rspec --tag ~slow
```

### Test Structure

```
spec/
├── spec_helper.rb           # Test configuration
├── smartcoder/
│   ├── cli_spec.rb
│   ├── config_spec.rb
│   ├── workflow_spec.rb
│   └── ...
└── fixtures/               # Test data and fixtures
```

### Writing Tests

```ruby
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SmartCoder::Workflow do
  describe '#run_chat' do
    context 'with a valid task' do
      it 'executes the patch and verify steps' do
        # Arrange
        config = SmartCoder::Config.new({})
        run = create_test_run
        workflow = described_class.new(config: config, run: run)

        # Act
        workflow.run_chat(task: 'Fix the bug', verify_command: 'rake test')

        # Assert
        expect(run.journal.entries.count).to eq(2)
      end
    end
  end
end
```

### Test Coverage Expectations

- Aim for **> 80% code coverage** for new code
- All new features must include tests
- Bug fixes should include regression tests
- Test edge cases and error conditions

---

## Documentation Guidelines

### Where to Document What

#### README.md

- Quick start guide for users
- Installation instructions
- Basic usage examples
- Key features and benefits
- Links to other documentation

#### docs/architecture.md

- Technical design decisions
- Module responsibilities and interactions
- Data flow diagrams
- Design patterns used
- Rationale for architectural choices

#### docs/technical-spec.md

- Detailed technical specifications
- API contracts
- Data structures and formats
- Execution models

#### docs/requirements.md

- Product requirements
- User stories
- Feature descriptions
- Non-functional requirements

#### Inline Code Documentation

- Public API methods must have RDoc comments
- Complex algorithms need explanatory comments
- Document configuration options

#### Contributing.md (This File)

- Development setup instructions
- Contribution workflow
- Code style guidelines
- Pull request process

### Documentation Style

- **Language**: Maintain current Chinese/English bilingual style
- **Tone**: Professional, clear, and concise
- **Formatting**: Use Markdown with consistent headers
- **Examples**: Provide working code examples
- **Links**: Verify all internal and external links

### Updating Documentation

When you make code changes, ensure documentation is updated:

1. **New Features**: Add to README.md and update docs/architecture.md
2. **Breaking Changes**: Document prominently in CHANGELOG.md
3. **Bug Fixes**: Update CHANGELOG.md
4. **API Changes**: Update inline documentation and docs/technical-spec.md

---

## Pull Request Process

### Before Submitting a PR

1. **Update Documentation**
   - Update relevant doc files (README, CHANGELOG, architecture)
   - Add inline comments for complex code

2. **Run Tests**
   - Ensure all tests pass: `bundle exec rspec`
   - Check test coverage: `COVERAGE=1 bundle exec rspec`

3. **Code Review Your Own Changes**
   - Review your changes for clarity and correctness
   - Remove debug code and commented-out code
   - Follow code style guidelines

4. **Squash Commits** (optional)
   - Squash small fix-up commits
   - Keep the commit history clean and meaningful

### PR Description Template

```markdown
## Summary
Brief description of what this PR does and why.

## Changes
- List major changes
- Bulleted format preferred

## Testing
- Describe how you tested
- Link to test runs if applicable

## Related Issues
Closes #XX
Fixes #XX
Related to #XX
```

### Code Review Process

1. **Review Feedback**
   - Address all review comments
   - Explain reasoning if you disagree
   - Update PR as needed

2. **CI/CD Checks**
   - All CI checks must pass
   - Fix any failures before requesting merge

3. **Merge Approval**
   - At least one maintainer approval required
   - Resolve all outstanding discussions
   - Ensure no merge conflicts

### Merge Guidelines

- **Squash and merge** for small PRs
- **Rebase and merge** for feature branches with clean history
- **Do not merge** with unresolved discussions
- **Delete branch** after merging

---

## Getting Help

### Where to Ask Questions

1. **GitHub Issues** - Bug reports and feature requests
2. **GitHub Discussions** - Questions and general discussions
3. **Pull Request Comments** - Specific PR-related questions

### Issue Reporting Guidelines

When reporting issues, please include:

- **Ruby version**: `ruby --version`
- **SmartCoder version**: `gem list smartcoder`
- **OS**: `uname -a` (Linux/macOS)
- **Error message**: Full error stack trace
- **Steps to reproduce**: Clear, step-by-step instructions
- **Expected behavior**: What you expected to happen
- **Actual behavior**: What actually happened
- **Configuration**: `.smartcoder.yml` content (redact sensitive info)

### Feature Requests

When proposing new features:

1. Check existing issues and PRs first
2. Describe the problem you're trying to solve
3. Explain why the feature would be valuable
3. Consider if you can contribute it yourself
4. Use the `feature request` label

---

## Code of Conduct

We expect all contributors to follow these principles:

- Be respectful and inclusive
- Provide constructive feedback
- Focus on what is best for the community
- Show empathy towards other community members

---

## License

By contributing to SmartCoder, you agree that your contributions will be licensed under the MIT License.

---

Thank you for contributing to SmartCoder! Every contribution, no matter how small, is valuable.
