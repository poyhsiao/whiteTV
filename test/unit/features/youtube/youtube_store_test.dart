// TDD 紅/綠: YoutubeStore 行為測試
// 規範: ARCHITECTURE.md §5.1 P2 YouTube 整合
// 目標: 驗 loadRecommend/loadCategories/selectCategory 3 個方法的 success/error 路徑

import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/core/api/api_client.dart';
import 'package:white_tv/core/api/api_client_fallbacks.dart';
import 'package:white_tv/core/api/models.dart';
import 'package:white_tv/features/youtube/presentation/providers/youtube_store.dart';

class _StubYouTubeApiClient with ApiClientFallbacks implements ApiClient {
  List<YoutubeVideo>? recommendResult;
  Exception? recommendError;
  List<YoutubeCategory>? categoriesResult;
  Exception? categoriesError;
  Map<String, List<YoutubeVideo>>? listResults;
  Exception? listError;

  int recommendCallCount = 0;
  int categoriesCallCount = 0;
  int listCallCount = 0;
  String? lastListCategoryId;

  @override
  Future<List<YoutubeVideo>> getYoutubeRecommend() async {
    recommendCallCount++;
    if (recommendError != null) throw recommendError!;
    return recommendResult ?? const [];
  }

  @override
  Future<List<YoutubeCategory>> getYoutubeCategories() async {
    categoriesCallCount++;
    if (categoriesError != null) throw categoriesError!;
    return categoriesResult ?? const [];
  }

  @override
  Future<List<YoutubeVideo>> getYoutubeList(
    String categoryId, {
    String? page,
  }) async {
    listCallCount++;
    lastListCategoryId = categoryId;
    if (listError != null) throw listError!;
    return listResults?[categoryId] ?? const [];
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

YoutubeVideo _yt(String id) => YoutubeVideo(
  id: id,
  title: 'title-$id',
  thumbnailUrl: 'https://i.ytimg.com/vi/$id/hqdefault.jpg',
  url: 'https://youtube.com/watch?v=$id',
  duration: '5:00',
  channelTitle: 'ch',
);

YoutubeCategory _cat(String id) => YoutubeCategory(
  id: id,
  name: 'cat-$id',
  thumbnailUrl: 'https://i.ytimg.com/$id.jpg',
);

void main() {
  group('YoutubeStore.loadRecommend', () {
    test('成功 → status=loaded + recommendVideos 填入', () async {
      final api = _StubYouTubeApiClient()
        ..recommendResult = [_yt('a'), _yt('b')];
      final store = YoutubeStore(api);

      await store.loadRecommend();

      expect(store.state.status, YoutubeStatus.loaded);
      expect(store.state.recommendVideos, hasLength(2));
      expect(store.state.error, isNull);
      expect(api.recommendCallCount, 1);
    });

    test('失敗 → status=error + error 訊息', () async {
      final api = _StubYouTubeApiClient()
        ..recommendError = Exception('network down');
      final store = YoutubeStore(api);

      await store.loadRecommend();

      expect(store.state.status, YoutubeStatus.error);
      expect(store.state.error, contains('network down'));
    });
  });

  group('YoutubeStore.loadCategories', () {
    test('成功 → categories 填入', () async {
      final api = _StubYouTubeApiClient()
        ..categoriesResult = [_cat('c1'), _cat('c2')];
      final store = YoutubeStore(api);

      await store.loadCategories();

      expect(store.state.status, YoutubeStatus.loaded);
      expect(store.state.categories, hasLength(2));
    });

    test('失敗 → status=error', () async {
      final api = _StubYouTubeApiClient()
        ..categoriesError = Exception('timeout');
      final store = YoutubeStore(api);

      await store.loadCategories();

      expect(store.state.status, YoutubeStatus.error);
    });
  });

  group('YoutubeStore.selectCategory', () {
    test('成功 → videosByCategory 填入 + selectedCategoryId 設定', () async {
      final api = _StubYouTubeApiClient()
        ..listResults = {
          'cat1': [_yt('x'), _yt('y')],
        };
      final store = YoutubeStore(api);

      await store.selectCategory('cat1');

      expect(store.state.status, YoutubeStatus.loaded);
      expect(store.state.selectedCategoryId, 'cat1');
      expect(store.state.videosByCategory['cat1'], hasLength(2));
      expect(api.lastListCategoryId, 'cat1');
    });

    test('失敗 → status=error', () async {
      final api = _StubYouTubeApiClient()..listError = Exception('404');
      final store = YoutubeStore(api);

      await store.selectCategory('missing');

      expect(store.state.status, YoutubeStatus.error);
      expect(store.state.error, contains('404'));
    });
  });

  group('YoutubeStore.clear', () {
    test('重置狀態為 initial', () async {
      final api = _StubYouTubeApiClient()..recommendResult = [_yt('a')];
      final store = YoutubeStore(api);
      await store.loadRecommend();

      store.clear();

      expect(store.state.status, YoutubeStatus.initial);
      expect(store.state.recommendVideos, isEmpty);
    });
  });
}
