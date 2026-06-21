# whiteTV 功能實作規格：時移播放 + Tab 自訂

**日期**: 2026-06-21
**版本**: v1.0
**功能**: 時移播放 (Timeshift) + Tab 導航自訂

---

## 1. 時移播放功能

### 1.1 功能描述

支援兩種時移機制，優先使用服務端時移，不支援時 fallback 到用戶端緩存。

### 1.2 架構

```
LivePlayerScreen
├── TimeshiftManager (interface)
│   ├── TimeshiftServiceAdapter (服務端時移)
│   │   └── LunaTV API: /iptv/timeshift?start=&end=
│   └── TimeshiftClientBuffer (用戶端時移 fallback)
│       └── 本地 HLS 片段緩存
└── TimeshiftControlBar (UI)
```

### 1.3 雙層時移策略

| 層級 | 優先級 | 實作 | 說明 |
|------|--------|------|------|
| **服務端** | P0 | `TimeshiftServiceAdapter` | 呼叫 LunaTV API 回看已錄製內容 |
| **用戶端** | P1 (fallback) | `TimeshiftClientBuffer` | 本地緩存最近 30 分鐘內容 |

### 1.4 API 端點

```dart
// 服務端時移
GET /iptv/timeshift?channel_id={id}&start={timestamp}&end={timestamp}
Response: HLS stream URL

// 用戶端時移（自動偵測）
POST /iptv/buffer/start  // 開始緩存
GET  /iptv/buffer/status // 查詢緩存狀態
GET  /iptv/buffer/{id}   // 取得緩存串流
```

### 1.5 TimeshiftManager 介面擴展

```dart
abstract interface class TimeshiftManager {
  // 現有方法保留
  Future<TimeshiftController> startTimeshift({...});
  Future<void> pause();
  Future<void> resume();
  Future<Duration> seek(Duration position);
  Future<Duration> fastForward(Duration duration);
  Future<Duration> rewind(Duration duration);
  Future<void> stopTimeshift();
  bool get isTimeshiftActive;
  Duration get maxTimeshiftDuration;
  Future<TimeshiftState> getState();

  // 新增方法
  Future<bool> isServiceSideSupported(String channelId);
  Future<String?> getServiceSideStream(String channelId, Duration startOffset, Duration endOffset);
  Future<void> startClientBuffer(String channelId, Duration duration);
  Future<void> stopClientBuffer();
}
```

### 1.6 UI 元件

#### TimeshiftControlBar

```
┌─────────────────────────────────────────────────────┐
│  ◀ 18:00  ━━━━━━━●━━━━━━━━━━━━━━━━  ▶ 19:30  [直播中] │
│         [拖曳時間軸回看]                              │
└─────────────────────────────────────────────────────┘
```

**狀態顯示**:
- `[直播中 ●]` — 正在觀看直播
- `[時移 ◀ 19:30]` — 正在回看 19:30 的內容
- `[緩存中... ◀]` — 用戶端緩存模式

**按鈕功能**:
- ◀/▶ — 快退/快進 30 秒
- 拖曳時間軸 — 任意時間點回看
- 點擊 `[直播中]` — 回到直播

### 1.7 單元測試

```dart
group('TimeshiftManager', () {
  test('服務端支援時優先使用服務端時移', () async {...});
  test('服務端不支援時 fallback 到用戶端緩存', () async {...});
  test('時移進度正確計算', () async {...});
  test('緩存容量限制 30 分鐘', () async {...});
});
```

### 1.8 BDD 測試情境

```gherkin
Feature: 直播時移功能
  Scenario: 用戶觀看直播時想回看之前的內容
    Given 用戶正在觀看 CCTV-1 直播
    When 用戶點擊時間軸向左拖曳到 19:00
    Then 播放器開始播放 19:00 的內容
    And 顯示 "[時移 ◀ 19:00]"

  Scenario: 服務端不支援時使用本地緩存
    Given 用戶正在觀看直播
    And 服務端時移 API 回應 404
    When 用戶嘗試時移
    Then 系統使用本地緩存播放
    And 顯示 "[緩存中... ◀]"

  Scenario: 用戶想回到直播
    Given 用戶正在觀看時移內容
    When 用戶點擊 [直播中] 按鈕
    Then 播放器回到直播串流
```

---

## 2. Tab 導航自訂功能

### 2.1 功能描述

允許用戶自訂 TV 頂部導航 Tab 的顯示順序，並可獨立開關每個 Tab 的可見性。

### 2.2 資料模型

```dart
class TabConfig {
  final String id;           // 'home', 'category', 'live', 'search', 'favorites', 'settings'
  final String label;        // 顯示名稱
  final bool isVisible;      // 是否顯示
  final int order;           // 排序順序

  const TabConfig({
    required this.id,
    required this.label,
    this.isVisible = true,
    this.order = 0,
  });
}

class TabNavigationConfig {
  final List<TabConfig> tabs;
  final bool useCustomOrder;

  const TabNavigationConfig({
    required this.tabs,
    this.useCustomOrder = true,
  });
}
```

### 2.3 預設 Tab 設定

| ID | 標籤 | 預設顯示 | 預設順序 |
|----|------|----------|----------|
| home | 首頁 | ✅ | 0 |
| category | 分類 | ✅ | 1 |
| live | 直播 | ✅ | 2 |
| search | 搜尋 | ✅ | 3 |
| favorites | 收藏 | ✅ | 4 |
| settings | 設定 | ✅ | 5 |

### 2.4 UI 元件

#### TabSettingsScreen

```
┌─────────────────────────────────────────────────────────┐
│  設定                                    user@example.com │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ▼ Tab 導航設定                                          │
│                                                          │
│  拖曳排序                                                │
│  ┌──────────────────────────────────────────────────┐ │
│  │ ≡ 首頁              [👁 顯示]                      │ │
│  ├──────────────────────────────────────────────────┤ │
│  │ ≡ 分類              [👁 顯示]                      │ │
│  ├──────────────────────────────────────────────────┤ │
│  │ ≡ 直播              [👁 顯示]                      │ │
│  ├──────────────────────────────────────────────────┤ │
│  │ ≡ 搜尋              [👁 隱藏]                      │ │
│  ├──────────────────────────────────────────────────┤ │
│  │ ≡ 收藏              [👁 顯示]                      │ │
│  └──────────────────────────────────────────────────┘ │
│                                                          │
│  💡 提示：長按拖曳圖標可調整 Tab 順序                    │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

### 2.5 實作細節

#### ReorderableTabList

```dart
class ReorderableTabList extends StatelessWidget {
  final List<TabConfig> tabs;
  final Function(int oldIndex, int newIndex) onReorder;
  final Function(String id, bool isVisible) onToggleVisibility;

  // 使用 ReorderableListView 實作拖曳
  // 支援長按開始拖曳
  // 拖曳時顯示視覺化回饋
}
```

#### TabNavigationStore

```dart
class TabNavigationStore extends ChangeNotifier {
  List<TabConfig> _tabs = defaultTabs;

  List<TabConfig> get visibleTabs =>
      _tabs.where((t) => t.isVisible).toList()
        ..sort((a, b) => a.order.compareTo(b.order));

  void toggleVisibility(String id) {...}
  void reorder(int oldIndex, int newIndex) {...}
  Future<void> saveConfig() {...}
  Future<void> loadConfig() {...}
}
```

### 2.6 單元測試

```dart
group('TabNavigationStore', () {
  test('只返回可見且排序後的 Tab', () {
    // 隱藏一個 Tab，確認不出現在 visibleTabs
  });

  test('拖曳重新排序正確更新 order', () {
    // 交換兩個 Tab 的位置，確認 order 正確更新
  });

  test('隱藏 Tab 後該 Tab 不顯示在導航', (...));
});
```

### 2.7 BDD 測試情境

```gherkin
Feature: Tab 導航自訂
  Scenario: 用戶隱藏不使用的 Tab
    Given 用戶打開設定頁
    When 用戶點擊 "搜尋" Tab 的隱藏按鈕
    Then 導航列不再顯示 "搜尋" Tab
    And 設定被自動儲存

  Scenario: 用戶調整 Tab 順序
    Given 用戶打開設定頁
    When 用戶長按 "收藏" Tab 並拖曳到第二位
    Then 導航列第二位顯示 "收藏"
    And 設定被自動儲存

  Scenario: 用戶還原預設設定
    Given 用戶已自訂 Tab 設定
    When 用戶點擊 "還原預設"
    Then 所有 Tab 回到預設順序和顯示狀態
```

---

## 3. 實作順序

### Phase 1: 時移播放
1. 擴展 `TimeshiftManager` 介面
2. 實作 `TimeshiftServiceAdapter`
3. 實作 `TimeshiftClientBuffer` fallback
4. 更新 `TimeshiftControlBar` UI
5. 單元測試 + BDD 測試

### Phase 2: Tab 自訂
1. 實作 `TabConfig` 資料模型
2. 實作 `TabNavigationStore`
3. 實作 `ReorderableTabList` widget
4. 更新 `SettingsScreen` 整合新設定
5. 單元測試 + BDD 測試

---

## 4. 測試覆蓋要求

| 功能 | 單元測試 | BDD 測試 |
|------|----------|----------|
| 時移播放 | 8+ | 6+ |
| Tab 自訂 | 6+ | 4+ |

---

*規格版本: v1.0 — 2026-06-21*
