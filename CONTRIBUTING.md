# Contributing to whiteTV

Thank you for your interest in contributing to whiteTV!

## Development Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/poyhsiao/whiteTV.git
   cd whiteTV
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Environment setup**
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

4. **Run the app**
   ```bash
   # TV mode
   EXPO_TV=1 yarn start
   
   # Mobile/Tablet
   yarn start
   ```

## Development Standards

- **TDD (Test-Driven Development)**: All features must be developed using TDD methodology
  1. Write test first (RED)
  2. Implement minimal fix (GREEN)
  3. Refactor (IMPROVE)
  4. Verify 80%+ coverage

- **Code Review**: All changes require code review before merging
- **Testing**: Minimum 80% test coverage is required
- **E2E Testing**: UI/UX functionality must be tested using Playwright

## Branching Strategy

- `main` - Production-ready code
- `feature/*` - New features
- `fix/*` - Bug fixes
- `refactor/*` - Code refactoring

## Commit Message Format

```
<type>: <description>

Types: feat, fix, refactor, docs, test, chore, perf, ci
```

## Pull Request Process

1. Fork the repository
2. Create a feature branch from `main`
3. Write tests first (TDD)
4. Ensure all tests pass
5. Update documentation if needed
6. Request code review
7. Squash and merge

## License

By contributing to whiteTV, you agree that your contributions will be licensed under the Mozilla Public License Version 2.0.
