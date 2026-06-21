# 時移播放 + Tab 自訂實作計劃

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 實作雙層時移播放（服務端優先 + 用戶端 fallback）和 Tab 導航自訂（拖曳排序 + 可見性開關）

**Architecture:** 
- 時移功能：擴展現有 `TimeshiftManager` 介面，新增 `TimeshiftServiceAdapter` 和 `TimeshiftClientBuffer`
- Tab 自訂：擴展現有 `TabOrderEditor` widget，新增 `TabVisibilityToggle` 和完整狀態管理

**Tech Stack:** Flutter + Riverpod + flutter_test

## Global Constraints

- TDD 方式開發：先寫測試，再實作
- BDD 方式驗證：使用 Gherkin 語法撰寫驗收測試
- 測試覆蓋率：時移功能 8+ 單元測試，Tab 自訂 6+ 單元測試
- 遵循現有程式碼風格和架構模式

---

## Phase 1: 時移播放功能

### Task 1: 擴展 TimeshiftManager 介面

**Files:**
- Modify: `lib/features/live/domain/repositories/timeshift_manager.dart`
- Test: `test/features/live/domain/repositories/timeshift_manager_test.dart`

**Interfaces:**
- Consumes: 無
- Produces: `TimeshiftManager` 介面含新方法

- [ ] **Step 1: 寫入失敗測試**

```dart
// test/features/live/domain/repositories/timeshift_manager_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/live/domain/repositories/timeshift_manager.dart';

void main() {
  group('TimeshiftManager 擴展方法', () {
    test('isServiceSideSupported 回傳服務端支援狀態', () async {
      final manager = TimeshiftManagerImpl();
      final supported = await manager.isServiceSideSupported('ch1');
      expect(supported, isA<bool>());
    });

    test('getServiceSideStream 回傳時移串流 URL', () async {
      final manager = TimeshiftManagerImpl();
      final streamUrl = await manager.getServiceSideStream(
        'ch1',
        const Duration(minutes: -10),
        const Duration(minutes: -5),
      );
      expect(streamUrl, anyOf(isNull, isA<String>()));
    });

    test('startClientBuffer 開始用戶端緩存', () async {
      final manager = TimeshiftManagerImpl();
      await manager.startClientBuffer('ch1', const Duration(minutes: 30));
    });

    test('stopClientBuffer 停止用戶端緩存', () async {
      final manager = TimeshiftManagerImpl();
      await manager.startClientBuffer('ch1', const Duration(minutes: 30));
      await manager.stopClientBuffer();
    });
  });
}
```

- [ ] **Step 2: 執行測試確認失敗**

Run: `flutter test test/features/live/domain/repositories/timeshift_manager_test.dart`
Expected: FAIL - methods not defined

- [ ] **Step 3: 實作新方法**

在 `TimeshiftManager` 介面新增：
```dart
Future<bool> isServiceSideSupported(String channelId);
Future<String?> getServiceSideStream(
  String channelId,
  Duration startOffset,
  Duration endOffset,
);
Future<void> startClientBuffer(String channelId, Duration duration);
Future<void> stopClientBuffer();
```

在 `TimeshiftManagerImpl` 實作新方法。

- [ ] **Step 4: 執行測試確認通過**

- [ ] **Step 5: 提交**

```bash
git add lib/features/live/domain/repositories/timeshift_manager.dart test/features/live/domain/repositories/timeshift_manager_test.dart
git commit -m "feat(live): extend TimeshiftManager with service-side and client buffer methods"
```

---

### Task 2: 實作 TimeshiftServiceAdapter

**Files:**
- Create: `lib/features/live/domain/services/timeshift_service_adapter.dart`
- Test: `test/features/live/domain/services/timeshift_service_adapter_test.dart`

**Interfaces:**
- Consumes: `ApiClient`
- Produces: `TimeshiftServiceAdapter` 類別

- [ ] **Step 1: 寫入失敗測試**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/live/domain/services/timeshift_service_adapter.dart';

void main() {
  group('TimeshiftServiceAdapter', () {
    test('checkSupport 回傳服務端支援狀態', () async {
      final adapter = TimeshiftServiceAdapter(mockApiClient);
      final supported = await adapter.checkSupport('ch1');
      expect(supported, isA<bool>());
    });

    test('getStream 回傳時移串流 URL 或 null', () async {
      final adapter = TimeshiftServiceAdapter(mockApiClient);
      final url = await adapter.getStream(
        'ch1',
        const Duration(minutes: -10),
        const Duration(minutes: -5),
      );
      expect(url, anyOf(isNull, isA<String>()));
    });
  });
}
```

- [ ] **Step 2: 執行測試確認失敗**

- [ ] **Step 3: 實作**

```dart
// lib/features/live/domain/services/timeshift_service_adapter.dart

/// 服務端時移適配器
/// 串接 LunaTV API 的時移功能
class TimeshiftServiceAdapter {
  final ApiClient _apiClient;

  TimeshiftServiceAdapter(this._apiClient);

  /// 檢查服務端是否支援時移
  Future<bool> checkSupport(String channelId) async {
    try {
      final channels = await _apiClient.getIptvChannels();
      return channels.any((c) => c.id == channelId);
    } catch (_) {
      return false;
    }
  }

  /// 取得時移串流 URL
  Future<String?> getStream(
    String channelId,
    Duration startOffset,
    Duration endOffset,
  ) async {
    // TODO: 串接 LunaTV 時移 API
    // GET /iptv/timeshift?channel_id={id}&start={timestamp}&end={timestamp}
    return null;
  }
}
```

- [ ] **Step 4: 執行測試確認通過**

- [ ] **Step 5: 提交**

---

### Task 3: 實作 TimeshiftClientBuffer

**Files:**
- Create: `lib/features/live/domain/services/timeshift_client_buffer.dart`
- Test: `test/features/live/domain/services/timeshift_client_buffer_test.dart`

- [ ] **Step 1: 寫入失敗測試**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/live/domain/services/timeshift_client_buffer.dart';

void main() {
  group('TimeshiftClientBuffer', () {
    test('start 開始緩存', () async {
      final buffer = TimeshiftClientBuffer();
      await buffer.start('ch1', const Duration(minutes: 30));
      expect(buffer.isActive, isTrue);
    });

    test('stop 停止緩存', () async {
      final buffer = TimeshiftClientBuffer();
      await buffer.start('ch1', const Duration(minutes: 30));
      await buffer.stop();
      expect(buffer.isActive, isFalse);
    });

    test('緩存容量限制 30 分鐘', () async {
      final buffer = TimeshiftClientBuffer();
      await buffer.start('ch1', const Duration(minutes: 60));
      expect(buffer.maxDuration, const Duration(minutes: 30));
    });
  });
}
```

- [ ] **Step 2: 執行測試確認失敗**

- [ ] **Step 3: 實作**

```dart
// lib/features/live/domain/services/timeshift_client_buffer.dart

/// 用戶端時移緩存
/// 本地緩存最近一段時間的直播內容
class TimeshiftClientBuffer {
  static const maxBufferDuration = Duration(minutes: 30);
  
  String? _channelId;
  DateTime? _startTime;
  Duration _requestedDuration = maxBufferDuration;
  
  bool get isActive => _channelId != null;
  String? get channelId => _channelId;
  Duration get maxDuration => maxBufferDuration;
  
  Future<void> start(String channelId, Duration duration) async {
    _channelId = channelId;
    _startTime = DateTime.now();
    _requestedDuration = duration > maxBufferDuration 
        ? maxBufferDuration 
        : duration;
  }
  
  Future<void> stop() async {
    _channelId = null;
    _startTime = null;
  }
  
  Duration get bufferedDuration {
    if (_startTime == null) return Duration.zero;
    final elapsed = DateTime.now().difference(_startTime!);
    return elapsed > maxBufferDuration ? maxBufferDuration : elapsed;
  }
}
```

- [ ] **Step 4: 執行測試確認通過**

- [ ] **Step 5: 提交**

---

### Task 4: 更新 TimeshiftControlBar UI

**Files:**
- Modify: `lib/features/live/presentation/widgets/timeshift_control_bar.dart`
- Test: `test/features/live/presentation/widgets/timeshift_control_bar_test.dart`

- [ ] **Step 1: 寫入失敗測試**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/live/presentation/widgets/timeshift_control_bar.dart';

void main() {
  group('TimeshiftControlBar 增強', () {
    testWidgets('顯示 [直播中] 狀態', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimeshiftControlBar(
              position: Duration.zero,
              mode: TimeshiftMode.live,
              onSeek: (_) {},
              onPlayPause: () {},
              onGoLive: () {},
            ),
          ),
        ),
      );
      
      expect(find.text('直播中'), findsOneWidget);
    });

    testWidgets('緩存模式顯示不同圖示', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimeshiftControlBar(
              position: const Duration(minutes: -5),
              mode: TimeshiftMode.buffer,
              onSeek: (_) {},
              onPlayPause: () {},
              onGoLive: () {},
            ),
          ),
        ),
      );
      
      expect(find.byIcon(Icons.cloud_download), findsOneWidget);
    });
  });
}
```

- [ ] **Step 2: 執行測試確認失敗**

- [ ] **Step 3: 實作增強 UI**

新增 `TimeshiftMode` enum 和增強 `TimeshiftControlBar` widget。

- [ ] **Step 4: 執行測試確認通過**

- [ ] **Step 5: 提交**

---

### Task 5: BDD 測試 - 時移播放

**Files:**
- Create: `test/features/live/live_timeshift_bdd_test.dart`

- [ ] **Step 1: 寫入 BDD 測試**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/live/domain/repositories/timeshift_manager.dart';
import 'package:white_tv/features/live/domain/services/timeshift_client_buffer.dart';

void main() {
  group('Feature: 直播時移功能', () {
    test('GIVEN 用戶正在觀看直播 '
         'WHEN 用戶拖曳時間軸 '
         'THEN 播放器開始播放時移內容', () async {
      final timeshiftManager = TimeshiftManagerImpl();
      await timeshiftManager.startTimeshift(
        channelId: 'ch1',
        streamUrl: 'http://stream.com/ch1.m3u8',
      );
      final position = await timeshiftManager.seek(const Duration(hours: 1));
      expect(position, const Duration(hours: 1));
    });

    test('GIVEN 服務端不支援時 '
         'WHEN 用戶嘗試時移 '
         'THEN 系統使用本地緩存播放', () async {
      final clientBuffer = TimeshiftClientBuffer();
      await clientBuffer.start('ch1', const Duration(minutes: 30));
      expect(clientBuffer.isActive, isTrue);
    });

    test('GIVEN 用戶正在觀看時移內容 '
         'WHEN 用戶點擊 [直播中] 按鈕 '
         'THEN 播放器回到直播串流', () async {
      final timeshiftManager = TimeshiftManagerImpl();
      await timeshiftManager.startTimeshift(
        channelId: 'ch1',
        streamUrl: 'http://stream.com/ch1.m3u8',
      );
      await timeshiftManager.stopTimeshift();
      expect(timeshiftManager.isTimeshiftActive, isFalse);
    });
  });
}
```

- [ ] **Step 2: 執行 BDD 測試**

- [ ] **Step 3: 提交**

---

## Phase 2: Tab 導航自訂功能

### Task 6: 實作 TabConfig 模型和 TabNavigationStore

**Files:**
- Create: `lib/features/settings/models/tab_config.dart`
- Create: `lib/features/settings/stores/tab_navigation_store.dart`
- Test: `test/features/settings/stores/tab_navigation_store_test.dart`

- [ ] **Step 1: 寫入失敗測試**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/settings/models/tab_config.dart';
import 'package:white_tv/features/settings/stores/tab_navigation_store.dart';

void main() {
  group('TabNavigationStore', () {
    test('visibleTabs 只返回可見且排序後的 Tab', () {
      final store = TabNavigationStore(MockStorage());
      store.setVisibility('search', false);
      expect(store.visibleTabs.any((t) => t.id == 'search'), isFalse);
    });

    test('reorder 正確更新 order', () {
      final store = TabNavigationStore(MockStorage());
      store.reorder(0, 2);
      expect(store.visibleTabs[0].id, 'categories');
    });

    test('toggleVisibility 切換可見性', () {
      final store = TabNavigationStore(MockStorage());
      store.setVisibility('search', false);
      expect(store.isVisible('search'), isFalse);
    });

    test('restoreDefaults 還原預設設定', () {
      final store = TabNavigationStore(MockStorage());
      store.setVisibility('search', false);
      store.restoreDefaults();
      expect(store.isVisible('search'), isTrue);
    });
  });
}
```

- [ ] **Step 2: 執行測試確認失敗**

- [ ] **Step 3: 實作 TabConfig 模型**

```dart
// lib/features/settings/models/tab_config.dart

class TabConfig {
  final String id;
  final String label;
  final bool isVisible;
  final int order;

  const TabConfig({
    required this.id,
    required this.label,
    this.isVisible = true,
    this.order = 0,
  });

  TabConfig copyWith({
    String? id,
    String? label,
    bool? isVisible,
    int? order,
  }) {
    return TabConfig(
      id: id ?? this.id,
      label: label ?? this.label,
      isVisible: isVisible ?? this.isVisible,
      order: order ?? this.order,
    );
  }
}

const defaultTabs = [
  TabConfig(id: 'home', label: '首頁', order: 0),
  TabConfig(id: 'categories', label: '分類', order: 1),
  TabConfig(id: 'live', label: '直播', order: 2),
  TabConfig(id: 'search', label: '搜尋', order: 3),
  TabConfig(id: 'favorites', label: '收藏', order: 4),
  TabConfig(id: 'settings', label: '設定', order: 5),
];
```

- [ ] **Step 4: 實作 TabNavigationStore**

- [ ] **Step 5: 執行測試確認通過**

- [ ] **Step 6: 提交**

---

### Task 7: 實作 ReorderableTabList Widget（含可見性開關）

**Files:**
- Create: `lib/features/settings/widgets/reorderable_tab_list.dart`
- Test: `test/features/settings/widgets/reorderable_tab_list_test.dart`

- [ ] **Step 1: 寫入失敗測試**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/features/settings/widgets/reorderable_tab_list.dart';

void main() {
  group('ReorderableTabList', () {
    testWidgets('顯示所有 Tab 項目', (tester) async {
      await tester.pumpWidget(
        ProviderScope(child: MaterialApp(home: Scaffold(body: ReorderableTabList()))),
      );
      expect(find.text('首頁'), findsOneWidget);
    });

    testWidgets('顯示可見性開關按鈕', (tester) async {
      await tester.pumpWidget(
        ProviderScope(child: MaterialApp(home: Scaffold(body: ReorderableTabList()))),
      );
      expect(find.byIcon(Icons.visibility), findsWidgets);
    });
  });
}
```

- [ ] **Step 2: 執行測試確認失敗**

- [ ] **Step 3: 實作 ReorderableTabList**

- [ ] **Step 4: 執行測試確認通過**

- [ ] **Step 5: 提交**

---

### Task 8: 更新 SettingsScreen 整合 Tab 設定

**Files:**
- Modify: `lib/features/settings/settings_screen.dart`

- [ ] **Step 1: 更新 SettingsScreen**

在 TabBar 新增「Tab 設定」頁面，並在 TabBarView 中新增 `ReorderableTabList()`。

- [ ] **Step 2: 執行測試確認通過**

- [ ] **Step 3: 提交**

---

### Task 9: BDD 測試 - Tab 導航自訂

**Files:**
- Create: `test/features/settings/tab_customization_bdd_test.dart`

- [ ] **Step 1: 寫入 BDD 測試**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/settings/stores/tab_navigation_store.dart';

void main() {
  group('Feature: Tab 導航自訂', () {
    test('GIVEN 用戶打開設定頁 '
         'WHEN 用戶點擊隱藏按鈕 '
         'THEN 導航列不再顯示該 Tab', () {
      final store = TabNavigationStore(MockStorage());
      store.setVisibility('search', false);
      expect(store.visibleTabs.any((t) => t.id == 'search'), isFalse);
    });

    test('GIVEN 用戶打開設定頁 '
         'WHEN 用戶拖曳調整順序 '
         'THEN 導航列顯示新順序', () {
      final store = TabNavigationStore(MockStorage());
      store.reorder(4, 1);
      expect(store.visibleTabs[1].id, 'favorites');
    });

    test('GIVEN 用戶已自訂 Tab 設定 '
         'WHEN 用戶點擊還原預設 '
         'THEN 所有 Tab 回到預設', () {
      final store = TabNavigationStore(MockStorage());
      store.setVisibility('search', false);
      store.reorder(0, 5);
      store.restoreDefaults();
      expect(store.isVisible('search'), isTrue);
      expect(store.visibleTabs[0].id, 'home');
    });
  });
}
```

- [ ] **Step 2: 執行 BDD 測試**

- [ ] **Step 3: 提交**

---

## 測試覆蓋總結

| Task | 單元測試 | BDD 測試 |
|------|----------|----------|
| Task 1: TimeshiftManager 介面擴展 | 4 | - |
| Task 2: TimeshiftServiceAdapter | 2 | - |
| Task 3: TimeshiftClientBuffer | 3 | - |
| Task 4: TimeshiftControlBar UI | 2 | - |
| Task 5: 時移播放 BDD | - | 3 |
| Task 6: TabNavigationStore | 4 | - |
| Task 7: ReorderableTabList | 2 | - |
| Task 8: SettingsScreen 整合 | 1 | - |
| Task 9: Tab 自訂 BDD | - | 3 |
| **總計** | **18** | **6** |

---

*Plan 版本: v1.0 — 2026-06-21*
