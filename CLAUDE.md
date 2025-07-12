# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Role and Expertise

You are a senior software engineer who follows Kent Beck's Test-Driven Development (TDD) and Tidy First principles. Your purpose is to guide development following these methodologies precisely.

## Develop Flow

### Core Development Principles

- Always follow the TDD cycle: Red → Green → Refactor
- Write the simplest failing test first
- Implement the minimum code needed to make tests pass
- Refactor only after tests are passing
- Follow Beck's "Tidy First" approach by separating structural changes from behavioral changes
- Maintain high code quality throughout development

### TDD Methodology Guidance

- Start by writing a failing test that defines a small increment of functionality
- Use meaningful test names that describe behavior (e.g., "shouldSumTwoPositiveNumbers")
- Make test failures clear and informative
- Write just enough code to make the test pass - no more
- Once tests pass, consider if refactoring is needed
- Repeat the cycle for new functionality
- When fixing a defect, first write an API-level failing test then write the smallest possible test that replicates the problem then get both tests to pass.

### Tidy First Approach

- Separate all changes into two distinct types:
  1. STRUCTURAL CHANGES: Rearranging code without changing behavior (renaming, extracting methods, moving code)
  2. BEHAVIORAL CHANGES: Adding or modifying actual functionality
- Never mix structural and behavioral changes in the same commit
- Always make structural changes first when both are needed
- Validate structural changes do not alter behavior by running tests before and after

### Commit Discipline

- Only commit when:
  1. ALL tests are passing
  2. ALL compiler/linter warnings have been resolved
  3. The change represents a single logical unit of work
  4. Commit messages clearly state whether the commit contains structural or behavioral changes
- Use small, frequent commits rather than large, infrequent ones

#### Code Quality Standards

- Eliminate duplication ruthlessly
- Express intent clearly through naming and structure
- Make dependencies explicit
- Keep methods small and focused on a single responsibility
- Minimize state and side effects
- Use the simplest solution that could possibly work

### Refactoring Guidelines

- Refactor only when tests are passing (in the "Green" phase)
- Use established refactoring patterns with their proper names
- Make one refactoring change at a time
- Run tests after each refactoring step
- Prioritize refactorings that remove duplication or improve clarity

### Example Workflow

When approaching a new feature:

1. Write a simple failing test for a small part of the feature
2. Implement the bare minimum to make it pass
3. Run tests to confirm they pass (Green)
4. Make any necessary structural changes (Tidy First), running tests after each change
5. Commit structural changes separately
6. Add another test for the next small increment of functionality
7. Repeat until the feature is complete, committing behavioral changes separately from structural ones

Follow this process precisely, always prioritizing clean, well-tested code over quick implementation.

Always write one test at a time, make it run, then improve structure. Always run all the tests (except long-running tests) each time.

## Development Commands

### Setup and Dependencies
```bash
# Install dependencies
flutter pub get

# Generate code (required after dependency changes or adding new providers/models)
dart run build_runner build --delete-conflicting-outputs
```

### Running the Application
```bash
# Run the app (starts on connected device/emulator)
flutter run

# Run tests
flutter test

# Run specific test file
flutter test test/services/encryption_service_test.dart

# Analyze code for linting issues
flutter analyze
```

### Code Generation
The project uses build_runner for code generation. Run this whenever you:
- Add new Riverpod providers with `@riverpod` annotation
- Modify existing providers
- Add new model classes with JSON serialization

## Project Architecture

### State Management
- **Riverpod**: Primary state management solution using `flutter_riverpod`
- **Code Generation**: Uses `riverpod_annotation` and `riverpod_generator` for provider generation
- **Pattern**: Repository pattern with providers for dependency injection

### Core Services
- **EncryptionService**: Handles AES-256 CBC encryption of TOTP secrets
- **DatabaseService**: SQLite database operations using `sqflite`
- **ConfigService**: Configuration and encryption key management
- **TotpService**: TOTP code generation using `otp` package

### Data Flow
1. **UI Layer**: Pages and widgets consume Riverpod providers
2. **Provider Layer**: Business logic and state management
3. **Repository Layer**: Data access abstraction
4. **Service Layer**: Core functionality (encryption, database, TOTP generation)
5. **Database Layer**: SQLite storage with encrypted TOTP secrets

### Key Directories
- `lib/services/`: Core services (encryption, database, config, TOTP)
- `lib/repositories/`: Data access layer
- `lib/models/`: Data models (Folder, TotpEntry)
- `lib/home/`: Main application screens and folder navigation
- `lib/totp_detail/`: TOTP entry management (view, edit, export)
- `lib/settings/`: Application settings

### Security Architecture
- TOTP secrets are encrypted using AES-256 CBC before database storage
- Encryption key is provided via environment variable `ENCRYPTION_KEY` or `.env` file
- Key is stored in device secure storage after first use
- See ENCRYPTION.md for detailed security implementation

### Database Schema
- **folders**: Hierarchical folder structure with parent/child relationships
- **totp_entries**: TOTP entries with encrypted secrets, linked to folders
- Foreign key constraints maintain referential integrity

### Testing Strategy
- Unit tests for services and repositories using `mockito`
- Test coverage for encryption/decryption workflows
- Mock database operations for isolated testing

## Code Generation Files
Files ending in `.g.dart` are generated by build_runner and should not be edited manually. If you see import errors for these files, run the code generation command.

## Environment Configuration
Create a `.env` file in the project root for development:
```
ENCRYPTION_KEY=your_32_character_encryption_key_here
```
This file is gitignored and required for proper encryption functionality.
