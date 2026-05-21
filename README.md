# whiteTV

A Flutter TV application for streaming video content, designed for Apple TV and Android TV with remote control support.

## Version

**v0.2.1** - Search + Play History Release

## Features

- **Home Screen**: Category-based video browsing with responsive layout
- **Detail Screen**: TV/Mobile adaptive layout with episode selection
- **Player Screen**: Video playback with media_kit
- **Settings**: Tab-based settings with persistent storage
- **Search**: Full-text search with TV remote D-pad navigation, QR code input support
- **Play History**: Local-first playback history with LunaTV sync, time grouping

### Search Feature (v0.2.1)

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

- **State Management**: Riverpod (HomeStore, DetailStore, PlayerStore, SettingsStore, AuthStore, SearchStore, HistoryStore)
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