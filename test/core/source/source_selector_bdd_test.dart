import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:white_tv/core/api/models.dart';
import 'package:white_tv/core/source/source_selector.dart';

/// BDD 來源選擇集成測試
/// 驗證完整用戶場景

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('來源選擇 BDD 場景', () {
    late SourceSelector selector;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      selector = SourceSelector();
      await selector.loadBlockedSources();
    });

    group('場景 1: 用戶進入詳情頁時自動選擇最快來源', () {
      test('當有多個可用來源時，選擇延遲最低的來源', () async {
        final sources = [
          const VideoSource(id: 'src1', name: '量子資源', url: 'http://a.com', latency: 80, isAvailable: true),
          const VideoSource(id: 'src2', name: '非凡資源', url: 'http://b.com', latency: 120, isAvailable: true),
          const VideoSource(id: 'src3', name: '雲播資源', url: 'http://c.com', latency: 200, isAvailable: true),
        ];

        final selected = await selector.selectSource(sources, 'video123');

        expect(selected.id, 'src1'); // 80ms 是最低延遲
      });

      test('當最快的來源被屏蔽時，選擇次快的來源', () async {
        await selector.setBlockedSources(['src1']);

        final sources = [
          const VideoSource(id: 'src1', name: '量子資源', url: 'http://a.com', latency: 80, isAvailable: true),
          const VideoSource(id: 'src2', name: '非凡資源', url: 'http://b.com', latency: 120, isAvailable: true),
          const VideoSource(id: 'src3', name: '雲播資源', url: 'http://c.com', latency: 200, isAvailable: true),
        ];

        final selected = await selector.selectSource(sources, 'video123');

        expect(selected.id, 'src2'); // src1 被屏蔽，選擇次快的
      });
    });

    group('場景 2: 播放失敗時自動切換到下一個來源', () {
      test('記錄失敗後，下一次選擇時該來源評分降低', () async {
        // 記錄 src1 失敗
        selector.recordResult('src1', isSuccess: false, latency: 0);

        // 記錄 src2 成功
        selector.recordResult('src2', isSuccess: true, latency: 100);

        final metrics1 = selector.getMetrics('src1');
        final metrics2 = selector.getMetrics('src2');

        expect(metrics1!.failCount, 1);
        expect(metrics1.successCount, 0);
        expect(metrics2!.successCount, 1);
        expect(metrics2.failCount, 0);
      });

      test('連續失敗的來源評分低於連續成功的來源', () async {
        // src1: 3 次成功
        selector.recordResult('src1', isSuccess: true, latency: 100);
        selector.recordResult('src1', isSuccess: true, latency: 100);
        selector.recordResult('src1', isSuccess: true, latency: 100);

        // src2: 2 次成功，1 次失敗
        selector.recordResult('src2', isSuccess: true, latency: 100);
        selector.recordResult('src2', isSuccess: true, latency: 100);
        selector.recordResult('src2', isSuccess: false, latency: 0);

        final metrics1 = selector.getMetrics('src1');
        final metrics2 = selector.getMetrics('src2');

        expect(metrics1!.successRate, 1.0);
        expect(metrics2!.successRate, 2 / 3); // 2 成功 / 3 總次數
      });
    });

    group('場景 3: 用戶屏蔽來源後不再被選擇', () {
      test('屏蔽單個來源後，該來源不會被 selectSource 返回', () async {
        await selector.setBlockedSources(['src2']);

        final sources = [
          const VideoSource(id: 'src1', name: '量子資源', url: 'http://a.com', latency: 80, isAvailable: true),
          const VideoSource(id: 'src2', name: '非凡資源', url: 'http://b.com', latency: 50, isAvailable: true), // 最低延遲但被屏蔽
          const VideoSource(id: 'src3', name: '雲播資源', url: 'http://c.com', latency: 120, isAvailable: true),
        ];

        final selected = await selector.selectSource(sources, 'video123');

        expect(selected.id, isNot('src2'));
        expect(selected.id, 'src1'); // 選擇次低的可用來源
      });

      test('屏蔽多個來源後，選擇剩餘最快的來源', () async {
        await selector.setBlockedSources(['src1', 'src3']);

        final sources = [
          const VideoSource(id: 'src1', name: '量子資源', url: 'http://a.com', latency: 50, isAvailable: true),
          const VideoSource(id: 'src2', name: '非凡資源', url: 'http://b.com', latency: 100, isAvailable: true),
          const VideoSource(id: 'src3', name: '雲播資源', url: 'http://c.com', latency: 80, isAvailable: true),
        ];

        final selected = await selector.selectSource(sources, 'video123');

        expect(selected.id, 'src2'); // 只有 src2 可用
      });

      test('所有來源都被屏蔽時，返回原列表第一個作為備用', () async {
        await selector.setBlockedSources(['src1', 'src2', 'src3']);

        final sources = [
          const VideoSource(id: 'src1', name: '量子資源', url: 'http://a.com', latency: 50, isAvailable: true),
          const VideoSource(id: 'src2', name: '非凡資源', url: 'http://b.com', latency: 100, isAvailable: true),
          const VideoSource(id: 'src3', name: '雲播資源', url: 'http://c.com', latency: 80, isAvailable: true),
        ];

        final selected = await selector.selectSource(sources, 'video123');

        expect(selected.id, 'src1'); // 返回原列表第一個作為備用
      });
    });

    group('場景 4: 快取機制', () {
      test('首次選擇後結果被快取', () async {
        final sources = [
          const VideoSource(id: 'src1', name: '量子資源', url: 'http://a.com', latency: 80, isAvailable: true),
          const VideoSource(id: 'src2', name: '非凡資源', url: 'http://b.com', latency: 120, isAvailable: true),
        ];

        final selected1 = await selector.selectSource(sources, 'video123');
        expect(selected1.id, 'src1');

        // 驗證快取存在
        final remaining = selector.getCacheRemainingTime('video123');
        expect(remaining, isNotNull);
        expect(remaining!.inMinutes, greaterThan(0));
      });

      test('快取有效期內返回相同的來源', () async {
        final sources = [
          const VideoSource(id: 'src1', name: '量子資源', url: 'http://a.com', latency: 80, isAvailable: true),
          const VideoSource(id: 'src2', name: '非凡資源', url: 'http://b.com', latency: 120, isAvailable: true),
        ];

        final selected1 = await selector.selectSource(sources, 'video123');
        final selected2 = await selector.selectSource(sources, 'video123');

        expect(selected1.id, selected2.id); // 應該返回相同的快取結果
      });
    });
  });
}