# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-05-20

### Added
- Initial release
- HomeScreen with category-based video browsing
- DetailScreen with TV/Mobile responsive layout
- PlayerScreen with media_kit video playback
- Riverpod state management (HomeStore, DetailStore, PlayerStore)
- GoRouter navigation setup
- LunaTV API integration with mock data fallback
- Client Factory pattern for API dual-track implementation
- Design system (AppTheme with glassmorphism components)
- Device detection utilities (TV, tablet, mobile)
- GitHub Actions CI workflow

### Features
- TV Leanback support for Android TV
- Cross-platform responsive design
- Remote control server for external device control
- Automatic update checking system

## [0.2.0] - 2026-05-20

### Added
- **Settings Feature**: Full settings system with persistent storage
  - SettingsScreen with TabBar navigation (General, Account, Display, Playback)
  - SettingsState and SettingsStore for state management
  - SettingsStorageService for persistent storage using SharedPreferences
  - SourceBlocklistTile for managing blocked content sources
  - TabOrderEditor for customizable tab ordering
- **Authentication**: AuthState and AuthStore for login/logout functionality
- **API Enhancement**: ApiClient interface with login() method
  - LunaClient and MockClient updated with login support
- **Settings Widgets**: Reusable settings card components

### Features
- Tab-based settings navigation
- Cookie-based authentication persistence
- Content source blocklist management
- Customizable UI tab ordering

## [Unreleased]

### Planned
- Search functionality
- User authentication
- Favorites management
- Playback history
- Multi-language support

[0.1.0]: https://github.com/poyhsiao/whiteTV/releases/tag/v0.1.0
