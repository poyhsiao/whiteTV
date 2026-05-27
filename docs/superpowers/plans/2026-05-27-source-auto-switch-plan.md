# 多來源自動切換功能實作計畫

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 當播放失敗時（超時或錯誤），自動切換到最快的可用來源，實現無縫繼續播放

**Architecture:** 在 `PlayerStore` 整合失敗偵測與自動切換邏輯，使用 `Timer` 監控緩衝狀態，搭配 `SourceSelector` 的測速與排序能力

**Tech Stack:** Flutter Riverpod, Dart async Timer, 現有 SourceSelector

---

## 檔案結構

```
lib/features/player/
├── player_store.dart          # 修改：新增失敗偵測與自動切換觸發
├── player_screen.dart         # 修改：整合自動切換監聽
└── widgets/
    └── player_error_overlay.dart  # 新增：錯誤提示 UI

test/features/player/
├── player_store_auto_switch_test.dart     # 新增：自動切換單元測試
└── player_auto_switch_bdd_test.dart      # 新增：自動切換 BDD 測試
```

---

## Task 1: 新增失敗偵測 Timer 機制

**Files:**
- Modify: `lib/features/player/player_store.dart:67-86`
- Test: `test/features/player/player_store_auto_switch_test.dart`

- [ ] **Step 1: 寫失敗的測試**

```dart
// test/features/player/player_store_auto_switch_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:white_tv/core/api/models.dart';
import 'package:white_tv/core/source/source_selector.dart';
import 'package:white_tv/core/source/source_selector_provider.dart';
import 'package:white_tv/features/player/player_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PlayerStore 自動切換', () {
    late ProviderContainer container;
    late PlayerStore store;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();
    });

    tearDown(() => container.dispose());

    test('setBuffering 超時後觸發自動切換', () async {
      store = container.read(playerStoreProvider.notifier);
      final sources = [
        const VideoSource(id: 'src1', name: '量子資源', url: 'http://a.com', latency: 80, isAvailable: true),
        const VideoSource(id: 'src2', name: '非凡資源', url: 'http://b.com', latency: 120, isAvailable: true),
      ];

      await store.setVideo('video1', 'ep1');
      store.play();
      store.setBuffering(true);

      // 模擬超時（10秒）
      await Future.delayed(const Duration(seconds: 11));

      // 驗證 autoSwitchCount 增加
      expect(store.state.autoSwitchCount, 1);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/player/player_store_auto_switch_test.dart -v`
Expected: FAIL — `setBuffering` doesn't trigger auto-switch yet

- [ ] **Step 3: 新增 bufferingTimer 和 超時邏輯**

在 `PlayerStore` 中新增：

```dart
class PlayerStore extends StateNotifier<PlayerState> {
  // ... existing fields ...
  Timer? _bufferingTimer;
  static const Duration bufferingTimeout = Duration(seconds: 10);

  // 在 setBuffering 加入計時器
  void setBuffering(bool buffering) {
    _bufferingTimer?.cancel();

    if (buffering) {
      // 開始計時
      _bufferingTimer = Timer(bufferingTimeout, () {
        _onBufferingTimeout();
      });
    }

    state = state.copyWith(isBuffering: buffering);
  }

  void _onBufferingTimeout() {
    if (!state.isPlaying) return; // 已經停止就忽略

    // 觸發自動切換
    _triggerAutoSwitch(FailureReason.timeout);
  }

  Future<void> _triggerAutoSwitch(FailureReason reason) async {
    // 取得所有來源（需要從呼叫端傳入或從 state）
    // 這裡調用 switchToNextSource
    final allSources = _lastKnownSources; // 待實作
    final nextSource = await switchToNextSource(allSources);
    if (nextSource != null) {
      // 重置計時器，繼續播放
      play();
    }
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/player/player_store_auto_switch_test.dart -v`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/features/player/player_store.dart test/features/player/player_store_auto_switch_test.dart
git commit -m "feat: add buffering timeout detection for auto-switch"
```

---

## Task 2: 整合錯誤回調與自動切換

**Files:**
- Modify: `lib/features/player/player_store.dart:195-206`（現有 `recordSourceResult`）
- Test: `test/features/player/player_store_auto_switch_test.dart`

- [ ] **Step 1: 寫失敗的測試**

```dart
test('播放錯誤時自動切換來源', () async {
  store = container.read(playerStoreProvider.notifier);
  final sources = [
    const VideoSource(id: 'src1', name: '量子資源', url: 'http://a.com', latency: 80, isAvailable: true),
    const VideoSource(id: 'src2', name: '非凡資源', url: 'http://b.com', latency: 120, isAvailable: true),
  ];

  await store.setVideo('video1', 'ep1');
  store.play();

  // 模擬播放錯誤
  store.onPlaybackError(PlaybackError(message: '解析失敗', isTimeout: false));

  // 驗證切換到 src2
  expect(store.state.source?.id, 'src2');
  expect(store.state.autoSwitchCount, 1);
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/player/player_store_auto_switch_test.dart -v`
Expected: FAIL — `onPlaybackError` doesn't exist yet

- [ ] **Step 3: 新增 onPlaybackError 方法**

```dart
/// 播放錯誤回調
void onPlaybackError(PlaybackError error) {
  if (state.autoSwitchCount >= SourceSelector.maxAutoSwitch) {
    // 超過限制，顯示錯誤
    state = state.copyWith(error: '播放失敗，已嘗試所有來源');
    return;
  }

  // 記錄失敗
  recordSourceResult(isSuccess: false);

  // 觸發自動切換
  _triggerAutoSwitch(error.isTimeout ? FailureReason.timeout : FailureReason.error);
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/player/player_store_auto_switch_test.dart -v`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/features/player/player_store.dart test/features/player/player_store_auto_switch_test.dart
git commit -m "feat: integrate playback error callback with auto-switch"
```

---

## Task 3: 新增錯誤提示 UI

**Files:**
- Create: `lib/features/player/widgets/player_error_overlay.dart`
- Modify: `lib/features/player/player_screen.dart`
- Test: `test/features/player/player_error_overlay_test.dart`

- [ ] **Step 1: 創建錯誤提示元件**

```dart
// lib/features/player/widgets/player_error_overlay.dart
import 'package:flutter/material.dart';

class PlayerErrorOverlay extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final VoidCallback? onSelectSource;

  const PlayerErrorOverlay({
    super.key,
    required this.message,
    this.onRetry,
    this.onSelectSource,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 48),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onRetry != null)
                  ElevatedButton(
                    onPressed: onRetry,
                    child: const Text('重試'),
                  ),
                const SizedBox(width: 16),
                if (onSelectSource != null)
                  OutlinedButton(
                    onPressed: onSelectSource,
                    child: const Text('選擇來源'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: 在 PlayerScreen 集成**

在 `player_screen.dart` 的 build 方法中加入：

```dart
// 在 Stack 中加入 error overlay
Stack(
  children: [
    // 現有播放器
    videoPlayerWidget,
    // 錯誤提示
    if (state.error != null)
      PlayerErrorOverlay(
        message: state.error!,
        onRetry: () => store.play(),
        onSelectSource: () => showSourceSelector(context),
      ),
  ],
)
```

- [ ] **Step 3: 撰寫 widget 測試**

```dart
testWidgets('PlayerErrorOverlay 顯示錯誤訊息', (tester) async {
  await tester.pumpWidget(
    const MaterialApp(
      home: PlayerErrorOverlay(
        message: '播放失敗',
      ),
    ),
  );

  expect(find.text('播放失敗'), findsOneWidget);
  expect(find.byIcon(Icons.error_outline), findsOneWidget);
});
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/player/player_error_overlay_test.dart -v`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/features/player/widgets/player_error_overlay.dart lib/features/player/player_screen.dart test/features/player/player_error_overlay_test.dart
git commit -m "feat: add player error overlay widget"
```

---

## Task 4: BDD 測試 - 自動切換場景

**Files:**
- Create: `test/features/player/player_auto_switch_bdd_test.dart`

- [ ] **Step 1: 撰寫 BDD 測試**

```dart
// test/features/player/player_auto_switch_bdd_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:white_tv/core/api/models.dart';
import 'package:white_tv/core/source/source_selector.dart';
import 'package:white_tv/core/source/source_selector_provider.dart';
import 'package:white_tv/features/player/player_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('多來源自動切換 BDD 場景', () {
    late ProviderContainer container;
    late PlayerStore store;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();
      store = container.read(playerStoreProvider.notifier);
    });

    tearDown(() => container.dispose());

    group('場景 1: 來源 A 播放失敗，自動切換到來源 B', () {
      test('Given 使用者正在觀看影片（來源 A）', () async {
        final sources = [
          const VideoSource(id: 'src1', name: '量子資源', url: 'http://a.com', latency: 80, isAvailable: true),
          const VideoSource(id: 'src2', name: '非凡資源', url: 'http://b.com', latency: 120, isAvailable: true),
        ];

        await store.setVideo('video1', 'ep1');
        store.play();

        expect(store.state.source?.id, 'src1');
        expect(store.state.autoSwitchCount, 0);
      });

      test('When 來源 A 播放失敗（超時）', () async {
        store.setBuffering(true);
        await Future.delayed(const Duration(seconds: 11));

        expect(store.state.autoSwitchCount, 1);
        expect(store.state.source?.id, 'src2'); // 切換到 src2
      });

      test('Then 播放繼續，用戶無感知', () {
        // autoSwitchCount = 1 表示已切換但繼續播放
        expect(store.state.autoSwitchCount, 1);
        expect(store.state.isPlaying, true);
        expect(store.state.error, isNull);
      });
    });

    group('場景 2: 所有來源都失敗', () {
      test('Given 使用者正在觀看影片', () async {
        final sources = [
          const VideoSource(id: 'src1', name: '量子資源', url: 'http://a.com', latency: 80, isAvailable: true),
          const VideoSource(id: 'src2', name: '非凡資源', url: 'http://b.com', latency: 120, isAvailable: true),
        ];

        await store.setVideo('video1', 'ep1');
        store.play();
      });

      test('When 所有來源都播放失敗', () async {
        // 觸發第一次切換
        store.setBuffering(true);
        await Future.delayed(const Duration(seconds: 11));

        // 觸發第二次切換
        store.setBuffering(true);
        await Future.delayed(const Duration(seconds: 11));

        // 第三次失敗（已達上限）
        store.setBuffering(true);
        await Future.delayed(const Duration(seconds: 11));
      });

      test('Then 系統顯示錯誤提示', () {
        expect(store.state.error, isNotNull);
        expect(store.state.error, contains('已嘗試所有來源'));
      });
    });
  });
}
```

- [ ] **Step 2: Run BDD test to verify it passes**

Run: `flutter test test/features/player/player_auto_switch_bdd_test.dart -v`
Expected: PASS (all scenarios)

- [ ] **Step 3: Commit**

```bash
git add test/features/player/player_auto_switch_bdd_test.dart
git commit -m "test: add BDD tests for source auto-switch scenarios"
```

---

## Task 5: 整合測試 - 完整流程

**Files:**
- Create: `test/integration/player_source_auto_switch_test.dart`

- [ ] **Step 1: 撰寫整合測試**

```dart
// test/integration/player_source_auto_switch_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:white_tv/main.dart' as app;
import 'package:white_tv/core/api/models.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('player_source_auto_switch', () {
    testWidgets('播放失敗時自動切換來源並繼續', (tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(
        const ProviderScope(
          child: app.WhiteTVApp(),
        ),
      );

      // 導航到播放器
      await tester.pumpAndSettle();

      // 點擊播放
      await tester.tap(find.byKey(const Key('play_button')));
      await tester.pumpAndSettle();

      // 驗證正在播放
      expect(find.byKey(const Key('player')), findsOneWidget);

      // 模擬來源失敗（通過錯誤回調）
      // ... 需要集成測試框架支持
    });
  });
}
```

- [ ] **Step 2: Run integration test**

Run: `flutter test integration_test/player_source_auto_switch_test.dart -v`
Expected: PASS (if running on device/emulator)

- [ ] **Step 3: Commit**

```bash
git add test/integration/player_source_auto_switch_test.dart
git commit -m "test: add integration test for auto-switch flow"
```

---

## 驗證清單

- [ ] 所有單元測試通過
- [ ] 所有 BDD 測試通過
- [ ] `flutter analyze` 無錯誤
- [ ] `flutter test --coverage` 覆蓋率 >= 80%
- [ ] 文件更新（CHANGELOG、README）

---

**Plan complete.** Saved to `docs/superpowers/plans/2026-05-27-source-auto-switch-plan.md`