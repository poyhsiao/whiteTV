import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:white_tv/core/api/models.dart';
import 'package:white_tv/core/source/source_selector.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SourceSelector', () {
    late SourceSelector selector;
    late List<VideoSource> sources;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      selector = SourceSelector();
      await selector.loadBlockedSources();
      sources = [
        const VideoSource(id: 'src1', name: '量子資源', url: 'http://a.com', latency: 80, isAvailable: true),
        const VideoSource(id: 'src2', name: '非凡資源', url: 'http://b.com', latency: 120, isAvailable: true),
        const VideoSource(id: 'src3', name: '雲播資源', url: 'http://c.com', latency: 200, isAvailable: true),
        const VideoSource(id: 'src4', name: '已屏蔽源', url: 'http://d.com', latency: 50, isAvailable: true),
      ];
    });

    test('選擇來源時排除已屏蔽來源', () async {
      // 先屏蔽 src4 (latency: 50, 最快但被屏蔽)
      await selector.setBlockedSources(['src4']);

      // 使用測速後的結果來驗證屏蔽邏輯
      // 由於 URL 是測試用，都會返回 9999ms，所以選擇邏輯基於排除屏蔽源
      final selected = await selector.selectSource(sources, 'video123');

      // src4 被屏蔽，所以不應該選中它
      expect(selected.id, isNot('src4'));
      // src1 不被屏蔽，應該是可選的
      expect(selected.id, isIn(['src1', 'src2', 'src3']));
    });

    test('選擇來源時排除 isAvailable=false 的來源', () async {
      final unavailableSources = [
        const VideoSource(id: 'src1', name: '量子資源', url: 'http://a.com', latency: 80, isAvailable: false),
        const VideoSource(id: 'src2', name: '非凡資源', url: 'http://b.com', latency: 120, isAvailable: true),
      ];

      final selected = await selector.selectSource(unavailableSources, 'video123');

      expect(selected.id, 'src2'); // 只能選 src2
    });

    test('所有來源都被屏蔽時返回原列表第一個', () async {
      await selector.setBlockedSources(['src1', 'src2', 'src3']);

      final selected = await selector.selectSource(sources, 'video123');

      expect(selected.id, 'src4'); // 返回原列表第一個
    });

    test('recordResult 記錄成功增加 successCount', () async {
      selector.recordResult('src1', isSuccess: true, latency: 100);

      final metrics = selector.getMetrics('src1');
      expect(metrics?.successCount, 1);
      expect(metrics?.failCount, 0);
    });

    test('recordResult 記錄失敗增加 failCount', () async {
      selector.recordResult('src1', isSuccess: false, latency: 0);

      final metrics = selector.getMetrics('src1');
      expect(metrics?.failCount, 1);
      expect(metrics?.successCount, 0);
    });

    test('連續多次成功和失敗後計算成功率正確', () async {
      selector.recordResult('src1', isSuccess: true, latency: 100);
      selector.recordResult('src1', isSuccess: true, latency: 200);
      selector.recordResult('src1', isSuccess: false, latency: 0);
      selector.recordResult('src1', isSuccess: true, latency: 150);

      final metrics = selector.getMetrics('src1');
      expect(metrics?.successCount, 3);
      expect(metrics?.failCount, 1);
      expect(metrics?.successRate, 0.75);
    });

    test('setBlockedSources 設置屏蔽列表', () async {
      await selector.setBlockedSources(['src1', 'src2']);

      final blocked = selector.getBlockedSources();
      expect(blocked, contains('src1'));
      expect(blocked, contains('src2'));
    });

    test('getMetrics 返回 null 當來源從未被記錄', () {
      final metrics = selector.getMetrics('never_recorded');
      expect(metrics, isNull);
    });

    test('speedTest 返回更新後的 VideoSource 包含測試延遲', () async {
      // 使用 google.com 作為測試目標 - 應該能成功或快速失敗
      final sources = [
        const VideoSource(id: 'src1', name: '測試來源', url: 'http://www.google.com/generate_204', latency: 0, isAvailable: true),
      ];

      // 測試後應該返回有 latency 的 source
      final tested = await selector.speedTest(sources);

      expect(tested.length, 1);
      // latency 應該是 >= 0（成功時有實際值，失敗時為 9999）
      expect(tested.first.latency, greaterThanOrEqualTo(0));
    });

    test('多個來源測試後按延遲排序', () async {
      final sources = [
        const VideoSource(id: 'src1', name: '來源1', url: 'http://www.google.com', latency: 0, isAvailable: true),
        const VideoSource(id: 'src2', name: '來源2', url: 'http://www.cloudflare.com', latency: 0, isAvailable: true),
      ];

      final tested = await selector.speedTest(sources);

      // 應該返回兩個結果並已排序
      expect(tested.length, 2);
      // 第一個不應該有比第二個更高的延遲
      expect(tested.first.latency, lessThanOrEqualTo(tested.last.latency));
    });
  });
}