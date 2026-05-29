# Favorites Sync Feature Design

**日期**: 2026-05-29
**功能**: 收藏同步（完整雙向同步）
**方法論**: TDD + BDD

---

## 1. 概述

實現完整的收藏同步系統，使用 Remote-first 策略：
- 從 LunaTV 拉取遠端收藏
- 本地上傳新增/刪除
- 本地新增/刪除時同步到 LunaTV
- 未登入時禁用 UI

---

## 2. 架構

```
┌─────────────────────────────────────────────────────────────┐
│                      FavoritesSyncFeature                    │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐    ┌──────────────┐    ┌───────────────┐   │
│  │   UI Layer  │───▶│FavoritesStore│───▶│FavoritesService│  │
│  │(Player/Detail│    │  (Riverpod)  │    │   (Facade)    │  │
│  │ Search/Sync)│    └──────────────┘    └───────┬───────┘  │
│  └─────────────┘                                  │          │
│                                                   ▼          │
│                              ┌────────────────────────────┐ │
│                              │  同步策略 (Remote-first)  │ │
│                              └────────────────────────────┘ │
│                                    │           │             │
│                           ┌────────┘           └────────┐   │
│                           ▼                            ▼     │
│              ┌────────────────────┐  ┌─────────────────────┐│
│              │FavoritesRemoteService│  │FavoritesLocalService││
│              │   (LunaTV API)      │  │   (SharedPrefs)    ││
│              └────────────────────┘  └─────────────────────┘│
└─────────────────────────────────────────────────────────────┘
```

---

## 3. API 端點

| 操作 | API | 說明 |
|------|-----|------|
| 獲取收藏 | `GET /favorites` | 需要登入 |
| 新增收藏 | `POST /favorites` | 需要登入，body: `{id, type}` |
| 刪除收藏 | `DELETE /favorites/{id}` | 需要登入 |
| 同步 | `POST /favorites/sync` | 雙向同步端點 |

---

## 4. 資料模型

```dart
class FavoriteItem {
  final String id;
  final String title;
  final String posterUrl;
  final String type; // movie, series, anime, variety
  final bool isAvailable;
  final DateTime addedAt;
  final bool isSynced;
}
```

---

## 5. 狀態管理

```dart
class FavoritesState {
  final List<FavoriteItem> items;
  final bool isLoading;
  final bool isSyncing;
  final String? error;
  final bool isGridView;
  final String filterType; // all, movie, series, anime, variety
  final DateTime? lastSyncedAt;
}
```

---

## 6. 同步流程 (Remote-first)

```
用戶觸發同步
       │
       ▼
┌──────────────────┐
│ 檢查登入狀態      │
└────────┬─────────┘
         │
    未登入─→顯示提示對話框，禁用 UI
         │
        已登入
         │
         ▼
┌──────────────────┐
│ 從 LunaTV 拉取    │◀── /favorites (GET)
│ 遠端收藏列表      │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ 與本地收藏合併    │──→ 保留所有項目（去重）
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ 更新本地存儲      │──→ SharedPreferences
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ 更新 UI 狀態      │
└──────────────────┘
```

---

## 7. UI 整合點

| 頁面 | 收藏按鈕位置 | 行為 |
|------|-------------|------|
| **播放器** | 控制欄右侧 | 點擊新增/移除 |
| **詳情頁** | 右上角工具列 | 點擊新增/移除 |
| **搜尋結果** | 每個結果卡片 | 點擊新增/移除 |
| **收藏頁** | 頂部工具列 | [同步] 按鈕 + 時間顯示 |

---

## 8. 未登入處理

- **收藏按鈕**：在 player/detail/search 頁面隱藏或顯示為禁用狀態
- **嘗試操作**：如果用戶點擊被禁用的按鈕，顯示「請先登入」對話框

---

## 9. 測試策略 (TDD + BDD)

### Unit Tests
- FavoriteItem 模型驗證
- Sync 邏輯、去重演算法
- Store 狀態轉換

### Integration Tests
- API 呼叫（Mock LunaTV）
- 本地存儲讀寫
- Store 與 Service 整合

### BDD Tests
- 完整 user flows：
  1. 登入 → 自動同步 → 查看收藏
  2. 登入 → 手動同步 → 新增項目 → 刪除項目
  3. 未登入 → 嘗試收藏 → 顯示提示
  4. 離線 → 本地新增 → 恢復網路 → 同步

---

## 10. 實現順序

1. **Phase 1**: 補全現有框架（Service、Store 的實際實作）
2. **Phase 2**: API 整合（LunaTV /favorites 端點）
3. **Phase 3**: 同步邏輯（Remote-first + 合併策略）
4. **Phase 4**: UI 整合（播放器、詳情、搜尋頁的收藏按鈕）
5. **Phase 5**: BDD 測試驗證

---

*文件版本: v1.0 — 收藏同步功能設計*