# P0 Gap Fill Design — 首頁區塊開關、來源狀態徽章、播放進度儲存

**日期**: 2026-06-20
**範圍**: 補齊 ARCHITECTURE.md P0 規格中已實作但未對齊 UI_UX.md 的功能缺口
**方式**: TDD + BDD 驗證

---

## 1. 首頁區塊顯示開關

### 規格 (UI_UX §3.2)
> 用戶可在設定中開關各區塊顯示。

### 現狀
- `SettingsState.homeBlocks` 欄位已存在（`Map<String, bool>`）
- `SettingsStorageService` 已有 `getHomeBlocks`/`saveHomeBlocks`
- `HomeScreen` **完全未讀取** `homeBlocks`，所有區塊固定顯示

### 設計

#### 1.1 HomeScreen 讀取 homeBlocks

`HomeScreen` 透過 `ref.watch(settingsStoreProvider)` 取得 `homeBlocks`，用 `homeBlocks[sectionId] ?? true` 條件渲染各區塊。

區塊 ID 對應：
- `recent_watch` → 最近觀看
- `live_entry` → 直播入口（預留，尚未實作）
- `recommend` → 為你推薦
- `categories` → 分類內容

#### 1.2 SettingsScreen 區塊開關 UI

設定頁新增「首頁區塊」子頁面，顯示 toggle 開關。每個開關變更即時透過 `settingsStore.updateHomeBlocks()` 持久化。

### 涉及檔案
- `lib/features/home/home_screen.dart` — 讀取 homeBlocks，條件渲染
- `lib/features/settings/settings_screen.dart` — 新增區塊開關入口
- `lib/features/settings/widgets/home_blocks_settings.dart` — 新增子頁面

### BDD 驗證
- 首頁區塊開關關閉時，對應區塊不顯示
- 首頁區塊開關開啟時，對應區塊顯示
- 區塊設定持久化，重啟後保留

---

## 2. 來源狀態徽章 + TV 列表式佈局

### 規格 (UI_UX §10.2, §10.5)
> TV 模式直接列出所有可用來源（不使用下拉選單）
> 顯示延遲時間（ms）、顯示該來源的集數、當前自動選擇的來源標記 [自動]
> 來源狀態：可用🟢/測試中🟡/不可用

### 現狀
- `DetailScreen._buildSourceSelector` 使用 `Wrap` + `GlassCard` chips
- 只顯示 `name (latency ms)`
- TV 和 Mobile 共用同一個來源選擇器

### 設計

#### 2.1 資料模型擴充

`VideoSource` 已有 `latency` 和 `isAvailable`。新增測試中狀態 enum：

```dart
enum SourceStatus { available, testing, unavailable }

extension SourceStatusX on VideoSource {
  SourceStatus get status {
    if (!isAvailable) return SourceStatus.unavailable;
    if (latency == 0) return SourceStatus.testing;
    return SourceStatus.available;
  }
}
```

#### 2.2 TV 列表式來源選擇器

TV 模式改為垂直列表卡片，每行：狀態圖示 + 名稱 + 延遲 + 集數 + [自動] 標記

#### 2.3 Mobile 下拉式維持

Mobile 模式維持 `Wrap` chips，加入狀態圖示和延遲。

#### 2.4 來源測速觸發

`DetailScreen` 載入時，若 `autoSelectSource` 為 true，背景觸發 `SourceSelector.speedTest()`，測速期間顯示 🟡。

### 涉及檔案
- `lib/core/api/models.dart` — 新增 `SourceStatus` enum + extension
- `lib/features/detail/detail_screen.dart` — TV/Mobile 分離的來源選擇器
- `lib/features/detail/detail_store.dart` — 新增 `testAndSelectSource()` 方法

### BDD 驗證
- TV 模式顯示列表式來源選擇器
- 可用來源顯示🟢圖示和延遲
- 不可用來源顯示🔴圖示
- 測試中來源顯示🟡圖示
- 自動選擇的來源顯示 [自動] 標記

---

## 3. 播放進度儲存

### 規格 (ARCHITECTURE §7.2)
> 進度控制：播放進度儲存

### 現狀
- `PlayerStore` 無進度持久化邏輯
- `HistoryService` 有 `PlayHistory` model（含 `position` 欄位）但未在播放器中使用

### 設計

#### 3.1 進度儲存服務

新增 `PlaybackProgressService`：

```dart
class PlaybackProgressService {
  /// 儲存播放進度（節流，每10秒最多一次）
  Future<void> saveProgress(String videoId, String sourceId,
      int episodeNumber, Duration position, Duration totalDuration);

  /// 載入上次播放進度
  PlayHistory? loadProgress(String videoId, int episodeNumber);

  /// 刪除進度（看完時）
  Future<void> deleteProgress(String videoId, int episodeNumber);
}
```

#### 3.2 PlayerStore 整合

- `PlayerStore` 在 `position` 變更時，透過節流機制每 10 秒呼叫 `saveProgress()`
- 進入播放頁時，`loadProgress()` 取得上次進度，自動跳轉
- 播放完畢（進度 > 95%）時，`deleteProgress()` 清除記錄

### 涉及檔案
- `lib/features/player/services/playback_progress_service.dart` — 新增
- `lib/features/player/player_store.dart` — 整合進度儲存
- `lib/features/player/player_screen.dart` — 自動跳轉到上次進度

### BDD 驗證
- 播放進度每 10 秒自動儲存
- 重新開啟影片時自動跳轉到上次進度
- 播放完畢（>95%）後清除進度
- 進度條正確顯示觀看百分比

---

## 實作順序

1. **首頁區塊開關** — 改動最小，已有資料結構
2. **來源狀態徽章** — 核心 UI 體驗改進
3. **播放進度儲存** — 新增服務層

每項均遵循 TDD：先寫單元測試 → 實作 → BDD 驗證場景測試。