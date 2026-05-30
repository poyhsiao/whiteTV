# Category Browsing Feature Design

**日期**: 2026-05-30
**功能**: 分類瀏覽頁面
**版本**: v1.0

---

## 1. 路由與導航

```
路徑: /category/:categoryId
例如: /category/movie, /category/drama, /category/anime, /category/variety

從首頁分類列 →點擊進入該分類的內容頁
```

---

## 2. 頁面結構

### TV Mode

```
┌──────────────────────────────────────────────────┐
│  ← 分類                   電影          user@example.com│
├──────────────────────────────────────────────────┤
│  二級分類                                          │
│  [全部] [動作] [喜劇] [科幻] [愛情] [懸疑] [戰爭] [恐怖] │
├──────────────────────────────────────────────────┤
│  地區 + 年份  ▼ (折疊，點擊展開) │
├──────────────────────────────────────────────────┤
│  排序: [最近更新] [字母]                          │
│         (評分/播放量 因 API 不支援而隱藏)           │
├──────────────────────────────────────────────────┤
│  ┌────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐          │
│  │海報│ │海報│ │海報│ │海報│ │海報│          │
│  └────┘ └────┘ └────┘ └────┘ └────┘          │
└──────────────────────────────────────────────────┘
```

### Mobile Mode

```
┌──────────────────────────────────────────────────┐
│  ← 分類                    電影                   │
├──────────────────────────────────────────────────┤
│  ▼ 二級分類：[全部]                              │
│  ▼ 地區：[全部] │
│  ▼ 年份：[全部]                                  │
│  ▼ 排序：[最近更新 ▼] │
├──────────────────────────────────────────────────┤
│  ┌────┐ ┌────┐ ┌────┐ ┌────┐                │
│  │海報│ │海報│ │海報│ │海報│                │
│  └────┘ └────┘ └────┘ └────┘                │
└──────────────────────────────────────────────────┘
```

### 設計原則

- **混合模式**:預設顯示二級分類和排序，地區和年份折疊
- **TV 模式**: 水平晶片組（不用下拉選單）
- **Mobile模式**: 折疊式篩選（符合觸控操作）

---

## 3. 元件架構

```
lib/features/category/
├── category_screen.dart          # 主頁面（TV/Mobile 自動適配）
├── category_screen.tv.dart     # TV 版面
├── category_screen.mobile.dart # Mobile 版面
├── category_store.dart         # Riverpod store
├── widgets/
│   ├── category_filter_chips.dart # 二級分類 Chips
│   ├── region_filter.dart            # 地區/年份折疊區塊
│   ├── sort_selector.dart # 排序選擇器
│   └── video_grid.dart               # 影片網格
└── services/
    └── category_filter_service.dart   # 客戶端篩選邏輯
```

### 元件職責

| 元件 | 職責 |
|------|------|
| `CategoryScreen` | 根據設備類型渲染 TV/Mobile 版面 |
| `CategoryStore` | 管理分類資料、篩選狀態、排序 |
| `CategoryFilterChips` | 二級分類多選晶片 |
| `RegionFilter` | 地區/年份折疊展開 UI |
| `SortSelector` | 排序選項（隱藏不支援的評分/播放量） |
| `VideoGrid` | 橫向滾動網格（TV）或垂直網格（Mobile） |
| `CategoryFilterService` | 客戶端篩選：二級分類、地區、年份過濾 |

---

## 4. 資料流程與狀態管理

### CategoryStore狀態

```dart
class CategoryState {
  final Category category;           // 當前分類
  final List<Video> allVideos;     // API 回傳的所有影片（原列表）
  final List<Video> filteredVideos; //篩選後的影片
  final Set<String> selectedGenres;  // 選中的二級分類（多選）
  final String selectedRegion;       // 選中的地區
  final String selectedYear; // 選中的年份
  final SortOption sortOption;      // 排序選項
  final bool isLoading;
  final String? error;
}
```

###篩選流程

```
API 回傳影片
    ↓
CategoryStore.loadVideos()
    ↓
CategoryFilterService.filter() ← 客戶端篩選
    ├─ 根據 selectedGenres 過濾（二級分類，多選）
    ├─ 根據 selectedRegion 過濾（地區）
    ├─ 根據 selectedYear 過濾（年份）
    └─ 根據 sortOption 排序（只支援：最近更新、字母）
    ↓
filteredVideos 更新 → UI 自動刷新
```

### 為什麼 selectedGenres 用 Set（多選）？

因為二級分類可以多選，例如：用戶可以同時看「動作」+「科幻」的影片。

---

## 5. Video 模型擴展

**修改 `lib/core/api/models.dart`**：

```dart
class Video {
  // ...現有欄位 ...
  final String? year;  // 新增：用於年份篩選

  const Video({
    required this.id,
    required this.title,
    this.posterUrl,
    this.description,
    required this.categoryId,
    required this.type,
    this.year,  // 新增
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      // ...現有欄位 ...
      year: json['year'] as String?,  // 新增
    );
  }
}
```

### 說明

- 實際 LunaTV API 可能回傳 `year` 欄位
- 如果 API 沒有回傳，`fromJson` 會正常處理（變成 `null`）
- 年份篩選時，`null` 的影片會被排除

---

## 6. 固定篩選選項

### 二級分類（固定列表）

```
動作、喜劇、科幻、愛情、懸疑、戰爭、恐怖、動畫、劇情、記錄片
```

### 地區（固定列表）

```
全部、大陸、香港、台灣、日本、韓國、美國、歐洲
```

### 年份（固定列表）

```
全部、2024、2023、2022、2021、2020、2019、更早期
```

### 排序選項

| 選項 | 狀態 | 說明 |
|------|------|------|
| 最近更新 | ✅ 可用 | 客戶端排序（使用現有列表順序） |
| 字母 | ✅ 可用 | 按標題字母排序 |
| 評分 | ❌ 隱藏 | API 不支援 |
| 播放量 | ❌ 隱藏 | API 不支援 |

---

## 7. 測試策略 (TDD + BDD)

### 單元測試 (Unit Tests)

| 測試目標 | 驗證內容 |
|----------|----------|
| `CategoryFilterService` | 篩選邏輯正確（二級分類多選、地區過濾、年份過濾、排序） |
| `CategoryStore` | 狀態更新、載入流程、錯誤處理 |

### Widget測試 (Widget Tests)

| 測試目標 | 驗證內容 |
|----------|----------|
| `CategoryFilterChips` | 晶片點擊選中/取消、視覺狀態正確 |
| `RegionFilter` | 折疊/展開行為 |
| `SortSelector` | 排序選項切換 |

### BDD 測試 (BDD Tests)

| 場景 | 驗證流程 |
|------|----------|
| `category_browsing.feature` | 用戶進入分類 → 選擇二級分類 → 確認列表過濾 |
| `category_filter.feature` | 用戶展開地區/年份 → 選擇篩選條件 → 確認結果 |
| `category_sort.feature` | 用戶選擇排序 → 確認列表順序正確 |

### TDD 流程

```
1. 先寫 BDD feature 檔（描述行為）
2. 寫 failing unit test（CategoryFilterService）
3. 實作篩選邏輯（GREEN）
4. 寫 failing widget test
5. 實作 UI 元件（GREEN）
6. 重構 + 驗證覆蓋率 80%+
```

---

## 8. 實作任務清單

- [ ] 擴展 Video 模型（新增 `year` 欄位）
- [ ] 建立 CategoryStore（Riverpod）
- [ ] 建立 CategoryFilterService（客戶端篩選邏輯）
- [ ] 建立 CategoryScreen（含 TV/Mobile 版面）
- [ ] 建立 CategoryFilterChips 元件
- [ ] 建立 RegionFilter 元件
- [ ] 建立 SortSelector 元件
- [ ] 建立 VideoGrid 元件
- [ ] 實作 BDD feature檔
- [ ] 實作單元測試
- [ ] 實作 Widget 測試
- [ ] 驗證覆蓋率 80%+

---

*文件版本: v1.0 — 分類瀏覽功能設計文件*
