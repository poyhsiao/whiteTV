import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/core/api/mock_client.dart';
import 'package:white_tv/features/youtube/presentation/providers/youtube_store.dart';

// ============================================================================
// Helper
// ============================================================================

YoutubeStore _createStore() {
  return YoutubeStore(MockClient());
}

// ============================================================================
// BDD Test Suite — YouTube Feature
// ============================================================================

void main() {
  group('YouTube BDD Tests', () {
    // -------------------------------------------------------------------------
    // Scenario: Load YouTube recommendations
    // -------------------------------------------------------------------------
    group('Scenario: User loads YouTube recommendations', () {
      test(
        'GIVEN store is initial '
        'WHEN loadRecommend is called '
        'THEN recommendVideos are populated',
        () async {
          // Arrange
          final store = _createStore();
          expect(store.state.recommendVideos, isEmpty);

          // Act
          await store.loadRecommend();

          // Assert
          expect(store.state.status, YoutubeStatus.loaded);
          expect(store.state.recommendVideos, isNotEmpty);
          expect(store.state.recommendVideos.length, 3);
        },
      );

      test(
        'GIVEN store is initial '
        'WHEN loadRecommend is called '
        'THEN status transitions to loaded',
        () async {
          // Arrange
          final store = _createStore();
          expect(store.state.status, YoutubeStatus.initial);

          // Act
          await store.loadRecommend();

          // Assert
          expect(store.state.status, YoutubeStatus.loaded);
        },
      );

      test(
        'GIVEN API returns videos '
        'WHEN loadRecommend is called '
        'THEN video titles are correct',
        () async {
          // Arrange
          final store = _createStore();

          // Act
          await store.loadRecommend();

          // Assert
          expect(store.state.recommendVideos[0].title, '熱門影片 1');
          expect(store.state.recommendVideos[1].title, '熱門影片 2');
        },
      );
    });

    // -------------------------------------------------------------------------
    // Scenario: Load YouTube categories
    // -------------------------------------------------------------------------
    group('Scenario: User loads YouTube categories', () {
      test(
        'GIVEN store is initial '
        'WHEN loadCategories is called '
        'THEN categories are populated',
        () async {
          // Arrange
          final store = _createStore();
          expect(store.state.categories, isEmpty);

          // Act
          await store.loadCategories();

          // Assert
          expect(store.state.status, YoutubeStatus.loaded);
          expect(store.state.categories, isNotEmpty);
          expect(store.state.categories.length, 4);
        },
      );

      test(
        'GIVEN API returns categories '
        'WHEN loadCategories is called '
        'THEN category names are correct',
        () async {
          // Arrange
          final store = _createStore();

          // Act
          await store.loadCategories();

          // Assert
          expect(store.state.categories[0].name, '音樂');
          expect(store.state.categories[1].name, '遊戲');
          expect(store.state.categories[2].name, '娛樂');
        },
      );

      test(
        'GIVEN categories are loaded '
        'WHEN selectCategory is called '
        'THEN selectedCategoryId is updated',
        () async {
          // Arrange
          final store = _createStore();
          await store.loadCategories();

          // Act
          await store.selectCategory('gaming');

          // Assert
          expect(store.state.selectedCategoryId, 'gaming');
        },
      );

      test(
        'GIVEN category is selected '
        'WHEN selectCategory is called '
        'THEN videosByCategory is populated',
        () async {
          // Arrange
          final store = _createStore();
          await store.loadCategories();

          // Act
          await store.selectCategory('music');

          // Assert
          expect(store.state.videosByCategory.containsKey('music'), isTrue);
          expect(store.state.videosByCategory['music'], isNotEmpty);
        },
      );

      test(
        'GIVEN category is selected '
        'WHEN selectCategory is called with different category '
        'THEN new category videos are loaded alongside previous',
        () async {
          // Arrange
          final store = _createStore();
          await store.selectCategory('music');

          // Act
          await store.selectCategory('gaming');

          // Assert
          expect(store.state.videosByCategory.containsKey('music'), isTrue);
          expect(store.state.videosByCategory.containsKey('gaming'), isTrue);
        },
      );
    });

    // -------------------------------------------------------------------------
    // Scenario: Clear YouTube state
    // -------------------------------------------------------------------------
    group('Scenario: User clears YouTube state', () {
      test(
        'GIVEN store has loaded data '
        'WHEN clear is called '
        'THEN state is reset to initial',
        () async {
          // Arrange
          final store = _createStore();
          await store.loadRecommend();
          await store.loadCategories();
          await store.selectCategory('music');

          // Act
          store.clear();

          // Assert
          expect(store.state.status, YoutubeStatus.initial);
          expect(store.state.recommendVideos, isEmpty);
          expect(store.state.categories, isEmpty);
          expect(store.state.videosByCategory, isEmpty);
          expect(store.state.selectedCategoryId, isNull);
        },
      );
    });

    // -------------------------------------------------------------------------
    // Scenario: Loading state transitions
    // -------------------------------------------------------------------------
    group('Scenario: Loading state transitions', () {
      test(
        'GIVEN store is initial '
        'WHEN loadRecommend starts '
        'THEN status is loading',
        () async {
          // Arrange
          final store = _createStore();

          // Act
          final future = store.loadRecommend();
          expect(store.state.status, YoutubeStatus.loading);

          // Assert
          await future;
          expect(store.state.status, YoutubeStatus.loaded);
        },
      );

      test(
        'GIVEN store is initial '
        'WHEN loadCategories starts '
        'THEN status is loading',
        () async {
          // Arrange
          final store = _createStore();

          // Act
          final future = store.loadCategories();
          expect(store.state.status, YoutubeStatus.loading);

          // Assert
          await future;
          expect(store.state.status, YoutubeStatus.loaded);
        },
      );

      test(
        'GIVEN store is initial '
        'WHEN selectCategory starts '
        'THEN status is loading',
        () async {
          // Arrange
          final store = _createStore();

          // Act
          final future = store.selectCategory('music');
          expect(store.state.status, YoutubeStatus.loading);

          // Assert
          await future;
          expect(store.state.status, YoutubeStatus.loaded);
        },
      );
    });

    // -------------------------------------------------------------------------
    // Scenario: Error handling
    // -------------------------------------------------------------------------
    group('Scenario: Error handling', () {
      test(
        'GIVEN MockClient succeeds '
        'WHEN loadRecommend is called '
        'THEN status is loaded with no error',
        () async {
          // Arrange
          final store = _createStore();

          // Act
          await store.loadRecommend();

          // Assert
          expect(store.state.status, YoutubeStatus.loaded);
          expect(store.state.error, isNull);
        },
      );
    });

    // -------------------------------------------------------------------------
    // Scenario: 中文 BDD 驗收情境
    // -------------------------------------------------------------------------
    group('中文 BDD 驗收情境', () {
      test(
        'GIVEN 用戶在首頁 '
        'WHEN 用戶滾動到 YouTube 專區 '
        'THEN 顯示 YouTube 影片列表',
        () async {
          // Arrange
          final store = _createStore();

          // Act
          await store.loadRecommend();

          // Assert
          expect(store.state.status, YoutubeStatus.loaded);
          expect(store.state.recommendVideos, isNotEmpty);
          expect(store.state.recommendVideos.first.title, isNotEmpty);
        },
      );

      test(
        'GIVEN 用戶進入 YouTube 分類頁面 '
        'WHEN 頁面載入完成 '
        'THEN 顯示分類導航列',
        () async {
          // Arrange
          final store = _createStore();

          // Act
          await store.loadCategories();

          // Assert
          expect(store.state.categories, isNotEmpty);
          expect(store.state.categories.first.name, '音樂');
        },
      );

      test(
        'GIVEN 用戶在 YouTube 分類頁面 '
        'WHEN 用戶點擊第二個分類 '
        'THEN 載入第二個分類的影片',
        () async {
          // Arrange
          final store = _createStore();
          await store.loadCategories();

          // Act
          await store.selectCategory('gaming');

          // Assert
          expect(store.state.selectedCategoryId, 'gaming');
          expect(store.state.videosByCategory['gaming'], isNotEmpty);
        },
      );

      test(
        'GIVEN 用戶已選擇分類 '
        'WHEN 用戶切換到其他分類 '
        'THEN 影片網格更新顯示',
        () async {
          // Arrange
          final store = _createStore();
          await store.selectCategory('music');
          await store.selectCategory('gaming');

          // Assert
          expect(store.state.videosByCategory['music'], isNotEmpty);
          expect(store.state.videosByCategory['gaming'], isNotEmpty);
        },
      );
    });
  });
}
