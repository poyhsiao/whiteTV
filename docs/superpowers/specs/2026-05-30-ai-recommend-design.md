# AI 推薦功能設計規格

**版本**: v1.0
**日期**: 2026-05-30
**功能**: AI 智能推薦系統
**狀態**: 草稿

---

## 1. 概述

### 1.1 功能目標

實現 AI 智能推薦系統，提供個人化內容推薦，幫助用戶發現感興趣的影視內容。

### 1.2 雙軌策略

採用 API + Fallback 雙軌策略確保推薦功能穩定可用：

1. **主要軌**：調用 LunaTV AI API (`/api/ai-recommend`)
2. **Fallback 軌**：基於用戶觀看歷史和搜尋歷史的本地推薦邏輯

---

## 2. 系統架構

```
┌─────────────────────────────────────────────────────────────┐
│                        AI 推薦系統                           │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐ │
│  │  HomeStore   │    │AIRecommendStore│    │AIRecommendPage│ │
│  │  (首頁整合)  │    │  (狀態管理)   │    │  (獨立頁面)   │ │
│  └──────┬───────┘    └──────┬───────┘    └──────┬───────┘ │
│         │                   │                   │         │
│         └───────────────────┼───────────────────┘         │
│                             │                             │
│                             ▼                             │
│  ┌─────────────────────────────────────────────────────┐  │
│  │              AIRecommendRepository                  │  │
│  │  • getRecommendations() → 雙軌獲取                  │  │
│  │  • getAIRecommendations() → AI API                 │  │
│  │  • getLocalRecommendations() → 本地邏輯            │  │
│  └──────────────────────┬──────────────────────────────┘  │
│                         │                                  │
│         ┌───────────────┴───────────────┐                 │
│         ▼                               ▼                  │
│  ┌─────────────────┐        ┌─────────────────┐          │
│  │AIRecommendService│        │    LunaClient    │          │
│  │   (本地推薦)     │        │    (AI API)      │          │
│  └─────────────────┘        └─────────────────┘          │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 3. API 規格

### 3.1 AI 推薦 API

**端點**: `GET /api/ai-recommend`

**需要認證**: Cookie

**當前回應格式**:
```json
{
  "history": [],
  "total": 0
}
```

**預期回應格式** (若 AI 有推薦):
```json
{
  "recommendations": [
    {
      "id": "12345",
      "title": "影片標題",
      "poster": "https://...",
      "year": "2024",
      "source": "lovedan",
      "source_name": "量子資源",
      "type": "movie",
      "reason": "根據您的觀看偏好推薦"
    }
  ],
  "total": 10
}
```

### 3.2 用戶統計 API (用於 Fallback)

**端點**: `GET /api/user/my-stats`

**當前回應**:
```json
{
  "stats": {
    "totalFavorites": 50,
    "totalWatchTime": 3600,
    "recentRecords": [
      {
        "title": "影片標題",
        "cover": "https://...",
        "type": "movie",
        "douban_id": 3078609
      }
    ]
  }
}
```

### 3.3 搜尋歷史 API (用於 Fallback)

**端點**: `GET /api/searchhistory`

**當前回應**:
```json
{
  "history": ["關鍵詞1", "關鍵詞2"]
}
```

---

## 4. 資料模型

### 4.1 AIRecommendation

```dart
class AIRecommendation {
  final String id;
  final String title;
  final String posterUrl;
  final String? description;
  final String source;
  final String sourceName;
  final String? reason;              // AI 推薦理由
  final RecommendationSource sourceType; // ai | history | popular
  final int? year;
  final String? type;
  final String? doubanId;
  final int? episodeTotal;
}
```

### 4.2 RecommendationSource

```dart
enum RecommendationSource {
  ai,      // 來自 AI API
  history, // 基於觀看歷史
  popular  // 熱門推薦
}
```

### 4.3 AIRecommendState

```dart
class AIRecommendState {
  final List<AIRecommendation> recommendations;
  final bool isLoading;
  final String? error;
  final RecommendationSource primarySource;
  final DateTime lastUpdated;
}
```

---

## 5. 推薦流程

```
用戶請求推薦
       │
       ▼
┌─────────────────────────┐
│  調用 /api/ai-recommend  │
└───────────┬─────────────┘
            │
    ┌───────┴───────┐
    ▼               ▼
┌─────────┐    ┌─────────┐
│有內容    │    │ 空值    │
│total>0  │    │total=0 │
└────┬────┘    └────┬────┘
     │              │
     ▼              ▼
返回 AI    ┌─────────────────┐
推薦      │  觸發 Fallback   │
          └────────┬────────┘
                   │
                   ▼
         ┌─────────────────┐
         │ 分析用戶歷史     │
         │ • 觀看記錄       │
         │ • 搜尋歷史       │
         │ • 熱門內容       │
         └────────┬────────┘
                  │
                  ▼
         ┌─────────────────┐
         │ 返回本地推薦     │
         │ (標記 sourceType)│
         └─────────────────┘
```

---

## 6. 實作結構

```
lib/
├── core/api/
│   ├── api_client.dart        # 新增 getAIRecommendations()
│   └── luna_client.dart       # 實現 AI API 調用
│
├── features/recommend/
│   ├── data/
│   │   ├── models/
│   │   │   └── ai_recommendation.dart
│   │   └── repositories/
│   │       └── ai_recommend_repository.dart
│   │
│   ├── services/
│   │   └── ai_recommend_service.dart   # 本地推薦邏輯
│   │
│   └── presentation/
│       ├── providers/
│       │   └── ai_recommend_store.dart
│       │
│       ├── widgets/
│       │   ├── recommendation_card.dart
│       │   ├── recommendation_carousel.dart
│       │   └── recommendation_reason_sheet.dart
│       │
│       └── pages/
│           └── ai_recommend_page.dart
```

---

## 7. API Client 擴展

### 7.1 新增方法

```dart
abstract class ApiClient {
  // ... 現有方法 ...

  /// AI 推薦
  Future<List<AIRecommendation>> getAIRecommendations();

  /// 本地推薦（Fallback）
  Future<List<AIRecommendation>> getLocalRecommendations({
    List<String>? watchHistory,
    List<String>? searchHistory,
    int limit = 20,
  });
}
```

---

## 8. UI/UX 設計

### 8.1 首頁「為你推薦」區塊

```
┌──────────────────────────────────────────────────────────┐
│  為你推薦                                    [🔄 刷新]   │
├──────────────────────────────────────────────────────────┤
│  ┌────┐  ┌────┐  ┌────┐  ┌────┐  ┌────┐                │
│  │海報│  │海報│  │海報│  │海報│  │海報│                │
│  │    │  │    │  │    │  │    │  │    │                │
│  └────┘  └────┘  └────┘  └────┘  └────┘                │
│  標題    標題    標題    標題    標題                    │
│  2024   2023    2024    2022    2025                    │
│  [🤖AI] [🤖AI] [📺偏好][📺偏好][🔥熱門]              │
└──────────────────────────────────────────────────────────┘
```

### 8.2 推薦卡片標籤

| 標籤 | 顏色 | 意義 |
|------|------|------|
| 🤖 AI | 琥珀色 | 來自 AI API 推薦 |
| 📺 偏好 | 藍色 | 基於觀看偏好推薦 |
| 🔥 熱門 | 紅色 | 熱門內容推薦 |

### 8.3 推薦理由底部弹窗

```
┌──────────────────────────────────────────────────────────┐
│                                              [X]          │
│  推薦理由                                                 │
│  ─────────────────────────────────────────────────────   │
│                                                          │
│  根據您觀看《星際穿越》《盜夢空間》等科幻電影，            │
│  我們為您推薦這部同類型作品。                              │
│                                                          │
│  ┌────────────────────────────────────────────────────┐  │
│  │ 🎬 克里斯托弗·諾蘭 執導                             │  │
│  │ ⭐ 8.5/10 (豆瓣)                                   │  │
│  │ 🎭 科幻 / 懸疑 / 冒險                              │  │
│  └────────────────────────────────────────────────────┘  │
│                                                          │
│                              [▶ 開始觀看]                 │
└──────────────────────────────────────────────────────────┘
```

### 8.4 獨立 AI 推薦頁面

```
┌──────────────────────────────────────────────────────────┐
│  ← 返回                      AI 推薦                     │
├──────────────────────────────────────────────────────────┤
│                                                          │
│  根據您的觀看記錄，我們為您精選了以下內容：               │
│                                                          │
│  ┌────────────────────────────────────────────────────┐  │
│  │ 為您推薦的理由：                                    │  │
│  │                                                    │  │
│  │ 您近期觀看了多部科幻電影，我們認為您會喜歡這部...   │  │
│  └────────────────────────────────────────────────────┘  │
│                                                          │
│  [電影] [電視劇] [動漫] [綜藝]     ← 類型篩選             │
│                                                          │
│  ┌────┐  ┌────┐  ┌────┐  ┌────┐                       │
│  │    │  │    │  │    │  │    │                       │
│  │海報│  │海報│  │海報│  │海報│                       │
│  │    │  │    │  │    │  │    │                       │
│  └────┘  └────┘  └────┘  └────┘                       │
│  標題    標題    標題    標題                          │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

---

## 9. 測試策略

### 9.1 TDD 測試案例

```dart
group('AIRecommendRepository', () {
  test('getRecommendations returns AI recommendations when available', () async {
    // Arrange
    when(() => mockClient.getAIRecommendations())
        .thenAnswer((_) async => [testAIRecommendation]);

    // Act
    final result = await repository.getRecommendations();

    // Assert
    expect(result.first.sourceType, equals(RecommendationSource.ai));
  });

  test('getRecommendations falls back to local when AI returns empty', () async {
    // Arrange
    when(() => mockClient.getAIRecommendations())
        .thenAnswer((_) async => []);
    when(() => mockClient.getUserStats())
        .thenAnswer((_) async => testUserStats);
    when(() => mockClient.getSearchHistory())
        .thenAnswer((_) async => ['科幻', '周星馳']);

    // Act
    final result = await repository.getRecommendations();

    // Assert
    expect(result, isNotEmpty);
  });
});
```

### 9.2 BDD 驗收案例

```gherkin
Scenario: AI 推薦成功獲取內容
  Given 用戶已登入
  And AI API 回傳有效推薦
  When 用戶打開首頁
  Then 看到「為你推薦」區塊顯示 AI 推薦內容
  And 卡片顯示「🤖 AI」標籤

Scenario: AI API 回傳空值，使用 Fallback
  Given 用戶已登入
  And AI API 回傳空值
  When 用戶打開首頁
  Then 看到「為你推薦」區塊顯示本地推薦
  And 卡片顯示「📺 偏好」標籤

Scenario: 用戶點擊推薦理由
  Given 推薦卡片顯示中
  When 用戶點擊「為何推薦？」
  Then 底部弹窗顯示推薦理由
```

---

## 10. 依賴變更

### 10.1 需要修改的檔案

- `lib/core/api/api_client.dart` — 新增 AI 推薦方法
- `lib/core/api/luna_client.dart` — 實現 AI API 調用
- `lib/core/api/mock_client.dart` — Mock 實現（測試用）

### 10.2 需要新增的檔案

- `lib/features/recommend/data/models/ai_recommendation.dart`
- `lib/features/recommend/data/repositories/ai_recommend_repository.dart`
- `lib/features/recommend/services/ai_recommend_service.dart`
- `lib/features/recommend/presentation/providers/ai_recommend_store.dart`
- `lib/features/recommend/presentation/widgets/recommendation_card.dart`
- `lib/features/recommend/presentation/widgets/recommendation_carousel.dart`
- `lib/features/recommend/presentation/widgets/recommendation_reason_sheet.dart`
- `lib/features/recommend/presentation/pages/ai_recommend_page.dart`

### 10.3 測試檔案

- `test/unit/features/recommend/ai_recommend_repository_test.dart`
- `test/unit/features/recommend/ai_recommend_service_test.dart`
- `test/bdd/recommend/ai_recommend.feature`

---

## 11. 實作順序

1. **模型定義** — `AIRecommendation`, `RecommendationSource`
2. **API Client 擴展** — 新增 `getAIRecommendations()` 方法
3. **Repository 實現** — 雙軌策略實現
4. **Service 實現** — 本地推薦邏輯
5. **Store 實現** — Riverpod 狀態管理
6. **UI Widgets** — 卡片、輪播、理由弹窗
7. **首頁整合** — 「為你推薦」區塊
8. **獨立頁面** — AI 推薦頁面
9. **測試** — TDD + BDD

---

*文件版本: v1.0 — AI 推薦功能設計規格*