# Timeshift (Client Buffer) + YouTube Integration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 實作時移功能（客戶端緩衝）+ YouTube 整合

**Architecture:** 
- 時移：擴展現有 TimeshiftManagerImpl，實作客戶端 MPEG-TS 分段緩衝
- YouTube：新增 youtube feature module，对接 LunaTV API YouTube endpoints

**Tech Stack:** Flutter, Riverpod, media_kit, Dio

## Global Constraints

- TDD: 每次實作前先寫失敗的測試
- BDD: 每個功能完成後寫 E2E 場景
- 最小改動：修改現有檔案而非重寫
- Mock 模式：使用 Fake* 類別實作介面
- 提交規範：每個 task 独立 commit

---

## Phase 1: Timeshift (Client Buffer)

---

### Task 1: 新增 SettingsStore.timeshiftBufferDuration 欄位

**Files:**
- Modify: `lib/features/settings/settings_store.dart`
- Modify: `lib/features/settings/services/settings_storage_service.dart`
- Create: `test/features/settings/settings_store_test.dart`

**Interfaces:**
- Consumes: `SettingsStorageService`
- Produces: `settings.timeshiftBufferDuration` (int, minutes: 15/30/60)

- [ ] **Step 1: 寫失敗測試**

```dart
test('timeshiftBufferDuration 預設為 30 分鐘', () {
  final store = SettingsStore(FakeSettingsStorageService());
  expect(store.state.timeshiftBufferDuration, 30);
});

test('updateTimeshiftBufferDuration 更新狀態和儲存', () async {
  final storage = FakeSettingsStorageService();
  final store = SettingsStore(storage);
  await store.updateTimeshiftBufferDuration(60);
  expect(store.state.timeshiftBufferDuration, 60);
  expect(await storage.getTimeshiftBufferDuration(), 60);
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/settings/settings_store_test.dart`
Expected: FAIL - `timeshiftBufferDuration` not found

- [ ] **Step 3: 新增 SettingsState 欄位**

在 `SettingsState` class 新增：`int timeshiftBufferDuration = 30;`
更新 `copyWith` 新增 `int? timeshiftBufferDuration` 參數。

- [ ] **Step 4: 新增 SettingsStorageService 介面方法**

```dart
abstract interface class SettingsStorageService {
  // ... existing methods
  Future<int> getTimeshiftBufferDuration();
  Future<void> saveTimeshiftBufferDuration(int minutes);
}
```

- [ ] **Step 5: 實作 FakeSettingsStorageService**

```dart
int _timeshiftBufferDuration = 30;

@override
Future<int> getTimeshiftBufferDuration() async => _timeshiftBufferDuration;

@override
Future<void> saveTimeshiftBufferDuration(int minutes) async {
  _timeshiftBufferDuration = minutes;
}
```

- [ ] **Step 6: 新增 SettingsStore.updateTimeshiftBufferDuration**

```dart
Future<void> updateTimeshiftBufferDuration(int minutes) async {
  await _storage.saveTimeshiftBufferDuration(minutes);
  state = state.copyWith(timeshiftBufferDuration: minutes);
}
```

- [ ] **Step 7: Run test to verify it passes**

Run: `flutter test test/features/settings/settings_store_test.dart`
Expected: PASS

- [ ] **Step 8: Commit**

```bash
git add lib/features/settings/settings_store.dart lib/features/settings/services/settings_storage_service.dart test/features/settings/settings_store_test.dart
git commit -m "feat(settings): add timeshiftBufferDuration to SettingsStore"
```

---

### Task 2: Settings 頁新增時移緩衝時長設定 UI

**Files:**
- Modify: `lib/features/settings/presentation/screens/settings_screen.dart`

**Interfaces:**
- Consumes: `settingsStoreProvider.timeshiftBufferDuration`
- Produces: `settingsStoreProvider.notifier.updateTimeshiftBufferDuration(minutes)`

- [ ] **Step 1: 找 Settings 頁中直播相關設定的位置**

執行: `grep -n "直播" lib/features/settings/presentation/screens/settings_screen.dart`

- [ ] **Step 2: 在直播設定區塊新增 RadioListTile**

```dart
RadioListTile<int>(
  title: const Text('15 分鐘'),
  value: 15,
  groupValue: settings.timeshiftBufferDuration,
  onChanged: (v) => ref.read(settingsStoreProvider.notifier).updateTimeshiftBufferDuration(v!),
),
RadioListTile<int>(
  title: const Text('30 分鐘'),
  value: 30,
  groupValue: settings.timeshiftBufferDuration,
  onChanged: (v) => ref.read(settingsStoreProvider.notifier).updateTimeshiftBufferDuration(v!),
),
RadioListTile<int>(
  title: const Text('60 分鐘'),
  value: 60,
  groupValue: settings.timeshiftBufferDuration,
  onChanged: (v) => ref.read(settingsStoreProvider.notifier).updateTimeshiftBufferDuration(v!),
),
```

- [ ] **Step 3: Run flutter analyze**

Run: `flutter analyze lib/features/settings/presentation/screens/settings_screen.dart`

- [ ] **Step 4: Commit**

```bash
git add lib/features/settings/presentation/screens/settings_screen.dart
git commit -m "feat(settings): add timeshift buffer duration RadioListTile"
```

---

### Task 3: 實作 TimeshiftManagerImpl.startClientBuffer()

**Files:**
- Modify: `lib/features/live/domain/repositories/timeshift_manager.dart`
- Create: `test/features/live/domain/repositories/timeshift_manager_test.dart`

**Interfaces:**
- Consumes: `channelId`, `Duration`, `streamUrl`
- Produces: `startClientBuffer()` 创建本地 TS 分段檔案

- [ ] **Step 1: 寫失敗測試**

```dart
group('startClientBuffer', () {
  late TimeshiftManagerImpl manager;
  late Directory tempDir;

  setUp(() async {
    manager = TimeshiftManagerImpl();
    tempDir = await Directory.systemTemp.createTemp('timeshift_test_');
  });

  tearDown(() async {
    await manager.stopClientBuffer();
    await tempDir.delete(recursive: true);
  });

  test('開始錄製後產生 TS 檔案', () async {
    await manager.startClientBuffer('channel_1', const Duration(minutes: 30));
    await Future.delayed(const Duration(seconds: 2));
    final files = await tempDir.list().toList();
    expect(files.any((f) => f.path.endsWith('.ts')), isTrue);
  });
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/live/domain/repositories/timeshift_manager_test.dart`
Expected: FAIL

- [ ] **Step 3: 實作 startClientBuffer**

```dart
import 'dart:io';
import 'package:path_provider/path_provider.dart';

File? _bufferFile;
IOSink? _bufferSink;
Timer? _segmentTimer;
String? _currentChannelId;
DateTime? _recordingStartTime;

@override
Future<void> startClientBuffer(String channelId, Duration duration) async {
  _currentChannelId = channelId;
  _recordingStartTime = DateTime.now();
  
  final tempDir = await getTemporaryDirectory();
  _bufferFile = File('${tempDir.path}/timeshift_${channelId}_${DateTime.now().millisecondsSinceEpoch}.ts');
  _bufferSink = _bufferFile!.openWrite();
  
  _segmentTimer = Timer.periodic(const Duration(seconds: 30), (_) {
    await _createNewSegment(channelId, duration);
  });
}

Future<void> _createNewSegment(String channelId, Duration maxDuration) async {
  await _bufferSink?.close();
  
  final tempDir = await getTemporaryDirectory();
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  _bufferFile = File('${tempDir.path}/timeshift_${channelId}_$timestamp.ts');
  _bufferSink = _bufferFile!.openWrite();
  
  await _cleanupOldSegments(channelId, maxDuration);
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/live/domain/repositories/timeshift_manager_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/features/live/domain/repositories/timeshift_manager.dart test/features/live/domain/repositories/timeshift_manager_test.dart
git commit -m "feat(timeshift): implement startClientBuffer"
```

---

### Task 4: 實作 TimeshiftManagerImpl.stopClientBuffer()

**Files:**
- Modify: `lib/features/live/domain/repositories/timeshift_manager.dart`

- [ ] **Step 1: 寫失敗測試**

```dart
test('停止錄製後清理檔案', () async {
  await manager.startClientBuffer('channel_1', const Duration(minutes: 30));
  await Future.delayed(const Duration(seconds: 2));
  await manager.stopClientBuffer();
  
  final tempDir = await Directory.systemTemp.list().toList();
  final tsFiles = tempDir.where((f) => f.path.contains('timeshift_channel_1'));
  expect(tsFiles.isEmpty, isTrue);
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/live/domain/repositories/timeshift_manager_test.dart`
Expected: FAIL

- [ ] **Step 3: 實作 stopClientBuffer**

```dart
@override
Future<void> stopClientBuffer() async {
  _segmentTimer?.cancel();
  _segmentTimer = null;
  
  await _bufferSink?.close();
  _bufferSink = null;
  
  if (_currentChannelId != null) {
    final tempDir = await getTemporaryDirectory();
    final files = await tempDir.list().toList();
    for (final file in files) {
      if (file.path.contains('timeshift_${_currentChannelId}')) {
        await file.delete();
      }
    }
  }
  
  _currentChannelId = null;
  _bufferFile = null;
  _recordingStartTime = null;
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/live/domain/repositories/timeshift_manager_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/features/live/domain/repositories/timeshift_manager.dart
git commit -m "feat(timeshift): implement stopClientBuffer cleanup"
```

---

### Task 5: 實作緩衝上限自動淘汰邏輯

**Files:**
- Modify: `lib/features/live/domain/repositories/timeshift_manager.dart`

- [ ] **Step 1: 寫失敗測試**

```dart
test('達到上限時淘汰舊段落', () async {
  await manager.startClientBuffer('channel_1', const Duration(minutes: 1));
  await Future.delayed(const Duration(minutes: 2));
  
  final tempDir = await Directory.systemTemp.list().toList();
  final tsFiles = tempDir.where((f) => f.path.contains('timeshift_channel_1')).toList();
  expect(tsFiles.length, lessThanOrEqualTo(3));
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/live/domain/repositories/timeshift_manager_test.dart`
Expected: FAIL

- [ ] **Step 3: 實作 _cleanupOldSegments**

```dart
Future<void> _cleanupOldSegments(String channelId, Duration maxDuration) async {
  final tempDir = await getTemporaryDirectory();
  final files = await tempDir.list().toList();
  final tsFiles = files
      .where((f) => f.path.contains('timeshift_$channelId') && f.path.endsWith('.ts'))
      .toList();
  
  tsFiles.sort((a, b) => a.path.compareTo(b.path));
  
  final maxSegments = (maxDuration.inSeconds / 30).ceil();
  
  if (tsFiles.length > maxSegments) {
    final toDelete = tsFiles.take(tsFiles.length - maxSegments);
    for (final file in toDelete) {
      await file.delete();
    }
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/live/domain/repositories/timeshift_manager_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/features/live/domain/repositories/timeshift_manager.dart
git commit -m "feat(timeshift): implement segment cleanup for buffer limit"
```

---

### Task 6: 實作 getBufferedStream()

**Files:**
- Modify: `lib/features/live/domain/repositories/timeshift_manager.dart`

- [ ] **Step 1: 寫失敗測試**

```dart
test('回看播放從正確位置開始', () async {
  await manager.startClientBuffer('channel_1', const Duration(minutes: 5));
  await Future.delayed(const Duration(seconds: 5));
  
  final file = manager.getBufferedStream('channel_1', Duration.zero);
  expect(file, isNotNull);
  expect(await file!.exists(), isTrue);
});
```

- [ ] **Step 2: Run test to verify it fails**

- [ ] **Step 3: 實作 getBufferedStream 和分段追蹤**

需要維護分段時間戳列表來找到對應 offset 的分段檔案。

- [ ] **Step 4: Run test to verify it passes**

- [ ] **Step 5: Commit**

---

### Task 7: 整合 LiveStore 與時移播放

**Files:**
- Modify: `lib/features/live/presentation/providers/live_store.dart`

- [ ] **Step 1: 在 playChannel 中呼叫 startClientBuffer**

```dart
Future<void> playChannel(IptvChannel channel) async {
  final bufferDuration = _settingsStore.state.timeshiftBufferDuration;
  await _timeshiftManager.startClientBuffer(channel.id, Duration(minutes: bufferDuration));
  // ... existing playback logic
}
```

- [ ] **Step 2: 實作 timeshiftMode 切換邏輯**

- [ ] **Step 3: Run tests**

- [ ] **Step 4: Commit**

---

### Task 8: Timeshift BDD E2E 測試

**Files:**
- Create: `test/bdd/features/live_timeshift.feature`
- Create: `test/features/live/live_timeshift_bdd_test.dart`

- [ ] **Step 1: 撰寫 Gherkin 場景**

```gherkin
Feature: 直播時移功能
  Scenario: 用戶觀看直播並回看過去內容
    Given 用戶正在觀看直播頻道
    When 用戶拖曳時間軸到 10 分鐘前
    Then 播放器從緩衝播放過去的內容
    And 畫面顯示「回看中」

  Scenario: 緩衝已滿，舊內容被淘汰
    Given 緩衝已達到設定的上限
    When 用戶嘗試拖曳到更早的時間
    Then 時間軸停在最舊的可用片段

  Scenario: 用戶回到直播
    Given 用戶正在觀看回看內容
    When 用戶點擊「直播中」按鈕
    Then 播放器回到即時直播
```

- [ ] **Step 2: 實作 BDD step definitions**

- [ ] **Step 3: Run BDD tests**

- [ ] **Step 4: Commit**

---

## Phase 2: YouTube 整合

---

### Task 9: 新增 YouTube 資料模型

**Files:**
- Create: `lib/features/youtube/domain/models/youtube_video.dart`
- Create: `test/features/youtube/domain/models/youtube_video_test.dart`

- [ ] **Step 1: 寫失敗測試**

```dart
test('從 JSON 正確解析', () {
  final json = {
    'id': 'youtube_abc123',
    'title': 'Test Video',
    'thumbnail': 'https://example.com/thumb.jpg',
    'duration': '10:30',
    'url': 'https://example.com/stream.m3u8',
  };
  
  final video = YoutubeVideo.fromJson(json);
  expect(video.id, 'youtube_abc123');
  expect(video.title, 'Test Video');
});
```

- [ ] **Step 2: Run test to verify it fails**

- [ ] **Step 3: 實作 YoutubeVideo 和 YoutubeCategory 模型**

- [ ] **Step 4: Run test to verify it passes**

- [ ] **Step 5: Commit**

---

### Task 10: 新增 ApiClient YouTube 方法

**Files:**
- Modify: `lib/core/api/api_client.dart`
- Modify: `lib/core/api/luna_client.dart`
- Modify: `lib/core/api/mock_client.dart`

**Interfaces:**
- Produces: `getYoutubeRecommend()`, `getYoutubeList(category, page)`, `getYoutubeCategories()`

- [ ] **Step 1: 在 ApiClient 介面新增方法**

```dart
Future<List<YoutubeVideo>> getYoutubeRecommend();
Future<List<YoutubeVideo>> getYoutubeList(String categoryId, {String? page});
Future<List<YoutubeCategory>> getYoutubeCategories();
```

- [ ] **Step 2: 在 LunaClient 實作**

```dart
@override
Future<List<YoutubeVideo>> getYoutubeRecommend() async {
  final response = await _dio.get('/api/youtube/recommend');
  final data = response.data as Map<String, dynamic>;
  return (data['videos'] as List)
      .map((v) => YoutubeVideo.fromJson(v as Map<String, dynamic>))
      .toList();
}
// ... getYoutubeList, getYoutubeCategories similar
```

- [ ] **Step 3: 在 MockApiClient 實作 mock 資料**

- [ ] **Step 4: Run tests**

- [ ] **Step 5: Commit**

---

### Task 11: 新增 YoutubeStore

**Files:**
- Create: `lib/features/youtube/presentation/providers/youtube_store.dart`
- Create: `test/features/youtube/presentation/providers/youtube_store_test.dart`

- [ ] **Step 1: 實作 YoutubeState 和 YoutubeStore**

```dart
enum YoutubeStatus { initial, loading, loaded, error }

class YoutubeState {
  final YoutubeStatus status;
  final List<YoutubeVideo> recommendVideos;
  final List<YoutubeCategory> categories;
  final Map<String, List<YoutubeVideo>> videosByCategory;
  final String? selectedCategoryId;
  final String? error;
  // ...
}

class YoutubeStore extends StateNotifier<YoutubeState> {
  YoutubeStore(this._apiClient);
  final ApiClient _apiClient;
  
  Future<void> loadRecommend() async {...}
  Future<void> loadCategories() async {...}
  Future<void> selectCategory(String categoryId) async {...}
}

final youtubeStoreProvider = StateNotifierProvider<YoutubeStore, YoutubeState>
```

- [ ] **Step 2: 寫並執行測試**

- [ ] **Step 3: Commit**

---

### Task 12: 新增首頁 YouTube 專區 Widget

**Files:**
- Create: `lib/features/youtube/presentation/widgets/youtube_section.dart`
- Modify: `lib/features/home/presentation/screens/home_screen.dart`

- [ ] **Step 1: 實作 YoutubeSection widget**

```dart
class YoutubeSection extends StatelessWidget {
  const YoutubeSection({super.key, required this.videos});
  final List<YoutubeVideo> videos;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('YouTube', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(width: 8),
            Icon(Icons.play_circle_fill, color: Theme.of(context).colorScheme.primary),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: videos.length,
            itemBuilder: (context, index) => VideoCard(video: videos[index]),
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 2: 在 HomeScreen 整合**

- [ ] **Step 3: Run tests**

- [ ] **Step 4: Commit**

---

### Task 13: 新增分類頁 YouTube 類別

**Files:**
- Modify: `lib/features/category/category_screen.dart`
- Create: `lib/features/youtube/presentation/screens/youtube_category_screen.dart`

- [ ] **Step 1: 在分類網格新增 YouTube 卡片**

- [ ] **Step 2: 實作 YoutubeCategoryScreen**

- [ ] **Step 3: Run flutter analyze**

- [ ] **Step 4: Commit**

---

### Task 14: YouTube 播放整合

**Files:**
- Modify: `lib/features/player/player_store.dart`

- [ ] **Step 1: 新增 playYoutubeVideo 方法**

```dart
Future<void> playYoutubeVideo(YoutubeVideo video) async {
  await playVideo(
    videoId: video.id,
    title: video.title,
    thumbnail: video.thumbnail,
    sources: [VideoSource(url: video.streamUrl, name: 'YouTube')],
    autoSelectSource: false,
  );
}
```

- [ ] **Step 2: Run tests**

- [ ] **Step 3: Commit**

---

### Task 15: YouTube BDD E2E 測試

**Files:**
- Create: `test/bdd/features/youtube.feature`
- Create: `test/e2e/flows/youtube_flow_test.dart`

- [ ] **Step 1: 撰寫並實作 Gherkin 場景**

- [ ] **Step 2: Run E2E tests**

- [ ] **Step 3: Commit**

---

## 最終驗證

- [ ] `flutter analyze` 無錯誤
- [ ] 所有單元測試通過
- [ ] 所有 BDD 測試通過
- [ ] E2E 測試通過
