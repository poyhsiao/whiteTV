# whiteTV

A cross-platform TV streaming application built with Flutter, optimized for Apple TV and Android TV with remote control support, while also supporting mobile and tablet devices.

## Features

- **Multi-Platform Support**: Apple TV, Android TV, iOS, Android, macOS, Linux
- **Responsive Design**: Adaptive layouts for TV, tablet, and mobile devices
- **Remote Control**: Built-in remote control server for external device control
- **Video Playback**: media_kit-powered video player with full controls
- **State Management**: Riverpod for predictable state management
- **Navigation**: GoRouter for type-safe routing
- **API Integration**: LunaTV API with mock data fallback

## Tech Stack

- **Flutter SDK** 3.x
- **State Management**: Riverpod
- **Navigation**: GoRouter
- **Video Player**: media_kit
- **HTTP Client**: Dio
- **Testing**: flutter_test, mockito

## Getting Started

### Prerequisites

- Flutter SDK 3.x
- Xcode (for iOS/macOS)
- Android SDK (for Android)

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/poyhsiao/whiteTV.git
   cd whiteTV
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Configure environment:
   ```bash
   cp .env.example .env
   # Edit .env with your API configuration
   ```

### Development

```bash
# Start Metro bundler in TV mode
EXPO_TV=1 flutter run

# Mobile/Tablet development
flutter run

# Run tests
flutter test

# Analyze code
flutter analyze
```

## Project Structure

```
lib/
├── core/           # Core utilities, theme, constants
├── features/       # Feature modules (home, detail, player)
├── services/       # API, storage, remote control services
├── stores/         # Riverpod state stores
├── models/         # Data models
└── main.dart       # App entry point
```

## License

This project is licensed under the [Mozilla Public License Version 2.0](LICENSE).

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for development standards and guidelines.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history.
