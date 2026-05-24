import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/core/source/source_metrics.dart';

void main() {
  group('SourceMetrics', () {
    test('初始狀態 successCount 和 failCount 為 0', () {
      final metrics = SourceMetrics(sourceId: 'test_source');
      expect(metrics.successCount, 0);
      expect(metrics.failCount, 0);
      expect(metrics.totalLatency, 0);
    });

    test('recordSuccess 增加 successCount 並累加延遲', () {
      final metrics = SourceMetrics(sourceId: 'test_source');
      metrics.recordSuccess(latency: 100);
      expect(metrics.successCount, 1);
      expect(metrics.totalLatency, 100);
    });

    test('recordFailure 增加 failCount', () {
      final metrics = SourceMetrics(sourceId: 'test_source');
      metrics.recordFailure();
      expect(metrics.failCount, 1);
    });

    test('recordSuccess 多次後計算成功率正確', () {
      final metrics = SourceMetrics(sourceId: 'test_source');
      metrics.recordSuccess(latency: 100);
      metrics.recordSuccess(latency: 200);
      metrics.recordSuccess(latency: 150);
      expect(metrics.successCount, 3);
      expect(metrics.totalLatency, 450);
    });

    test('混合記錄後計算成功率正確', () {
      final metrics = SourceMetrics(sourceId: 'test_source');
      metrics.recordSuccess(latency: 100);
      metrics.recordSuccess(latency: 200);
      metrics.recordFailure();
      metrics.recordSuccess(latency: 150);
      expect(metrics.successCount, 3);
      expect(metrics.failCount, 1);
    });

    test('avgLatency 在無成功時返回 0', () {
      final metrics = SourceMetrics(sourceId: 'test_source');
      metrics.recordFailure();
      expect(metrics.avgLatency, 0);
    });

    test('avgLatency 在有成功時計算正確', () {
      final metrics = SourceMetrics(sourceId: 'test_source');
      metrics.recordSuccess(latency: 100);
      metrics.recordSuccess(latency: 200);
      expect(metrics.avgLatency, 150);
    });

    test('toJson 和 fromJson 正確序列化', () {
      final metrics = SourceMetrics(
        sourceId: 'test_source',
        successCount: 10,
        failCount: 2,
        totalLatency: 1500,
        lastTested: DateTime(2026, 5, 24, 10, 0),
      );

      final json = metrics.toJson();
      final restored = SourceMetrics.fromJson(json);

      expect(restored.sourceId, 'test_source');
      expect(restored.successCount, 10);
      expect(restored.failCount, 2);
      expect(restored.totalLatency, 1500);
    });
  });
}