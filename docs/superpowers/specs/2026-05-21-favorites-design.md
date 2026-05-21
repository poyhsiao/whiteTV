# Favorites 功能設計規格 (v1.0)

**專案**: whiteTV 跨平台影視串流客戶端
**功能**: 收藏列表管理
**版本**: v1.0
**最後更新**: 2026-05-21

---

## 1. 概述

### 1.1 功能目標

實現用戶收藏內容管理，支援：
- 收藏/取消收藏
- 本地優先 + LunaTV 背景同步
- 網格/列表視圖切換
- 類型篩選
- 「已下架」狀態處理

### 1.2 實作方式

**本地優先 + 背景同步**：
- 所有操作先在本地執行
- 背景任務與 LunaTV API 同步
- 同步衝突時以伺服器數據為準
- 啟動時自動同步一次

---

## 2. 架構設計

### 2.1 目錄結構

```
lib/features/favorites/
├── data/
│   └── models/
│       └── favorite_item.dart          # 收藏項目資料模型
├── domain/
│   ├── models/
│   │   └── favorites_state.dart        # UI 狀態模型
│   ├── repositories/
│   │   └── favorites_repository.dart   # 抽象介面
│   └── services/
│       └── favorites_service.dart      # Facade 服務
├── presentation/
│   ├── providers/
│   │   └── favorites_store.dart        # Riverpod StateNotifier
│   ├── screens/
│   │   └── favorites_screen.dart       # 收藏頁面
│   └── widgets/
│       ├── favorite_tile.dart          # 列表視圖項目
│       ├── favorite_grid.dart          # 網格視圖項目
│       └── favorites_filter_bar.dart   # 篩選列
├── services/
│   ├── favorites_local_service.dart    # 本地存儲實現
│   └── favorites_remote_service.dart   # LunaTV API 同步
test/features/favorites/
├── models/
│   └── favorite_item_test.dart
├── services/
│   ├── favorites_local_service_test.dart
│   └── favorites_remote_service_test.dart
├── stores/
│   └── favorites_store_test.dart
├── widgets/
│   ├── favorite_tile_test.dart
│   └── favorites_screen_test.dart
└── favorites_bdd_test.dart             # BDD 整合測試
```

### 2.2 依賴關係

```
FavoritesScreen
    │
    ├── FavoritesStore (Riverpod)
    │       │
    │       └── FavoritesService
    │               │
    │               ├── FavoritesLocalService
    │               │       └── AsyncStorage
    │               │
    │               └── FavoritesRemoteService
    │                       └── LunaTV API
    │
    ├── FavoritesFilterBar
    └── FavoriteTile / FavoriteGrid
```

---

## 3. 數據模型

### 3.1 FavoriteItem

```dart
class FavoriteItem {
  final String id;           // 內容唯一 ID
  final String title;        // 標題
  final String posterUrl;    // 海報 URL
  final String type;         // movie | series | anime | variety
  final bool isAvailable;    // false = 已下架
  final DateTime addedAt;    // 收藏時間

  const FavoriteItem({
    required this.id,
    required this.title,
    required this.posterUrl,
    required this.type,
    this.isAvailable = true,
    required this.addedAt,
  });

  FavoriteItem copyWith({...});
}
```

### 3.2 FavoritesState

```dart
class FavoritesState {
  final List<FavoriteItem> items;
  final bool isLoading;
  final String? error;
  final bool isGridView;           // true = 網格, false = 列表
  final String filterType;         // all | movie | series | anime | variety
  final bool isSyncing;

  const FavoritesState({...});

  List<FavoriteItem> get filteredItems => ...;
  List<FavoriteItem> get availableItems => ...;
  List<FavoriteItem> get unavailableItems => ...;
}
```

---

## 4. 服務層設計

### 4.1 FavoritesRepository（抽象介面）

```dart
abstract interface class FavoritesRepository {
  Future<List<FavoriteItem>> getAll();
  Future<void> add(FavoriteItem item);
  Future<void> remove(String id);
  Future<bool> isFavorite(String id);
  Future<void> sync();  // 與 LunaTV 同步
}
```

### 4.2 FavoritesLocalService

- 使用 `AsyncStorage` 持久化
- 讀寫緩存收藏列表
- 提供同步鉤子

### 4.3 FavoritesRemoteService

- 調用 LunaTV API `/favorites`
- 實現增量同步邏輯
- 衝突解決：伺服器優先

### 4.4 FavoritesService（Facade）

```dart
class FavoritesService {
  const FavoritesService({
    required FavoritesRepository repository,
  });

  final FavoritesRepository _repository;

  Future<void> addFavorite(FavoriteItem item) async {
    await _repository.add(item);
    _backgroundSync();
  }

  Future<void> removeFavorite(String id) async {
    await _repository.remove(id);
    _backgroundSync();
  }

  Future<void> syncWithServer() async {
    await _repository.sync();
  }

  Future<void> _backgroundSync() async {
    // 延後同步，不阻塞主執行緒
  }
}
```

---

## 5. UI/UX 設計（根據 UI_UX.md Section 5）

### 5.1 頁面結構

```
┌──────────────────────────────────────────────────┐
│  我的收藏                              [🔲列表]  │
├──────────────────────────────────────────────────┤
│  [全部] [電影] [劇集] [動漫] [綜藝]              │
├──────────────────────────────────────────────────┤
│  ┌────┐ ┌────┐ ┌────┐ ┌────┐                    │
│  │海報│ │海報│ │海報│ │海報│                    │
│  │    │ │    │ │    │ │    │                    │
│  └────┘ └────┘ └────┘ └────┘                    │
└──────────────────────────────────────────────────┘
```

### 5.2 組件設計

#### FavoritesScreen

- 頁面標題「我的收藏」
- 右上角視圖切換按鈕（列表/網格）
- 類型篩選橫向滾動列
- 內容區域（列表或網格）

#### FavoriteGrid

- 4 列網格佈局
- 每個項目顯示海報、標題、「已下架」標籤（如需要）

#### FavoriteTile

- 橫向列表佈局
- 左側海報、右側標題和類型
- 「已下架」狀態顯示

#### FavoritesFilterBar

- 橫向滾動篩選按鈕
- 當前選中狀態高亮

### 5.3 狀態處理

| 狀態 | UI |
|------|-----|
| 載入中 | 骨架屏 |
| 空收藏 | 空狀態插圖 + 「開始探索內容」|
| 同步中 | 頂部進度指示器 |
| 錯誤 | 錯誤提示 + 重試按鈕 |

---

## 6. TDD 工作流程

每個 Task 遵循：
```
1. Write FAILING test (RED)
2. Run test → verify FAIL
3. Write MINIMAL implementation (GREEN)
4. Run test → verify PASS
5. Refactor if needed (IMPROVE)
6. Run all tests → verify PASS
7. Commit with TDD message
```

---

## 7. BDD 整合測試

```gherkin
Scenario: 用戶進入收藏頁面
  Given 用戶已登入
  When 用戶點擊 "收藏" Tab
  Then 顯示收藏列表或空狀態

Scenario: 用戶收藏內容
  Given 用戶在詳情頁
  When 用戶點擊 "收藏" 按鈕
  Then 內容被添加到收藏
  And 顯示成功提示

Scenario: 用戶取消收藏
  Given 用戶在收藏頁面
  When 用戶長按項目
  Then 顯示刪除確認
  And 用戶確認後從收藏移除

Scenario: 內容已下架
  Given 用戶的收藏中有一項已下架
  When 用戶查看收藏列表
  Then 該項目顯示「已下架」狀態
  And 該項目可以長按刪除

Scenario: 視圖切換
  Given 用戶在收藏頁面
  When 用戶點擊右上角視圖按鈕
  Then 收藏列表在網格/列表視圖間切換
```

---

## 8. 實作順序

1. **FavoriteItem 模型** - Task 1
2. **FavoritesState 模型** - Task 2
3. **FavoritesRepository 介面** - Task 3
4. **FavoritesLocalService** - Task 4
5. **FavoritesRemoteService** - Task 5
6. **FavoritesService Facade** - Task 6
7. **FavoritesStore** - Task 7
8. **FavoriteTile Widget** - Task 8
9. **FavoriteGrid Widget** - Task 9
10. **FavoritesFilterBar Widget** - Task 10
11. **FavoritesScreen** - Task 11
12. **BDD 整合測試** - Task 12

---

*文件版本: v1.0 — Favorites 功能設計規格*