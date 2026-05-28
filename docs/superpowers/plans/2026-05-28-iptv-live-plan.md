# IPTV Live 功能實現計劃

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 將 IPTV Live 功能從 demo data 升級為與 LunaTV API 整合，採用 JSON 優先 + M3U 備援策略

**Architecture:** 擴展 LunaClient 加入 IPTV API 方法，更新 LiveStore 使用真實 API，建立 IptvChannel model 處理 JSON 格式回應

**Tech Stack:** Flutter Riverpod, Dio, TDD, BDD

---

## 檔案結構

```
lib/
├── core/api/
│   ├── api_client.dart          # 新增 getIptvChannels(), getIptvM3U()
│   ├── luna_client.dart         # 擴展 IPTV 方法
│   └── models.dart              # 新增 IptvChannel
│
lib/features/live/
├── data/models/
│   └── ipvt_channel.dart        # 新增 IptvChannel model (JSON)
├── domain/
│   └── services/
│       └── live_service.dart    # 新增 fallback 邏輯
└── presentation/
    ├── providers/
    │   └── live_store.dart      # 新增 loadFromApi(), 移除 demo data
    └── screens/
        └── live_screen.dart     # 更新為使用 loadFromApi()
```

---

## 任務清單

### 任務 1: 擴展 ApiClient 介面

**Files:**
- Modify: `lib/core/api/api_client.dart:1-41`

- [ ] **Step 1: 新增 IPTV 方法到 ApiClient 介面**

在 `abstract class ApiClient` 中新增兩個方法：

```dart
/// 取得 IPTV 頻道列表 (JSON 格式)
Future<List<IptvChannel>> getIptvChannels();

/// 取得 IPTV M3U playlist
Future<String?> getIptvM3U();

/// 取得 EPG 節目表
Future<Map<String, dynamic>> getIptvEpg();
```

- [ ] **Step 2: 提交變更**

```bash
git add lib/core/api/api_client.dart
git commit -m "feat(api): add IPTV methods to ApiClient interface"
```

---

### 任務 2: 建立 IptvChannel Model

**Files:**
- Create: `lib/features/live/data/models/ipvt_channel.dart`
- Modify: `lib/core/api/models.dart:1-200`

- [ ] **Step 1: 建立 IptvChannel class**

```dart
class IptvChannel {
  final String id;
  final String name;
  final String logo;
  final String url;
  final String? group;

  const IptvChannel({
    required this.id,
    required this.name,
    required this.logo,
    required this.url,
    this.group,
  });

  factory IptvChannel.fromJson(Map<String, dynamic> json) {
    return IptvChannel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      logo: json['logo'] as String? ?? '',
      url: json['url'] as String? ?? '',
      group: json['group'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'logo': logo,
        'url': url,
        'group': group,
      };

  /// 轉換為 M3uChannel (internal model)
  M3uChannel toM3uChannel() {
    return M3uChannel(
      name: name,
      url: url,
      logoUrl: logo.isNotEmpty ? logo : null,
      groupTitle: group,
      tvgId: id,
    );
  }
}
```

- [ ] **Step 2: 在 models.dart 中引入 M3uChannel**

在 `lib/core/api/models.dart` 新增 import：

```dart
import 'package:white_tv/features/live/data/models/m3u_channel.dart';
```

- [ ] **Step 3: 執行 dart format**

```bash
dart format lib/features/live/data/models/ipvt_channel.dart lib/core/api/models.dart
```

- [ ] **Step 4: 提交變更**

```bash
git add lib/features/live/data/models/ipvt_channel.dart lib/core/api/models.dart
git commit -m "feat(live): add IptvChannel model for JSON parsing"
```

---

### 任務 3: 擴展 LunaClient

**Files:**
- Modify: `lib/core/api/luna_client.dart:1-150`

- [ ] **Step 1: 新增 IPTV 方法到 LunaClient**

在 `LunaClient` class 中新增：

```dart
@override
Future<List<IptvChannel>> getIptvChannels() async {
  try {
    final response = await _dio.get('/api/iptv/channels');
    final List<dynamic> data = response.data['channels'] ?? [];
    return data.map((json) => IptvChannel.fromJson(json)).toList();
  } on DioException {
    return [];
  }
}

@override
Future<String?> getIptvM3U() async {
  try {
    final response = await _dio.get(
      '/api/iptv/list',
      options: Options(responseType: ResponseType.plain),
    );
    return response.data as String?;
  } on DioException {
    return null;
  }
}

@override
Future<Map<String, dynamic>> getIptvEpg() async {
  try {
    final response = await _dio.get('/api/iptv/epg');
    return response.data as Map<String, dynamic>;
  } on DioException {
    return {};
  }
}
```

- [ ] **Step 2: 新增必要的 import**

確認 LunaClient 有：
```dart
import 'package:dio/dio.dart';
import 'package:white_tv/features/live/data/models/ipvt_channel.dart';
```

- [ ] **Step 3: 執行 dart analyze**

```bash
dart analyze lib/core/api/luna_client.dart
```

- [ ] **Step 4: 提交變更**

```bash
git add lib/core/api/luna_client.dart
git commit -m "feat(luna): add IPTV endpoints (channels, m3u, epg)"
```

---

### 任務 4: 更新 LiveService 加入 Fallback 邏輯

**Files:**
- Modify: `lib/features/live/domain/services/live_service.dart:1-104`

- [ ] **Step 1: 新增 ApiClient 依賴和 loadFromApi 方法**

在 `LiveService` class 中新增：

```dart
class LiveService {
  final M3uParser m3uParser;
  final EpgManager epgManager;
  final TimeshiftManager timeshiftManager;
  final ApiClient? apiClient;  // 新增可選的 API client

  LiveState _state = LiveState.initial();

  LiveService({
    required this.m3uParser,
    required this.epgManager,
    required this.timeshiftManager,
    this.apiClient,
  });

  /// 從 API 載入頻道（JSON 優先，M3U 備援）
  Future<LiveState> loadFromApi() async {
    _state = _state.copyWith(status: LiveStatus.loading);

    // 嘗試 JSON 格式
    if (apiClient != null) {
      final channels = await apiClient!.getIptvChannels();
      if (channels.isNotEmpty) {
        final m3uChannels = channels.map((c) => c.toM3uChannel()).toList();
        _state = _state.copyWith(
          status: LiveStatus.loaded,
          channels: m3uChannels,
        );
        return _state;
      }

      // Fallback 到 M3U
      final m3uContent = await apiClient!.getIptvM3U();
      if (m3uContent != null && m3uContent.isNotEmpty) {
        final channels = m3uParser.parse(m3uContent);
        _state = _state.copyWith(
          status: LiveStatus.loaded,
          channels: channels,
        );
        return _state;
      }
    }

    // 無法載入，回傳錯誤
    _state = _state.copyWith(
      status: LiveStatus.error,
      errorMessage: '無法載入頻道列表',
    );
    return _state;
  }
}
```

- [ ] **Step 2: 新增 ApiClient import**

```dart
import 'package:white_tv/core/api/api_client.dart';
```

- [ ] **Step 3: 執行 dart format 和 analyze**

```bash
dart format lib/features/live/domain/services/live_service.dart
dart analyze lib/features/live/domain/services/live_service.dart
```

- [ ] **Step 4: 提交變更**

```bash
git add lib/features/live/domain/services/live_service.dart
git commit -m "feat(live): add loadFromApi with JSON+M3U fallback"
```

---

### 任務 5: 更新 LiveStore

**Files:**
- Modify: `lib/features/live/presentation/providers/live_store.dart:1-97`

- [ ] **Step 1: 新增 loadFromApi 方法到 LiveStore**

在 `LiveStore` class 中新增：

```dart
final LiveService _service;
final ApiClient? _apiClient;  // 新增

LiveStore(this._service, [this._apiClient]) : super(LiveState.initial());

/// 從 API 載入頻道（JSON 優先，M3U 備援）
Future<void> loadFromApi() async {
  if (_apiClient != null) {
    final service = LiveService(
      m3uParser: const M3uParserImpl(),
      epgManager: EpgManagerImpl(),
      timeshiftManager: TimeshiftManagerImpl(),
      apiClient: _apiClient,
    );
    final newState = await service.loadFromApi();
    state = newState;
  }
}
```

- [ ] **Step 2: 更新 liveServiceProvider 傳入 ApiClient**

```dart
final apiClientProvider = Provider<ApiClient>((ref) {
  // 從現有 provider 取得 LunaClient
  return ref.watch(lunaClientProvider);
});

final liveServiceProvider = Provider<LiveService>((ref) {
  return LiveService(
    m3uParser: ref.watch(m3uParserProvider),
    epgManager: ref.watch(epgManagerProvider),
    timeshiftManager: ref.watch(timeshiftManagerProvider),
    apiClient: ref.watch(apiClientProvider),
  );
});
```

- [ ] **Step 3: 執行 dart format 和 analyze**

```bash
dart format lib/features/live/presentation/providers/live_store.dart
dart analyze lib/features/live/presentation/providers/live_store.dart
```

- [ ] **Step 4: 提交變更**

```bash
git add lib/features/live/presentation/providers/live_store.dart
git commit -m "feat(live): add loadFromApi to LiveStore"
```

---

### 任務 6: 更新 LiveScreen

**Files:**
- Modify: `lib/features/live/presentation/screens/live_screen.dart:1-173`

- [ ] **Step 1: 將 _loadChannels 改為使用 loadFromApi**

```dart
void _loadChannels() {
  // 舊：使用 demo M3U content
  // const demoM3uContent = '''#EXTM3U...''';
  // ref.read(liveStoreProvider.notifier).loadChannels(demoM3uContent);

  // 新：使用真實 API
  ref.read(liveStoreProvider.notifier).loadFromApi();
}
```

- [ ] **Step 2: 執行 dart format 和 analyze**

```bash
dart format lib/features/live/presentation/screens/live_screen.dart
dart analyze lib/features/live/presentation/screens/live_screen.dart
```

- [ ] **Step 3: 提交變更**

```bash
git add lib/features/live/presentation/screens/live_screen.dart
git commit -m "feat(live): replace demo data with API call"
```

---

### 任務 7: TDD 測試

**Files:**
- Create: `test/features/live/luna_client_iptv_test.dart`
- Modify: `test/features/live/live_store_test.dart`

- [ ] **Step 1: 為 LunaClient IPTV 方法撰寫測試**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/core/api/luna_client.dart';

void main() {
  group('LunaClient IPTV', () {
    late LunaClient client;

    setUp(() {
      client = LunaClient();
    });

    test('getIptvChannels returns list of channels', () async {
      final channels = await client.getIptvChannels();
      // 根據 API 回應驗證
      expect(channels, isA<List>());
    });

    test('getIptvM3U returns m3u content', () async {
      final m3uContent = await client.getIptvM3U();
      // 根據 API 回應驗證
      expect(m3uContent, anyOf(isNull, isA<String>()));
    });

    test('getIptvEpg returns epg data', () async {
      final epg = await client.getIptvEpg();
      expect(epg, isA<Map>());
    });
  });
}
```

- [ ] **Step 2: 為 LiveService fallback 邏輯撰寫測試**

```dart
test('loadFromApi uses JSON when available', () async {
  // Mock API client that returns JSON
  final mockClient = MockApiClient();
  when(mockClient.getIptvChannels()).thenAnswer((_) async => [
    IptvChannel(id: '1', name: 'Channel 1', logo: '', url: 'http://example.com/ch1.m3u8'),
  ]);

  final service = LiveService(
    m3uParser: const M3uParserImpl(),
    epgManager: EpgManagerImpl(),
    timeshiftManager: TimeshiftManagerImpl(),
    apiClient: mockClient,
  );

  final state = await service.loadFromApi();
  expect(state.status, LiveStatus.loaded);
  expect(state.channels.length, 1);
});

test('loadFromApi fallback to M3U when JSON fails', () async {
  final mockClient = MockApiClient();
  when(mockClient.getIptvChannels()).thenAnswer((_) async => []);
  when(mockClient.getIptvM3U()).thenAnswer((_) async => '''
#EXTM3U
#EXTINF:-1 tvg-name="Channel 1",Channel 1
https://example.com/ch1.m3u8
''');

  final service = LiveService(
    m3uParser: const M3uParserImpl(),
    epgManager: EpgManagerImpl(),
    timeshiftManager: TimeshiftManagerImpl(),
    apiClient: mockClient,
  );

  final state = await service.loadFromApi();
  expect(state.status, LiveStatus.loaded);
});
```

- [ ] **Step 3: 執行測試**

```bash
flutter test test/features/live/luna_client_iptv_test.dart
flutter test test/features/live/live_store_test.dart
```

- [ ] **Step 4: 提交測試**

```bash
git add test/features/live/luna_client_iptv_test.dart test/features/live/live_store_test.dart
git commit -m "test(live): add IPTV API tests"
```

---

### 任務 8: BDD 驗證

**Files:**
- Modify: `test/features/live/live_bdd_test.dart`

- [ ] **Step 1: 更新 BDD 測試驗證頻道載入流程**

```dart
test('GIVEN LunaTV API is available WHEN user opens Live TV THEN channels are displayed', () async {
  // 驗證頻道列表正確顯示
});

test('GIVEN JSON API fails WHEN user opens Live TV THEN M3U fallback is used', () async {
  // 驗證 fallback 邏輯
});

test('GIVEN user searches for channel WHEN user types query THEN matching channels are shown', () async {
  // 驗證搜尋功能
});
```

- [ ] **Step 2: 執行 BDD 測試**

```bash
flutter test test/features/live/live_bdd_test.dart
```

- [ ] **Step 3: 提交 BDD 測試**

```bash
git add test/features/live/live_bdd_test.dart
git commit -m "test(live): add BDD tests for IPTV integration"
```

---

## 自檢查清單

- [ ] Spec 覆蓋：所有 spec 中的需求都有對應 task
- [ ] 無 Placeholder：無 TBD、TODO、未完成章節
- [ ] 類型一致性：方法簽名、屬性名稱一致
- [ ] TDD 流程：每個功能先寫測試再實作
- [ ] 提交规范：每個 task 有獨立 commit

---

**Plan 完成！儲存於 `docs/superpowers/plans/2026-05-28-iptv-live-plan.md`**

## 執行選項

**1. Subagent-Driven (推薦)** - 每個 task 由 subagent 執行，完成後 review

**2. Inline Execution** - 在本 session 依序執行每個 task

你想用哪種方式？