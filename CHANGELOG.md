# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **LunaClient API contract tests** (2026-07-08)
  - `test/core/api/luna_client_test.dart` — 7 個測試驗證 `getCategories`、`getVideosByCategory`、`getVideoDetail`、`getSources`、`search`、`testSourceLatency` API 合約

### Changed
- **TV 全域 Back 鍵確認** (Sprint 1.1 / ROADMAP §2.2)
  - `BackConfirmation` widget (lib/shared/widgets/back_confirmation.dart)
  - TV 平台首頁按 Back → SnackBar「再按一次退出 whiteTV」;2 秒內再按觸發退出
  - `SystemNavigator.pop()` 整合
- **Category 排序測試覆蓋** (Sprint 1.2 / ROADMAP §3.2.a)
  - 10 個 retrofitted test 驗證 SortOption 5 種 + copyWith 行為
- **Downloads BDD 整合測試** (Sprint 1.3 / ROADMAP §3.1.a)
  - `downloads_store_bdd_test.dart` 驗證完整鏈結 (下載 → history 標記 → list 出現)
- **跨設備歷史同步合併策略** (Sprint 2.1 / ROADMAP §2.1)
  - `HistoryService.syncFromRemote()` 用 lastWatched timestamp 比較,本地較新覆寫遠端
  - 3 個 merge test 驗證 3 種情境 (本地新 / 遠端新 / 本地空)
- **AIRecommend Reason widget test** (Sprint 2.2 / ROADMAP §3.4)
  - 3 個 widget test 驗證 reason/title 渲染
  - 補上 RecommendationReasonSheet 顯示 recommendation.title
- **YouTube Store unit test** (Sprint 2.3 / ROADMAP §3.3)
  - 7 個 test 驗證 loadRecommend/loadCategories/selectCategory/clear 的 success/error
  - 覆蓋率 91% (LF:34 / LH:31)

### Changed
- `HomeScreen` (lib/features/home/home_screen.dart) 包 `BackConfirmation` widget (僅 TV)
- `RecommendationReasonSheet` 加上 `recommendation.title` 顯示

## Sprint 7.1 DioProvider 統一 (2026-07-05)
- 新增 `lib/core/api/dio_provider.dart` — canonical Dio provider,跨模組共用,default `Dio()` (fail-soft)
- `lib/providers/downloads_providers.dart` 移除本地 `dioProvider`,改 `export '...dio_provider.dart' show dioProvider`(相容既有 import)
- `lib/features/favorites/services/favorites_remote_service.dart` 改用 `ref.watch(dioProvider)` + `FavoritesRemoteService.fromDio(...)`,消除 `Dio(BaseOptions(...))` 硬編碼
- 新增 `test/core/api/dio_provider_test.dart` — 3 個測試:override 成功 / legacy re-export 同一物件 / 預設返回 `Dio`
- `test/features/favorites/stores/favorites_store_test.dart` 補 `favoritesRemoteServiceProvider.overrideWith(throw ...)` 保留 "Remote service not configured" 語意
- 全 suite: +1267 ~15 / 0 失敗 / 0 issues

## Sprint 8.1 InputServiceProvider (2026-07-05)
- 新增 `lib/core/services/input_service_provider.dart` — canonical InputService provider
- `lib/features/login/presentation/screens/login_screen.dart` 改用 `ref.read(inputServiceProvider)`(從直接 `InputService()` 改為注入)
- `lib/features/settings/presentation/screens/input_screen.dart` 改為 `ConsumerStatefulWidget` + provider 注入
- 新增 `test/core/services/input_service_provider_test.dart` — 2 個測試
- `test/features/settings/input_screen_test.dart` 與 `test/features/login/login_screen_test.dart` 加 `ProviderScope` + `_SpyInputService` override
- 全 suite: +1269 ~15 / 0 失敗 / 0 issues

## Sprint 8.2 SourceSelector HttpClient 工廠 (2026-07-05)
- `SourceSelector` 新增 named ctor `httpClientFactory` (Sprint 7.3 audit 高 ROI 候選)
- 改寫 `testSingleSource` 用 `_httpClientFactory()` 而非 `new HttpClient()`
- 新增 `test/core/source/source_selector_httpclient_test.dart` — 3 個測試 (happy / throw / backward compat)
- 全 suite: +1272 ~15 / 0 失敗 / 0 issues

## Sprint 7.2 AppRouter smoke test (2026-07-05)
- 新增 `test/integration/app_routes_smoke_test.dart` — 3 個 pumpWidget test,驗證 3 個 GoRoute (`/downloads`, `/onboarding`, `/remote-guide`) 真的 navigate 到正確 widget
- 用 `UncontrolledProviderScope` + `createAppRouter(initialLocation: ...)` 注入完整 ProviderScope
- 複雜 route (history/home, 需完整 store override) 留給各自 widget test,不在 smoke 範圍
- 全 suite: +1275 ~15 / 0 失敗 / 0 issues

## Sprint 8.3 SourceSelector prefs DI (2026-07-05)
- `SourceSelector` ctor 新增 `prefsReader` / `prefsWriter` named params(預設走 `SharedPreferences`)
- `setBlockedSources` 改用 `_prefsWriter`,`_refreshBlockedSources` 改用 `_prefsReader`(移除內部 `SharedPreferences.getInstance` 呼叫)
- 新增 `test/core/source/source_selector_prefs_test.dart` — 4 個測試(預設相容 / writer 注入 / reader 注入影響 selectSource / 空 reader)
- 全 suite: +1279 ~15 / 0 失敗 / 0 issues
- 後續:`source_selector_provider.dart` 可改用 `ref.read(sharedPreferencesProvider)` 傳入 lambda,提升 test isolation(Sprint 8.3 follow-up)

## Sprint 3 Coverage (2026-07-04)
- 設定頁 3 項 (autoPlay / defaultQuality / autoSelectSource) — retrofitted coverage tests
- QR Remote (InputService + LocalHttpServer) — 已實作,既有測試 12 個全綠
- settings_store.dart 覆蓋率: 98% (65/66)
- 整體 Sprint 3 模組回歸: 31 全綠 / 0 失敗

## Sprint 4 Hardening (2026-07-04)
- Sprint 4.1 input_service: 57%→65% (4 retrofitted test,純 getter 達極限)
- Sprint 4.2 favorites_remote_service: 5 mock HTTP test,但因 service 無 Dio factory 採測試替身
- Sprint 4.3 voice_input_service: 受限於 _speech 硬編碼,需 DI refactor
- Sprint 4.4 app_router: 受限於 14 GoRoute builder 內 pathParameters,需 integration test
- 整體 Sprint 4: 13 個新 test 全綠 / 0 失敗 / 0 issues

## Sprint 5 DI Refactor (2026-07-04)
- **FavoritesRemoteService** (lib/features/favorites/services/favorites_remote_service.dart)
  - 新增 `FavoritesRemoteService.fromDio(Dio)` factory 注入既有 Dio
  - 覆蓋率 12%→90% (5 個 mock HTTP test)
- **TVVoiceInputService** (lib/features/search/services/voice_input_service.dart)
  - 新增 `SpeechController` abstract interface
  - 新增 `_PlatformSpeechController` 適配 `SpeechToText`
  - 新增 `TVVoiceInputService.fromSpeech(SpeechController)` factory
  - 覆蓋率 28%→70% (7 個 test)
- **AppRouter** (lib/core/router/app_router.dart)
  - 既有 test 改寫為 navigate-based, 13 個 test 覆蓋 13 個 route 結構
  - 涵蓋 home/detail/player/login/settings/history/category/youtube 等
- 整體 Sprint 5: 25 個 test 全綠 / 0 失敗 / 0 issues

## [0.10.3] - 2026-06-21

### Added
- **Timeshift playback**: Full timeshift support with `TimeshiftManager`
  - `TimeshiftMode` enum: `none`, `serviceSide`, `clientBuffer`
  - `TimeshiftServiceAdapter`: Service-side timeshift via LunaTV API
  - `TimeshiftClientBuffer`: Client-side buffer fallback
  - `TimeshiftControlBar`: TV player controls with rewind/forward seek
- **Tab customization**: Dynamic tab order with drag-to-reorder
  - `TabConfig` and `TabNavigationStore` for persistent tab config
  - `ReorderableTabList` widget with visibility toggle

### Changed
- Progress ledger tracking for timeshift and tab customization

## [0.10.2] - 2026-06-21

### Added
- **iOS Platform Channel**: Flutter MethodChannel for Handoff and PiP support
  - IosPlatformChannel wrapper for native communication
  - UnifiedIosPlatform service facade
  - UnifiedIosPlatformPlugin Swift implementation

### Fixed
- Test mock handler cleanup in ios_platform_channel_test.dart
- MethodChannel const issue affecting test mocking
- Map.cast type coercion in receiveHandoff

## [0.10.1] - 2026-06-21

### Fixed
- Test mock handler cleanup in ios_platform_channel_test.dart
- MethodChannel const issue affecting test mocking
- Map.cast type coercion in receiveHandoff

## [0.10.0] - 2026-06-21

### Added
- **HomeScreen live entry section**: Clickable live TV entry card on home page with gradient design, controlled by `showLive` setting toggle
- **TV source selector (vertical list)**: DetailScreen TV mode shows sources in vertical list with status emoji (🟢🟡🔴), latency, episode count, auto-select tag, and current indicator
- **Mobile source selector**: DetailScreen mobile mode retains Wrap chip layout with status badges
- **Player controls lock button**: 🔒 Lock/unlock button in TV player controls to prevent auto-hide

## [0.9.0] - 2026-06-03

### Added
- **EmptyStateWidget**: Reusable empty state component with icon, title, subtitle, and action button
  - Applied to search, favorites, history, EPG, and AI recommend screens
- **Logout redirect**: Navigates to /login after logout
- **Login route**: Added /login route to GoRouter
- **Remote button guide**: TV remote button mapping guide screen accessible from settings
- **TV tab navigation**: Dynamic tab order with drag-to-reorder support
- **Onboarding wizard**: 3-step first-launch flow (welcome → API URL → done)
  - Persists completion state via SharedPreferences
  - Auto-redirects on first launch
- **Parental controls**: PIN-based content gate for adult content
  - ParentalControlService with hashed PIN storage, verification, and lockout
  - PIN dialog widget with numeric keypad
  - Settings UI for PIN setup and toggle
  - Parental gate on detail screen for adult content

### Fixed
- **FakeSettingsStorageService**: Added missing onboarding methods to test fakes

## [0.8.3] - 2026-05-30

### Added
- **AI 推薦功能**: 雙軌策略智能推薦系統
  - AIRecommendation 模型與 RecommendationSource enum
  - ApiClient 新增 getAIRecommendations/getLocalRecommendations 方法
  - LunaClient AI API 整合
  - AIRecommendRepository 雙軌策略實現
  - AIRecommendService 本地推薦邏輯
  - AIRecommendStore Riverpod 狀態管理
  - RecommendationCard/RecommendationCarousel/RecommendationReasonSheet UI 組件
  - 首頁「為你推薦」區塊整合
  - AIRecommendPage 獨立推薦頁面
  - BDD 測試案例

### Fixed
- **History 右鍵/鍵盤刪除**: 添加 CallbackShortcuts 支持 Delete/Backspace 鍵刪除
- **Favorites 跨設備同步**: 實現 loadFavorites() 連接 FavoritesRemoteService，添加 syncToServer() 方法
- **Live/IPTV 靜音過渡**: 添加 isMuted 狀態，nextChannel()/previousChannel() 自動靜音切換，添加靜音指示器 UI

## [0.8.1] - 2026-05-28

### Added
- **IPTV Live API Integration**: JSON 優先 + M3U 備援策略
  - ApiClient 新增 getIptvChannels/getIptvM3U/getIptvEpg 方法
  - IptvChannel model 處理 JSON 格式
  - LiveService.loadFromApi() 实现 fallback 逻辑
  - LiveStore 新增 loadFromApi 方法
  - LiveScreen 移除 demo data，改用真實 API
  - MockClient IPTV 方法完整实现
  - 123 个测试通过（TDD + BDD）

## [0.8.0] - 2026-05-27

### Added
- **Search History Overlay**: Frosted glass overlay for search history
  - SearchHistoryOverlay widget with glassmorphism effect (BackdropFilter blur)
  - HistoryCard widget with tap-to-search and delete functionality
  - isHistoryOverlayOpen state in SearchStore
  - openHistoryOverlay/closeHistoryOverlay methods
  - searchFromHistory/deleteHistoryItem/clearAllHistory methods
  - deleteItem/clearAll methods in SearchHistoryService
  - TV remote D-pad navigation support
  - Empty state and confirmation dialogs

- **Play History Enhancement**: Continue watching feature with progress tracking
  - MediaType enum for play history classification
  - HistoryService offline queue with pushRecordToRemote method
  - NetworkRestored callback in NetworkListener
  - continueWatchRecords getter in HistoryStore
  - RecentContinueSection widget for home screen
  - Continue watching button in detail screen
  - Progress bar and source tag in HistoryTile
  - Time grouping (今天/昨天/更早) in history list
  - BDD scenarios for play history feature

### Fixed
- Flutter analyzer warnings (unused imports, deprecated methods)
- Test mock implementations for HistoryService interface

## [0.7.0] - 2026-05-26

### Added
- **Unified Input System**: QR code + phone browser input for TV and mobile
  - SessionManager for QR session lifecycle management
  - LocalHttpServer (shelf HTTP server) for phone input via browser
  - InputService facade coordinating all input services
  - QrInputWidget for QR code display
  - InputScreen (TV full-screen mode) and LoginScreen (QR input support)
  - BDD integration tests (input flow, session handling)
  - 12 integration tests passing

## [0.6.0] - 2026-05-25

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

## [0.5.0] - 2026-05-24

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

## [0.4.0] - 2026-05-22

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

## [0.3.0] - 2026-05-21

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

## [0.2.0] - 2026-05-20

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

## [0.10.3]: https://github.com/poyhsiao/whiteTV/releases/tag/v0.10.3
## [0.10.2]: https://github.com/poyhsiao/whiteTV/releases/tag/v0.10.2
## [0.10.1]: https://github.com/poyhsiao/whiteTV/releases/tag/v0.10.1
## [0.10.0]: https://github.com/poyhsiao/whiteTV/releases/tag/v0.10.0
## [0.9.0]: https://github.com/poyhsiao/whiteTV/releases/tag/v0.9.0
## [0.8.3]: https://github.com/poyhsiao/whiteTV/releases/tag/v0.8.3
## [0.8.1]: https://github.com/poyhsiao/whiteTV/releases/tag/v0.8.1
## [0.8.0]: https://github.com/poyhsiao/whiteTV/releases/tag/v0.8.0
## [0.7.0]: https://github.com/poyhsiao/whiteTV/releases/tag/v0.7.0
## [0.6.0]: https://github.com/poyhsiao/whiteTV/releases/tag/v0.6.0
## [0.5.0]: https://github.com/poyhsiao/whiteTV/releases/tag/v0.5.0
## [0.4.0]: https://github.com/poyhsiao/whiteTV/releases/tag/v0.4.0
## [0.3.0]: https://github.com/poyhsiao/whiteTV/releases/tag/v0.3.0
## [0.2.0]: https://github.com/poyhsiao/whiteTV/releases/tag/v0.2.0
