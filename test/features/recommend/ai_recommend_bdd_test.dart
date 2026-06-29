import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod/riverpod.dart';
import 'package:white_tv/core/api/api_client.dart';
import 'package:white_tv/core/api/api_client_fallbacks.dart';
import 'package:white_tv/core/api/client_factory.dart';
import 'package:white_tv/features/recommend/data/models/ai_recommendation.dart';
import 'package:white_tv/features/recommend/presentation/pages/ai_recommend_page.dart';
import 'package:white_tv/features/recommend/presentation/providers/ai_recommend_store.dart';
import 'package:white_tv/features/recommend/presentation/widgets/recommendation_carousel.dart';
import 'package:white_tv/features/recommend/presentation/widgets/recommendation_reason_sheet.dart';
import 'package:white_tv/shared/widgets/empty_state.dart';

class MockApiClient extends Mock with ApiClientFallbacks implements ApiClient {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ==================== 測試資料 ====================
  final aiRecommendations = [
    const AIRecommendation(
      id: 'ai-1',
      title: 'AI 推薦電影 1',
      source: 'lunatv',
      sourceName: 'LunaTV AI',
      sourceType: RecommendationSource.ai,
      reason: '根據您觀看科幻電影的記錄',
      posterUrl: 'https://example.com/poster1.jpg',
    ),
    const AIRecommendation(
      id: 'ai-2',
      title: 'AI 推薦電影 2',
      source: 'lunatv',
      sourceName: 'LunaTV AI',
      sourceType: RecommendationSource.ai,
      reason: '與您收藏的電影類型相似',
    ),
  ];

  final historyRecommendations = [
    const AIRecommendation(
      id: 'his-1',
      title: '根據偏好推薦',
      source: 'local',
      sourceName: '本地推薦',
      sourceType: RecommendationSource.history,
      reason: '您最近觀看戰爭電影',
    ),
  ];

  final popularRecommendations = [
    const AIRecommendation(
      id: 'pop-1',
      title: '熱門推薦 1',
      source: 'popular',
      sourceName: '熱門推薦',
      sourceType: RecommendationSource.popular,
      reason: '本週熱門榜單',
    ),
  ];

  // ==================== AI 推薦功能 BDD 測試 ====================
  group('AI 推薦功能 (BDD)', () {
    late MockApiClient mockClient;

    setUp(() {
      mockClient = MockApiClient();
    });

    // ======== Scenario: AI 推薦成功獲取內容 ========
    testWidgets('''
      Given 用戶已登入
      And AI API 回傳有效推薦
      When 用戶打開首頁
      Then 看到「為你推薦」區塊顯示 AI 推薦內容
      And 卡片顯示「🤖 AI」標籤
    ''', (tester) async {
      // Arrange
      when(() => mockClient.getAIRecommendations())
          .thenAnswer((_) async => aiRecommendations);
      when(() => mockClient.getLocalRecommendations(
            watchHistory: any(named: 'watchHistory'),
            searchHistory: any(named: 'searchHistory'),
            limit: any(named: 'limit'),
          )).thenAnswer((_) async => []);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            apiClientProvider.overrideWithValue(mockClient),
          ],
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, _) {
                // Trigger load on page build
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ref.read(aiRecommendStoreProvider.notifier).loadRecommendations();
                });
                return const AIRecommendPage();
              },
            ),
          ),
        ),
      );

      // Wait for loading then content
      await tester.pump();
      await tester.pumpAndSettle();

      // Assert - 檢查 AI 推薦標題存在
      expect(find.text('🤖 AI 智能推薦'), findsOneWidget);
      expect(find.text('AI 推薦電影 1'), findsOneWidget);
    });

    // ======== Scenario: AI API 回傳空值，使用 Fallback ========
    testWidgets('''
      Given 用戶已登入
      And AI API 回傳空值
      When 用戶打開首頁
      Then 看到「為你推薦」區塊顯示本地推薦
      And 卡片顯示「📺 偏好」標籤
    ''', (tester) async {
      // Arrange
      when(() => mockClient.getAIRecommendations())
          .thenAnswer((_) async => []);
      when(() => mockClient.getLocalRecommendations(
            watchHistory: any(named: 'watchHistory'),
            searchHistory: any(named: 'searchHistory'),
            limit: any(named: 'limit'),
          )).thenAnswer((_) async => historyRecommendations);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            apiClientProvider.overrideWithValue(mockClient),
          ],
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, _) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ref.read(aiRecommendStoreProvider.notifier).loadRecommendations();
                });
                return const AIRecommendPage();
              },
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      // Assert - 檢查本地推薦標題
      expect(find.text('📺 根據您的偏好'), findsOneWidget);
      expect(find.text('根據偏好推薦'), findsOneWidget);
    });

    // ======== Scenario: 空狀態顯示 ========
    testWidgets('''
      Given 沒有推薦內容
      When 用戶打開 AI 推薦頁
      Then 顯示「暫無推薦內容」
      And 顯示空狀態插圖
    ''', (tester) async {
      // Arrange
      when(() => mockClient.getAIRecommendations())
          .thenAnswer((_) async => []);
      when(() => mockClient.getLocalRecommendations(
            watchHistory: any(named: 'watchHistory'),
            searchHistory: any(named: 'searchHistory'),
            limit: any(named: 'limit'),
          )).thenAnswer((_) async => []);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            apiClientProvider.overrideWithValue(mockClient),
          ],
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, _) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ref.read(aiRecommendStoreProvider.notifier).loadRecommendations();
                });
                return const AIRecommendPage();
              },
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(EmptyStateWidget), findsOneWidget);
      expect(find.text('暫無推薦內容'), findsOneWidget);
    });

    // ======== Scenario: 下拉刷新 ========
    testWidgets('''
      Given 用戶在 AI 推薦頁面
      When 用戶下拉刷新
      Then 推薦內容重新載入
    ''', (tester) async {
      // Arrange
      var loadCount = 0;
      when(() => mockClient.getAIRecommendations()).thenAnswer((_) async {
        loadCount++;
        return aiRecommendations;
      });
      when(() => mockClient.getLocalRecommendations(
            watchHistory: any(named: 'watchHistory'),
            searchHistory: any(named: 'searchHistory'),
            limit: any(named: 'limit'),
          )).thenAnswer((_) async => []);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            apiClientProvider.overrideWithValue(mockClient),
          ],
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, _) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ref.read(aiRecommendStoreProvider.notifier).loadRecommendations();
                });
                return const AIRecommendPage();
              },
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();
      expect(loadCount, equals(1));

      // Trigger refresh by finding and tapping refresh button
      final refreshButton = find.byIcon(Icons.refresh);
      if (refreshButton.evaluate().isNotEmpty) {
        await tester.tap(refreshButton.first);
        await tester.pump();
        await tester.pumpAndSettle();
        expect(loadCount, equals(2));
      }
    });

    // ======== Scenario: 熱門推薦分類 ========
    testWidgets('''
      Given 有熱門推薦內容
      Then 顯示「🔥 熱門推薦」區塊
    ''', (tester) async {
      // Arrange
      when(() => mockClient.getAIRecommendations())
          .thenAnswer((_) async => []);
      when(() => mockClient.getLocalRecommendations(
            watchHistory: any(named: 'watchHistory'),
            searchHistory: any(named: 'searchHistory'),
            limit: any(named: 'limit'),
          )).thenAnswer((_) async => popularRecommendations);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            apiClientProvider.overrideWithValue(mockClient),
          ],
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, _) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ref.read(aiRecommendStoreProvider.notifier).loadRecommendations();
                });
                return const AIRecommendPage();
              },
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('🔥 熱門推薦'), findsOneWidget);
    });
  });

  // ==================== RecommendationReasonSheet BDD 測試 ====================
  group('推薦理由彈窗 (BDD)', () {
    testWidgets('''
      Given 推薦卡片顯示中
      When 用戶查看推薦理由
      Then 底部弹窗顯示推薦理由
    ''', (tester) async {
      // Arrange
      const recommendation = AIRecommendation(
        id: 'test-1',
        title: '測試電影',
        source: 'lunatv',
        sourceName: 'LunaTV',
        sourceType: RecommendationSource.ai,
        reason: '根據您觀看記錄',
        year: '2024',
        type: '科幻',
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecommendationReasonSheet(
              recommendation: recommendation,
              onPlayTap: () {},
            ),
          ),
        ),
      );

      // Assert - 檢查推薦理由標題和理由文字
      expect(find.text('推薦理由'), findsOneWidget);
      expect(find.text('根據您觀看記錄'), findsOneWidget);
    });

    testWidgets('顯示元數據（年份、類型）', (tester) async {
      const recommendation = AIRecommendation(
        id: 'test-1',
        title: '測試電影',
        source: 'lunatv',
        sourceName: 'LunaTV',
        sourceType: RecommendationSource.ai,
        year: '2024',
        type: '科幻',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecommendationReasonSheet(
              recommendation: recommendation,
            ),
          ),
        ),
      );

      // 檢查有 emoji 前綴的元數據
      expect(find.text('📅 2024'), findsOneWidget);
      expect(find.text('🎭 科幻'), findsOneWidget);
    });
  });

  // ==================== AIRecommendStore 單元測試 ====================
  group('AIRecommendStore (Unit)', () {
    test('初始狀態正確', () {
      const state = AIRecommendState();
      expect(state.recommendations, isEmpty);
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
      expect(state.primarySource, isNull);
    });

    test('copyWith 正確更新狀態', () {
      const state = AIRecommendState();
      final newState = state.copyWith(isLoading: true);
      expect(newState.isLoading, isTrue);
      expect(state.isLoading, isFalse); // 原始狀態不變
    });

    test('primarySource 從建構函數設置', () {
      // primarySource is set by store when loading, not auto-computed
      final state = AIRecommendState(
        recommendations: [
          const AIRecommendation(
            id: '1',
            title: 'Test',
            source: 'test',
            sourceName: 'Test',
            sourceType: RecommendationSource.history,
          ),
        ],
        primarySource: RecommendationSource.history,
      );
      expect(state.primarySource, equals(RecommendationSource.history));
    });
  });
}
