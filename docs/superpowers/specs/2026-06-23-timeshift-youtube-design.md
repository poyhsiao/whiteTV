# whiteTV 功能實作規格：時移（客戶端緩衝）+ YouTube 整合

**日期:** 2026-06-23
**版本:** v1.0
**功能:** 時移功能（客戶端緩衝）+ YouTube 整合
**開發方式:** TDD + BDD

---

## 1. 時移功能（客戶端緩衝）

### 1.1 功能說明

直播觀看時支援回看功能，透過在本地緩衝一段時間的串流資料，讓用戶可以拖曳時間軸回看過去的節目內容。

### 1.2 技術規格

| 項目 | 規格 |
|------|------|
| **緩衝模式** | 客戶端本地檔案緩衝 |
| **緩衝時長選項** | 15 分鐘 / 30 分鐘 / 60 分鐘（用戶可選） |
| **儲存位置** | `getTemporaryDirectory()`（App 暫存目錄） |
| **儲存格式** | MPEG-TS 分段檔案（每段 30 秒） |
| **最大磁碟佔用** | ~1GB（60 分鐘 @ 720p 估算） |

### 1.3 架構設計

```
TimeshiftManagerImpl (lib/features/live/domain/repositories/)
├── isServiceSideSupported() → false（維持現狀）
├── getServiceSideStream() → null（維持現狀）
├── startClientBuffer(channelId, Duration duration)
│   ├── 建立錄製分段（每段 30 秒 TS 檔）
│   ├── 持續錄製直到用戶停止或達到上限
│   └── 淘汰最舊的段落維持緩衝上限
├── stopClientBuffer()
│   └── 停止錄製，刪除暫存檔案
└── getBufferedStream(channelId, Duration offset)
    └── 回傳指定 offset 的串流檔案

TimeshiftMode (PlaybackState)
├── live    → 即時直播
├── buffer  → 回看模式（從緩衝播放）
└── service → 服務端（目前不使用，永遠返回 false）
```

### 1.4 UI 規格

使用現有 `timeshift_control_bar.dart` 元件：

```
┌──────────────────────────────────────────────────┐
│  ◀ 18:00  ▶ 19:30  [直播中 ●]                    │
│  ━━━━━━━●━━━━━━━━━━━━━━━━━━━                    │
│         可拖曳回看                               │
└──────────────────────────────────────────────────┘
```

- 直播中：顯示「直播中 ●」，時間軸為即時
- 回看中：顯示「回看中 ○」，時間軸可拖曳
- 拖曳極限：不能超過最舊的緩衝片段

### 1.5 設定頁

在「直播設定」新增：

```
直播回看緩衝時長
○ 15 分鐘
● 30 分鐘
○ 60 分鐘
```

### 1.6 單元測試（TDD）

```dart
// test/features/live/timeshift_manager_test.dart

group('TimeshiftManager - 客戶端緩衝', () {
  test('開始錄製後產生 TS 檔案', () async {
    // 預期：startClientBuffer() 後暫存目錄出現 TS 檔
  });

  test('達到上限時淘汰舊段落', () async {
    // 預期：錄製超過設定時長後，最舊的段落被刪除
  });

  test('回看播放從正確位置開始', () async {
    // 預期：getBufferedStream(offset) 回傳對應位置的串流
  });

  test('停止錄製後清理檔案', () async {
    // 預期：stopClientBuffer() 後暫存目錄被清空
  });

  test('設定值正確儲存和讀取', () async {
    // 預期：SettingsStore 中的 timeshiftBufferDuration 被正確保存
  });
});
```

### 1.7 BDD 測試情境

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
    And 顯示「超出緩衝範圍」

  Scenario: 用戶回到直播
    Given 用戶正在觀看回看內容
    When 用戶點擊「直播中」按鈕
    Then 播放器回到即時直播
```

---

## 2. YouTube 整合

### 2.1 功能說明

將 LunaTV API 的 YouTube 內容整合進 whiteTV，讓用戶可以在首頁和分類頁瀏覽和播放 YouTube 影片。

### 2.2 技術規格

| 項目 | 規格 |
|------|------|
| **資料來源** | LunaTV API (`/api/youtube/*`) |
| **播放方式** | media_kit 直接播放 YouTube HLS URL |
| **呈現位置** | 首頁 + 分類頁 |
| **卡片樣式** | 與現有影片海報卡片相同 |

### 2.3 API 規格（假設 LunaTV API 格式）

```
GET /api/youtube/recommend
Response: {
  "videos": [
    {
      "id": "youtube_xxx",
      "title": "標題",
      "thumbnail": "https://...",
      "duration": "10:30",
      "url": "https://YouTube-HLS-URL..."
    }
  ]
}

GET /api/youtube/list?category={categoryId}&page={page}
Response: {
  "videos": [...],
  "nextPage": "token"
}

GET /api/youtube/categories
Response: {
  "categories": [
    {"id": "trending", "name": "熱門影片"},
    {"id": "music", "name": "音樂"}
  ]
}
```

### 2.4 架構設計

```
lib/features/youtube/
├── domain/
│   ├── models/
│   │   └── youtube_video.dart
│   └── repositories/
│       └── youtube_repository.dart
├── data/
│   ├── youtube_api_client.dart
│   └── youtube_repository_impl.dart
└── presentation/
    ├── providers/
    │   └── youtube_store.dart
    ├── screens/
    │   └── (使用現有 components)
    └── widgets/
        └── youtube_section.dart (首頁專區 widget)
```

### 2.5 UI 規格

**首頁 YouTube 專區：**

```
為你推薦    YouTube  🎬
┌────┐ ┌────┐ ┌────┐ ┌────┐
│    │ │    │ │    │ │    │
│海報│ │海報│ │海報│ │海報│
│    │ │    │ │    │ │    │
└────┘ └────┘ └────┘ └────┘
```

**分類頁 YouTube 類別：**

在現有分類網格中新增：
```
┌──────────────────┐  ┌──────────────────┐
│                  │  │                  │
│      電影        │  │      電視劇      │
│                  │  │                  │
└──────────────────┘  └──────────────────┘

┌──────────────────┐  ┌──────────────────┐
│                  │  │                  │
│      YouTube     │  │      動漫        │
│        🎬        │  │                  │
└──────────────────┘  └──────────────────┘
```

**播放：**
- 使用現有 `PlayerScreen`，直接以 YouTube HLS URL 作為 source
- 控制列和功能與一般 VOD 相同

### 2.6 單元測試（TDD）

```dart
// test/features/youtube/youtube_store_test.dart

group('YoutubeStore', () {
  test('成功載入推薦影片', () async {
    // 預期：fetchRecommend() 回傳 YouTube 影片列表
  });

  test('網路錯誤時顯示空狀態', () async {
    // 預期：API 失敗時 state 為 error，UI 顯示重試按鈕
  });

  test('HLS URL 正確傳入 player', () async {
    // 預期：選擇影片後 playerStore 收到正確的 source URL
  });

  test('分類切換正確載入新列表', () async {
    // 預期：切換分類後正確載入新列表
  });
});
```

### 2.7 BDD 測試情境

```gherkin
Feature: YouTube 整合
  Scenario: 用戶在首頁瀏覽 YouTube 推薦
    Given 用戶在首頁
    Then 用戶看到 YouTube 專區
    And 顯示 YouTube 影片海報

  Scenario: 用戶點擊 YouTube 影片並播放
    Given 用戶在首頁 YouTube 專區
    When 用戶點擊某部影片
    Then 播放器開啟
    And 播放該 YouTube 影片

  Scenario: 用戶在分類頁瀏覽 YouTube 影片
    Given 用戶在分類頁
    When 用戶選擇 YouTube 類別
    Then 顯示 YouTube 影片列表
```

---

## 3. 實作順序

### Phase 1: 時移功能
1. 修改 `TimeshiftManagerImpl` 實作客戶端緩衝
2. 新增設定頁緩衝時長選項
3. 實作 UI 拖曳和播放邏輯
4. TDD + BDD 驗證

### Phase 2: YouTube 整合
1. 新增 LunaTV API YouTube endpoints 對接
2. 建立 `YoutubeStore` 和 `YoutubeRepository`
3. 新增首頁 YouTube 專區 widget
4. 新增分類頁 YouTube 類別
5. TDD + BDD 驗證

---

## 4. 檔案變動清單

### 時移功能
| 檔案 | 變動 |
|------|------|
| `lib/features/live/domain/repositories/timeshift_manager.dart` | 實作 startClientBuffer/stopClientBuffer |
| `lib/features/live/domain/repositories/timeshift_service_adapter.dart` | 新增緩衝設定存取 |
| `lib/features/settings/settings_store.dart` | 新增 timeshiftBufferDuration 欄位 |
| `lib/features/settings/presentation/screens/settings_screen.dart` | 新增緩衝時長設定 UI |
| `lib/features/live/presentation/providers/live_store.dart` | 整合時移播放邏輯 |
| `test/features/live/**/timeshift_*_test.dart` | 新增測試 |

### YouTube 整合
| 檔案 | 變動 |
|------|------|
| `lib/core/api/luna_client.dart` | 新增 YouTube API methods |
| `lib/features/youtube/` (新目錄) | 新增 domain/data/presentation 結構 |
| `lib/features/home/home_store.dart` | 整合 YouTube 推薦資料 |
| `lib/features/home/presentation/screens/home_screen.dart` | 新增 YouTube 專區 widget |
| `lib/features/category/category_screen.dart` | 新增 YouTube 類別入口 |
| `lib/features/player/player_store.dart` | 支援 YouTube HLS URL |
| `test/features/youtube/**/*_test.dart` | 新增測試 |
| `test/e2e/flows/youtube_*_test.dart` | 新增 E2E 測試 |

---

## 5. 風險與依賴

| 風險 | 影響 | 緩解 |
|------|------|------|
| LunaTV API 無 `/api/youtube/*` endpoints | YouTube 無法取資料 | 先以 mock data 實作，等 API 就緒 |
| 客戶端緩衝佔用大量磁碟 | 空間不足 | 設定上限，自動淘汰舊片段 |
| media_kit 不支援某些 YouTube URL 格式 | 播放失敗 | 先測試多種 URL 格式，做 fallback |

---

## 6. 完成標準

- [ ] 時移：設定緩衝時長後，直播可拖曳回看
- [ ] 時移：超過緩衝上限時自動淘汰舊片段
- [ ] 時移：停止回看後正確清理暫存檔案
- [ ] YouTube：首頁正確顯示 YouTube 專區
- [ ] YouTube：分類頁正確顯示 YouTube 類別
- [ ] YouTube：點擊 YouTube 影片可正常播放
- [ ] 所有功能 TDD 測試通過
- [ ] 所有功能 BDD E2E 測試通過
- [ ] `flutter analyze` 無錯誤

---

*規格版本: v1.0 — 2026-06-23*
