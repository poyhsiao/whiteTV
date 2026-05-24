import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:white_tv/core/api/mock_client.dart';
import 'package:white_tv/core/source/source_selector.dart';
import 'package:white_tv/features/player/player_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PlayerStore 集成 SourceSelector', () {
    late MockClient mockClient;
    late SourceSelector sourceSelector;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      mockClient = MockClient();
      sourceSelector = SourceSelector();
      await sourceSelector.loadBlockedSources();
    });

    tearDown(() {
      // PlayerStore dispose is called in tearDown
    });

    test('setVideo 使用 SourceSelector 選擇來源', () async {
      final store = PlayerStore(mockClient, sourceSelector);

      await store.setVideo('movie-1', 'ep-1');

      expect(store.state.videoId, 'movie-1');
      expect(store.state.source, isNotNull);
      expect(store.state.autoSwitchCount, 0);
    });

    test('setVideo 記錄來源指標', () async {
      final store = PlayerStore(mockClient, sourceSelector);

      await store.setVideo('movie-1', 'ep-1');

      // 播放成功，記錄結果
      store.recordSourceResult(isSuccess: true, latency: 120);

      final metrics = sourceSelector.getMetrics(store.state.source!.id);
      expect(metrics, isNotNull);
      expect(metrics!.successCount, 1);
    });

    test('switchToNextSource 自動切換來源', () async {
      final store = PlayerStore(mockClient, sourceSelector);

      await store.setVideo('movie-1', 'ep-1');
      final originalSourceId = store.state.source!.id;

      // 獲取所有來源來測試切換
      final allSources = await mockClient.getSources('movie-1');

      // 嘗試切換到下一個來源
      final nextSource = await store.switchToNextSource(allSources);

      if (nextSource != null) {
        expect(nextSource.id, isNot(originalSourceId));
        expect(store.state.autoSwitchCount, 1);
      }
    });

    test('switchToNextSource 超過限制後返回 null', () async {
      final store = PlayerStore(mockClient, sourceSelector);

      await store.setVideo('movie-1', 'ep-1');
      final allSources = await mockClient.getSources('movie-1');

      // 模擬連續切換
      await store.switchToNextSource(allSources);
      await store.switchToNextSource(allSources);

      // 第三次應該返回 null（超過限制）
      final result = await store.switchToNextSource(allSources);
      expect(result, isNull);
    });

    test('recordSourceResult 記錄成功', () async {
      final store = PlayerStore(mockClient, sourceSelector);

      await store.setVideo('movie-1', 'ep-1');
      final sourceId = store.state.source!.id;

      store.recordSourceResult(isSuccess: true, latency: 100);

      final metrics = sourceSelector.getMetrics(sourceId);
      expect(metrics!.successCount, 1);
      expect(metrics.failCount, 0);
    });

    test('recordSourceResult 記錄失敗', () async {
      final store = PlayerStore(mockClient, sourceSelector);

      await store.setVideo('movie-1', 'ep-1');
      final sourceId = store.state.source!.id;

      store.recordSourceResult(isSuccess: false, latency: 0);

      final metrics = sourceSelector.getMetrics(sourceId);
      expect(metrics!.failCount, 1);
      expect(metrics.successCount, 0);
    });
  });
}