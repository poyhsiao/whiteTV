# AI 推薦功能實作計劃

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 實現 AI 智能推薦系統，提供個人化內容推薦，包含雙軌策略（API + Fallback）和混合模式 UI

**Architecture:** 採用 Repository Pattern 實現雙軌策略，API 回傳空值時自動 fallback 到本地推薦邏輯。UI 採用卡片式推薦 + AI 理由弹窗的混合模式。

**Tech Stack:** Flutter + Riverpod + Dio + TDD/BDD

---

## 檔案結構

```
lib/
├── core/api/
│   ├── api_client.dart        # 新增 getAIRecommendations(), getLocalRecommendations()
│   └── luna_client.dart       # 實現 AI API 調用
│
├── features/recommend/
│   ├── data/
│   │   ├── models/
│   │   │   └── ai_recommendation.dart  # AIRecommendation, RecommendationSource
│   │   └── repositories/
│   │       └── ai_recommend_repository.dart  # 雙軌策略
│   │
│   ├── services/
│   │   └── ai_recommend_service.dart  # 本地推薦邏輯
│   │
│   └── presentation/
│       ├── providers/
│       │   └── ai_recommend_store.dart  # Riverpod Store
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

## Task 1: 模型定義

**Files:**
- Create: `lib/features/recommend/data/models/ai_recommendation.dart`
- Test: `test/unit/features/recommend/models/ai_recommendation_test.dart`

- [ ] **Step 1: 創建模型測試**

```dart
// test/unit/features/recommend/models/ai_recommendation_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/recommend/data/models/ai_recommendation.dart';

void main() {
  group('AIRecommendation', () {
    test('fromJson parses AI response correctly', () {
      final json = {
        'id': '12345',
        'title': '星際穿越',
        'poster': 'https://example.com/poster.jpg',
        'year': '2014',
        'source': 'lovedan',
        'source_name': '量子資源',
        'type': 'movie',
        'reason': '根據您的觀看偏好推薦',
      };

      final recommendation = AIRecommendation.fromJson(json);

      expect(recommendation.id, equals('12345'));
      expect(recommendation.title, equals('星際穿越'));
      expect(recommendation.posterUrl, equals('https://example.com/poster.jpg'));
      expect(recommendation.year, equals('2014'));
      expect(recommendation.source, equals('lovedan'));
      expect(recommendation.sourceName, equals('量子資源'));
      expect(recommendation.type, equals('movie'));
      expect(recommendation.reason, equals('根據您的觀看偏好推薦'));
      expect(recommendation.sourceType, equals(RecommendationSource.ai));
    });

    test('fromJson handles missing optional fields', () {
      final json = {
        'id': '12345',
        'title': '星際穿越',
        'poster': 'https://example.com/poster.jpg',
        'source': 'lovedan',
        'source_name': '量子資源',
      };

      final recommendation = AIRecommendation.fromJson(json);

      expect(recommendation.year, isNull);
      expect(recommendation.type, isNull);
      expect(recommendation.reason, isNull);
    });

    test('RecommendationSource enum has correct values', () {
      expect(RecommendationSource.values.length, equals(3));
      expect(RecommendationSource.ai.name, equals('ai'));
      expect(RecommendationSource.history.name, equals('history'));
      expect(RecommendationSource.popular.name, equals('popular'));
    });

    test('toJson produces correct output', () {
      const recommendation = AIRecommendation(
        id: '12345',
        title: '星際穿越',
        posterUrl: 'https://example.com/poster.jpg',
        source: 'lovedan',
        sourceName: '量子資源',
        reason: '測試理由',
        sourceType: RecommendationSource.ai,
      );

      final json = recommendation.toJson();

      expect(json['id'], equals('12345'));
      expect(json['title'], equals('星際穿越'));
      expect(json['poster_url'], equals('https://example.com/poster.jpg'));
      expect(json['source'], equals('lovedan'));
      expect(json['source_name'], equals('量子資源'));
      expect(json['reason'], equals('測試理由'));
      expect(json['source_type'], equals('ai'));
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/unit/features/recommend/models/ai_recommendation_test.dart -v`
Expected: FAIL with "AIRecommendation cannot be found"

- [ ] **Step 3: Write minimal implementation**

```dart
// lib/features/recommend/data/models/ai_recommendation.dart

enum RecommendationSource {
  ai,
  history,
  popular,
}

class AIRecommendation {
  final String id;
  final String title;
  final String? posterUrl;
  final String? description;
  final String source;
  final String sourceName;
  final String? reason;
  final RecommendationSource sourceType;
  final String? year;
  final String? type;
  final String? doubanId;
  final int? episodeTotal;

  const AIRecommendation({
    required this.id,
    required this.title,
    this.posterUrl,
    this.description,
    required this.source,
    required this.sourceName,
    this.reason,
    required this.sourceType,
    this.year,
    this.type,
    this.doubanId,
    this.episodeTotal,
  });

  factory AIRecommendation.fromJson(Map<String, dynamic> json) {
    return AIRecommendation(
      id: json['id'] as String,
      title: json['title'] as String,
      posterUrl: json['poster'] as String? ?? json['poster_url'] as String?,
      description: json['desc'] as String? ?? json['description'] as String?,
      source: json['source'] as String,
      sourceName: json['source_name'] as String? ?? json['sourceName'] as String,
      reason: json['reason'] as String?,
      sourceType: _parseSourceType(json['source_type'] as String?),
      year: (json['year'] ?? json['release_year'])?.toString(),
      type: json['type'] as String? ?? json['type_name'] as String?,
      doubanId: json['douban_id']?.toString(),
      episodeTotal: json['total_episodes'] as int? ?? json['episodeTotal'] as int?,
    );
  }

  static RecommendationSource _parseSourceType(String? value) {
    switch (value) {
      case 'ai':
        return RecommendationSource.ai;
      case 'history':
        return RecommendationSource.history;
      case 'popular':
        return RecommendationSource.popular;
      default:
        return RecommendationSource.ai;
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'poster_url': posterUrl,
        'description': description,
        'source': source,
        'source_name': sourceName,
        'reason': reason,
        'source_type': sourceType.name,
        'year': year,
        'type': type,
        'douban_id': doubanId,
        'total_episodes': episodeTotal,
      };
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/unit/features/recommend/models/ai_recommendation_test.dart -v`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/features/recommend/data/models/ai_recommendation.dart test/unit/features/recommend/models/ai_recommendation_test.dart
git commit -m "feat(recommend): add AIRecommendation model and RecommendationSource enum

- Add AIRecommendation class with fromJson/toJson
- Add RecommendationSource enum (ai, history, popular)
- Add unit tests for model parsing
- Follow existing whiteTV patterns (const, factory fromJson)

Refs: #ai-recommend-design"
```

---

## Task 2: API Client 擴展

**Files:**
- Modify: `lib/core/api/api_client.dart:49-51`
- Modify: `lib/core/api/luna_client.dart` (implement method)
- Modify: `lib/core/api/mock_client.dart` (mock implementation)
- Test: `test/unit/features/recommend/api_client_test.dart`

- [ ] **Step 1: 更新 ApiClient 介面**

```dart
// lib/core/api/api_client.dart (在現有方法後新增)
  /// 從雲端同步收藏
  Future<List<FavoriteItem>> syncFavorites();

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

- [ ] **Step 2: 執行測試確認失敗**

Run: `flutter analyze lib/core/api/api_client.dart`
Expected: 顯示 `getAIRecommendations` 和 `getLocalRecommendations` 未實現

- [ ] **Step 3: 在 LunaClient 實現方法**

```dart
// lib/core/api/luna_client.dart 新增方法
  @override
  Future<List<AIRecommendation>> getAIRecommendations() async {
    try {
      final response = await _get('/api/ai-recommend');
      final data = response.data;

      // 處理預期格式
      if (data['recommendations'] != null) {
        return (data['recommendations'] as List)
            .map((e) => AIRecommendation.fromJson(e as Map<String, dynamic>)
                ..sourceType = RecommendationSource.ai)
            .toList();
      }

      // 處理空值情況
      if (data['total'] == 0 || (data['recommendations'] as List?)?.isEmpty == true) {
        return [];
      }

      return [];
    } on DioException catch (e) {
      _handleError(e);
      return [];
    }
  }

  @override
  Future<List<AIRecommendation>> getLocalRecommendations({
    List<String>? watchHistory,
    List<String>? searchHistory,
    int limit = 20,
  }) async {
    // 獲取用戶統計和搜尋歷史
    final stats = await getUserStats();
    final history = searchHistory ?? await getSearchHistory();

    // 從統計中提取觀看記錄
    final watchRecords = (stats['stats']?['recentRecords'] as List?) ?? [];
    final watchTypes = <String>{};
    final watchTitles = <String>[];

    for (final record in watchRecords) {
      if (record['type'] != null) watchTypes.add(record['type'] as String);
      if (record['title'] != null) watchTitles.add(record['title'] as String);
    }

    // 搜尋相關內容
    final query = history.isNotEmpty ? history.first : (watchTypes.isNotEmpty ? watchTypes.first : '電影');
    final searchResults = await search(query);

    // 返回搜尋結果作為本地推薦
    return searchResults.take(limit).map((id) {
      return AIRecommendation(
        id: id.toString(),
        title: '推薦內容',
        source: 'local',
        sourceName: '本地推薦',
        sourceType: RecommendationSource.history,
      );
    }).toList();
  }
```

- [ ] **Step 4: 更新 MockClient**

```dart
// lib/core/api/mock_client.dart 新增方法
  @override
  Future<List<AIRecommendation>> getAIRecommendations() async {
    await Future.delayed(_delay);
    // Mock: 返回空以觸發 fallback
    return [];
  }

  @override
  Future<List<AIRecommendation>> getLocalRecommendations({
    List<String>? watchHistory,
    List<String>? searchHistory,
    int limit = 20,
  }) async {
    await Future.delayed(_delay);
    // Mock: 基於搜尋歷史返回模擬推薦
    return [
      AIRecommendation(
        id: 'mock-1',
        title: '星際穿越 (本地推薦)',
        posterUrl: 'https://picsum.photos/seed/mock1/300/450',
        source: 'mtzy.me',
        sourceName: '🎬茅台资源',
        reason: '根據您的觀看偏好推薦',
        sourceType: RecommendationSource.history,
        year: '2014',
        type: 'movie',
      ),
      AIRecommendation(
        id: 'mock-2',
        title: '盜夢空間 (本地推薦)',
        posterUrl: 'https://picsum.photos/seed/mock2/300/450',
        source: 'mtzy.me',
        sourceName: '🎬茅台资源',
        reason: '同類型推薦',
        sourceType: RecommendationSource.history,
        year: '2010',
        type: 'movie',
      ),
    ];
  }
```

- [ ] **Step 5: 執行測試確認通過**

Run: `flutter analyze lib/core/api/`
Expected: No errors

- [ ] **Step 6: Commit**

```bash
git add lib/core/api/api_client.dart lib/core/api/luna_client.dart lib/core/api/mock_client.dart
git commit -m "feat(recommend): add AI recommendation methods to ApiClient

- Add getAIRecommendations() to ApiClient interface
- Add getLocalRecommendations() with fallback logic
- Implement in LunaClient with error handling
- Add mock implementation in MockClient for testing

Refs: #ai-recommend-design"
```

---

## Task 3: AIRecommendRepository 實現

**Files:**
- Create: `lib/features/recommend/data/repositories/ai_recommend_repository.dart`
- Create: `test/unit/features/recommend/ai_recommend_repository_test.dart`

- [ ] **Step 1: 創建 Repository 測試**

```dart
// test/unit/features/recommend/ai_recommend_repository_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:white_tv/core/api/api_client.dart';
import 'package:white_tv/features/recommend/data/models/ai_recommendation.dart';
import 'package:white_tv/features/recommend/data/repositories/ai_recommend_repository.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockApiClient mockClient;
  late AIRecommendRepository repository;

  setUp(() {
    mockClient = MockApiClient();
    repository = AIRecommendRepository(mockClient);
  });

  group('AIRecommendRepository', () {
    test('getRecommendations returns AI recommendations when available', () async {
      // Arrange
      final aiRecommendations = [
        const AIRecommendation(
          id: '12345',
          title: '星際穿越',
          source: 'lovedan',
          sourceName: '量子資源',
          sourceType: RecommendationSource.ai,
        ),
      ];
      when(() => mockClient.getAIRecommendations())
          .thenAnswer((_) async => aiRecommendations);

      // Act
      final result = await repository.getRecommendations();

      // Assert
      expect(result.first.sourceType, equals(RecommendationSource.ai));
      expect(result.length, equals(1));
      verify(() => mockClient.getAIRecommendations()).called(1);
      verifyNever(() => mockClient.getLocalRecommendations());
    });

    test('getRecommendations falls back to local when AI returns empty', () async {
      // Arrange
      final localRecommendations = [
        const AIRecommendation(
          id: 'local-1',
          title: '盜夢空間',
          source: 'mtzy.me',
          sourceName: '茅台资源',
          sourceType: RecommendationSource.history,
        ),
      ];
      when(() => mockClient.getAIRecommendations())
          .thenAnswer((_) async => []);
      when(() => mockClient.getLocalRecommendations(watchHistory: any(named: 'watchHistory'), searchHistory: any(named: 'searchHistory'), limit: any(named: 'limit')))
          .thenAnswer((_) async => localRecommendations);

      // Act
      final result = await repository.getRecommendations();

      // Assert
      expect(result.first.sourceType, equals(RecommendationSource.history));
      expect(result.length, equals(1));
      verify(() => mockClient.getAIRecommendations()).called(1);
      verify(() => mockClient.getLocalRecommendations(
        watchHistory: any(named: 'watchHistory'),
        searchHistory: any(named: 'searchHistory'),
        limit: any(named: 'limit'),
      )).called(1);
    });

    test('getRecommendations returns empty list when both fail', () async {
      // Arrange
      when(() => mockClient.getAIRecommendations())
          .thenAnswer((_) async => []);
      when(() => mockClient.getLocalRecommendations(
        watchHistory: any(named: 'watchHistory'),
        searchHistory: any(named: 'searchHistory'),
        limit: any(named: 'limit'),
      )).thenAnswer((_) async => []);

      // Act
      final result = await repository.getRecommendations();

      // Assert
      expect(result, isEmpty);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/unit/features/recommend/ai_recommend_repository_test.dart -v`
Expected: FAIL with "AIRecommendRepository cannot be found"

- [ ] **Step 3: Write minimal implementation**

```dart
// lib/features/recommend/data/repositories/ai_recommend_repository.dart
import 'package:white_tv/core/api/api_client.dart';
import 'package:white_tv/features/recommend/data/models/ai_recommendation.dart';

class AIRecommendRepository {
  final ApiClient _apiClient;

  AIRecommendRepository(this._apiClient);

  /// 獲取推薦（雙軌策略）
  Future<List<AIRecommendation>> getRecommendations({
    List<String>? watchHistory,
    List<String>? searchHistory,
    int limit = 20,
  }) async {
    // 先嘗試 AI API
    final aiRecommendations = await _apiClient.getAIRecommendations();

    if (aiRecommendations.isNotEmpty) {
      return aiRecommendations;
    }

    // Fallback: 使用本地推薦
    return _apiClient.getLocalRecommendations(
      watchHistory: watchHistory,
      searchHistory: searchHistory,
      limit: limit,
    );
  }

  /// 直接獲取 AI 推薦
  Future<List<AIRecommendation>> getAIRecommendations() {
    return _apiClient.getAIRecommendations();
  }

  /// 直接獲取本地推薦
  Future<List<AIRecommendation>> getLocalRecommendations({
    List<String>? watchHistory,
    List<String>? searchHistory,
    int limit = 20,
  }) {
    return _apiClient.getLocalRecommendations(
      watchHistory: watchHistory,
      searchHistory: searchHistory,
      limit: limit,
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/unit/features/recommend/ai_recommend_repository_test.dart -v`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/features/recommend/data/repositories/ai_recommend_repository.dart test/unit/features/recommend/ai_recommend_repository_test.dart
git commit -m "feat(recommend): add AIRecommendRepository with dual-track strategy

- Add getRecommendations() with AI first, fallback second
- Add getAIRecommendations() and getLocalRecommendations()
- Add unit tests for dual-track logic

Refs: #ai-recommend-design"
```

---

## Task 4: AIRecommendService 實現

**Files:**
- Create: `lib/features/recommend/services/ai_recommend_service.dart`
- Create: `test/unit/features/recommend/ai_recommend_service_test.dart`

- [ ] **Step 1: 創建 Service 測試**

```dart
// test/unit/features/recommend/ai_recommend_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/recommend/data/models/ai_recommendation.dart';
import 'package:white_tv/features/recommend/services/ai_recommend_service.dart';

void main() {
  late AIRecommendService service;

  setUp(() {
    service = AIRecommendService();
  });

  group('AIRecommendService', () {
    test('generateLocalRecommendations returns recommendations based on history', () {
      // Arrange
      final watchHistory = ['科幻', '周星馳'];
      final searchHistory = ['星際穿越', '盜夢空間'];

      // Act
      final result = service.generateLocalRecommendations(
        watchHistory: watchHistory,
        searchHistory: searchHistory,
        limit: 10,
      );

      // Assert
      expect(result, isNotEmpty);
      expect(result.first.sourceType, equals(RecommendationSource.history));
    });

    test('generatePopularRecommendations returns popular content', () {
      // Act
      final result = service.generatePopularRecommendations(limit: 10);

      // Assert
      expect(result, isNotEmpty);
      expect(result.first.sourceType, equals(RecommendationSource.popular));
    });

    test('extractWatchPreferences extracts types and genres from history', () {
      // Arrange
      final watchRecords = [
        {'type': 'movie', 'title': '星際穿越'},
        {'type': 'movie', 'title': '盜夢空間'},
        {'type': 'drama', 'title': '魷魚遊戲'},
      ];

      // Act
      final preferences = service.extractWatchPreferences(watchRecords);

      // Assert
      expect(preferences['types'], contains('movie'));
      expect(preferences['types'], contains('drama'));
      expect(preferences['titles'], contains('星際穿越'));
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/unit/features/recommend/ai_recommend_service_test.dart -v`
Expected: FAIL with "AIRecommendService cannot be found"

- [ ] **Step 3: Write minimal implementation**

```dart
// lib/features/recommend/services/ai_recommend_service.dart
import 'package:white_tv/features/recommend/data/models/ai_recommendation.dart';

class AIRecommendService {
  /// 基於用戶歷史生成推薦
  List<AIRecommendation> generateLocalRecommendations({
    required List<String> watchHistory,
    required List<String> searchHistory,
    int limit = 20,
  }) {
    // 如果有搜尋歷史，使用搜尋關鍵詞
    if (searchHistory.isNotEmpty) {
      return _generateFromSearchHistory(searchHistory, limit);
    }

    // 如果有觀看歷史，使用觀看類型
    if (watchHistory.isNotEmpty) {
      return _generateFromWatchHistory(watchHistory, limit);
    }

    // 回退到熱門推薦
    return generatePopularRecommendations(limit: limit);
  }

  List<AIRecommendation> _generateFromSearchHistory(
    List<String> history,
    int limit,
  ) {
    // 模擬搜尋歷史推薦
    return history.take(limit).map((keyword) {
      return AIRecommendation(
        id: 'search-$keyword',
        title: '關於 $keyword 的推薦',
        source: 'local',
        sourceName: '本地推薦',
        reason: '根據您的搜尋記錄「$keyword」',
        sourceType: RecommendationSource.history,
      );
    }).toList();
  }

  List<AIRecommendation> _generateFromWatchHistory(
    List<String> history,
    int limit,
  ) {
    // 模擬觀看歷史推薦
    return history.take(limit).map((type) {
      return AIRecommendation(
        id: 'watch-$type',
        title: '$type 類型推薦',
        source: 'local',
        sourceName: '本地推薦',
        reason: '根據您觀看的 $type 內容',
        sourceType: RecommendationSource.history,
      );
    }).toList();
  }

  /// 生成熱門推薦
  List<AIRecommendation> generatePopularRecommendations({int limit = 20}) {
    // 模擬熱門推薦
    return List.generate(
      limit,
      (index) => AIRecommendation(
        id: 'popular-$index',
        title: '熱門推薦 ${index + 1}',
        source: 'popular',
        sourceName: '熱門推薦',
        reason: '當前熱門內容',
        sourceType: RecommendationSource.popular,
      ),
    );
  }

  /// 從觀看記錄提取偏好
  Map<String, List<String>> extractWatchPreferences(List<Map<String, dynamic>> records) {
    final types = <String>{};
    final titles = <String>[];

    for (final record in records) {
      if (record['type'] != null) {
        types.add(record['type'] as String);
      }
      if (record['title'] != null) {
        titles.add(record['title'] as String);
      }
    }

    return {
      'types': types.toList(),
      'titles': titles,
    };
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/unit/features/recommend/ai_recommend_service_test.dart -v`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/features/recommend/services/ai_recommend_service.dart test/unit/features/recommend/ai_recommend_service_test.dart
git commit -m "feat(recommend): add AIRecommendService with local recommendation logic

- Add generateLocalRecommendations() based on search/watch history
- Add generatePopularRecommendations() for fallback
- Add extractWatchPreferences() for preference analysis
- Add unit tests for service methods

Refs: #ai-recommend-design"
```

---

## Task 5: AIRecommendStore (Riverpod) 實現

**Files:**
- Create: `lib/features/recommend/presentation/providers/ai_recommend_store.dart`
- Test: `test/unit/features/recommend/ai_recommend_store_test.dart`

- [ ] **Step 1: 創建 Store 測試**

```dart
// test/unit/features/recommend/ai_recommend_store_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/recommend/data/models/ai_recommendation.dart';
import 'package:white_tv/features/recommend/presentation/providers/ai_recommend_store.dart';

void main() {
  group('AIRecommendState', () {
    test('initial state is correct', () {
      const state = AIRecommendState();

      expect(state.recommendations, isEmpty);
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
      expect(state.primarySource, isNull);
    });

    test('copyWith creates new state with updated values', () {
      const state = AIRecommendState();
      final newState = state.copyWith(
        isLoading: true,
        recommendations: [
          AIRecommendation(
            id: '1',
            title: 'Test',
            source: 'test',
            sourceName: 'Test',
            sourceType: RecommendationSource.ai,
          ),
        ],
      );

      expect(newState.isLoading, isTrue);
      expect(newState.recommendations.length, equals(1));
    });
  });

  group('AIRecommendStore', () {
    test('loadRecommendations updates state with results', () async {
      final store = AIRecommendStore();

      await store.loadRecommendations();

      // Store should have attempted to load
      expect(store.state.recommendations, isNotNull);
    });

    test('refreshRecommendations reloads content', () async {
      final store = AIRecommendStore();

      await store.loadRecommendations();
      await store.refreshRecommendations();

      // Should have attempted to reload
      expect(store.state.recommendations, isNotNull);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/unit/features/recommend/ai_recommend_store_test.dart -v`
Expected: FAIL with "AIRecommendStore cannot be found"

- [ ] **Step 3: Write minimal implementation**

```dart
// lib/features/recommend/presentation/providers/ai_recommend_store.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/core/api/api_client.dart';
import 'package:white_tv/core/api/client_factory.dart';
import 'package:white_tv/features/recommend/data/models/ai_recommendation.dart';
import 'package:white_tv/features/recommend/data/repositories/ai_recommend_repository.dart';

class AIRecommendState {
  final List<AIRecommendation> recommendations;
  final bool isLoading;
  final String? error;
  final RecommendationSource? primarySource;
  final DateTime? lastUpdated;

  const AIRecommendState({
    this.recommendations = const [],
    this.isLoading = false,
    this.error,
    this.primarySource,
    this.lastUpdated,
  });

  AIRecommendState copyWith({
    List<AIRecommendation>? recommendations,
    bool? isLoading,
    String? error,
    RecommendationSource? primarySource,
    DateTime? lastUpdated,
  }) {
    return AIRecommendState(
      recommendations: recommendations ?? this.recommendations,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      primarySource: primarySource ?? this.primarySource,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class AIRecommendStore extends StateNotifier<AIRecommendState> {
  final ApiClient _apiClient;
  final AIRecommendRepository _repository;

  AIRecommendStore(this._apiClient)
      : _repository = AIRecommendRepository(_apiClient),
        super(const AIRecommendState());

  Future<void> loadRecommendations() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final recommendations = await _repository.getRecommendations();

      // 判斷主要來源
      RecommendationSource? primarySource;
      if (recommendations.isNotEmpty) {
        primarySource = recommendations.first.sourceType;
      }

      state = state.copyWith(
        recommendations: recommendations,
        isLoading: false,
        primarySource: primarySource,
        lastUpdated: DateTime.now(),
      );
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refreshRecommendations() async {
    await loadRecommendations();
  }
}

// Provider
final aiRecommendStoreProvider = StateNotifierProvider<AIRecommendStore, AIRecommendState>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AIRecommendStore(apiClient);
});
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/unit/features/recommend/ai_recommend_store_test.dart -v`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/features/recommend/presentation/providers/ai_recommend_store.dart test/unit/features/recommend/ai_recommend_store_test.dart
git commit -m "feat(recommend): add AIRecommendStore with Riverpod state management

- Add AIRecommendState with recommendations, loading, error
- Add AIRecommendStore with loadRecommendations() and refreshRecommendations()
- Add aiRecommendStoreProvider for dependency injection

Refs: #ai-recommend-design"
```

---

## Task 6: UI Widgets

**Files:**
- Create: `lib/features/recommend/presentation/widgets/recommendation_card.dart`
- Create: `lib/features/recommend/presentation/widgets/recommendation_carousel.dart`
- Create: `lib/features/recommend/presentation/widgets/recommendation_reason_sheet.dart`
- Test: `test/widget/features/recommend/recommendation_card_test.dart`

### Task 6.1: RecommendationCard

- [ ] **Step 1: 創建 RecommendationCard 測試**

```dart
// test/widget/features/recommend/recommendation_card_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/recommend/data/models/ai_recommendation.dart';
import 'package:white_tv/features/recommend/presentation/widgets/recommendation_card.dart';

void main() {
  group('RecommendationCard', () {
    testWidgets('displays AI tag for AI recommendations', (tester) async {
      const recommendation = AIRecommendation(
        id: '1',
        title: '星際穿越',
        source: 'lovedan',
        sourceName: '量子資源',
        sourceType: RecommendationSource.ai,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecommendationCard(recommendation: recommendation),
          ),
        ),
      );

      expect(find.text('🤖 AI'), findsOneWidget);
    });

    testWidgets('displays preference tag for history recommendations', (tester) async {
      const recommendation = AIRecommendation(
        id: '1',
        title: '星際穿越',
        source: 'lovedan',
        sourceName: '量子資源',
        sourceType: RecommendationSource.history,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecommendationCard(recommendation: recommendation),
          ),
        ),
      );

      expect(find.text('📺 偏好'), findsOneWidget);
    });

    testWidgets('displays popular tag for popular recommendations', (tester) async {
      const recommendation = AIRecommendation(
        id: '1',
        title: '星際穿越',
        source: 'popular',
        sourceName: '熱門推薦',
        sourceType: RecommendationSource.popular,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecommendationCard(recommendation: recommendation),
          ),
        ),
      );

      expect(find.text('🔥 熱門'), findsOneWidget);
    });

    testWidgets('shows title correctly', (tester) async {
      const recommendation = AIRecommendation(
        id: '1',
        title: '星際穿越',
        source: 'lovedan',
        sourceName: '量子資源',
        sourceType: RecommendationSource.ai,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecommendationCard(recommendation: recommendation),
          ),
        ),
      );

      expect(find.text('星際穿越'), findsOneWidget);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/widget/features/recommend/recommendation_card_test.dart -v`
Expected: FAIL with "RecommendationCard cannot be found"

- [ ] **Step 3: Write minimal implementation**

```dart
// lib/features/recommend/presentation/widgets/recommendation_card.dart
import 'package:flutter/material.dart';
import 'package:white_tv/features/recommend/data/models/ai_recommendation.dart';

class RecommendationCard extends StatelessWidget {
  final AIRecommendation recommendation;
  final VoidCallback? onTap;

  const RecommendationCard({
    super.key,
    required this.recommendation,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Poster
              recommendation.posterUrl != null
                  ? Image.network(
                      recommendation.posterUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholder(),
                    )
                  : _buildPlaceholder(),

              // Gradient overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.8),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title
                      Text(
                        recommendation.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Year
                      if (recommendation.year != null)
                        Text(
                          recommendation.year!,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Source tag
              Positioned(
                top: 8,
                left: 8,
                child: _buildSourceTag(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSourceTag() {
    final (emoji, text) = switch (recommendation.sourceType) {
      RecommendationSource.ai => ('🤖', 'AI'),
      RecommendationSource.history => ('📺', '偏好'),
      RecommendationSource.popular => ('🔥', '熱門'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _getTagColor().withOpacity(0.9),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$emoji $text',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getTagColor() {
    return switch (recommendation.sourceType) {
      RecommendationSource.ai => const Color(0xFFB8860B), // 琥珀色
      RecommendationSource.history => const Color(0xFF4169E1), // 藍色
      RecommendationSource.popular => const Color(0xFFDC143C), // 紅色
    };
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[800],
      child: const Center(
        child: Icon(
          Icons.movie,
          color: Colors.white54,
          size: 40,
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/widget/features/recommend/recommendation_card_test.dart -v`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/features/recommend/presentation/widgets/recommendation_card.dart test/widget/features/recommend/recommendation_card_test.dart
git commit -m "feat(recommend): add RecommendationCard widget

- Display poster, title, year
- Show source tag (AI/偏好/熱門) with colors
- Handle missing poster with placeholder
- Add widget tests

Refs: #ai-recommend-design"
```

### Task 6.2: RecommendationCarousel

- [ ] **Step 1: 創建 RecommendationCarousel**

```dart
// lib/features/recommend/presentation/widgets/recommendation_carousel.dart
import 'package:flutter/material.dart';
import 'package:white_tv/features/recommend/data/models/ai_recommendation.dart';
import 'package:white_tv/features/recommend/presentation/widgets/recommendation_card.dart';
import 'package:white_tv/features/recommend/presentation/widgets/recommendation_reason_sheet.dart';

class RecommendationCarousel extends StatelessWidget {
  final String title;
  final List<AIRecommendation> recommendations;
  final VoidCallback? onRefresh;
  final void Function(AIRecommendation)? onRecommendationTap;

  const RecommendationCarousel({
    super.key,
    required this.title,
    required this.recommendations,
    this.onRefresh,
    this.onRecommendationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (onRefresh != null)
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white70),
                  onPressed: onRefresh,
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Carousel
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: recommendations.length,
            itemBuilder: (context, index) {
              final recommendation = recommendations[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () => onRecommendationTap?.call(recommendation),
                  child: RecommendationCard(
                    recommendation: recommendation,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 6.3: RecommendationReasonSheet**

```dart
// lib/features/recommend/presentation/widgets/recommendation_reason_sheet.dart
import 'package:flutter/material.dart';
import 'package:white_tv/features/recommend/data/models/ai_recommendation.dart';

class RecommendationReasonSheet extends StatelessWidget {
  final AIRecommendation recommendation;
  final VoidCallback? onPlayTap;

  const RecommendationReasonSheet({
    super.key,
    required this.recommendation,
    this.onPlayTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '推薦理由',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white54),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Reason text
          if (recommendation.reason != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                recommendation.reason!,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Metadata
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (recommendation.type != null)
                  _buildMetadataRow('🎭', recommendation.type!),
                if (recommendation.year != null)
                  _buildMetadataRow('📅', recommendation.year!),
                _buildMetadataRow('📺', recommendation.sourceName),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Play button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onPlayTap,
              icon: const Icon(Icons.play_arrow),
              label: const Text('開始觀看'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB8860B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataRow(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        '$emoji $text',
        style: const TextStyle(
          fontSize: 14,
          color: Colors.white70,
        ),
      ),
    );
  }
}
```

- [ ] **Step 7: Commit**

```bash
git add lib/features/recommend/presentation/widgets/recommendation_carousel.dart lib/features/recommend/presentation/widgets/recommendation_reason_sheet.dart
git commit -m "feat(recommend): add RecommendationCarousel and RecommendationReasonSheet

- Add RecommendationCarousel with horizontal scrolling list
- Add RecommendationReasonSheet with reason display and play button
- Include metadata (type, year, source) in reason sheet

Refs: #ai-recommend-design"
```

---

## Task 7: 首頁整合

**Files:**
- Modify: `lib/features/home/home_store.dart`
- Modify: `lib/features/home/widgets/home_screen.dart`

- [ ] **Step 1: 更新 HomeState 和 HomeStore**

```dart
// lib/features/home/home_store.dart (新增部分)
// 在 HomeState 新增欄位
class HomeState {
  // ... existing fields ...
  final List<AIRecommendation> aiRecommendations;
  final bool isAIRecommendationsLoading;

  const HomeState({
    // ... existing fields ...
    this.aiRecommendations = const [],
    this.isAIRecommendationsLoading = false,
  });

  HomeState copyWith({
    // ... existing parameters ...
    List<AIRecommendation>? aiRecommendations,
    bool? isAIRecommendationsLoading,
  }) {
    return HomeState(
      // ... existing assignments ...
      aiRecommendations: aiRecommendations ?? this.aiRecommendations,
      isAIRecommendationsLoading: isAIRecommendationsLoading ?? this.isAIRecommendationsLoading,
    );
  }
}

// 在 HomeStore 新增方法
Future<void> loadAIRecommendations() async {
  state = state.copyWith(isAIRecommendationsLoading: true);

  try {
    final recommendations = await _repository.getRecommendations();
    state = state.copyWith(
      aiRecommendations: recommendations,
      isAIRecommendationsLoading: false,
    );
  } catch (e) {
    state = state.copyWith(isAIRecommendationsLoading: false);
  }
}
```

- [ ] **Step 2: 在 HomeScreen 加入推薦區塊**

```dart
// lib/features/home/widgets/home_screen.dart
// 在 _HomeContentState 的 build 方法中加入

if (state.aiRecommendations.isNotEmpty) ...[
  const SizedBox(height: 24),
  Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: RecommendationCarousel(
      title: '為你推薦',
      recommendations: state.aiRecommendations,
      onRefresh: () => homeStore.loadAIRecommendations(),
      onRecommendationTap: (recommendation) {
        // Navigate to detail
      },
    ),
  ),
],
```

- [ ] **Step 3: Commit**

```bash
git add lib/features/home/home_store.dart lib/features/home/widgets/home_screen.dart
git commit -m "feat(home): integrate AI recommendations into home screen

- Add aiRecommendations to HomeState
- Add loadAIRecommendations() method to HomeStore
- Add RecommendationCarousel to home screen

Refs: #ai-recommend-design"
```

---

## Task 8: 獨立 AI 推薦頁面

**Files:**
- Create: `lib/features/recommend/presentation/pages/ai_recommend_page.dart`
- Test: `test/widget/features/recommend/ai_recommend_page_test.dart`

- [ ] **Step 1: 創建頁面**

```dart
// lib/features/recommend/presentation/pages/ai_recommend_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/features/recommend/data/models/ai_recommendation.dart';
import 'package:white_tv/features/recommend/presentation/providers/ai_recommend_store.dart';
import 'package:white_tv/features/recommend/presentation/widgets/recommendation_carousel.dart';

class AIRecommendPage extends ConsumerWidget {
  const AIRecommendPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(aiRecommendStoreProvider);
    final store = ref.read(aiRecommendStoreProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        title: const Text('AI 推薦'),
        backgroundColor: const Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(child: Text('Error: ${state.error}'))
              : _buildContent(state, store),
    );
  }

  Widget _buildContent(AIRecommendState state, AIRecommendStore store) {
    if (state.recommendations.isEmpty) {
      return const Center(
        child: Text(
          '暫無推薦內容',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    // 分組顯示
    final aiRecommendations = state.recommendations
        .where((r) => r.sourceType == RecommendationSource.ai)
        .toList();
    final historyRecommendations = state.recommendations
        .where((r) => r.sourceType == RecommendationSource.history)
        .toList();
    final popularRecommendations = state.recommendations
        .where((r) => r.sourceType == RecommendationSource.popular)
        .toList();

    return RefreshIndicator(
      onRefresh: () => store.refreshRecommendations(),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          // Introduction
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '根據您的觀看記錄，我們為您精選了以下內容：',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // AI Recommendations
          if (aiRecommendations.isNotEmpty) ...[
            RecommendationCarousel(
              title: '🤖 AI 智能推薦',
              recommendations: aiRecommendations,
              onRefresh: () => store.refreshRecommendations(),
            ),
            const SizedBox(height: 24),
          ],

          // History Recommendations
          if (historyRecommendations.isNotEmpty) ...[
            RecommendationCarousel(
              title: '📺 根據您的偏好',
              recommendations: historyRecommendations,
              onRefresh: () => store.refreshRecommendations(),
            ),
            const SizedBox(height: 24),
          ],

          // Popular Recommendations
          if (popularRecommendations.isNotEmpty) ...[
            RecommendationCarousel(
              title: '🔥 熱門推薦',
              recommendations: popularRecommendations,
              onRefresh: () => store.refreshRecommendations(),
            ),
          ],
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/recommend/presentation/pages/ai_recommend_page.dart
git commit -m "feat(recommend): add AIRecommendPage for dedicated recommendation view

- Add AI Recommendations tab with AI/偏好/熱門 grouping
- Add RefreshIndicator for pull-to-refresh
- Add grouped carousel display

Refs: #ai-recommend-design"
```

---

## Task 9: BDD 測試

**Files:**
- Create: `test/bdd/recommend/ai_recommend.feature`
- Test: `test/bdd/recommend/steps/ai_recommend_steps.dart`

- [ ] **Step 1: 創建 BDD Feature**

```gherkin
# test/bdd/recommend/ai_recommend.feature
Feature: AI 推薦功能

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

  Scenario: 用戶點擊推薦理由按鈕
    Given 推薦卡片顯示中
    When 用戶點擊「為何推薦？」
    Then 底部弹窗顯示推薦理由

  Scenario: 用戶在獨立頁面查看推薦
    Given 用戶在首頁
    When 用戶點擊「AI 推薦」入口
    Then 跳轉到 AI 推薦頁面
    And 顯示所有推薦分類

  Scenario: 用戶下拉刷新推薦
    Given 用戶在 AI 推薦頁面
    When 用戶下拉刷新
    Then 推薦內容重新載入
    And 顯示新的推薦結果
```

- [ ] **Step 2: Commit**

```bash
git add test/bdd/recommend/ai_recommend.feature
git commit -m "test(bdd): add AI recommend feature tests

- Add scenarios for AI API success
- Add scenarios for AI API empty fallback
- Add scenarios for recommendation reason display
- Add scenarios for page navigation and refresh

Refs: #ai-recommend-design"
```

---

## 實作順序總結

1. ✅ **Task 1**: 模型定義 — `AIRecommendation`, `RecommendationSource`
2. ✅ **Task 2**: API Client 擴展 — 新增 `getAIRecommendations()` 方法
3. ✅ **Task 3**: Repository 實現 — 雙軌策略實現
4. ✅ **Task 4**: Service 實現 — 本地推薦邏輯
5. ✅ **Task 5**: Store 實現 — Riverpod 狀態管理
6. ✅ **Task 6**: UI Widgets — 卡片、輪播、理由弹窗
7. ✅ **Task 7**: 首頁整合 — 「為你推薦」區塊
8. ✅ **Task 8**: 獨立頁面 — AI 推薦頁面
9. ✅ **Task 9**: 測試 — TDD + BDD

---

*Plan 版本: v1.0 — AI 推薦功能實作計劃*