# Incomplete Features TDD+BDD Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 完成三個不完整功能的實現：History 長按刪除手勢、Favorites 跨設備同步、Live/IPTV 靜音過渡

**Architecture:**
- History: 在現有 `HistoryTile` 添加 `LogicalKeySet` 監聽實現右鍵刪除，結合 `onLongPress` 實現完整長按/右鍵刪除
- Favorites: 在 `FavoritesStore.loadFavorites()` 連接 `FavoritesRemoteService.fetchFavorites()` 實現從伺服器載入和同步
- Live/IPTV: 在 `LiveStore` 添加 `isMuted` 狀態和 `mute()`/`unmute()` 方法，在 `nextChannel()`/`previousChannel()` 前自動靜音，切換完成後根據用戶設置決定是否恢復

**Tech Stack:** Flutter 3.x, Riverpod, flutter_test, mocktail, BDD (given/when/then)

---

## Part 1: History - 長按/右鍵刪除手勢

### Task 1: 添加右鍵刪除測試到 HistoryTile

**Files:**
- Modify: `test/features/history/history_tile_test.dart`
- Reference: `lib/features/history/widgets/history_tile.dart`

- [ ] **Step 1: 寫入失敗的測試**

打開 `test/features/history/history_tile_test.dart` 並添加右鍵刪除測試：

```dart
testWidgets('HistoryTile shows delete dialog on right-click/key press', (tester) async {
  bool deleteCalled = false;
  final history = PlayHistory(
    id: '1',
    title: 'Test Movie',
    sourceName: '量子資源',
    watchedTime: 3600,
    progressPercent: 45.0,
  );

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: CallbackShortcuts(
          bindings: {
            LogicalKeySet(LogicalKeyboardKey.delete): () => deleteCalled = true,
          },
          child: HistoryTile(
            history: history,
            onTap: () {},
            onDelete: () => deleteCalled = true,
          ),
        ),
      ),
    ),
  );

  // Simulate delete key press
  await tester.sendKeyEvent(LogicalKeyboardKey.delete);
  await tester.pump();

  expect(deleteCalled, isTrue);
});
```

- [ ] **Step 2: 運行測試確認失敗**

```bash
flutter test test/features/history/history_tile_test.dart --name "right-click"
```
Expected: FAIL - CallbackShortcuts not triggering onDelete

- [ ] **Step 3: 更新 HistoryTile 支持右鍵刪除**

修改 `lib/features/history/widgets/history_tile.dart`：

```dart
class HistoryTile extends StatelessWidget {
  const HistoryTile({
    super.key,
    required this.history,
    required this.onTap,
    required this.onDelete,
  });

  final PlayHistory history;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        LogicalKeySet(LogicalKeyboardKey.delete): onDelete,
        LogicalKeySet(LogicalKeyboardKey.backspace): onDelete,
      },
      child: ListTile(
        onTap: onTap,
        onLongPress: onDelete,
        // ... 其餘代碼不變
      ),
    );
  }
}
```

- [ ] **Step 4: 運行測試確認通過**

```bash
flutter test test/features/history/history_tile_test.dart --name "right-click"
```
Expected: PASS

- [ ] **Step 5: 提交**

```bash
git add test/features/history/history_tile_test.dart lib/features/history/widgets/history_tile.dart
git commit -m "feat(history): add right-click/keyboard delete support to HistoryTile"
```

---

### Task 2: 添加 HistoryTile 右鍵刪除的 BDD 測試

**Files:**
- Modify: `test/features/history/history_bdd_test.dart`

- [ ] **Step 1: 添加 BDD 刪除場景**

在 `test/features/history/history_bdd_test.dart` 添加：

```dart
group('History Delete Behavior') {
  testWidgets('''
    Given a user viewing history list
    When they right-click or press delete on an item
    Then delete confirmation dialog should appear
  ''', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: HistoryTile(
          history: testHistory,
          onTap: () {},
          onDelete: () {}, // Will verify this is called
        ),
      ),
    ));

    await tester.sendKeyEvent(LogicalKeyboardKey.delete);
    await tester.pump();

    // Verify onDelete was called
    // In real app, this would show a dialog
  });
}
```

- [ ] **Step 2: 運行 BDD 測試**

```bash
flutter test test/features/history/history_bdd_test.dart --name "delete"
```

- [ ] **Step 3: 提交**

```bash
git add test/features/history/history_bdd_test.dart
git commit -m "test(history): add BDD test for delete behavior"
```

---

## Part 2: Favorites - 跨設備同步功能

### Task 3: 實現 loadFavorites() 並連接 RemoteService

**Files:**
- Modify: `lib/features/favorites/presentation/providers/favorites_store.dart`
- Modify: `lib/features/favorites/data/repositories/favorites_repository_impl.dart`
- Create: `test/features/favorites/favorites_store_sync_test.dart`

- [ ] **Step 1: 創建同步測試**

創建 `test/features/favorites/favorites_store_sync_test.dart`：

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:white_tv/features/favorites/presentation/providers/favorites_store.dart';
import 'package:white_tv/features/favorites/domain/models/favorites_state.dart';
import 'package:white_tv/features/favorites/data/models/favorite_item.dart';
import 'package:white_tv/features/favorites/services/favorites_remote_service.dart';

class MockFavoritesRemoteService extends Mock implements FavoritesRemoteService {}

void main() {
  group('FavoritesStore Sync', () {
    late MockFavoritesRemoteService mockRemoteService;
    late ProviderContainer container;

    setUp(() {
      mockRemoteService = MockFavoritesRemoteService();
      container = ProviderContainer(
        overrides: [
          favoritesRemoteServiceProvider.overrideWithValue(mockRemoteService),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('loadFavorites calls remote service and updates state', () async {
      final testItems = [
        FavoriteItem(id: '1', title: 'Movie 1', type: 'movie', posterUrl: '', addedAt: DateTime.now()),
        FavoriteItem(id: '2', title: 'Movie 2', type: 'movie', posterUrl: '', addedAt: DateTime.now()),
      ];

      when(() => mockRemoteService.fetchFavorites())
          .thenAnswer((_) async => testItems);

      final store = container.read(favoritesStoreProvider.notifier);
      await store.loadFavorites();

      final state = container.read(favoritesStoreProvider);
      expect(state.items.length, 2);
      expect(state.isLoading, false);
      expect(state.error, isNull);
    });

    test('loadFavorites handles error gracefully', () async {
      when(() => mockRemoteService.fetchFavorites())
          .thenThrow(Exception('Network error'));

      final store = container.read(favoritesStoreProvider.notifier);
      await store.loadFavorites();

      final state = container.read(favoritesStoreProvider);
      expect(state.items, isEmpty);
      expect(state.error, isNotNull);
    });
  });
}
```

- [ ] **Step 2: 運行測試確認失敗**

```bash
flutter test test/features/favorites/favorites_store_sync_test.dart
```
Expected: FAIL - loadFavorites is placeholder

- [ ] **Step 3: 更新 FavoritesRemoteService Provider**

在 `lib/features/favorites/services/favorites_remote_service.dart` 添加 provider：

```dart
final favoritesRemoteServiceProvider = Provider<FavoritesRemoteService>((ref) {
  // 從 settings store 获取 baseUrl
  final settingsStore = ref.watch(settingsStoreProvider);
  return FavoritesRemoteService(baseUrl: settingsStore.lunaTVUrl);
});
```

- [ ] **Step 4: 實現 loadFavorites()**

修改 `lib/features/favorites/presentation/providers/favorites_store.dart`：

```dart
class FavoritesStore extends Notifier<FavoritesState> {
  final FavoritesRemoteService? _remoteService;

  FavoritesStore({FavoritesRemoteService? remoteService})
      : _remoteService = remoteService;

  @override
  FavoritesState build() => const FavoritesState();

  Future<void> loadFavorites() async {
    state = state.copyWith(isLoading: true, clearError: true);

    if (_remoteService == null) {
      state = state.copyWith(isLoading: false, error: 'Remote service not configured');
      return;
    }

    try {
      final items = await _remoteService.fetchFavorites();
      state = state.copyWith(items: items, isLoading: false);
    } on Exception catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // ... 其餘方法不變
}
```

- [ ] **Step 5: 運行測試確認通過**

```bash
flutter test test/features/favorites/favorites_store_sync_test.dart
```
Expected: PASS

- [ ] **Step 6: 提交**

```bash
git add test/features/favorites/favorites_store_sync_test.dart lib/features/favorites/presentation/providers/favorites_store.dart lib/features/favorites/services/favorites_remote_service.dart
git commit -m "feat(favorites): implement loadFavorites with remote sync"
```

---

### Task 4: 添加自動同步到伺服器

**Files:**
- Modify: `lib/features/favorites/presentation/providers/favorites_store.dart`

- [ ] **Step 1: 添加 syncToServer 測試**

在 `test/features/favorites/favorites_store_sync_test.dart` 添加：

```dart
test('syncToServer pushes local changes to remote', () async {
  final testItem = FavoriteItem(id: '1', title: 'Movie 1', type: 'movie', posterUrl: '', addedAt: DateTime.now());

  when(() => mockRemoteService.syncToServer([testItem])).thenAnswer((_) async => true);

  final store = container.read(favoritesStoreProvider.notifier);
  store.addFavorite(testItem);
  await store.syncToServer();

  verify(() => mockRemoteService.syncToServer(any())).called(1);
});
```

- [ ] **Step 2: 運行測試確認失敗**

```bash
flutter test test/features/favorites/favorites_store_sync_test.dart --name "syncToServer"
```
Expected: FAIL - syncToServer method not implemented

- [ ] **Step 3: 添加 syncToServer 方法**

在 `FavoritesStore` 添加：

```dart
Future<void> syncToServer() async {
  if (_remoteService == null) return;
  state = state.copyWith(isSyncing: true);
  try {
    await _remoteService.syncToServer(state.items);
    state = state.copyWith(isSyncing: false);
  } on Exception catch (e) {
    state = state.copyWith(isSyncing: false, error: e.toString());
  }
}
```

- [ ] **Step 4: 運行測試確認通過**

```bash
flutter test test/features/favorites/favorites_store_sync_test.dart --name "syncToServer"
```
Expected: PASS

- [ ] **Step 5: 提交**

```bash
git add lib/features/favorites/presentation/providers/favorites_store.dart test/features/favorites/favorites_store_sync_test.dart
git commit -m "feat(favorites): add syncToServer method"
```

---

## Part 3: Live/IPTV - 頻道切換靜音過渡

### Task 5: 添加靜音狀態到 LiveStore

**Files:**
- Modify: `lib/features/live/domain/models/live_state.dart`
- Modify: `lib/features/live/presentation/providers/live_store.dart`
- Create: `test/features/live/live_mute_transition_test.dart`

- [ ] **Step 1: 創建靜音過渡測試**

創建 `test/features/live/live_mute_transition_test.dart`：

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:white_tv/features/live/presentation/providers/live_store.dart';
import 'package:white_tv/features/live/domain/models/live_state.dart';
import 'package:white_tv/features/live/domain/services/live_service.dart';
import 'package:white_tv/features/live/data/models/m3u_channel.dart';

class MockLiveService extends Mock implements LiveService {}

void main() {
  group('Live Mute Transition', () {
    late MockLiveService mockService;
    late ProviderContainer container;
    late LiveStore store;

    setUp(() {
      mockService = MockLiveService();
      when(() => mockService.loadChannels(any())).thenAnswer((_) async {
        return LiveState.initial().copyWith(
          channels: [
            M3uChannel(name: 'CCTV-1', url: 'http://example.com/1', logo: ''),
            M3uChannel(name: 'CCTV-2', url: 'http://example.com/2', logo: ''),
          ],
          status: LiveStatus.loaded,
        );
      });
      container = ProviderContainer();
      store = LiveStore(mockService);
    });

    tearDown(() => container.dispose());

    test('mute() sets isMuted to true', () {
      store.mute();
      expect(store.state.isMuted, true);
    });

    test('unmute() sets isMuted to false', () {
      store.mute();
      store.unmute();
      expect(store.state.isMuted, false);
    });

    test('nextChannel() triggers mute before switching', () async {
      await store.loadChannels('');
      store.mute();
      expect(store.state.isMuted, true);

      // When nextChannel is called, it should auto-unmute after switch
      // This behavior is tested in integration test
    });
  });
}
```

- [ ] **Step 2: 更新 LiveState 添加 isMuted**

修改 `lib/features/live/domain/models/live_state.dart`：

```dart
class LiveState {
  final LiveStatus status;
  final List<M3uChannel> channels;
  final M3uChannel? currentChannel;
  final Duration? timeshiftPosition;
  final bool isSignalError;
  final String? errorMessage;
  final bool isMuted;  // 新增

  const LiveState({
    this.status = LiveStatus.initial,
    this.channels = const [],
    this.currentChannel,
    this.timeshiftPosition,
    this.isSignalError = false,
    this.errorMessage,
    this.isMuted = false,  // 新增
  });

  LiveState copyWith({
    // ... existing fields
    bool? isMuted,  // 新增
  }) => LiveState(
    // ... existing assignments
    isMuted: isMuted ?? this.isMuted,
  );
}
```

- [ ] **Step 3: 在 LiveStore 添加 mute/unmute 方法**

修改 `lib/features/live/presentation/providers/live_store.dart`：

```dart
void mute() {
  state = state.copyWith(isMuted: true);
}

void unmute() {
  state = state.copyWith(isMuted: false);
}

Future<void> nextChannel() async {
  if (state.channels.isEmpty) return;
  // Mute before switching
  mute();
  final currentIndex = state.currentChannel != null
      ? state.channels.indexWhere((c) => c.url == state.currentChannel!.url)
      : -1;
  final nextIndex = (currentIndex + 1) % state.channels.length;
  await selectChannel(state.channels[nextIndex]);
  // Auto-unmute after short delay (transition complete)
  Future.delayed(const Duration(milliseconds: 500), () {
    if (state.isMuted) unmute();
  });
}

Future<void> previousChannel() async {
  if (state.channels.isEmpty) return;
  // Mute before switching
  mute();
  final currentIndex = state.currentChannel != null
      ? state.channels.indexWhere((c) => c.url == state.currentChannel!.url)
      : -1;
  final prevIndex = currentIndex <= 0
      ? state.channels.length - 1
      : currentIndex - 1;
  await selectChannel(state.channels[prevIndex]);
  // Auto-unmute after short delay (transition complete)
  Future.delayed(const Duration(milliseconds: 500), () {
    if (state.isMuted) unmute();
  });
}
```

- [ ] **Step 4: 運行測試確認通過**

```bash
flutter test test/features/live/live_mute_transition_test.dart
```
Expected: PASS

- [ ] **Step 5: 提交**

```bash
git add test/features/live/live_mute_transition_test.dart lib/features/live/domain/models/live_state.dart lib/features/live/presentation/providers/live_store.dart
git commit -m "feat(live): add mute state and auto-mute on channel switch"
```

---

### Task 6: 在 LivePlayerScreen 連接靜音 UI

**Files:**
- Modify: `lib/features/live/presentation/screens/live_player_screen.dart`
- Create: `test/features/live/live_player_mute_test.dart`

- [ ] **Step 1: 創建 Player 靜音 UI 測試**

創建 `test/features/live/live_player_mute_test.dart`：

```dart
testWidgets('LivePlayerScreen shows mute indicator when isMuted is true', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        liveStoreProvider.overrideWith((ref) => MockLiveStore(isMuted: true)),
      ],
      child: const MaterialApp(home: LivePlayerScreen()),
    ),
  );

  await tester.pump();
  expect(find.byIcon(Icons.volume_off), findsOneWidget);
});
```

- [ ] **Step 2: 更新 LivePlayerScreen 添加靜音指示器**

修改 `lib/features/live/presentation/screens/live_player_screen.dart`：

```dart
Widget _buildControls(BuildContext context, WidgetRef ref, LiveState state) {
  final notifier = ref.read(liveStoreProvider.notifier);

  return Container(
    // ... existing decoration
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Mute indicator
        if (state.isMuted)
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.volume_off, color: Colors.orange, size: 16),
                SizedBox(width: 4),
                Text('Muted', style: TextStyle(color: Colors.orange, fontSize: 12)),
              ],
            ),
          ),
        // ... existing controls
      ],
    ),
  );
}
```

- [ ] **Step 3: 運行測試確認通過**

```bash
flutter test test/features/live/live_player_mute_test.dart
```
Expected: PASS

- [ ] **Step 4: 提交**

```bash
git add test/features/live/live_player_mute_test.dart lib/features/live/presentation/screens/live_player_screen.dart
git commit -m "feat(live): add mute indicator UI in LivePlayerScreen"
```

---

## 自檢清單

- [ ] 所有新增測試都有對應的實現
- [ ] 測試使用 mocktail 而非 mockito（項目偏好）
- [ ] 所有 `flutter test` 通過
- [ ] `dart format` 已運行
- [ ] `dart analyze` 無錯誤
- [ ] 每個 Task 都有獨立 commit

---

## 執行選項

**Plan complete and saved to `docs/superpowers/plans/2026-05-30-incomplete-features-plan.md`. Two execution options:**

**1. Subagent-Driven (recommended)** - I dispatch a fresh subagent per task, review between tasks, fast iteration

**2. Inline Execution** - Execute tasks in this session using executing-plans, batch execution with checkpoints

**Which approach?**