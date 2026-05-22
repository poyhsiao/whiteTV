# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.4.1] - 2026-05-22

### Added
- **Unified Input System**: QR code + phone browser input for TV and mobile
  - SessionManager for QR session lifecycle management
  - LocalHttpServer (shelf HTTP server) for phone input via browser
  - InputService facade coordinating all input services
  - QrInputWidget for QR code display
  - InputScreen (TV full-screen mode) and LoginScreen (QR input support)
  - BDD integration tests (input flow, session handling)
  - 12 integration tests passing

### Changed
- Login system now supports QR code input for TV devices
- Flutter analyze passed with no issues

## [0.4.0] - 2026-05-22

### Added
- **Favorites Feature**: Full favorites management with local-first sync
  - FavoriteItem, FavoritesState models (TDD)
  - FavoritesRepository abstract interface
  - FavoritesLocalService (SharedPreferences storage)
  - FavoritesRemoteService (LunaTV API sync)
  - FavoritesService facade with background sync
  - FavoritesStore (Riverpod state management)
  - FavoritesScreen with grid/list view toggle
  - FavoritesFilterBar with type filtering (all/movie/series/anime/variety)
  - FavoriteTile, FavoriteGrid widgets
  - "已下架" badge for unavailable content
  - BDD integration tests (26 scenarios)
  - 74 tests passing for favorites feature

## [0.3.0] - 2026-05-21

### Added
- **IPTV Live Feature**: Full live TV streaming with M3U playlist support
  - M3uChannel, EpgProgram, EpgChannel models (TDD)
  - M3uParser, EpgManager, TimeshiftManager abstract interfaces
  - LiveService facade coordinating all services
  - LiveStore with Riverpod state management
  - LiveScreen (channel list) and LivePlayerScreen (player)
  - ChannelTile, EpgProgramTile, EpgProgramList widgets
  - TimeshiftControlBar and SignalErrorWidget
  - Full TV remote + touch support
  - BDD integration tests (10 scenarios)
  - Router integration (/live, /live/player)
  - 107 tests passing for live feature

## [0.2.1] - 2026-05-21

### Added
- **Search Feature**: Full search system with TV remote D-pad navigation
  - SearchScreen with search input and category filter
  - KeyboardInputView for TV remote D-pad text input
  - SearchStore with search history management
  - SearchHistoryService for persistent search history
  - CategoryFilter for filtering by category
  - QRInputView for QR code scanning input
  - SearchResults widget for displaying results
  - BDD integration tests for search feature (20 tests)
- **Play History Feature**: Playback history with local-first sync
  - HistoryScreen with time grouping (今天/昨天/更早)
  - HistoryStore with loadHistory, addRecord, deleteRecord
  - HistoryService facade with local + LunaTV sync
  - HistoryLocalService (SharedPreferences storage)
  - HistoryRemoteService (LunaTV /api/user/stats integration)
  - RecentWatchSection for home screen (max 10 records)
  - HistoryTile widget with progress display
  - BDD integration tests for play history (4 scenarios)

### Security
- Input validation and sanitization for search queries
- Search query length limit (200 chars) and whitespace trimming

### Planned
- Favorites management
- Multi-language support

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

[0.4.1]: https://github.com/poyhsiao/whiteTV/releases/tag/v0.4.1
[0.4.0]: https://github.com/poyhsiao/whiteTV/releases/tag/v0.4.0
[0.3.0]: https://github.com/poyhsiao/whiteTV/releases/tag/v0.3.0
[0.2.1]: https://github.com/poyhsiao/whiteTV/releases/tag/v0.2.1
[0.2.0]: https://github.com/poyhsiao/whiteTV/releases/tag/v0.2.0
[0.1.0]: https://github.com/poyhsiao/whiteTV/releases/tag/v0.1.0