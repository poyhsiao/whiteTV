# whiteTV

> A cross-platform TV streaming application built with Flutter, supporting Apple TV, Android TV, and mobile devices with unified remote control and QR-code input.

A production-ready Flutter TV application for streaming video content, featuring IPTV live TV, VOD playback, favorites sync, and play history — optimized for both physical TV remote controls and mobile phone input via QR code.

## Version

**v0.12.0** - Various fixes and improvements

## Features

- **Home Screen**: Category-based video browsing with responsive layout
- **Detail Screen**: TV/Mobile adaptive layout with episode selection
- **Player Screen**: Video playback with media_kit, speed control, fullscreen
- **Settings**: Tab-based settings with persistent storage
- **Search**: Full-text search with TV remote D-pad navigation, QR code input support, search history overlay
- **Play History**: Local-first playback history with LunaTV sync, time grouping
- **IPTV Live**: Live TV streaming with M3U playlist, EPG, and timeshift replay
- **Favorites**: Local-first favorites with grid/list view, type filtering, LunaTV sync
- **Empty States**: Reusable empty state component across all screens
- **Onboarding**: 3-step first-launch wizard with API URL setup
- **Parental Controls**: PIN-based content gate for adult content
- **Remote Guide**: TV remote button mapping reference screen
- **TV Tab Navigation**: Dynamic tab order with drag-to-reorder
- **Unified Input**: QR code + phone browser input for TV (full-screen) and mobile (modal)
- **Search History**: Frosted glass overlay with tap-to-search, individual delete, clear all

### Search History Overlay (v0.7.1)

- SearchHistoryOverlay widget with glassmorphism effect
- HistoryCard with tap-to-search and delete functionality
- TV remote D-pad navigation support
- Empty state and confirmation dialogs

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