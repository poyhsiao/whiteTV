import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/core/api/mock_client.dart';
import 'package:white_tv/features/youtube/presentation/providers/youtube_store.dart';

// ============================================================================
// YouTube Feature BDD Steps
//
// 對應 feature: test/bdd/features/youtube.feature
// 涵蓋場景:
//   1. 用戶瀏覽 YouTube 推薦影片
//   2. 用戶點擊 YouTube 影片
//   3. 用戶瀏覽 YouTube 分類
//   4. 用戶選擇不同分類
//   5. 用戶切換回首頁 YouTube 專區
// ============================================================================

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('YouTube Feature BDD Steps', () {
    late ProviderContainer container;
    late YoutubeStore store;

    setUp(() {
      // 每個測試使用獨立的 ProviderContainer 與 Store,避免狀態污染。
      container = ProviderContainer(
        overrides: [
          youtubeStoreProvider.overrideWith((ref) {
            return YoutubeStore(MockClient());
          }),
        ],
      );
      // 用 listen 訂閱 provider,以避免 autoDispose 在讀取後立即釋放 notifier。
      container.listen(youtubeStoreProvider, (_, __) {}, fireImmediately: true);
      store = container.read(youtubeStoreProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    // -------------------------------------------------------------------------
    // Scenario 1: 用戶瀏覽 YouTube 推薦影片
    // -------------------------------------------------------------------------
    test('Scenario: 用戶瀏覽 YouTube 推薦影片 — '
        'GIVEN 用戶在首頁 WHEN 用戶滾動到 YouTube 專區 '
        'THEN 顯示 YouTube 影片列表 AND 顯示影片標題和時長', () async {
      // Given 用戶在首頁 (store 初始為 initial)
      expect(store.state.status, YoutubeStatus.initial);
      expect(store.state.recommendVideos, isEmpty);

      // When 用戶滾動到 YouTube 專區 — 觸發載入推薦
      await store.loadRecommend();

      // Then 顯示 YouTube 影片列表
      final state = container.read(youtubeStoreProvider);
      expect(state.status, YoutubeStatus.loaded);
      expect(state.recommendVideos, isNotEmpty);

      // And 顯示影片標題和時長
      final firstVideo = state.recommendVideos.first;
      expect(firstVideo.title, isNotEmpty);
      // 時長欄位在 MockClient 中以 "MM:SS" 格式提供
      expect(firstVideo.duration, isNotNull);
    });

    // -------------------------------------------------------------------------
    // Scenario 2: 用戶點擊 YouTube 影片 — 驗證導航資料已就緒
    // -------------------------------------------------------------------------
    test('Scenario: 用戶點擊 YouTube 影片 — '
        'GIVEN 用戶在首頁 YouTube 專區 WHEN 用戶點擊某個影片 '
        'THEN 導航到 YouTube 播放頁面', () async {
      // Given 用戶在首頁 YouTube 專區 (已載入推薦影片)
      await store.loadRecommend();
      final state = container.read(youtubeStoreProvider);
      expect(state.recommendVideos, isNotEmpty);

      // When 用戶點擊某個影片 — 模擬選取第一個影片
      final selectedVideo = state.recommendVideos.first;

      // Then 導航到 YouTube 播放頁面所需的必要資料 (id / url) 已就緒
      expect(selectedVideo.id, isNotEmpty);
      // router '/youtube/:id' 會以 videoId 為路徑參數,url 為 query string
      // 此處驗證必要欄位存在,實際導航在 widget/integration 測試中驗證
    });

    // -------------------------------------------------------------------------
    // Scenario 3: 用戶瀏覽 YouTube 分類
    // -------------------------------------------------------------------------
    test('Scenario: 用戶瀏覽 YouTube 分類 — '
        'GIVEN 用戶進入 YouTube 分類頁面 WHEN 頁面載入完成 '
        'THEN 顯示分類導航列 AND 顯示預設分類的影片網格', () async {
      // Given 用戶進入 YouTube 分類頁面 (YoutubeCategoryScreen.initState 會呼叫 loadCategories)
      await store.loadCategories();

      // When 頁面載入完成
      final state = container.read(youtubeStoreProvider);
      expect(state.status, YoutubeStatus.loaded);

      // Then 顯示分類導航列
      expect(state.categories, isNotEmpty);
      // 分類至少應有 name 欄位可供導航列顯示
      expect(state.categories.first.name, isNotEmpty);

      // And 顯示預設分類的影片網格 — 模擬載入第一個分類
      final defaultCategoryId = state.categories.first.id;
      await store.selectCategory(defaultCategoryId);

      final loadedState = container.read(youtubeStoreProvider);
      expect(loadedState.selectedCategoryId, defaultCategoryId);
      expect(loadedState.videosByCategory[defaultCategoryId], isNotEmpty);
    });

    // -------------------------------------------------------------------------
    // Scenario 4: 用戶選擇不同分類
    // -------------------------------------------------------------------------
    test('Scenario: 用戶選擇不同分類 — '
        'GIVEN 用戶在 YouTube 分類頁面 AND 已選擇第一個分類 '
        'WHEN 用戶點擊第二個分類 THEN 載入第二個分類的影片 AND 更新影片網格顯示', () async {
      // Given 用戶在 YouTube 分類頁面
      await store.loadCategories();
      final categories = container.read(youtubeStoreProvider).categories;
      expect(
        categories.length,
        greaterThanOrEqualTo(2),
        reason: '測試需要至少兩個分類才能切換',
      );

      // And 已選擇第一個分類
      final firstCategoryId = categories[0].id;
      final secondCategoryId = categories[1].id;
      await store.selectCategory(firstCategoryId);
      expect(
        container.read(youtubeStoreProvider).selectedCategoryId,
        firstCategoryId,
      );

      // When 用戶點擊第二個分類
      await store.selectCategory(secondCategoryId);

      // Then 載入第二個分類的影片
      final state = container.read(youtubeStoreProvider);
      expect(state.selectedCategoryId, secondCategoryId);
      expect(state.videosByCategory[secondCategoryId], isNotEmpty);

      // And 更新影片網格顯示 — 第一個分類的影片也應保留於 map 中
      expect(state.videosByCategory.containsKey(firstCategoryId), isTrue);
      expect(state.videosByCategory[firstCategoryId], isNotEmpty);
    });

    // -------------------------------------------------------------------------
    // Scenario 5: 用戶切換回首頁 YouTube 專區
    // -------------------------------------------------------------------------
    test('Scenario: 用戶切換回首頁 YouTube 專區 — '
        'GIVEN 用戶在 YouTube 分類頁面 WHEN 用戶返回首頁 '
        'THEN 首頁顯示 YouTube 專區', () async {
      // Given 用戶在 YouTube 分類頁面 (已進入分類並載入影片)
      await store.loadCategories();
      await store.selectCategory(
        container.read(youtubeStoreProvider).categories.first.id,
      );
      expect(
        container.read(youtubeStoreProvider).selectedCategoryId,
        isNotNull,
      );

      // When 用戶返回首頁 — 模擬清除分類狀態並重新載入推薦
      store.clear();
      await store.loadRecommend();

      // Then 首頁顯示 YouTube 專區 (recommendVideos 已就緒供 YoutubeSection 顯示)
      final state = container.read(youtubeStoreProvider);
      expect(state.status, YoutubeStatus.loaded);
      expect(state.recommendVideos, isNotEmpty);
      // 回到首頁後不應殘留分類選取狀態
      expect(state.selectedCategoryId, isNull);
    });
  });
}
