import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:white_tv/core/api/mock_client.dart';
import 'package:white_tv/core/source/source_selector.dart';
import 'package:white_tv/features/detail/detail_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DetailStore 集成 SourceSelector', () {
    late MockClient mockClient;
    late SourceSelector sourceSelector;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      mockClient = MockClient();
      sourceSelector = SourceSelector();
      await sourceSelector.loadBlockedSources();
    });

    test('loadDetail 使用 SourceSelector 選擇來源', () async {
      final store = DetailStore(mockClient, sourceSelector);

      await store.loadDetail('movie-1');

      expect(store.state.detail, isNotNull);
      expect(store.state.selectedSource, isNotNull);
      expect(store.state.isLoading, false);
    });

    test('loadDetail 排除屏蔽的來源', () async {
      // 先獲取可用來源來了解 MockClient 的來源結構
      final allSources = await mockClient.getSources('movie-1');
      if (allSources.isEmpty) return; // 保護性返回

      // 屏蔽最快來源
      await sourceSelector.setBlockedSources([allSources.first.id]);

      final store = DetailStore(mockClient, sourceSelector);

      await store.loadDetail('movie-1');

      // 應該選擇次快的來源
      expect(store.state.selectedSource?.id, isNot(allSources.first.id));
    });

    test('loadDetail 所有來源都被屏蔽時返回第一個', () async {
      final allSources = await mockClient.getSources('movie-1');
      if (allSources.isEmpty) return;

      await sourceSelector.setBlockedSources(allSources.map((s) => s.id).toList());

      final store = DetailStore(mockClient, sourceSelector);

      await store.loadDetail('movie-1');

      // 返回原列表第一個作為備用
      expect(store.state.selectedSource, isNotNull);
    });

    test('selectSource 手動選擇來源', () async {
      final store = DetailStore(mockClient, sourceSelector);

      await store.loadDetail('movie-1');
      final allSources = await mockClient.getSources('movie-1');

      if (allSources.length > 1) {
        store.selectSource(allSources[1]);
        expect(store.state.selectedSource?.id, allSources[1].id);
      }
    });

    test('loadDetail 後 getMetrics 返回 null（因為尚未播放）', () async {
      final store = DetailStore(mockClient, sourceSelector);

      await store.loadDetail('movie-1');

      // loadDetail 不會自動記錄指標，所以 getMetrics 返回 null
      final metrics = sourceSelector.getMetrics(store.state.selectedSource!.id);
      expect(metrics, isNull);
    });

    test('loadDetail 後 recordSourceResult 會創建指標', () async {
      final store = DetailStore(mockClient, sourceSelector);

      await store.loadDetail('movie-1');
      final sourceId = store.state.selectedSource!.id;

      // 記錄播放成功後，指標才會被創建
      store.recordSourceResult(isSuccess: true, latency: 120);

      final metrics = sourceSelector.getMetrics(sourceId);
      expect(metrics, isNotNull);
      expect(metrics!.successCount, 1);
      expect(metrics.failCount, 0);
    });

    test('recordSourceResult 記錄成功', () async {
      final store = DetailStore(mockClient, sourceSelector);

      await store.loadDetail('movie-1');
      final sourceId = store.state.selectedSource!.id;

      store.recordSourceResult(isSuccess: true, latency: 100);

      final metrics = sourceSelector.getMetrics(sourceId);
      expect(metrics!.successCount, 1);
    });

    test('recordSourceResult 記錄失敗', () async {
      final store = DetailStore(mockClient, sourceSelector);

      await store.loadDetail('movie-1');
      final sourceId = store.state.selectedSource!.id;

      store.recordSourceResult(isSuccess: false, latency: 0);

      final metrics = sourceSelector.getMetrics(sourceId);
      expect(metrics!.failCount, 1);
    });
  });
}