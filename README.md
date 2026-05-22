# whiteTV

A Flutter TV application for streaming video content, designed for Apple TV and Android TV with remote control support.

## Version

**v0.4.1** - Unified Input System

## Features

- **Home Screen**: Category-based video browsing with responsive layout
- **Detail Screen**: TV/Mobile adaptive layout with episode selection
- **Player Screen**: Video playback with media_kit
- **Settings**: Tab-based settings with persistent storage
- **Search**: Full-text search with TV remote D-pad navigation, QR code input support
- **Play History**: Local-first playback history with LunaTV sync, time grouping
- **IPTV Live**: Live TV streaming with M3U playlist, EPG, and timeshift replay
- **Favorites**: Local-first favorites with grid/list view, type filtering, LunaTV sync
- **Unified Input**: QR code + phone browser input for TV (full-screen) and mobile (modal)

### Unified Input System (v0.4.1)

- SessionManager for QR session lifecycle management
- LocalHttpServer (shelf HTTP server) for phone input via browser
- InputService facade coordinating all input services
- QrInputWidget for QR code display
- InputScreen (TV full-screen mode) and LoginScreen (QR input support)
- BDD integration tests and 12 integration tests passing

### IPTV Live Feature (v0.3.0)

- M3uChannel, EpgProgram, EpgChannel data models
- M3uParser, EpgManager, TimeshiftManager abstract interfaces
- LiveService facade with LiveStore (Riverpod)
- LiveScreen (channel list) + LivePlayerScreen (full-screen player)
- ChannelTile, EpgProgramTile, EpgProgramList widgets
- TimeshiftControlBar, SignalErrorWidget
- Full TV remote + touch support
- Router integration (/live, /live/player)
- BDD integration tests (10 scenarios)

### Favorites Feature (v0.4.0)

- FavoriteItem, FavoritesState, FavoritesRepository
- FavoritesLocalService (SharedPreferences)
- FavoritesRemoteService (LunaTV API sync)
- FavoritesService facade with background sync
- FavoritesStore (Riverpod), FavoritesScreen
- FavoritesFilterBar (all/movie/series/anime/variety)
- FavoriteTile, FavoriteGrid widgets
- "已下架" badge for unavailable content
- BDD integration tests (26 scenarios)

- KeyboardInputView for TV remote D-pad text input
- CategoryFilter for filtering by category
- QRInputView for QR code scanning
- SearchHistoryService for persistent search history
- BDD integration tests

### Play History Feature (v0.2.1)

- HistoryScreen with time grouping (今天/昨天/更早)
- RecentWatchSection on home screen (max 10 records)
- HistoryService with local-first sync to LunaTV
- HistoryLocalService (SharedPreferences)
- HistoryRemoteService (LunaTV /api/user/stats)
- BDD integration tests (4 scenarios)

### Architecture

- **State Management**: Riverpod (HomeStore, DetailStore, PlayerStore, SettingsStore, AuthStore, SearchStore, HistoryStore, LiveStore, FavoritesStore)
- **Navigation**: GoRouter
- **API**: LunaClient with MockClient fallback
- **Design System**: Glassmorphism components

## Getting Started

```bash
# Install dependencies
yarn install

# Run on TV
yarn start           # Start Metro bundler (TV mode)
yarn android         # Build and run on Android TV
yarn ios             # Build and run on Apple TV

# Testing
yarn test            # Run all tests (203 tests)

# Build
yarn build           # Build release APK
```

## Tech Stack

- Flutter TVOS (0.74.x)
- Expo SDK 51
- TypeScript
- Riverpod
- GoRouter
- media_kit

## License

Private - All rights reserved